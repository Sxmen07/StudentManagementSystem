using Antlr.Runtime.Misc;
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentManagementSystems.Student
{
    public partial class StudentCourseNotification : Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
            {
                Response.Redirect("/Login.aspx");
                return;
            }

            if (!IsPostBack && Request.QueryString["id"] != null && int.TryParse(Request.QueryString["id"], out int notifId))
            {
                LoadNotification(notifId);
                SetBackButtonUrl();
            }
            else
            {
                Response.Redirect("/Student/Dashboard.aspx");
            }
        }

        private void SetBackButtonUrl()
        {
            string courseOfferId = Request.QueryString["courseOfferId"];
            if (!string.IsNullOrEmpty(courseOfferId))
            {
                hlBackToCourse.NavigateUrl = $"/Student/StudentCourseMaterial/StudentCourseMaterial.aspx?courseOfferId={courseOfferId}";
            }
            else
            {
                hlBackToCourse.NavigateUrl = "/Student/StudentCourseEnrol/StudentCourseEnrol.aspx";
            }
        }

        private void LoadNotification(int notifId)
        {
            int studentId = GetStudentIdFromSession();
            if (studentId == 0) return;

            string courseOfferId = Request.QueryString["courseOfferId"];
            int parsedCourseOfferId = 0;
            int.TryParse(courseOfferId, out parsedCourseOfferId);

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // Get notification details
                string query = @"
                    SELECT Title, Description, CreatedDate, TargetType 
                    FROM Announcement 
                    WHERE AnnouncementID = @ID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@ID", notifId);
                SqlDataReader dr = cmd.ExecuteReader();
                string targetType = "";
                DateTime createdDate = DateTime.Now;
                if (dr.Read())
                {
                    lblTitle.Text = dr["Title"].ToString();
                    lblDescription.Text = dr["Description"].ToString();
                    createdDate = Convert.ToDateTime(dr["CreatedDate"]);
                    lblDate.Text = createdDate.ToString("MMMM dd, yyyy 'at' h:mm tt");
                    targetType = dr["TargetType"].ToString();
                }
                dr.Close();

                // Determine sender name
                string senderName = "System";
                if (targetType == "CourseCode" && parsedCourseOfferId > 0)
                {
                    senderName = GetLecturerNameForCourseOffer(parsedCourseOfferId);
                }
                else if (targetType == "All")
                {
                    senderName = "Admin";
                }
                lblSender.Text = $"Sent by: {senderName}";

                // Mark as read
                MarkNotificationAsRead(studentId, notifId);
            }
        }

        private string GetLecturerNameForCourseOffer(int courseOfferId)
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT l.LecturerName 
                    FROM CourseOffer co
                    LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
                    WHERE co.CourseOfferID = @CourseOfferID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : "Lecturer";
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
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Email", email);
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
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@SID", studentId);
                cmd.Parameters.AddWithValue("@AID", announcementId);
                cmd.ExecuteNonQuery();
            }
        }
    }
}