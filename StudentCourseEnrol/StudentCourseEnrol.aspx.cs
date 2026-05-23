using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentCourseEnrol : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
                Response.Redirect("/StudeLogin.aspx");

            if (!IsPostBack)
            {
                LoadAvailableCourses();
            }
        }

        private void LoadAvailableCourses(string searchTerm = null)
        {
            // Get logged-in student's email
            string studentEmail = Session["UserEmail"].ToString();

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();

                // 1. Get student's ProgrammeCode
                string getProgrammeQuery = "SELECT ProgrammeCode FROM Student WHERE StudentEmail = @Email";
                SqlCommand cmdProg = new SqlCommand(getProgrammeQuery, con);
                cmdProg.Parameters.AddWithValue("@Email", studentEmail);
                object progCodeObj = cmdProg.ExecuteScalar();
                if (progCodeObj == null)
                {
                    gvCourses.DataSource = null;
                    gvCourses.DataBind();
                    return;
                }
                string programmeCode = progCodeObj.ToString();

                // 2. Determine current active semester based on today's date
                int currentYear = DateTime.Now.Year;
                string currentMonthDay = DateTime.Now.ToString("MM-dd");
                string getActiveSemesterQuery = @"
                    SELECT SemesterID 
                    FROM Semester 
                    WHERE @CurrentMonthDay BETWEEN StartMonthDay AND EndMonthDay";
                SqlCommand cmdSem = new SqlCommand(getActiveSemesterQuery, con);
                cmdSem.Parameters.AddWithValue("@CurrentMonthDay", currentMonthDay);
                object semIdObj = cmdSem.ExecuteScalar();
                if (semIdObj == null)
                {
                    // No active semester – optional: show nothing or handle gracefully
                    gvCourses.DataSource = null;
                    gvCourses.DataBind();
                    return;
                }
                int currentSemesterId = Convert.ToInt32(semIdObj);

                // 3. Build main query: available courses for student's programme and current semester
                string query = @"
                    SELECT 
                        c.CourseCode,
                        c.CourseName,
                        c.Description AS CourseDescription,
                        s.Semester AS SemesterName,
                        l.LecturerName,
                        c.CreditHours AS Credits
                    FROM CourseOffer co
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    INNER JOIN Semester s ON co.SemesterID = s.SemesterID
                    LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
                    WHERE co.OfferStatus = 'Available'
                      AND c.ProgrammeCode = @ProgrammeCode
                      AND co.SemesterID = @SemesterID
                      AND co.Year = @Year";

                // Add search filter if provided
                if (!string.IsNullOrEmpty(searchTerm))
                {
                    query += " AND (c.CourseCode LIKE @Search OR c.CourseName LIKE @Search)";
                }

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@ProgrammeCode", programmeCode);
                cmd.Parameters.AddWithValue("@SemesterID", currentSemesterId);
                cmd.Parameters.AddWithValue("@Year", currentYear);
                if (!string.IsNullOrEmpty(searchTerm))
                {
                    cmd.Parameters.AddWithValue("@Search", "%" + searchTerm + "%");
                }

                SqlDataReader dr = cmd.ExecuteReader();
                gvCourses.DataSource = dr;
                gvCourses.DataBind();
            }
        }

        protected void btnEnrollCourse_Click(object sender, EventArgs e)
        {

        }

        protected void btnResetEnroll_Click(object sender, EventArgs e)
        {
            LoadAvailableCourses();
        }
       
    }
}
