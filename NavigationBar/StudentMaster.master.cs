using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentManagementSystem
{
    public partial class StudentMaster : MasterPage
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
            }

            // Always run highlight evaluation on every page initialization cycle
            HighlightActiveMenu();
        }

        private void HighlightActiveMenu()
        {
            string currentPath = Request.Url.AbsolutePath.ToLower();

            // Use the explicit CSS class we just defined in input.css
            string activeClasses = " sidebar-active";

            if (currentPath.Contains("studentdashboard.aspx"))
            {
                lnkDashboard.Attributes["class"] += activeClasses;
            }
            else if (currentPath.Contains("studentcourse.aspx") || currentPath.Contains("studentcoursematerial.aspx"))
            {
                lnkCourse.Attributes["class"] += activeClasses;
            }
            else if (currentPath.Contains("studentannoucement.aspx"))
            {
                lnkAnnouncement.Attributes["class"] += activeClasses;
            }
            else if (currentPath.Contains("studentcourseenrol.aspx"))
            {
                lnkEnrollment.Attributes["class"] += activeClasses;
            }
            else if (currentPath.Contains("contactadmin.aspx"))
            {
                lnkContact.Attributes["class"] += activeClasses;
            }
        }

        void LoadStudentInfo()
        {
            string email = Session["UserEmail"].ToString();

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = "SELECT StudentName, StudentID, ProfilePhotoPath FROM Student WHERE StudentEmail = @Email";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Email", email);
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    lblStudentName.Text = dr["StudentName"].ToString();

                    // Load profile photo if it exists
                    string photoPath = dr["ProfilePhotoPath"]?.ToString();
                    if (!string.IsNullOrEmpty(photoPath) && System.IO.File.Exists(Server.MapPath(photoPath)))
                    {
                        ProfilePicture.ImageUrl = photoPath;
                    }
                    else
                    {
                        // Default fallback layout placeholder image if null
                        ProfilePicture.ImageUrl = "/Images/default-avatar.png";
                    }
                }
            }
        }
    }
}
