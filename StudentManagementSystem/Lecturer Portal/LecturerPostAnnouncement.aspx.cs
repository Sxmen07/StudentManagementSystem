using System;
using System.Data;
using System.Data.SqlClient;
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

            if (!IsPostBack)
            {
                LoadCourses();
                ShowMenu();
            }
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

            string targetType = "";
            string targetValue = "";

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

            string query = @"
                INSERT INTO Announcement
                (Title, Description, TargetType, TargetValue, CreatedDate)
                OUTPUT INSERTED.AnnouncementID
                VALUES
                (@Title, @Description, @TargetType, @TargetValue, GETDATE())";

            SqlParameter[] p = {
                new SqlParameter("@Title", title),
                new SqlParameter("@Description", message),
                new SqlParameter("@TargetType", targetType),
                new SqlParameter("@TargetValue", targetValue)
            };

            DataTable result = DBHelper.ExecuteQuery(query, p);
            int announcementID = Convert.ToInt32(result.Rows[0]["AnnouncementID"]);

            if (ddlSendOption.SelectedValue == "SelectedStudents")
            {
                SaveSelectedStudents(announcementID);
            }

            ClearForm();
            ShowSuccess("Announcement posted successfully.");
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

        private bool HasSelectedStudent()
        {
            foreach (ListItem item in cblStudents.Items)
            {
                if (item.Selected)
                    return true;
            }

            return false;
        }

        private void SaveSelectedStudents(int announcementID)
        {
            foreach (ListItem item in cblStudents.Items)
            {
                if (item.Selected)
                {
                    string query = @"
                        INSERT INTO AnnouncementRecipient
                        (AnnouncementID, StudentID)
                        VALUES
                        (@AnnouncementID, @StudentID)";

                    SqlParameter[] p = {
                        new SqlParameter("@AnnouncementID", announcementID),
                        new SqlParameter("@StudentID", item.Value)
                    };

                    DBHelper.ExecuteNonQuery(query, p);
                }
            }
        }

        private void LoadRecentAnnouncements()
        {
            string query = @"
                SELECT TOP 20
                    Title,
                    Description,
                    TargetType,
                    TargetValue,
                    CreatedDate
                FROM Announcement
                ORDER BY CreatedDate DESC";

            DataTable dt = DBHelper.ExecuteQuery(query);

            gvAnnouncements.DataSource = dt;
            gvAnnouncements.DataBind();
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