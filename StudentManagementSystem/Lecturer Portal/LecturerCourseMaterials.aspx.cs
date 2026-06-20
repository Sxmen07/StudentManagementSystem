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

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            rptCourseCards.DataSource = dt;
            rptCourseCards.DataBind();
        }

        protected void rptCourseCards_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectCourse")
            {
                hfSelectedCourseOfferID.Value = e.CommandArgument.ToString();

                pnlCourseContent.Visible = true;
                lblStatus.Text = "";

                LoadMaterials();
            }
        }


        private void LoadMaterials()
        {
            string query = @"
                SELECT MaterialTitle, Description, FileURL, ScheduleDate, UploadDate
                FROM CourseMaterial
                WHERE CourseOfferID = @COID
                AND UploadByLecturerID = @LID
                ORDER BY UploadDate DESC";

            SqlParameter[] p =
            {
                new SqlParameter("@COID", hfSelectedCourseOfferID.Value),
                new SqlParameter("@LID", Session["LecturerID"])
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            rptMaterials.DataSource = dt;
            rptMaterials.DataBind();
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            if (hfSelectedCourseOfferID.Value == "0")
            {
                ShowError("Please select a course.");
                return;
            }

            if (string.IsNullOrWhiteSpace(txtTitle.Text))
            {
                ShowError("Enter title.");
                return;
            }

            if (!fileUpload.HasFile)
            {
                ShowError("Upload a file.");
                return;
            }

            string fileURL = SaveFile();

            DateTime scheduleDate;
            if (!DateTime.TryParse(txtDate.Text, out scheduleDate))
                scheduleDate = DateTime.Today;

            string query = @"
                INSERT INTO CourseMaterial
                (CourseOfferID, MaterialTitle, Description, FileURL, ScheduleDate, UploadDate, UploadByLecturerID)
                VALUES
                (@COID, @Title, @Desc, @FileURL, @ScheduleDate, GETDATE(), @LID)";

            SqlParameter[] p =
            {
                new SqlParameter("@COID", hfSelectedCourseOfferID.Value),
                new SqlParameter("@Title", txtTitle.Text.Trim()),
                new SqlParameter("@Desc",
                    string.IsNullOrEmpty(txtDescription.Text) ? (object)DBNull.Value : txtDescription.Text),
                new SqlParameter("@FileURL", fileURL),
                new SqlParameter("@ScheduleDate", scheduleDate),
                new SqlParameter("@LID", Session["LecturerID"])
            };

            DBHelper.ExecuteNonQuery(query, p);

            ClearForm();
            ShowSuccess("Material posted.");
            LoadMaterials();
        }

        private string SaveFile()
        {
            string folder = Server.MapPath("~/Uploads/CourseMaterials/");

            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            string fileName = "mat_" + DateTime.Now.Ticks + Path.GetExtension(fileUpload.FileName);
            string path = Path.Combine(folder, fileName);

            fileUpload.SaveAs(path);

            string urlPath = "/Uploads/CourseMaterials/" + fileName;
            return "~/Uploads/CourseMaterials/" + fileName;
        }

        private void ClearForm()
        {
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtDate.Text = "";
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