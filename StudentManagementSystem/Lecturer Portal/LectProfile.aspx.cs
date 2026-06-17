using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace LecturerPortal
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null) Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                LoadProfile();
                SetViewMode();
            }
        }

        private void LoadProfile()
        {
            string query = "SELECT * FROM Lecturer WHERE LecturerID = @ID";
            SqlParameter[] p = { new SqlParameter("@ID", Session["LecturerID"]) };
            DataTable dt = DBHelper.ExecuteQuery(query, p);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                txtName.Text = row["LecturerName"].ToString();
                txtEmail.Text = row["LecturerEmail"].ToString();
                txtContact.Text = row["ContactNo"].ToString();
                txtDepartment.Text = row["Department"].ToString();
                lblSidebarName.Text = row["LecturerName"].ToString();

                // Compute Initials for fallback placeholders
                string lecturerName = row["LecturerName"].ToString();
                string initials = "LE";
                if (!string.IsNullOrEmpty(lecturerName))
                {
                    string[] parts = lecturerName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                    initials = parts.Length > 1 ? (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper() : parts[0][0].ToString().ToUpper();
                }
                litInitials.Text = initials;
                lblMainInitials.Text = initials;

                // Profile Image Sync Verification Logic
                string imagePath = row["ProfileImagePath"]?.ToString();
                if (!string.IsNullOrEmpty(imagePath) && File.Exists(Server.MapPath(imagePath)))
                {
                    string cacheBuster = "?t=" + DateTime.Now.Ticks;

                    imgProfile.ImageUrl = imagePath + cacheBuster;
                    imgProfile.Visible = true;
                    litInitials.Visible = false;

                    imgMainProfile.ImageUrl = imagePath + cacheBuster;
                    imgMainProfile.Visible = true;
                    lblMainInitials.Visible = false;

                    btnDeletePhoto.Visible = true;
                }
                else
                {
                    imgProfile.Visible = false;
                    litInitials.Visible = true;

                    imgMainProfile.Visible = false;
                    lblMainInitials.Visible = true;

                    btnDeletePhoto.Visible = false;
                }
            }
        }

        protected void btnDeletePhoto_Click(object sender, EventArgs e)
        {
            try
            {
                // Find existing file path from DB to physically remove it from disk
                string pathQuery = "SELECT ProfileImagePath FROM Lecturer WHERE LecturerID = @ID";
                SqlParameter[] p = { new SqlParameter("@ID", Session["LecturerID"]) };
                DataTable dt = DBHelper.ExecuteQuery(pathQuery, p);

                if (dt.Rows.Count > 0 && dt.Rows[0]["ProfileImagePath"] != DBNull.Value)
                {
                    string oldPath = dt.Rows[0]["ProfileImagePath"].ToString();
                    if (!string.IsNullOrEmpty(oldPath) && File.Exists(Server.MapPath(oldPath)))
                    {
                        File.Delete(Server.MapPath(oldPath));
                    }
                }

                // Update Database setting row column entry to NULL
                string updateQuery = "UPDATE Lecturer SET ProfileImagePath = NULL WHERE LecturerID = @ID";
                DBHelper.ExecuteNonQuery(updateQuery, new[] { new SqlParameter("@ID", Session["LecturerID"]) });

                LoadProfile();
                lblStatus.Text = "✔ Profile picture deleted successfully!";
                lblStatus.CssClass = "success-msg";
            }
            catch (Exception ex)
            {
                lblStatus.Text = "❌ Failed to delete image: " + ex.Message;
                lblStatus.CssClass = "error-msg";
            }
        }

        private void SetViewMode()
        {
            txtName.ReadOnly = true;
            txtContact.ReadOnly = true;
            txtDepartment.ReadOnly = true;
            txtPassword.ReadOnly = true;
            pnlPhotoUpload.Visible = false;
            btnEdit.Visible = true;
            btnSave.Visible = false;
            btnCancel.Visible = false;
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            txtName.ReadOnly = false;
            txtContact.ReadOnly = false;
            txtDepartment.ReadOnly = false;
            txtPassword.ReadOnly = false;
            pnlPhotoUpload.Visible = true;
            btnEdit.Visible = false;
            btnSave.Visible = true;
            btnCancel.Visible = true;
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            LoadProfile();
            SetViewMode();
            lblStatus.Text = "";
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string passText = txtPassword.Text.Trim();
            string query = "";
            string savePath = null;

            if (fuProfilePic.HasFile)
            {
                string ext = Path.GetExtension(fuProfilePic.FileName).ToLower();
                if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
                {
                    string dir = "~/Uploads/Profiles/";
                    if (!Directory.Exists(Server.MapPath(dir))) Directory.CreateDirectory(Server.MapPath(dir));
                    savePath = dir + Session["LecturerID"] + ext;
                    fuProfilePic.SaveAs(Server.MapPath(savePath));
                }
            }

            if (!string.IsNullOrEmpty(passText))
            {
                query = @"UPDATE Lecturer SET LecturerName=@Name, ContactNo=@Contact, Department=@Dept, Password=@Pass" +
                        (savePath != null ? ", ProfileImagePath=@Img " : " ") + "WHERE LecturerID=@ID";
            }
            else
            {
                query = @"UPDATE Lecturer SET LecturerName=@Name, ContactNo=@Contact, Department=@Dept" +
                        (savePath != null ? ", ProfileImagePath=@Img " : " ") + "WHERE LecturerID=@ID";
            }

            var cmdParams = new System.Collections.Generic.List<SqlParameter> {
                new SqlParameter("@Name", txtName.Text.Trim()),
                new SqlParameter("@Contact", txtContact.Text.Trim()),
                new SqlParameter("@Dept", txtDepartment.Text.Trim()),
                new SqlParameter("@ID", Session["LecturerID"])
            };
            if (!string.IsNullOrEmpty(passText)) cmdParams.Add(new SqlParameter("@Pass", passText));
            if (savePath != null) cmdParams.Add(new SqlParameter("@Img", savePath));

            DBHelper.ExecuteNonQuery(query, cmdParams.ToArray());
            LoadProfile();
            SetViewMode();
            lblStatus.Text = "✔ Changes saved successfully!";
            lblStatus.CssClass = "success-msg";
        }
    }
}