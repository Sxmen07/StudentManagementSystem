using System;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace StudentManagementSystem
{
    public partial class UserProfile : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfileData();
            }
        }

        private void LoadUserProfileData()
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string role = Session["UserRole"].ToString();

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "";
                if (role == "Admin")
                {
                    query = "SELECT HopID AS ID, HopName AS Name, HopEmail AS Email, ProfilePictureUrl, BannerPictureUrl FROM HeadofProgramme WHERE HopID = @ID";
                }
                else if (role == "Lecturer")
                {
                    query = "SELECT LecturerID AS ID, LecturerName AS Name, LecturerEmail AS Email, ProfilePictureUrl, BannerPictureUrl FROM Lecturer WHERE LecturerID = @ID";
                }
                else if (role == "Student")
                {
                    query = "SELECT StudentID AS ID, StudentName AS Name, StudentEmail AS Email, ProfilePictureUrl, BannerPictureUrl FROM Student WHERE StudentID = @ID";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", userId);
                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                txtUserID.Text = reader["ID"].ToString();
                                txtRole.Text = role;
                                txtFullName.Text = reader["Name"].ToString();
                                txtEmail.Text = reader["Email"].ToString();

                                lblDisplayHeaderName.Text = reader["Name"].ToString();
                                litBadgeRole.Text = role;
                                litSubHeaderTitle.Text = role + " Account Workspace";

                                // Dynamic avatar assignment path validation
                                string picUrl = Convert.ToString(reader["ProfilePictureUrl"]);
                                imgAvatar.ImageUrl = !string.IsNullOrWhiteSpace(picUrl)
                                    ? ResolveUrl(picUrl)
                                    : ResolveUrl("~/images/profile_upload/default-avatar.jpg");

                                // Dynamic banner background assignment path validation
                                string bannerUrl = Convert.ToString(reader["BannerPictureUrl"]);
                                if (!string.IsNullOrWhiteSpace(bannerUrl))
                                {
                                    pnlBannerBackground.BackImageUrl = ResolveUrl(bannerUrl);
                                }
                                else
                                {
                                    pnlBannerBackground.BackImageUrl = ""; // Defaults directly back to CSS pastel gradients code loop
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowStatus("Error pulling profile parameters: " + ex.Message, false);
                    }
                }
            }
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string role = Session["UserRole"].ToString();
            string fullName = txtFullName.Text.Trim();
            string newPassword = txtPassword.Text.Trim();

            if (string.IsNullOrWhiteSpace(fullName))
            {
                ShowStatus("Validation error: Registered Name cannot be left blank.", false);
                return;
            }

            string safeName = fullName.Replace(" ", "_");
            foreach (char c in Path.GetInvalidFileNameChars())
            {
                safeName = safeName.Replace(c.ToString(), "");
            }

            string dbAvatarPath = null;
            string dbBannerPath = null;

            try
            {
                if (fuAvatar.HasFile)
                {
                    string avatarVirtualFolder = $"~/images/profile_upload/{role}/";
                    string avatarPhysicalPath = Server.MapPath(avatarVirtualFolder);

                    if (!Directory.Exists(avatarPhysicalPath)) Directory.CreateDirectory(avatarPhysicalPath);

                    string ext = Path.GetExtension(fuAvatar.FileName).ToLower();
                    string fileName = $"{safeName}_{userId}{ext}";
                    fuAvatar.SaveAs(Path.Combine(avatarPhysicalPath, fileName));
                    dbAvatarPath = avatarVirtualFolder + fileName;
                }

                if (fuBackground.HasFile)
                {
                    string bannerVirtualFolder = $"~/images/profile_bg/{role}/";
                    string bannerPhysicalPath = Server.MapPath(bannerVirtualFolder);

                    if (!Directory.Exists(bannerPhysicalPath)) Directory.CreateDirectory(bannerPhysicalPath);

                    string ext = Path.GetExtension(fuBackground.FileName).ToLower();
                    string fileName = $"{safeName}_{userId}{ext}";
                    fuBackground.SaveAs(Path.Combine(bannerPhysicalPath, fileName));
                    dbBannerPath = bannerVirtualFolder + fileName;
                }

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    string queryBase = "";
                    if (role == "Admin") queryBase = "UPDATE HeadofProgramme SET HopName = @Name {0} WHERE HopID = @ID";
                    else if (role == "Lecturer") queryBase = "UPDATE Lecturer SET LecturerName = @Name {0} WHERE LecturerID = @ID";
                    else if (role == "Student") queryBase = "UPDATE Student SET StudentName = @Name {0} WHERE StudentID = @ID";

                    string appends = "";
                    if (dbAvatarPath != null) appends += ", ProfilePictureUrl = @Avatar";
                    if (dbBannerPath != null) appends += ", BannerPictureUrl = @Banner";
                    if (!string.IsNullOrWhiteSpace(newPassword)) appends += ", Password = @Password";

                    using (SqlCommand cmd = new SqlCommand(string.Format(queryBase, appends), conn))
                    {
                        cmd.Parameters.AddWithValue("@Name", fullName);
                        cmd.Parameters.AddWithValue("@ID", userId);
                        if (dbAvatarPath != null) cmd.Parameters.AddWithValue("@Avatar", dbAvatarPath);
                        if (dbBannerPath != null) cmd.Parameters.AddWithValue("@Banner", dbBannerPath);
                        if (!string.IsNullOrWhiteSpace(newPassword)) cmd.Parameters.AddWithValue("@Password", newPassword);

                        cmd.ExecuteNonQuery();
                    }
                }

                ToggleEditState(false);
                LoadUserProfileData();
                ShowStatus("Profile updated and synchronized successfully!", true);
            }
            catch (Exception ex)
            {
                ShowStatus("System folder routing save failure: " + ex.Message, false);
            }
        }

        // BUTTON TRIGGER ACTION: REVERT CUSTOM AVATAR PHOTO BACK TO DEFAULT CAPTURES
        protected void lnkDeleteAvatar_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string role = Session["UserRole"].ToString();

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string findQuery = role == "Admin" ? "SELECT ProfilePictureUrl FROM HeadofProgramme WHERE HopID = @ID" :
                                    role == "Lecturer" ? "SELECT ProfilePictureUrl FROM Lecturer WHERE LecturerID = @ID" :
                                    "SELECT ProfilePictureUrl FROM Student WHERE StudentID = @ID";

                string deleteQuery = role == "Admin" ? "UPDATE HeadofProgramme SET ProfilePictureUrl = NULL WHERE HopID = @ID" :
                                     role == "Lecturer" ? "UPDATE Lecturer SET ProfilePictureUrl = NULL WHERE LecturerID = @ID" :
                                     "UPDATE Student SET ProfilePictureUrl = NULL WHERE StudentID = @ID";

                try
                {
                    conn.Open();
                    string physicalFileTarget = "";

                    using (SqlCommand cmd = new SqlCommand(findQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", userId);
                        physicalFileTarget = Convert.ToString(cmd.ExecuteScalar());
                    }

                    // 1. Physically delete old file from your images folder branch tree if found on disk storage
                    if (!string.IsNullOrWhiteSpace(physicalFileTarget))
                    {
                        string fileDiskLocation = Server.MapPath(physicalFileTarget);
                        if (File.Exists(fileDiskLocation)) File.Delete(fileDiskLocation);
                    }

                    // 2. Erase the link out of the database column record parameters
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", userId);
                        cmd.ExecuteNonQuery();
                    }

                    LoadUserProfileData();
                    ShowStatus("Custom uploaded profile picture purged. Default avatar fallback restored!", true);
                }
                catch (Exception ex)
                {
                    ShowStatus("Purge execution error: " + ex.Message, false);
                }
            }
        }

        // BUTTON TRIGGER ACTION: REVERT BACKGROUND BANNER OVERLAY TILES TO SYSTEM DEFAULT GRADIENTS
        protected void lnkDeleteBanner_Click(object sender, EventArgs e)
        {
            int userId = Convert.ToInt32(Session["UserID"]);
            string role = Session["UserRole"].ToString();

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string findQuery = role == "Admin" ? "SELECT BannerPictureUrl FROM HeadofProgramme WHERE HopID = @ID" :
                                    role == "Lecturer" ? "SELECT BannerPictureUrl FROM Lecturer WHERE LecturerID = @ID" :
                                    "SELECT BannerPictureUrl FROM Student WHERE StudentID = @ID";

                string deleteQuery = role == "Admin" ? "UPDATE HeadofProgramme SET BannerPictureUrl = NULL WHERE HopID = @ID" :
                                     role == "Lecturer" ? "UPDATE Lecturer SET BannerPictureUrl = NULL WHERE LecturerID = @ID" :
                                     "UPDATE Student SET BannerPictureUrl = NULL WHERE StudentID = @ID";

                try
                {
                    conn.Open();
                    string physicalFileTarget = "";

                    using (SqlCommand cmd = new SqlCommand(findQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", userId);
                        physicalFileTarget = Convert.ToString(cmd.ExecuteScalar());
                    }

                    // 1. Physically delete old banner file from folder path on disk
                    if (!string.IsNullOrWhiteSpace(physicalFileTarget))
                    {
                        string fileDiskLocation = Server.MapPath(physicalFileTarget);
                        if (File.Exists(fileDiskLocation)) File.Delete(fileDiskLocation);
                    }

                    // 2. Revert SQL column back to clean database NULL parameter values
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", userId);
                        cmd.ExecuteNonQuery();
                    }

                    LoadUserProfileData();
                    ShowStatus("Custom cover photo removed. Background pastel gradient color themes loaded!", true);
                }
                catch (Exception ex)
                {
                    ShowStatus("Purge execution error: " + ex.Message, false);
                }
            }
        }

        protected void btnEditToggle_Click(object sender, EventArgs e)
        {
            ToggleEditState(true);
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ToggleEditState(false);
            LoadUserProfileData();
        }

        private void ToggleEditState(bool isEditing)
        {
            txtFullName.ReadOnly = !isEditing;
            pnlUploadControls.Visible = isEditing;
            pnlPasswordBlock.Visible = isEditing;
            pnlAvatarOverlay.Visible = isEditing;

            btnEditToggle.Visible = !isEditing;
            btnSaveChanges.Visible = isEditing;
            btnCancelEdit.Visible = isEditing;

            lblStatus.Visible = false;

            string standardStyle = "w-full bg-gray-50 p-3 text-sm rounded-xl border border-gray-200 outline-none text-gray-700 transition-all font-medium";
            string editingStyle = "w-full bg-white p-3 text-sm rounded-xl border border-gray-300 focus:border-[#0095FD] focus:ring-2 focus:ring-[#0095FD]/20 outline-none text-gray-700 transition-all font-medium shadow-sm";

            txtFullName.CssClass = isEditing ? editingStyle : standardStyle;
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            lblStatus.BackColor = isSuccess ? System.Drawing.Color.FromArgb(240, 253, 244) : System.Drawing.Color.FromArgb(254, 242, 242);
            lblStatus.ForeColor = isSuccess ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed;
            lblStatus.Visible = true;
        }
    }
}