using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;

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

            HighlightActiveMenu();
        }

        private void HighlightActiveMenu()
        {
            string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();
            string activeClass = "sidebar-link-active";

            // List of sidebar links – lnkContact removed
            var menuLinks = new[] { lnkDashboard, lnkCourse, lnkAcademic, lnkEnrollment, lnkAttendance };
            foreach (var link in menuLinks)
            {
                if (link != null)
                    link.Attributes["class"] = link.Attributes["class"]?.Replace(activeClass, "")?.Trim();
            }

            // Apply active class to the matching link
            switch (currentPage)
            {
                case "studentdashboard.aspx":
                    AddClass(lnkDashboard, activeClass);
                    break;
                case "studentcourse.aspx":
                case "studentcoursematerial.aspx":
                case "studentcoursenotification.aspx":
                    AddClass(lnkCourse, activeClass);
                    break;
                case "studentacademicresult.aspx":
                    AddClass(lnkAcademic, activeClass);
                    break;
                case "studentcourseenrol.aspx":
                    AddClass(lnkEnrollment, activeClass);
                    break;
                case "studentattendance.aspx":
                    AddClass(lnkAttendance, activeClass);
                    break;
                    // Contact page case removed – no such menu item
            }
        }

        private void AddClass(HtmlAnchor link, string className)
        {
            if (link == null) return;
            string currentClass = link.Attributes["class"] ?? "";
            if (!currentClass.Contains(className))
                link.Attributes["class"] = (currentClass + " " + className).Trim();
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

                    string photoPath = dr["ProfilePhotoPath"]?.ToString();
                    if (!string.IsNullOrEmpty(photoPath) && System.IO.File.Exists(Server.MapPath(photoPath)))
                    {
                        ProfilePicture.ImageUrl = photoPath;
                    }
                    else
                    {
                        ProfilePicture.ImageUrl = "/Images/default-avatar.png";
                    }
                }
            }
        }
    }
}