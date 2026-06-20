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
            lblWelcomeName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                LoadSidebarProfilePic();
                LoadCourses();
                pnlCourseContent.Visible = false;
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

            SqlParameter[] p =
            {
                new SqlParameter("@LID", Session["LecturerID"])
            };

            rptCourseCards.DataSource = DBHelper.ExecuteQuery(query, p);
            rptCourseCards.DataBind();
        }

        protected void rptCourseCards_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectCourse")
            {
                hfSelectedCourseOfferID.Value = e.CommandArgument.ToString();
                pnlCourseContent.Visible = true;
                ClearForm();
                lblStatus.Text = "";
                LoadMaterials();
            }
        }

        private void LoadMaterials()
        {
            string query = @"
                SELECT MaterialID, MaterialTitle, Description, MaterialCategory, FileURL, ScheduleDate, UploadDate
                FROM CourseMaterial
                WHERE CourseOfferID = @COID
                AND UploadByLecturerID = @LID
                ORDER BY UploadDate DESC";

            SqlParameter[] p =
            {
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

            SqlParameter[] p =
            {
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

                SqlParameter[] p =
                {
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

                SqlParameter[] p =
                {
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

                SqlParameter[] p =
                {
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

                SqlParameter[] p =
                {
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

            string fileName = "mat_" + DateTime.Now.Ticks + Path.GetExtension(fileUpload.FileName);
            string path = Path.Combine(folder, fileName);

            fileUpload.SaveAs(path);

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