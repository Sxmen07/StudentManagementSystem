using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class LecturerPostAnnouncement : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null)
                Response.Redirect("Login.aspx");

            lblSidebarName.Text = Session["LecturerName"]?.ToString();
            lblWelcomeName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                LoadSidebarProfilePic();
                LoadCourses();
                ShowMenu();
            }
        }

        private void LoadSidebarProfilePic()
        {
            string lecturerName = Session["LecturerName"]?.ToString() ?? "Lecturer";
            lblSidebarName.Text = lecturerName;

            if (!string.IsNullOrEmpty(lecturerName))
            {
                string[] parts = lecturerName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length > 1)
                    litSideInitials.Text = (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper();
                else
                    litSideInitials.Text = parts[0][0].ToString().ToUpper();
            }
            else
            {
                litSideInitials.Text = "LE";
            }

            try
            {
                string query = "SELECT ProfileImagePath FROM Lecturer WHERE LecturerID = @ID";
                SqlParameter[] p = { new SqlParameter("@ID", Session["LecturerID"]) };
                DataTable dt = DBHelper.ExecuteQuery(query, p);

                if (dt.Rows.Count > 0 && dt.Rows[0]["ProfileImagePath"] != DBNull.Value)
                {
                    string imgPath = dt.Rows[0]["ProfileImagePath"].ToString();
                    if (!string.IsNullOrEmpty(imgPath) && File.Exists(Server.MapPath(imgPath)))
                    {
                        imgSidebar.ImageUrl = imgPath + "?t=" + DateTime.Now.Ticks;
                        imgSidebar.Visible = true;
                        litSideInitials.Visible = false;
                        return;
                    }
                }
            }
            catch
            {
                // Fallback softly to showing text placeholder characters on query exception errors
            }

            imgSidebar.Visible = false;
            litSideInitials.Visible = true;
        }

        private void ShowMenu()
        {
            pnlMenu.Visible = true;
            pnlPostAnnouncement.Visible = false;
            pnlViewAnnouncement.Visible = false;
            lblStatus.Text = "";
        }

        protected void btnShowPost_Click(object sender, EventArgs e)
        {
            pnlMenu.Visible = false;
            pnlPostAnnouncement.Visible = true;
            pnlViewAnnouncement.Visible = false;
        }

        protected void btnShowView_Click(object sender, EventArgs e)
        {
            pnlMenu.Visible = false;
            pnlPostAnnouncement.Visible = false;
            pnlViewAnnouncement.Visible = true;

            LoadRecentAnnouncements();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            ShowMenu();
        }

        private void LoadCourses()
        {
            string query = @"
                SELECT DISTINCT
                    c.CourseCode,
                    c.CourseCode + ' - ' + c.CourseName AS DisplayName
                FROM Course c
                INNER JOIN CourseOffer co ON co.CourseCode = c.CourseCode
                WHERE co.LecturerID = @LID
                AND co.OfferStatus = 'Available'
                ORDER BY c.CourseCode";

            SqlParameter[] p = {
                new SqlParameter("@LID", Session["LecturerID"])
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "DisplayName";
            ddlCourse.DataValueField = "CourseCode";
            ddlCourse.DataBind();

            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", "0"));
        }

        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlSendOption.SelectedValue == "SelectedStudents")
            {
                LoadStudentsByCourse();
                lblStatus.Text = "";
            }
        }

        protected void ddlSendOption_SelectedIndexChanged(object sender, EventArgs e)
        {
            pnlStudentSelect.Visible = ddlSendOption.SelectedValue == "SelectedStudents";

            chkSelectAllStudents.Checked = false;
            cblStudents.Items.Clear();

            if (ddlSendOption.SelectedValue == "SelectedStudents")
            {
                if (ddlCourse.SelectedValue == "0")
                {
                    ShowError("Please select a course first.");
                    return;
                }

                LoadStudentsByCourse();
                lblStatus.Text = "";
            }
        }

        protected void chkSelectAllStudents_CheckedChanged(object sender, EventArgs e)
        {
            foreach (ListItem item in cblStudents.Items)
            {
                item.Selected = chkSelectAllStudents.Checked;
            }
        }

        private void LoadStudentsByCourse()
        {
            cblStudents.Items.Clear();

            if (ddlCourse.SelectedValue == "0")
                return;

            string query = @"
                SELECT DISTINCT
                    s.StudentID,
                    s.StudentName + ' (' + CAST(s.StudentID AS NVARCHAR(20)) + ')' AS DisplayName
                FROM Student s
                INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                INNER JOIN CourseOffer co ON co.CourseOfferID = e.CourseOfferID
                WHERE co.CourseCode = @CourseCode
                AND e.EnrolStatus = 'Enrolled'
                ORDER BY DisplayName";

            SqlParameter[] p = {
                new SqlParameter("@CourseCode", ddlCourse.SelectedValue)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            cblStudents.DataSource = dt;
            cblStudents.DataTextField = "DisplayName";
            cblStudents.DataValueField = "StudentID";
            cblStudents.DataBind();
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string message = txtMessage.Text.Trim();

            if (title == "")
            {
                ShowError("Please enter announcement title.");
                return;
            }

            if (message == "")
            {
                ShowError("Please enter announcement message.");
                return;
            }

            if (ddlCourse.SelectedValue == "0")
            {
                ShowError("Please select a course.");
                return;
            }

            if (ddlSendOption.SelectedValue == "SelectedStudents" && !HasSelectedStudent())
            {
                ShowError("Please select at least one student.");
                return;
            }

            if (!fileUpload.HasFile)
            {
                ShowError("No file detected. Please choose a file before posting.");
                return;
            }

            string attachmentPath = SaveUploadedFile();

            string targetType;
            string targetValue;

            if (ddlSendOption.SelectedValue == "ProgrammeCode")
            {
                targetType = "ProgrammeCode";
                targetValue = GetProgrammeCodeByCourseCode(ddlCourse.SelectedValue);
            }
            else
            {
                targetType = "CourseCode";
                targetValue = ddlCourse.SelectedValue;
            }

            string insertQuery = @"
                INSERT INTO Announcement
                (Title, Description, TargetType, TargetValue, CreatedDate, AttachmentPath)
                OUTPUT INSERTED.AnnouncementID
                VALUES
                (@Title, @Description, @TargetType, @TargetValue, GETDATE(), @AttachmentPath)";

            SqlParameter[] insertParams = {
                new SqlParameter("@Title", title),
                new SqlParameter("@Description", message),
                new SqlParameter("@TargetType", targetType),
                new SqlParameter("@TargetValue", targetValue),
                new SqlParameter("@AttachmentPath",
                    string.IsNullOrEmpty(attachmentPath) ? (object)DBNull.Value : attachmentPath)
            };

            DataTable result = DBHelper.ExecuteQuery(insertQuery, insertParams);

            if (result.Rows.Count == 0)
            {
                ShowError("Announcement could not be posted.");
                return;
            }

            int announcementID = Convert.ToInt32(result.Rows[0]["AnnouncementID"]);

            if (ddlSendOption.SelectedValue == "SelectedStudents")
            {
                int sentCount = 0;
                int failedCount = 0;

                SendEmailToSelectedStudents(announcementID, title, message, ref sentCount, ref failedCount);

                ClearForm();

                if (failedCount > 0)
                {
                    ShowError("Announcement posted, but only " + sentCount + " email(s) were sent. " + failedCount + " failed.");
                }
                else
                {
                    ShowSuccess("Announcement posted and email sent to " + sentCount + " selected student(s).");
                }

                return;
            }

            ClearForm();
            ShowSuccess("Announcement posted successfully.");
        }

        private string SaveUploadedFile()
        {
            if (!fileUpload.HasFile)
                return null;

            string extension = Path.GetExtension(fileUpload.FileName).ToLower();

            string[] allowedExtensions = { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png" };

            bool allowed = false;

            foreach (string ext in allowedExtensions)
            {
                if (extension == ext)
                {
                    allowed = true;
                    break;
                }
            }

            if (!allowed)
            {
                ShowError("Only PDF, Word, PowerPoint, JPG and PNG files are allowed.");
                return null;
            }

            string folderPath = Server.MapPath("~/Uploads/Announcements/");

            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }

            string cleanFileName = Path.GetFileName(fileUpload.FileName);
            string newFileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + cleanFileName;

            string savePath = Path.Combine(folderPath, newFileName);

            fileUpload.SaveAs(savePath);

            return "~/Uploads/Announcements/" + newFileName;
        }

        public bool HasAttachment(object attachmentPath)
        {
            return attachmentPath != null &&
                   attachmentPath != DBNull.Value &&
                   !string.IsNullOrWhiteSpace(attachmentPath.ToString());
        }

        public string GetAttachmentUrl(object attachmentPath)
        {
            if (!HasAttachment(attachmentPath))
                return "#";

            return ResolveUrl(attachmentPath.ToString());
        }

        private bool HasSelectedStudent()
        {
            foreach (ListItem item in cblStudents.Items)
            {
                if (item.Selected)
                    return true;
            }

            return false;
        }

        private void SendEmailToSelectedStudents(int announcementID, string title, string message, ref int sentCount, ref int failedCount)
        {
            foreach (ListItem item in cblStudents.Items)
            {
                if (item.Selected)
                {
                    string studentEmail = GetStudentEmail(item.Value);

                    if (string.IsNullOrWhiteSpace(studentEmail))
                    {
                        failedCount++;
                        continue;
                    }

                    try
                    {
                        SendAnnouncementEmail(announcementID, studentEmail, title, message);
                        sentCount++;
                    }
                    catch
                    {
                        failedCount++;
                    }
                }
            }
        }

        private string GetStudentEmail(string studentID)
        {
            string query = @"
                SELECT StudentEmail, PersonalEmail
                FROM Student
                WHERE StudentID = @StudentID";

            SqlParameter[] p = {
                new SqlParameter("@StudentID", studentID)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            if (dt.Rows.Count == 0)
                return "";

            string studentEmail = dt.Rows[0]["StudentEmail"].ToString().Trim();
            string personalEmail = dt.Rows[0]["PersonalEmail"].ToString().Trim();

            if (!string.IsNullOrWhiteSpace(studentEmail) && !studentEmail.Contains("@unitrack.edu.my"))
                return studentEmail;

            if (!string.IsNullOrWhiteSpace(personalEmail))
                return personalEmail;

            return studentEmail;
        }

        private void SendAnnouncementEmail(int announcementID, string toEmail, string title, string message)
        {
            string query = @"
                INSERT INTO EmailLog
                (AnnouncementID, ToEmail, Subject, Body, Status)
                VALUES
                (@AnnouncementID, @ToEmail, @Subject, @Body, @Status)";

            SqlParameter[] p = {
                new SqlParameter("@AnnouncementID", announcementID),
                new SqlParameter("@ToEmail", toEmail),
                new SqlParameter("@Subject", "New Announcement: " + title),
                new SqlParameter("@Body", message),
                new SqlParameter("@Status", "Sent")
            };

            DBHelper.ExecuteNonQuery(query, p);
        }

        private string GetProgrammeCodeByCourseCode(string courseCode)
        {
            string query = @"
                SELECT TOP 1 ProgrammeCode
                FROM Course
                WHERE CourseCode = @CourseCode";

            SqlParameter[] p = {
                new SqlParameter("@CourseCode", courseCode)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            if (dt.Rows.Count > 0)
                return dt.Rows[0]["ProgrammeCode"].ToString();

            return "";
        }

        private void LoadRecentAnnouncements()
        {
            string query = @"
                SELECT TOP 20
                    a.AnnouncementID,
                    a.Title,
                    a.Description,
                    a.TargetType,
                    a.TargetValue,
                    a.CreatedDate,
                    a.AttachmentPath,
                    ISNULL(
                        STUFF((
                            SELECT ', ' + el.ToEmail
                            FROM EmailLog el
                            WHERE el.AnnouncementID = a.AnnouncementID
                            FOR XML PATH(''), TYPE
                        ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''),
                        ''
                    ) AS SentTo
                FROM Announcement a
                ORDER BY a.CreatedDate DESC";

            DataTable dt = DBHelper.ExecuteQuery(query);

            rptAnnouncements.DataSource = dt;
            rptAnnouncements.DataBind();
        }

        private void ClearForm()
        {
            txtTitle.Text = "";
            txtMessage.Text = "";
            txtDate.Text = "";
            ddlType.SelectedIndex = 0;
            ddlSendOption.SelectedIndex = 0;

            if (ddlCourse.Items.Count > 0)
                ddlCourse.SelectedIndex = 0;

            pnlStudentSelect.Visible = false;
            chkSelectAllStudents.Checked = false;
            cblStudents.Items.Clear();
        }

        private void ShowSuccess(string message)
        {
            lblStatus.Text = message;
            lblStatus.CssClass = "success-msg";
        }

        private void ShowError(string message)
        {
            lblStatus.Text = message;
            lblStatus.CssClass = "error-msg";
        }
    }
}