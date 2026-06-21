using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentCourse : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        public class CourseCard
        {
            public int CourseOfferID { get; set; }
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int CreditHours { get; set; }
            public string Description { get; set; }
            public string Instructor { get; set; }
            public DateTime SemesterEndDate { get; set; }
        }

        private bool IsCurrentTabActive
        {
            get { return ViewState["IsCurrentTabActive"] == null ? true : (bool)ViewState["IsCurrentTabActive"]; }
            set { ViewState["IsCurrentTabActive"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
                Response.Redirect("/Login.aspx");

            if (!IsPostBack)
            {
                LoadCourses();
                IsCurrentTabActive = true;
                UpdateTabVisibility();
            }
        }

        private void LoadCourses()
        {
            int studentId = GetStudentIdFromSession();
            if (studentId == 0) return;

            List<CourseCard> allCourses = new List<CourseCard>();

            string query = @"
                SELECT 
                    co.CourseOfferID,
                    c.CourseCode,
                    c.CourseName,
                    c.CreditHours,
                    c.Description,
                    l.LecturerName AS Instructor,
                    s.EndMonthDay,
                    co.Year
                FROM Enrolment e
                INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                INNER JOIN Course c ON co.CourseCode = c.CourseCode
                INNER JOIN Semester s ON co.SemesterID = s.SemesterID
                LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
                WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                ORDER BY co.Year DESC, s.SemesterID DESC";

            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string endMonthDay = reader["EndMonthDay"].ToString();
                        int year = Convert.ToInt32(reader["Year"]);
                        DateTime semesterEnd = DateTime.Parse($"{year}-{endMonthDay}");

                        allCourses.Add(new CourseCard
                        {
                            CourseOfferID = Convert.ToInt32(reader["CourseOfferID"]),
                            CourseCode = reader["CourseCode"].ToString(),
                            CourseName = reader["CourseName"].ToString(),
                            CreditHours = Convert.ToInt32(reader["CreditHours"]),
                            Description = reader["Description"]?.ToString() ?? "No description",
                            Instructor = reader["Instructor"]?.ToString() ?? "Staff",
                            SemesterEndDate = semesterEnd
                        });
                    }
                }
            }

            DateTime today = DateTime.Today;
            List<CourseCard> currentCourses = allCourses.FindAll(c => c.SemesterEndDate >= today);
            List<CourseCard> completedCourses = allCourses.FindAll(c => c.SemesterEndDate < today);

            // Bind to repeaters
            rptCurrentCourses.DataSource = currentCourses;
            rptCurrentCourses.DataBind();
            rptCompletedCourses.DataSource = completedCourses;
            rptCompletedCourses.DataBind();

            // Update summary cards
            lblTotalCourses.Text = allCourses.Count.ToString();
            lblCurrentCount.Text = currentCourses.Count.ToString();
            lblCompletedCount.Text = completedCourses.Count.ToString();

            // Empty state visibility
            lblNoCurrent.Visible = (currentCourses.Count == 0);
            lblNoCompleted.Visible = (completedCourses.Count == 0);
        }

        private void UpdateTabVisibility()
        {
            if (IsCurrentTabActive)
            {
                pnlCurrent.Visible = true;
                pnlCompleted.Visible = false;
                btnCurrent.CssClass = "text-base font-semibold transition duration-200 tab-active";
                btnCompleted.CssClass = "text-base font-semibold transition duration-200 tab-inactive";
            }
            else
            {
                pnlCurrent.Visible = false;
                pnlCompleted.Visible = true;
                btnCurrent.CssClass = "text-base font-semibold transition duration-200 tab-inactive";
                btnCompleted.CssClass = "text-base font-semibold transition duration-200 tab-active";
            }
        }

        protected void btnCurrent_Click(object sender, EventArgs e)
        {
            IsCurrentTabActive = true;
            UpdateTabVisibility();
        }

        protected void btnCompleted_Click(object sender, EventArgs e)
        {
            IsCurrentTabActive = false;
            UpdateTabVisibility();
        }

        private int GetStudentIdFromSession()
        {
            if (Session["StudentID"] != null)
                return Convert.ToInt32(Session["StudentID"]);

            string email = Session["UserEmail"]?.ToString();
            if (string.IsNullOrEmpty(email)) return 0;

            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand("SELECT StudentID FROM Student WHERE StudentEmail = @Email", conn))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null)
                {
                    int id = Convert.ToInt32(result);
                    Session["StudentID"] = id;
                    return id;
                }
            }
            return 0;
        }
    }
}
