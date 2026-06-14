using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentManagementSystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CompileDashboardMetrics();
            }
        }

        private void CompileDashboardMetrics()
        {
            int activeAdminId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();

                    // 1. Fetch scalar statistics metrics individually
                    litTotalSchools.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM Faculty", conn);
                    litTotalProgrammes.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM Programme", conn);
                    litTotalCourses.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM Course", conn);

                    string lecturersCount = ExecuteScalarQuery("SELECT COUNT(*) FROM Lecturer", conn);
                    litTotalLecturers.Text = lecturersCount;
                    litCountLecturers.Text = lecturersCount;

                    string studentsCount = ExecuteScalarQuery("SELECT COUNT(*) FROM Student", conn);
                    litTotalStudents.Text = studentsCount;
                    litCountStudents.Text = studentsCount;

                    litTotalOffers.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM CourseOffer", conn);
                    litTotalMaterials.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM CourseMaterial", conn);
                    litTotalAnnouncements.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM AdminAnnouncement", conn);
                    litCountAdmins.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM HeadofProgramme", conn);
                    litInboxCount.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM AdminMessage", conn);

                    // 2. Bind Recent Announcements Feed
                    using (SqlCommand cmd = new SqlCommand("SELECT TOP 3 Title, ContentText, CreatedDate FROM AdminAnnouncement ORDER BY CreatedDate DESC", conn))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);
                            rptRecentAnnouncements.DataSource = dt;
                            rptRecentAnnouncements.DataBind();
                        }
                    }

                    // 3. Bind Recent Support Messages List
                    using (SqlCommand cmd = new SqlCommand("SELECT TOP 4 SenderEmail, Subject, SubmissionDate FROM AdminMessage ORDER BY SubmissionDate DESC", conn))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);
                            rptRecentMessages.DataSource = dt;
                            rptRecentMessages.DataBind();
                        }
                    }

                    // 4. Bind Active Admin Account Name & Profile Image[cite: 5]
                    using (SqlCommand cmd = new SqlCommand("SELECT HopName, ProfilePictureUrl FROM HeadofProgramme WHERE HopID = @AdminID", conn))
                    {
                        cmd.Parameters.AddWithValue("@AdminID", activeAdminId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Set header username label text directly
                                string adminName = Convert.ToString(reader["HopName"]);
                                litAdminName.Text = !string.IsNullOrWhiteSpace(adminName) ? adminName : "Admin Account";

                                // Set navigation avatar element link directly
                                string navPicUrl = Convert.ToString(reader["ProfilePictureUrl"]);
                                imgNavAvatar.ImageUrl = !string.IsNullOrWhiteSpace(navPicUrl)
                                    ? ResolveUrl(navPicUrl)
                                    : ResolveUrl("~/profile_upload/default-avatar.jpg");
                            }
                        }
                    }
                }
                catch (Exception)
                {
                    SetDefaultMetrics();
                }
            }
        }

        private string ExecuteScalarQuery(string queryText, SqlConnection openConnection)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand(queryText, openConnection))
                {
                    object result = cmd.ExecuteScalar();
                    return result != null ? result.ToString() : "0";
                }
            }
            catch
            {
                return "0";
            }
        }

        private void SetDefaultMetrics()
        {
            litTotalSchools.Text = "0";
            litTotalProgrammes.Text = "0";
            litTotalCourses.Text = "0";
            litTotalLecturers.Text = "0";
            litTotalStudents.Text = "0";
            litTotalOffers.Text = "0";
            litTotalMaterials.Text = "0";
            litTotalAnnouncements.Text = "0";
            litCountAdmins.Text = "0";
            litCountLecturers.Text = "0";
            litCountStudents.Text = "0";
            litInboxCount.Text = "0";
            litAdminName.Text = "Admin Account";
            imgNavAvatar.ImageUrl = ResolveUrl("~/profile_upload/default-avatar.jpg");
        }
    }
}