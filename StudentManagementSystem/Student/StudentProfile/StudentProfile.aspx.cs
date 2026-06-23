using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentManagementSystem.Student
{
    public partial class StudentProfile : Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
            {
                Response.Redirect("/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStudentInfo();
                LoadEnrolledCourses();
            }
        }

        private void LoadStudentInfo()
        {
            string email = Session["UserEmail"].ToString();

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = @"
                    SELECT S.StudentName, S.StudentEmail, P.ProgrammeName, S.ProfilePhotoPath
                    FROM Student S
                    INNER JOIN Programme P ON S.ProgrammeCode = P.ProgrammeCode
                    WHERE S.StudentEmail = @Email";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            StudentName.Text = dr["StudentName"].ToString();
                            StudentEmail.Text = dr["StudentEmail"].ToString();
                            ProgramName.Text = dr["ProgrammeName"].ToString();

                            // Load structural image string safely matching the default framework settings
                            string photoPath = dr["ProfilePhotoPath"]?.ToString();
                            if (!string.IsNullOrEmpty(photoPath) && System.IO.File.Exists(Server.MapPath(photoPath)))
                            {
                                ProfilePicture.ImageUrl = photoPath + "?t=" + DateTime.Now.Ticks;
                            }
                            else
                            {
                                ProfilePicture.ImageUrl = "/Images/default-avatar.png?t=" + DateTime.Now.Ticks;
                            }
                        }
                    }
                }
            }
        }

        private void LoadEnrolledCourses()
        {
            string email = Session["UserEmail"].ToString();

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = @"
                    SELECT 
                        C.CourseCode,
                        C.CourseName,
                        Sem.Semester,
                        CO.Year
                    FROM Enrolment E
                    INNER JOIN CourseOffer CO ON E.CourseOfferID = CO.CourseOfferID
                    INNER JOIN Course C ON CO.CourseCode = C.CourseCode
                    INNER JOIN Semester Sem ON CO.SemesterID = Sem.SemesterID
                    INNER JOIN Student S ON E.StudentID = S.StudentID
                    WHERE S.StudentEmail = @Email
                    ORDER BY CO.Year DESC, Sem.SemesterID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.HasRows)
                        {
                            // If user has items, bind to the repeater grid structure safely
                            CourseRepeater.DataSource = dr;
                            CourseRepeater.DataBind();

                            CourseRepeater.Visible = true;
                            pnlNoCourses.Visible = false;
                        }
                        else
                        {
                            // If completely empty, drop the list elements and swap the message template panel on
                            CourseRepeater.Visible = false;
                            pnlNoCourses.Visible = true;
                        }
                    }
                }
            }
        }
    }
}