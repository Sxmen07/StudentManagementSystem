using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentManagementSystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

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

                    // 1. Core Counters - Restored safely from your working queries
                    litTotalSchools.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM Faculty", conn);
                    litTotalProgrammes.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM Programme", conn);
                    litTotalCourses.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM Course", conn);

                    // Dynamic Academic Term Verification based on current system date (June 2026 -> April Term)
                    DateTime today = DateTime.Now;
                    string calculatedTerm = "Jan Term";
                    if (today.Month >= 4 && today.Month <= 7) calculatedTerm = "April Term";
                    else if (today.Month >= 8) calculatedTerm = "August Term";
                    litActiveSemester.Text = $"{calculatedTerm} {today.Year}";

                    // 2. Demographic Card Metrics
                    string adminsCount = ExecuteScalarQuery("SELECT COUNT(*) FROM HeadofProgramme", conn);
                    litCountAdmins.Text = adminsCount;
                    hfAdmins.Value = adminsCount;

                    string lecturersCount = ExecuteScalarQuery("SELECT COUNT(*) FROM Lecturer", conn);
                    litCountLecturers.Text = lecturersCount;
                    hfLecturers.Value = lecturersCount;

                    string studentsCount = ExecuteScalarQuery("SELECT COUNT(*) FROM Student", conn);
                    litCountStudents.Text = studentsCount;
                    hfStudents.Value = studentsCount;

                    litInboxCount.Text = ExecuteScalarQuery("SELECT COUNT(*) FROM AdminMessage", conn);
                }
                catch (Exception ex)
                {
                    // If a core stat fails, protect the rest of the application load
                    System.Diagnostics.Debug.WriteLine("Core stats error: " + ex.Message);
                }

                // 3. Isolated Chart Queries: Wrapped in individual try-catches so they can NEVER break your main cards
                try { LoadCourseEnrollmentRealData(conn); } catch { }
                try { LoadFacultyStudentRealDensities(conn); } catch { }

                try
                {
                    // 4. Bind Recent Announcements
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

                    // 5. Bind Recent Inbox Messages
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

                    // 6. Bind Active Admin Account Identity Profile
                    using (SqlCommand cmd = new SqlCommand("SELECT HopName, ProfilePictureUrl FROM HeadofProgramme WHERE HopID = @AdminID", conn))
                    {
                        cmd.Parameters.AddWithValue("@AdminID", activeAdminId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string adminName = Convert.ToString(reader["HopName"]);
                                litAdminName.Text = !string.IsNullOrWhiteSpace(adminName) ? adminName : "Admin Account";

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

        private void LoadCourseEnrollmentRealData(SqlConnection openConn)
        {
            List<string> codes = new List<string>();
            List<string> enrolled = new List<string>();

            // Fix: join on CourseCode and count actual student enrolments (not just course offers)
            string query = @"
        SELECT c.CourseCode, COUNT(e.EnrolmentID) AS TotalEnrolled
        FROM Course c
        LEFT JOIN CourseOffer co ON c.CourseCode = co.CourseCode
        LEFT JOIN Enrolment e ON co.CourseOfferID = e.CourseOfferID AND e.EnrolStatus = 'Enrolled'
        GROUP BY c.CourseCode";

            using (SqlCommand cmd = new SqlCommand(query, openConn))
            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    codes.Add(rdr["CourseCode"].ToString());
                    enrolled.Add(rdr["TotalEnrolled"].ToString());
                }
            }

            hfCourseNames.Value = string.Join(",", codes);
            hfCourseEnrollment.Value = string.Join(",", enrolled);
        }

        private void LoadFacultyStudentRealDensities(SqlConnection openConn)
        {
            List<string> faculties = new List<string>();
            List<string> headcounts = new List<string>();

            // Fix: join through Programme to get student count per Faculty
            string query = @"
        SELECT f.FacultyName, COUNT(s.StudentID) AS StudentCount
        FROM Faculty f
        LEFT JOIN Programme p ON f.FacultyID = p.FacultyID
        LEFT JOIN Student s ON p.ProgrammeCode = s.ProgrammeCode
        GROUP BY f.FacultyName";

            using (SqlCommand cmd = new SqlCommand(query, openConn))
            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    faculties.Add(rdr["FacultyName"].ToString());
                    headcounts.Add(rdr["StudentCount"].ToString());
                }
            }

            hfFacultyNames.Value = string.Join(",", faculties);
            hfFacultyStudents.Value = string.Join(",", headcounts);
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
            litAdminName.Text = "Admin Account";
            imgNavAvatar.ImageUrl = ResolveUrl("~/profile_upload/default-avatar.jpg");
        }
    }
}