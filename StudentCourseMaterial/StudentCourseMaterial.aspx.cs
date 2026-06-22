using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

namespace StudentManagementSystem.Student
{
    public partial class StudentCourseMaterial : Page
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
                LoadCourseAndMaterials();
            }
        }

        private void LoadCourseAndMaterials()
        {
            if (Request.QueryString["courseOfferId"] == null || !int.TryParse(Request.QueryString["courseOfferId"], out int courseOfferId))
            {
                lblCourseTitle.Text = "Invalid course selection.";
                return;
            }

            int studentId = GetStudentIdFromSession();
            if (!IsStudentEnrolled(studentId, courseOfferId))
            {
                lblCourseTitle.Text = "You are not enrolled in this course.";
                rptMaterials.Visible = false;
                rptNotifications.Visible = false;
                return;
            }

            // If a notification ID is passed, mark it as read
            if (Request.QueryString["notifId"] != null && int.TryParse(Request.QueryString["notifId"], out int notifId))
            {
                MarkNotificationAsRead(studentId, notifId);
            }

            string courseCode = "";

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 1. Course details
                string courseQuery = @"
                    SELECT c.CourseCode, c.CourseName, l.LecturerName 
                    FROM CourseOffer co
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
                    WHERE co.CourseOfferID = @CourseOfferID";

                using (SqlCommand cmdCourse = new SqlCommand(courseQuery, conn))
                {
                    cmdCourse.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                    using (SqlDataReader reader = cmdCourse.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            courseCode = reader["CourseCode"].ToString();
                            lblCourseTitle.Text = $"{courseCode} - {reader["CourseName"]}";
                            lblInstructor.Text = $"Instructor: {reader["LecturerName"]?.ToString()}";
                        }
                        else
                        {
                            lblCourseTitle.Text = "Course not found.";
                            return;
                        }
                    }
                }

                // 2. Materials for this course (now includes MaterialCategory)
                string materialQuery = @"
                    SELECT MaterialTitle, Description, FileURL, UploadDate, MaterialCategory
                    FROM CourseMaterial
                    WHERE CourseOfferID = @CourseOfferID
                    ORDER BY UploadDate DESC";

                using (SqlCommand cmdMaterial = new SqlCommand(materialQuery, conn))
                {
                    cmdMaterial.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                    using (SqlDataReader materialReader = cmdMaterial.ExecuteReader())
                    {
                        if (materialReader.HasRows)
                        {
                            rptMaterials.DataSource = materialReader;
                            rptMaterials.DataBind();
                            lblNoMaterials.Visible = false;
                        }
                        else
                        {
                            lblNoMaterials.Visible = true;
                        }
                    }
                }

                // 3. Notifications with read status (filter by course code)
                string notificationQuery = @"
                    SELECT a.AnnouncementID, a.Title, a.Description, a.CreatedDate,
                           ISNULL(nrs.IsRead, 0) AS IsRead
                    FROM Announcement a
                    LEFT JOIN NotificationReadStatus nrs ON a.AnnouncementID = nrs.AnnouncementID AND nrs.StudentID = @StudentID
                    WHERE (a.TargetType = 'All')
                       OR (a.TargetType = 'CourseCode' AND a.TargetValue = @CourseCode)
                    ORDER BY a.CreatedDate DESC";

                using (SqlCommand cmdNotify = new SqlCommand(notificationQuery, conn))
                {
                    cmdNotify.Parameters.AddWithValue("@StudentID", studentId);
                    cmdNotify.Parameters.AddWithValue("@CourseCode", courseCode);
                    using (SqlDataReader notifyReader = cmdNotify.ExecuteReader())
                    {
                        rptNotifications.DataSource = notifyReader;
                        rptNotifications.DataBind();
                    }
                }

                // Show/hide "no notifications" message
                lblNoNotifications.Visible = (rptNotifications.Items.Count == 0);
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
                conn.Open();
                string query = "SELECT StudentID FROM Student WHERE StudentEmail = @Email";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        int id = Convert.ToInt32(result);
                        Session["StudentID"] = id;
                        return id;
                    }
                }
            }
            return 0;
        }

        private bool IsStudentEnrolled(int studentId, int courseOfferId)
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT COUNT(*) FROM Enrolment WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID AND EnrolStatus = 'Enrolled'";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    cmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                    int count = (int)cmd.ExecuteScalar();
                    return count > 0;
                }
            }
        }

        private void MarkNotificationAsRead(int studentId, int announcementId)
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    IF EXISTS (SELECT 1 FROM NotificationReadStatus WHERE StudentID = @SID AND AnnouncementID = @AID)
                        UPDATE NotificationReadStatus SET IsRead = 1, ReadDate = GETDATE() 
                        WHERE StudentID = @SID AND AnnouncementID = @AID
                    ELSE
                        INSERT INTO NotificationReadStatus (StudentID, AnnouncementID, IsRead, ReadDate)
                        VALUES (@SID, @AID, 1, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SID", studentId);
                    cmd.Parameters.AddWithValue("@AID", announcementId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        protected void MarkNotificationAsUnread_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int announcementId = Convert.ToInt32(btn.CommandArgument);
            int studentId = GetStudentIdFromSession();

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    IF EXISTS (SELECT 1 FROM NotificationReadStatus WHERE StudentID = @SID AND AnnouncementID = @AID)
                        UPDATE NotificationReadStatus SET IsRead = 0, ReadDate = NULL 
                        WHERE StudentID = @SID AND AnnouncementID = @AID
                    ELSE
                        INSERT INTO NotificationReadStatus (StudentID, AnnouncementID, IsRead, ReadDate)
                        VALUES (@SID, @AID, 0, NULL)";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SID", studentId);
                    cmd.Parameters.AddWithValue("@AID", announcementId);
                    cmd.ExecuteNonQuery();
                }
            }

            // Refresh the page to update the notification list
            Response.Redirect(Request.RawUrl);
        }

        // ========== HELPER METHODS FOR MARKUP ==========

        // Returns a CSS class for the category badge color
        protected string GetCategoryBadgeClass(string category)
        {
            if (string.IsNullOrEmpty(category)) return "bg-gray-100 text-gray-600";

            switch (category.ToLower())
            {
                case "lecturers": return "bg-blue-100 text-blue-800";
                case "assignments": return "bg-yellow-100 text-yellow-800";
                case "tutorials": return "bg-green-100 text-green-800";
                default: return "bg-gray-100 text-gray-600";
            }
        }

        // Extracts file name from the full URL (e.g., ~/Uploads/.../file.pdf -> file.pdf)
        protected string GetFileName(string fileUrl)
        {
            if (string.IsNullOrEmpty(fileUrl)) return "—";
            try
            {
                // Remove query string if any
                int qIndex = fileUrl.IndexOf('?');
                if (qIndex > 0) fileUrl = fileUrl.Substring(0, qIndex);

                // Get the last segment after '/'
                int lastSlash = fileUrl.LastIndexOf('/');
                if (lastSlash >= 0) return fileUrl.Substring(lastSlash + 1);
                return fileUrl;
            }
            catch
            {
                return "—";
            }
        }

        // (Legacy helper – no longer used for type, but kept for notifications)
        protected string GetMaterialType(string title)
        {
            // This is no longer used for the material type column,
            // but may be called from the markup if any leftover.
            // We can keep it as a fallback or remove it.
            return "Document";
        }

        protected string GetTimeAgo(DateTime date)
        {
            var diff = DateTime.Now - date;
            if (diff.TotalMinutes < 1)
                return "Just now";
            if (diff.TotalMinutes < 60)
                return $"{(int)diff.TotalMinutes} minutes ago";
            if (diff.TotalHours < 24)
                return $"{(int)diff.TotalHours} hours ago";
            if (diff.TotalDays < 7)
                return $"{(int)diff.TotalDays} days ago";
            return date.ToString("MMM dd, yyyy");
        }
    }
}
