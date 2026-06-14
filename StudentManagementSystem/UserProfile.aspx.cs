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
                                // Matches your original frontend ASP:TextBox control IDs exactly
                                txtUserID.Text = reader["ID"].ToString();
                                txtRole.Text = role;
                                txtFullName.Text = reader["Name"].ToString();
                                txtEmail.Text = reader["Email"].ToString();

                                // Matches your frontend text placeholder controls
                                lblDisplayHeaderName.Text = reader["Name"].ToString();
                                litBadgeRole.Text = role;
                                litSubHeaderTitle.Text = role + " Account Workspace";

                                // Safe DBNull string conversion for the avatar image path
                                string picUrl = Convert.ToString(reader["ProfilePictureUrl"]);
                                imgAvatar.ImageUrl = !string.IsNullOrWhiteSpace(picUrl)
                                    ? ResolveUrl(picUrl)
                                    : ResolveUrl("~/profile_upload/default-avatar.jpg");

                                // Safe background banner assignment logic
                                string bannerUrl = Convert.ToString(reader["BannerPictureUrl"]);
                                if (!string.IsNullOrWhiteSpace(bannerUrl))
                                {
                                    pnlBannerBackground.BackImageUrl = ResolveUrl(bannerUrl);
                                }
                                else
                                {
                                    pnlBannerBackground.BackImageUrl = "";
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

            // Locked securely to your profile_upload folder path
            string targetVirtualFolder = "~/profile_upload/";
            string physicalFolderPath = Server.MapPath(targetVirtualFolder);

            try
            {
                if (!Directory.Exists(physicalFolderPath))
                {
                    Directory.CreateDirectory(physicalFolderPath);
                }

                string dbAvatarPath = null;
                string dbBannerPath = null;

                // Process your avatar file input upload
                if (fuAvatar.HasFile)
                {
                    string ext = Path.GetExtension(fuAvatar.FileName).ToLower();
                    string fileName = "Avatar_" + role + "_" + userId + ext;
                    string fullPhysicalSavePath = Path.Combine(physicalFolderPath, fileName);

                    fuAvatar.SaveAs(fullPhysicalSavePath);
                    dbAvatarPath = targetVirtualFolder + fileName;
                }

                // Process your original background file input upload (fuBackground)
                if (fuBackground.HasFile)
                {
                    string ext = Path.GetExtension(fuBackground.FileName).ToLower();
                    string fileName = "Banner_" + role + "_" + userId + ext;
                    string fullPhysicalSavePath = Path.Combine(physicalFolderPath, fileName);

                    fuBackground.SaveAs(fullPhysicalSavePath);
                    dbBannerPath = targetVirtualFolder + fileName;
                }

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    string queryBase = "";
                    if (role == "Admin")
                    {
                        queryBase = "UPDATE HeadofProgramme SET HopName = @Name {0} WHERE HopID = @ID";
                    }
                    else if (role == "Lecturer")
                    {
                        queryBase = "UPDATE Lecturer SET LecturerName = @Name {0} WHERE LecturerID = @ID";
                    }
                    else if (role == "Student")
                    {
                        queryBase = "UPDATE Student SET StudentName = @Name {0} WHERE StudentID = @ID";
                    }

                    string appends = "";
                    if (dbAvatarPath != null) appends += ", ProfilePictureUrl = @Avatar";
                    if (dbBannerPath != null) appends += ", BannerPictureUrl = @Banner";
                    if (!string.IsNullOrWhiteSpace(newPassword)) appends += ", Password = @Password";

                    string finalQuery = string.Format(queryBase, appends);

                    using (SqlCommand cmd = new SqlCommand(finalQuery, conn))
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
                ShowStatus("System save failure: " + ex.Message, false);
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