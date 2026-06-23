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
            // Force UTF-8 for emojis
            Response.ContentEncoding = System.Text.Encoding.UTF8;
            Response.Charset = "UTF-8";
            Response.ContentType = "text/html; charset=utf-8";

            if (Session["LecturerID"] == null)
                Response.Redirect("Login.aspx");

            lblSidebarName.Text = Session["LecturerName"]?.ToString();
            lblWelcomeName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                LoadSidebarProfilePic();
                LoadProgrammes();
                pnlContent.Visible = false;      // Hide content until a course is loaded
                pnlStudentSelect.Visible = false;
                lblStatus.Text = "";
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
                litSideInitials.Text = "LE";

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
            catch { }

            imgSidebar.Visible = false;
            litSideInitials.Visible = true;
        }

        private void LoadProgrammes()
        {
            string query = @"
                SELECT DISTINCT p.ProgrammeCode, p.ProgrammeName
                FROM Programme p
                INNER JOIN Course c ON c.ProgrammeCode = p.ProgrammeCode
                INNER JOIN CourseOffer co ON co.CourseCode = c.CourseCode
                WHERE co.LecturerID = @LID";
            DataTable dt = DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@LID", Session["LecturerID"]) });
            ddlProgramme.DataSource = dt;
            ddlProgramme.DataTextField = "ProgrammeName";
            ddlProgramme.DataValueField = "ProgrammeCode";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
            ddlCourseOffer.Items.Clear();
            ddlCourseOffer.Items.Add(new ListItem("-- Select Course --", "0"));
        }

        protected void ddlProgramme_Changed(object sender, EventArgs e)
        {
            ddlCourseOffer.Items.Clear();
            if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                string query = @"
                    SELECT co.CourseOfferID,
                           c.CourseName + ' (' + s.Semester + ' ' + CAST(co.Year AS NVARCHAR) + ')' AS DisplayName,
                           c.CourseCode
                    FROM CourseOffer co
                    INNER JOIN Course c ON c.CourseCode = co.CourseCode
                    INNER JOIN Semester s ON s.SemesterID = co.SemesterID
                    WHERE co.LecturerID = @LID AND c.ProgrammeCode = @PCode AND co.OfferStatus = 'Available'";
                SqlParameter[] p = {
                    new SqlParameter("@LID", Session["LecturerID"]),
                    new SqlParameter("@PCode", ddlProgramme.SelectedValue)
                };
                DataTable dt = DBHelper.ExecuteQuery(query, p);
                ddlCourseOffer.DataSource = dt;
                ddlCourseOffer.DataTextField = "DisplayName";
                ddlCourseOffer.DataValueField = "CourseOfferID";
                ddlCourseOffer.DataBind();
            }
            ddlCourseOffer.Items.Insert(0, new ListItem("-- Select Course --", "0"));

            // Hide content and clear list when programme changes
            pnlContent.Visible = false;
            rptAnnouncements.DataSource = null;
            rptAnnouncements.DataBind();
            hfCourseCode.Value = "0";
            lblStatus.Text = "";
        }

        protected void ddlCourseOffer_Changed(object sender, EventArgs e)
        {
            // Update hidden course code when course changes
            if (ddlCourseOffer.SelectedValue != "0")
            {
                string query = "SELECT CourseCode FROM CourseOffer WHERE CourseOfferID = @COID";
                object code = DBHelper.ExecuteScalar(query, new[] { new SqlParameter("@COID", ddlCourseOffer.SelectedValue) });
                hfCourseCode.Value = code?.ToString() ?? "0";
            }
            else
                hfCourseCode.Value = "0";

            // Hide content until user clicks Load
            pnlContent.Visible = false;
            rptAnnouncements.DataSource = null;
            rptAnnouncements.DataBind();
            lblStatus.Text = "";
        }

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlProgramme.SelectedValue) ||
                string.IsNullOrEmpty(ddlCourseOffer.SelectedValue) ||
                ddlCourseOffer.SelectedValue == "0")
            {
                ShowError("Please select both a programme and a course.");
                pnlContent.Visible = false;
                return;
            }

            // Show the content panel
            pnlContent.Visible = true;
            LoadAnnouncementsForCourse();
            // Load students if selected student option is active
            if (ddlSendOption.SelectedValue == "SelectedStudents")
                LoadStudentsByCourse();
            lblStatus.Text = "";
        }

        private void LoadAnnouncementsForCourse()
        {
            string courseCode = hfCourseCode.Value;
            if (courseCode == "0") return;

            string query = @"
                SELECT TOP 20
                    a.AnnouncementID,
                    a.Title,
                    a.Description,
                    a.TargetType,
                    a.TargetValue,
                    a.CreatedDate,
                    a.AttachmentPath,
                    (SELECT COUNT(*) FROM EmailLog WHERE AnnouncementID = a.AnnouncementID) AS SentCount
                FROM Announcement a
                WHERE a.TargetValue = @CourseCode
                   OR a.TargetValue IN (SELECT ProgrammeCode FROM Course WHERE CourseCode = @CourseCode)
                   OR a.TargetType = 'All'
                ORDER BY a.CreatedDate DESC";

            DataTable dt = DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@CourseCode", courseCode) });
            rptAnnouncements.DataSource = dt;
            rptAnnouncements.DataBind();
        }

        protected void ddlSendOption_Changed(object sender, EventArgs e)
        {
            pnlStudentSelect.Visible = (ddlSendOption.SelectedValue == "SelectedStudents");
            chkSelectAllStudents.Checked = false;
            cblStudents.Items.Clear();

            if (ddlSendOption.SelectedValue == "SelectedStudents")
            {
                if (ddlCourseOffer.SelectedValue == "0")
                    ShowError("Please select a course first.");
                else
                    LoadStudentsByCourse();
            }
        }

        private void LoadStudentsByCourse()
        {
            cblStudents.Items.Clear();
            if (ddlCourseOffer.SelectedValue == "0") return;

            string query = @"
                SELECT DISTINCT
                    s.StudentID,
                    s.StudentName + ' (' + CAST(s.StudentID AS NVARCHAR(20)) + ')' AS DisplayName
                FROM Student s
                INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                WHERE e.CourseOfferID = @COID AND e.EnrolStatus = 'Enrolled'
                ORDER BY DisplayName";
            DataTable dt = DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@COID", ddlCourseOffer.SelectedValue) });
            cblStudents.DataSource = dt;
            cblStudents.DataTextField = "DisplayName";
            cblStudents.DataValueField = "StudentID";
            cblStudents.DataBind();
        }

        protected void chkSelectAllStudents_CheckedChanged(object sender, EventArgs e)
        {
            foreach (ListItem item in cblStudents.Items)
                item.Selected = chkSelectAllStudents.Checked;
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
            if (ddlCourseOffer.SelectedValue == "0")
            {
                ShowError("Please select a course.");
                return;
            }
            if (ddlSendOption.SelectedValue == "SelectedStudents" && !HasSelectedStudent())
            {
                ShowError("Please select at least one student.");
                return;
            }

            string attachmentPath = "";
            if (fileUpload.HasFile)
            {
                attachmentPath = SaveUploadedFile();
                if (attachmentPath == null) return; // error already shown
            }

            string targetType, targetValue;
            if (ddlSendOption.SelectedValue == "ProgrammeCode")
            {
                targetType = "ProgrammeCode";
                targetValue = GetProgrammeCodeByCourseCode(hfCourseCode.Value);
            }
            else
            {
                targetType = "CourseCode";
                targetValue = hfCourseCode.Value;
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
                new SqlParameter("@AttachmentPath", string.IsNullOrEmpty(attachmentPath) ? (object)DBNull.Value : attachmentPath)
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
                int sentCount = 0, failedCount = 0;
                SendEmailToSelectedStudents(announcementID, title, message, ref sentCount, ref failedCount);
                ClearForm();
                if (failedCount > 0)
                    ShowError($"Posted, but {sentCount} email(s) sent, {failedCount} failed.");
                else
                    ShowSuccess($"Announcement posted and email sent to {sentCount} selected student(s).");
            }
            else
            {
                ClearForm();
                ShowSuccess("Announcement posted successfully.");
            }

            // Refresh the announcement list
            LoadAnnouncementsForCourse();
        }

        private string SaveUploadedFile()
        {
            if (!fileUpload.HasFile) return null;
            string ext = Path.GetExtension(fileUpload.FileName).ToLower();
            string[] allowed = { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png" };
            if (!Array.Exists(allowed, e => e == ext))
            {
                ShowError("Only PDF, Word, PowerPoint, JPG and PNG files are allowed.");
                return null;
            }
            string folder = Server.MapPath("~/Uploads/Announcements/");
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
            string newName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Path.GetFileName(fileUpload.FileName);
            string savePath = Path.Combine(folder, newName);
            fileUpload.SaveAs(savePath);
            return "~/Uploads/Announcements/" + newName;
        }

        private void SendEmailToSelectedStudents(int announcementID, string title, string message, ref int sentCount, ref int failedCount)
        {
            foreach (ListItem item in cblStudents.Items)
            {
                if (!item.Selected) continue;
                string email = GetStudentEmail(item.Value);
                if (string.IsNullOrWhiteSpace(email)) { failedCount++; continue; }
                try
                {
                    string query = @"
                        INSERT INTO EmailLog (AnnouncementID, ToEmail, Subject, Body, Status)
                        VALUES (@AID, @Email, @Subject, @Body, 'Sent')";
                    SqlParameter[] p = {
                        new SqlParameter("@AID", announcementID),
                        new SqlParameter("@Email", email),
                        new SqlParameter("@Subject", "New Announcement: " + title),
                        new SqlParameter("@Body", message)
                    };
                    DBHelper.ExecuteNonQuery(query, p);
                    sentCount++;
                }
                catch { failedCount++; }
            }
        }

        private string GetStudentEmail(string studentID)
        {
            string query = "SELECT StudentEmail, PersonalEmail FROM Student WHERE StudentID = @SID";
            DataTable dt = DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@SID", studentID) });
            if (dt.Rows.Count == 0) return "";
            string studentEmail = dt.Rows[0]["StudentEmail"]?.ToString()?.Trim() ?? "";
            string personalEmail = dt.Rows[0]["PersonalEmail"]?.ToString()?.Trim() ?? "";
            if (!string.IsNullOrWhiteSpace(studentEmail) && !studentEmail.Contains("@unitrack.edu.my"))
                return studentEmail;
            return !string.IsNullOrWhiteSpace(personalEmail) ? personalEmail : studentEmail;
        }

        private string GetProgrammeCodeByCourseCode(string courseCode)
        {
            string query = "SELECT ProgrammeCode FROM Course WHERE CourseCode = @CC";
            object result = DBHelper.ExecuteScalar(query, new[] { new SqlParameter("@CC", courseCode) });
            return result?.ToString() ?? "";
        }

        private bool HasSelectedStudent()
        {
            foreach (ListItem item in cblStudents.Items)
                if (item.Selected) return true;
            return false;
        }

        private void ClearForm()
        {
            txtTitle.Text = "";
            txtMessage.Text = "";
            txtDate.Text = "";
            fileUpload.Attributes.Clear();
            ddlType.SelectedIndex = 0;
            ddlSendOption.SelectedIndex = 0;
            pnlStudentSelect.Visible = false;
            chkSelectAllStudents.Checked = false;
            cblStudents.Items.Clear();
        }

        private void ShowSuccess(string msg)
        {
            lblStatus.Text = msg;
            lblStatus.CssClass = "success-msg";
        }
        private void ShowError(string msg)
        {
            lblStatus.Text = msg;
            lblStatus.CssClass = "error-msg";
        }
    }
}