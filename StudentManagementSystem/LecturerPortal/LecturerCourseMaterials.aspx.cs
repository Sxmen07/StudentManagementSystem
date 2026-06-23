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
                pnlCourseContent.Visible = false;
                lblStatus.Text = "";
            }
        }

        private void LoadSidebarProfilePic()
        {
            string lecturerName = Session["LecturerName"]?.ToString() ?? "Lecturer";
            lblSidebarName.Text = lecturerName;

            string[] parts = lecturerName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            litSideInitials.Text = parts.Length > 1
                ? (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper()
                : lecturerName[0].ToString().ToUpper();

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
                           c.CourseName + ' (' + s.Semester + ' ' + CAST(co.Year AS NVARCHAR) + ')' AS DisplayName
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
            pnlCourseContent.Visible = false;
            rptMaterials.DataSource = null;
            rptMaterials.DataBind();
            lblStatus.Text = "";
        }

        protected void ddlCourseOffer_Changed(object sender, EventArgs e)
        {
            // Hide content until user clicks Load
            pnlCourseContent.Visible = false;
            rptMaterials.DataSource = null;
            rptMaterials.DataBind();
            lblStatus.Text = "";
        }

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlProgramme.SelectedValue) ||
                string.IsNullOrEmpty(ddlCourseOffer.SelectedValue) ||
                ddlCourseOffer.SelectedValue == "0")
            {
                ShowError("Please select both a programme and a course.");
                pnlCourseContent.Visible = false;
                return;
            }

            hfSelectedCourseOfferID.Value = ddlCourseOffer.SelectedValue;
            pnlCourseContent.Visible = true;
            ClearForm();
            lblStatus.Text = "";
            LoadMaterials();
        }

        private void LoadMaterials()
        {
            string query = @"
                SELECT MaterialID, MaterialTitle, Description, MaterialCategory, FileURL, ScheduleDate, UploadDate
                FROM CourseMaterial
                WHERE CourseOfferID = @COID
                AND UploadByLecturerID = @LID
                ORDER BY UploadDate DESC";

            SqlParameter[] p = {
                new SqlParameter("@COID", hfSelectedCourseOfferID.Value),
                new SqlParameter("@LID", Session["LecturerID"])
            };

            rptMaterials.DataSource = DBHelper.ExecuteQuery(query, p);
            rptMaterials.DataBind();
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfSelectedCourseOfferID.Value) || hfSelectedCourseOfferID.Value == "0")
            {
                ShowError("Please select a course.");
                return;
            }

            if (string.IsNullOrWhiteSpace(txtTitle.Text))
            {
                ShowError("Enter title.");
                return;
            }

            DateTime scheduleDate;
            if (!DateTime.TryParse(txtDate.Text, out scheduleDate))
                scheduleDate = DateTime.Today;

            if (hfEditingMaterialID.Value != "0")
            {
                UpdateMaterial(scheduleDate);
                ClearForm();
                ShowSuccess("Material updated successfully.");
                LoadMaterials();
                return;
            }

            string fileURL = fileUpload.HasFile ? SaveFile() : "";

            string query = @"
                INSERT INTO CourseMaterial
                (CourseOfferID, MaterialTitle, Description, MaterialCategory, FileURL, ScheduleDate, UploadDate, UploadByLecturerID)
                VALUES
                (@COID, @Title, @Desc, @Category, @FileURL, @ScheduleDate, GETDATE(), @LID)";

            SqlParameter[] p = {
                new SqlParameter("@COID", hfSelectedCourseOfferID.Value),
                new SqlParameter("@Title", txtTitle.Text.Trim()),
                new SqlParameter("@Desc", string.IsNullOrEmpty(txtDescription.Text) ? (object)DBNull.Value : txtDescription.Text.Trim()),
                new SqlParameter("@Category", ddlCategory.SelectedValue),
                new SqlParameter("@FileURL", fileURL),
                new SqlParameter("@ScheduleDate", scheduleDate),
                new SqlParameter("@LID", Session["LecturerID"])
            };

            DBHelper.ExecuteNonQuery(query, p);

            ClearForm();
            ShowSuccess("Material posted successfully.");
            LoadMaterials();
        }

        private void UpdateMaterial(DateTime scheduleDate)
        {
            if (fileUpload.HasFile)
            {
                string fileURL = SaveFile();

                string query = @"
                    UPDATE CourseMaterial
                    SET MaterialTitle = @Title,
                        Description = @Desc,
                        MaterialCategory = @Category,
                        FileURL = @FileURL,
                        ScheduleDate = @ScheduleDate
                    WHERE MaterialID = @MID
                    AND UploadByLecturerID = @LID";

                SqlParameter[] p = {
                    new SqlParameter("@Title", txtTitle.Text.Trim()),
                    new SqlParameter("@Desc", string.IsNullOrEmpty(txtDescription.Text) ? (object)DBNull.Value : txtDescription.Text.Trim()),
                    new SqlParameter("@Category", ddlCategory.SelectedValue),
                    new SqlParameter("@FileURL", fileURL),
                    new SqlParameter("@ScheduleDate", scheduleDate),
                    new SqlParameter("@MID", hfEditingMaterialID.Value),
                    new SqlParameter("@LID", Session["LecturerID"])
                };

                DBHelper.ExecuteNonQuery(query, p);
            }
            else
            {
                string query = @"
                    UPDATE CourseMaterial
                    SET MaterialTitle = @Title,
                        Description = @Desc,
                        MaterialCategory = @Category,
                        ScheduleDate = @ScheduleDate
                    WHERE MaterialID = @MID
                    AND UploadByLecturerID = @LID";

                SqlParameter[] p = {
                    new SqlParameter("@Title", txtTitle.Text.Trim()),
                    new SqlParameter("@Desc", string.IsNullOrEmpty(txtDescription.Text) ? (object)DBNull.Value : txtDescription.Text.Trim()),
                    new SqlParameter("@Category", ddlCategory.SelectedValue),
                    new SqlParameter("@ScheduleDate", scheduleDate),
                    new SqlParameter("@MID", hfEditingMaterialID.Value),
                    new SqlParameter("@LID", Session["LecturerID"])
                };

                DBHelper.ExecuteNonQuery(query, p);
            }
        }

        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "EditMaterial")
            {
                string query = @"
                    SELECT MaterialID, MaterialTitle, Description, MaterialCategory, ScheduleDate
                    FROM CourseMaterial
                    WHERE MaterialID = @MID
                    AND UploadByLecturerID = @LID";

                SqlParameter[] p = {
                    new SqlParameter("@MID", e.CommandArgument.ToString()),
                    new SqlParameter("@LID", Session["LecturerID"])
                };

                DataTable dt = DBHelper.ExecuteQuery(query, p);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];

                    hfEditingMaterialID.Value = row["MaterialID"].ToString();
                    txtTitle.Text = row["MaterialTitle"].ToString();
                    txtDescription.Text = row["Description"].ToString();

                    if (row["MaterialCategory"] != DBNull.Value)
                        ddlCategory.SelectedValue = row["MaterialCategory"].ToString();

                    if (row["ScheduleDate"] != DBNull.Value)
                        txtDate.Text = Convert.ToDateTime(row["ScheduleDate"]).ToString("yyyy-MM-dd");

                    btnPost.Text = "Update Material";
                    ShowSuccess("Editing selected material. Upload a new file only if you want to replace the old one.");
                }
            }
            else if (e.CommandName == "DeleteMaterial")
            {
                string query = @"
                    DELETE FROM CourseMaterial
                    WHERE MaterialID = @MID
                    AND UploadByLecturerID = @LID";

                SqlParameter[] p = {
                    new SqlParameter("@MID", e.CommandArgument.ToString()),
                    new SqlParameter("@LID", Session["LecturerID"])
                };

                DBHelper.ExecuteNonQuery(query, p);

                ClearForm();
                LoadMaterials();
                ShowSuccess("Material deleted successfully.");
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowSuccess("Edit cancelled.");
        }

        private string SaveFile()
        {
            string folder = Server.MapPath("~/Uploads/CourseMaterials/");
            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            string originalName = Path.GetFileName(fileUpload.FileName);
            string fileName = originalName;
            string fullPath = Path.Combine(folder, fileName);
            int counter = 1;

            while (File.Exists(fullPath))
            {
                string nameWithoutExt = Path.GetFileNameWithoutExtension(originalName);
                string ext = Path.GetExtension(originalName);
                fileName = $"{nameWithoutExt}({counter}){ext}";
                fullPath = Path.Combine(folder, fileName);
                counter++;
            }

            fileUpload.SaveAs(fullPath);
            return "~/Uploads/CourseMaterials/" + fileName;
        }

        private void ClearForm()
        {
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtDate.Text = "";
            ddlCategory.SelectedIndex = 0;
            hfEditingMaterialID.Value = "0";
            btnPost.Text = "Post Material";
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