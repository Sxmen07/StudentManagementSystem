using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Collections.Generic;

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
                // Load attendance and results after course is loaded
                LoadAttendanceAndResults();
            }
        }

        // ========== MAIN LOAD METHODS ==========

        private void LoadCourseAndMaterials()
        {
            if (Request.QueryString["courseOfferId"] == null || !int.TryParse(Request.QueryString["courseOfferId"], out int courseOfferId))
            {
                lblCourseTitle.Text = "Invalid course selection.";
                return;
            }

            int studentId = GetStudentIdFromSession();
            if (studentId == 0 || !IsStudentEnrolled(studentId, courseOfferId))
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
                            lblLecturer.Text = $"ILecturer: {reader["LecturerName"]?.ToString()}";
                        }
                        else
                        {
                            lblCourseTitle.Text = "Course not found.";
                            return;
                        }
                    }
                }

                // 2. Materials for this course
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

                // 3. Notifications with read status
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

                lblNoNotifications.Visible = (rptNotifications.Items.Count == 0);
            }
        }

        // ========== ATTENDANCE & RESULTS ==========

        private void LoadAttendanceAndResults()
        {
            if (Request.QueryString["courseOfferId"] == null || !int.TryParse(Request.QueryString["courseOfferId"], out int courseOfferId))
                return;

            int studentId = GetStudentIdFromSession();
            if (studentId == 0 || !IsStudentEnrolled(studentId, courseOfferId))
                return;

            LoadAttendance(courseOfferId, studentId);
            LoadResults(courseOfferId, studentId);
        }

        private void LoadAttendance(int courseOfferId, int studentId)
        {
            string query = @"
                SELECT AttendanceDate, AttendanceStatus
                FROM AttendanceRecord
                WHERE CourseOfferID = @COID AND StudentID = @SID
                ORDER BY AttendanceDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@COID", courseOfferId);
                cmd.Parameters.AddWithValue("@SID", studentId);
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            gvAttendance.DataSource = dt;
            gvAttendance.DataBind();

            int present = 0, late = 0, absent = 0;
            foreach (DataRow row in dt.Rows)
            {
                string status = row["AttendanceStatus"].ToString();
                if (status == "Present") present++;
                else if (status == "Late") late++;
                else if (status == "Absent") absent++;
            }
            int total = present + late + absent;
            double rate = total > 0 ? (double)(present + late) / total * 100 : 0;

            lblAttRate.Text = rate.ToString("F1") + "%";
            lblPresent.Text = present.ToString();
            lblLate.Text = late.ToString();
            lblAbsent.Text = absent.ToString();

            lblAttSummary.Text = $"Total records: {total} | Present: {present} | Late: {late} | Absent: {absent}";
        }

        protected void gvAttendance_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                TableCell statusCell = e.Row.Cells[1];
                string status = statusCell.Text.Trim();
                statusCell.Text = "";

                string badgeClass;
                // Traditional switch (C# 7.3 compatible)
                switch (status)
                {
                    case "Present":
                        badgeClass = "bg-green-100 text-green-800";
                        break;
                    case "Late":
                        badgeClass = "bg-yellow-100 text-yellow-800";
                        break;
                    case "Absent":
                        badgeClass = "bg-red-100 text-red-800";
                        break;
                    default:
                        badgeClass = "bg-gray-100 text-gray-600";
                        break;
                }

                statusCell.Controls.Add(new LiteralControl(
                    $"<span class='px-2 py-1 text-xs font-semibold rounded-full {badgeClass}'>{status}</span>"
                ));
            }
        }

        private void LoadResults(int courseOfferId, int studentId)
        {
            string query = @"
                SELECT A.AssessmentName, A.MaxMarks, A.Weightage, ISNULL(SA.ObtainedMark, 0) AS ObtainedMark
                FROM Assessment A
                LEFT JOIN StudentAssessment SA ON A.AssessmentID = SA.AssessmentID AND SA.StudentID = @SID
                WHERE A.CourseOfferID = @COID
                ORDER BY A.AssessmentID";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@COID", courseOfferId);
                cmd.Parameters.AddWithValue("@SID", studentId);
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            gvResults.DataSource = dt;
            gvResults.DataBind();

            decimal totalWeighted = 0;
            decimal totalWeightage = 0;
            foreach (DataRow row in dt.Rows)
            {
                decimal max = Convert.ToDecimal(row["MaxMarks"]);
                decimal obtained = Convert.ToDecimal(row["ObtainedMark"]);
                decimal weight = Convert.ToDecimal(row["Weightage"]);
                if (max > 0)
                {
                    totalWeighted += (obtained / max) * weight;
                }
                totalWeightage += weight;
            }

            decimal percentage = totalWeightage > 0 ? totalWeighted / totalWeightage * 100 : 0;
            string grade = GetGrade(percentage);
            lblTotalPercentage.Text = percentage.ToString("F2") + "%";
            lblGrade.Text = grade;
            lblCurrentGrade.Text = grade;
        }

        private string GetGrade(decimal percentage)
        {
            if (percentage >= 80) return "A";
            if (percentage >= 75) return "A-";
            if (percentage >= 70) return "B+";
            if (percentage >= 65) return "B";
            if (percentage >= 60) return "B-";
            if (percentage >= 55) return "C+";
            if (percentage >= 50) return "C";
            if (percentage >= 45) return "D";
            return "F";
        }

        // ========== NOTIFICATION HELPERS ==========

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
            if (studentId == 0) return false;
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

            Response.Redirect(Request.RawUrl);
        }

        // ========== HELPER METHODS FOR MARKUP ==========

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

        protected string GetFileName(string fileUrl)
        {
            if (string.IsNullOrEmpty(fileUrl)) return "—";
            try
            {
                int qIndex = fileUrl.IndexOf('?');
                if (qIndex > 0) fileUrl = fileUrl.Substring(0, qIndex);

                int lastSlash = fileUrl.LastIndexOf('/');
                if (lastSlash >= 0) return fileUrl.Substring(lastSlash + 1);
                return fileUrl;
            }
            catch
            {
                return "—";
            }
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

        protected bool IsDescriptionLong(object description)
        {
            if (description == null || description == DBNull.Value)
                return false;
            string text = description.ToString();
            return text.Length > 80;
        }
    }
}