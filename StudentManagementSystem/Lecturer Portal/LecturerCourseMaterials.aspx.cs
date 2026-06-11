using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class LecturerCourseMaterials : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null)
                Response.Redirect("Login.aspx");

            lblSidebarName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                LoadCourses();
                LoadRecentMaterials();
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

        protected void btnPost_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();

            if (title == "")
            {
                ShowError("Please enter material title.");
                return;
            }

            if (ddlCourse.SelectedValue == "0")
            {
                ShowError("Please select a course.");
                return;
            }

            if (!fileUpload.HasFile)
            {
                ShowError("Please upload a file.");
                return;
            }

            string fileURL = SaveUploadedFile();

            DateTime scheduleDate;
            if (!DateTime.TryParse(txtDate.Text, out scheduleDate))
                scheduleDate = DateTime.Today;

            string query = @"
                INSERT INTO CourseMaterial
                (CourseOfferID, MaterialTitle, Description, FileURL, ScheduleDate, UploadDate, UploadByLecturerID)
                VALUES
                (@COID, @Title, @Description, @FileURL, @ScheduleDate, GETDATE(), @LID)";

            SqlParameter descriptionParam = new SqlParameter("@Description", SqlDbType.NVarChar, 500);
            descriptionParam.Value = string.IsNullOrEmpty(description)
                ? (object)DBNull.Value
                : description;

            SqlParameter[] p = {
                new SqlParameter("@COID", ddlCourse.SelectedValue),
                new SqlParameter("@Title", title),
                descriptionParam,
                new SqlParameter("@FileURL", fileURL),
                new SqlParameter("@ScheduleDate", scheduleDate),
                new SqlParameter("@LID", Session["LecturerID"])
            };

            DBHelper.ExecuteNonQuery(query, p);

            ClearForm();
            ShowSuccess("Course material posted successfully.");
            LoadRecentMaterials();
        }

        private string SaveUploadedFile()
        {
            string uploadFolder = Server.MapPath("~/Uploads/CourseMaterials/");

            if (!Directory.Exists(uploadFolder))
                Directory.CreateDirectory(uploadFolder);

            string originalName = Path.GetFileName(fileUpload.FileName);
            string extension = Path.GetExtension(originalName);
            string savedName = "material_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + extension;
            string fullPath = Path.Combine(uploadFolder, savedName);

            fileUpload.SaveAs(fullPath);

            return "~/Uploads/CourseMaterials/" + savedName;
        }

        private void LoadRecentMaterials()
        {
            string query = @"
                SELECT TOP 20
                    cm.MaterialTitle,
                    cm.Description,
                    cm.FileURL,
                    cm.ScheduleDate,
                    cm.UploadDate,
                    c.CourseName
                FROM CourseMaterial cm
                INNER JOIN CourseOffer co ON co.CourseOfferID = cm.CourseOfferID
                INNER JOIN Course c ON c.CourseCode = co.CourseCode
                WHERE cm.UploadByLecturerID = @LID
                ORDER BY cm.UploadDate DESC";

            SqlParameter[] p = {
                new SqlParameter("@LID", Session["LecturerID"])
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            gvMaterials.DataSource = dt;
            gvMaterials.DataBind();
        }

        private void ClearForm()
        {
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtDate.Text = "";

            if (ddlCourse.Items.Count > 0)
                ddlCourse.SelectedIndex = 0;
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