using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentCourseMaterial : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
                Response.Redirect("/StudeLogin.aspx");

            if (!IsPostBack)
            {
                LoadCourseAndMaterials();
            }
        }

        private void LoadCourseAndMaterials()
        {
            // Get courseOfferId from query string
            if (Request.QueryString["courseOfferId"] == null)
            {
                lblCourseTitle.Text = "Invalid course selection.";
                return;
            }

            if (!int.TryParse(Request.QueryString["courseOfferId"], out int courseOfferId))
            {
                lblCourseTitle.Text = "Invalid course ID.";
                return;
            }

            // Verify student is enrolled in this course
            int studentId = GetStudentIdFromSession();
            if (!IsStudentEnrolled(studentId, courseOfferId))
            {
                lblCourseTitle.Text = "You are not enrolled in this course.";
                rptMaterials.Visible = false;
                return;
            }

            // Load course details
            using (SqlConnection conn = new SqlConnection(cs))
            {
                string courseQuery = @"
                    SELECT c.CourseCode, c.CourseName 
                    FROM CourseOffer co
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    WHERE co.CourseOfferID = @CourseOfferID";
                SqlCommand cmdCourse = new SqlCommand(courseQuery, conn);
                cmdCourse.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                conn.Open();
                SqlDataReader reader = cmdCourse.ExecuteReader();
                if (reader.Read())
                {
                    lblCourseTitle.Text = reader["CourseCode"].ToString() + " - " + reader["CourseName"].ToString();
                }
                reader.Close();

                // Load materials for this course
                string materialQuery = @"
                    SELECT MaterialTitle AS Title, Description, FileURL
                    FROM CourseMaterial
                    WHERE CourseOfferID = @CourseOfferID
                    ORDER BY ScheduleDate DESC";
                SqlCommand cmdMaterial = new SqlCommand(materialQuery, conn);
                cmdMaterial.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                SqlDataReader materialReader = cmdMaterial.ExecuteReader();
                rptMaterials.DataSource = materialReader;
                rptMaterials.DataBind();
            }
        }

        private int GetStudentIdFromSession()
        {
            if (Session["StudentID"] != null)
                return Convert.ToInt32(Session["StudentID"]);

            string email = Session["UserEmail"]?.ToString();
            if (string.IsNullOrEmpty(email)) return 0;

            using (SqlConnection conn = new SqlConnection(cs))
            {
                string query = "SELECT StudentID FROM Student WHERE StudentEmail = @Email";
                SqlCommand cmd = new SqlCommand(query, conn);
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

        private bool IsStudentEnrolled(int studentId, int courseOfferId)
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                string query = "SELECT COUNT(*) FROM Enrolment WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID AND EnrolStatus = 'Enrolled'";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                cmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                conn.Open();
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }
    }
}