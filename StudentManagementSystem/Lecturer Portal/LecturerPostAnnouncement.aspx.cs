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
                LoadRecentAnnouncements();
                pnlStudentSelect.Visible = false;
            }
        }

        private void LoadCourses()
        {
            string query = @"
                SELECT co.CourseOfferID,
                       c.CourseName + ' (' + s.Semester + ' ' + CAST(co.Year AS NVARCHAR) + ')' AS DisplayName
                FROM CourseOffer co
                INNER JOIN Course c ON c.CourseCode = co.CourseCode
                INNER JOIN Semester s ON s.SemesterID = co.SemesterID
                WHERE co.LecturerID = @LID
                AND co.OfferStatus = 'Available'
                ORDER BY c.CourseName";

            SqlParameter[] p = {
                new SqlParameter("@LID", Session["LecturerID"])
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "DisplayName";
            ddlCourse.DataValueField = "CourseOfferID";
            ddlCourse.DataBind();

            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", "0"));
        }

        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRecentAnnouncements();
        }

        protected void ddlSendOption_SelectedIndexChanged(object sender, EventArgs e)
        {
            pnlStudentSelect.Visible = false;
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

            if (ddlSendOption.SelectedValue == "CourseOfferID" && ddlCourse.SelectedValue == "0")
            {
                ShowError("Please select a course.");
                return;
            }

            string targetType = ddlSendOption.SelectedValue;

            string query = @"
                INSERT INTO Announcement
                (Title, Description, TargetType, CreatedDate)
                VALUES
                (@Title, @Description, @TargetType, GETDATE())";

            SqlParameter[] p = {
                new SqlParameter("@Title", title),
                new SqlParameter("@Description", message),
                new SqlParameter("@TargetType", targetType)
            };

            DBHelper.ExecuteNonQuery(query, p);

            ClearForm();

            ShowSuccess("Announcement posted successfully.");
            LoadRecentAnnouncements();
        }

        private void LoadRecentAnnouncements()
        {
            string query = @"
                SELECT TOP 20
                    Title,
                    Description,
                    TargetType,
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
            pnlStudentSelect.Visible = false;
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