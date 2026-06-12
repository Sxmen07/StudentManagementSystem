using System;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

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
            }

            if (!IsPostBack)
            {
                LoadUserProfileData();
            }
        }

        private void LoadUserProfileData()
        {
            string role = Session["UserRole"].ToString();
            string userId = Session["UserID"].ToString();

            string query = "";
            if (role == "Admin") query = "SELECT HopID AS ID, HopName AS Name, HopEmail AS Email, ProfilePictureUrl, BannerPictureUrl FROM HeadofProgramme WHERE HopID = @ID";
            else if (role == "Lecturer") query = "SELECT LecturerID AS ID, LecturerName AS Name, LecturerEmail AS Email, ProfilePictureUrl, BannerPictureUrl FROM Lecturer WHERE LecturerID = @ID";
            else if (role == "Student") query = "SELECT StudentID AS ID, StudentName AS Name, StudentEmail AS Email, ProfilePictureUrl, BannerPictureUrl FROM Student WHERE StudentID = @ID";

            using (SqlConnection conn = new SqlConnection(connString))
            {
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

                                // Programmatic subheader description matching layout rules
                                litSubHeaderTitle.Text = role == "Admin" ? "Institutional Platform Administrator" : "Bachelor of Science in Software Engineering (Hons)";

                                // Bind Profile Image URL asset paths
                                string picUrl = reader["ProfilePictureUrl"].ToString();
                                imgAvatar.ImageUrl = !string.IsNullOrEmpty(picUrl) ? picUrl : "~/profile_upload/default-avatar.jpg";

                                // Render background cover elements or stream custom CSS gradient matching layout specs
                                string bannerUrl = reader["BannerPictureUrl"].ToString();
                                if (!string.IsNullOrEmpty(bannerUrl))
                                {
                                    pnlBannerBackground.Style["background-image"] = ResolveUrl(bannerUrl);
                                    pnlBannerBackground.CssClass = "w-full h-64 bg-cover bg-center relative";
                                }
                                else
                                {
                                    pnlBannerBackground.Style.Remove("background-image");
                                    pnlBannerBackground.CssClass = "w-full h-64 bg-gradient-to-r from-[#CAD9FA] via-[#E2EDF7] to-[#FFF9D3] bg-cover bg-center relative";
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowStatus("Profile processing engine failure: " + ex.Message, false);
                    }
                }
            }
        }

        protected void btnEditToggle_Click(object sender, EventArgs e)
        {
            txtFullName.ReadOnly = false;
            txtFullName.CssClass = "w-full bg-white p-3 text-sm rounded-xl border border-gray-300 focus:border-[#0095FD] focus:ring-2 focus:ring-[#0095FD]/20 outline-none text-gray-700 transition-all font-medium";

            txtEmail.ReadOnly = false;
            txtEmail.CssClass = "w-full bg-white p-3 text-sm rounded-xl border border-gray-300 focus:border-[#0095FD] focus:ring-2 focus:ring-[#0095FD]/20 outline-none text-gray-700 transition-all font-medium";

            pnlUploadControls.Visible = true;
            pnlAvatarOverlay.Visible = true;
            pnlPasswordBlock.Visible = true;
            btnSaveChanges.Visible = true;
            btnCancelEdit.Visible = true;
            btnEditToggle.Visible = false;
        }

        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            string role = Session["UserRole"].ToString();
            string userId = Session["UserID"].ToString();
            string name = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(email))
            {
                ShowStatus("Validation error: Identity label fields cannot be blank.", false);
                return;
            }

            // Retrieve old current configurations
            string avatarPath = imgAvatar.ImageUrl;
            string bannerPath = pnlBannerBackground.Style["background-image"] != null ? pnlBannerBackground.Style["background-image"].Replace("url(", "").Replace(")", "").Replace("\"", "") : "";

            // Initialize folder upload checks
            string folderPath = Server.MapPath("~/Uploads/");
            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }

            // Stream File Transaction 1: Profiling Avatar Updates
            if (fuAvatar.HasFile)
            {
                string ext = Path.GetExtension(fuAvatar.FileName).ToLower();
                if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
                {
                    string fileName = "Avatar_" + role + "_" + userId + ext;
                    fuAvatar.SaveAs(folderPath + fileName);
                    avatarPath = "~/Uploads/" + fileName;
                }
                else
                {
                    ShowStatus("Validation block: Profile photos must match .jpg, .jpeg, or .png patterns.", false);
                    return;
                }
            }

            // Stream File Transaction 2: Cover Banner Graphic Updates
            if (fuBackground.HasFile)
            {
                string ext = Path.GetExtension(fuBackground.FileName).ToLower();
                if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
                {
                    string fileName = "Banner_" + role + "_" + userId + ext;
                    fuBackground.SaveAs(folderPath + fileName);
                    bannerPath = "~/Uploads/" + fileName;
                }
                else
                {
                    ShowStatus("Validation block: Background banners must match .jpg, .jpeg, or .png patterns.", false);
                    return;
                }
            }

            // Formulate dynamic SQL string mappings
            string query = "";
            if (role == "Admin")
            {
                query = !string.IsNullOrEmpty(password)
                    ? "UPDATE HeadofProgramme SET HopName = @Name, HopEmail = @Email, Password = @Password, ProfilePictureUrl = @Pic, BannerPictureUrl = @Banner WHERE HopID = @ID"
                    : "UPDATE HeadofProgramme SET HopName = @Name, HopEmail = @Email, ProfilePictureUrl = @Pic, BannerPictureUrl = @Banner WHERE HopID = @ID";
            }
            else if (role == "Lecturer")
            {
                query = !string.IsNullOrEmpty(password)
                    ? "UPDATE Lecturer SET LecturerName = @Name, LecturerEmail = @Email, Password = @Password, ProfilePictureUrl = @Pic, BannerPictureUrl = @Banner WHERE LecturerID = @ID"
                    : "UPDATE Lecturer SET LecturerName = @Name, LecturerEmail = @Email, ProfilePictureUrl = @Pic, BannerPictureUrl = @Banner WHERE LecturerID = @ID";
            }
            else if (role == "Student")
            {
                query = !string.IsNullOrEmpty(password)
                    ? "UPDATE Student SET StudentName = @Name, StudentEmail = @Email, Password = @Password, ProfilePictureUrl = @Pic, BannerPictureUrl = @Banner WHERE StudentID = @ID"
                    : "UPDATE Student SET StudentName = @Name, StudentEmail = @Email, ProfilePictureUrl = @Pic, BannerPictureUrl = @Banner WHERE StudentID = @ID";
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Pic", avatarPath);
                    cmd.Parameters.AddWithValue("@Banner", string.IsNullOrEmpty(bannerPath) ? (object)DBNull.Value : bannerPath);
                    cmd.Parameters.AddWithValue("@ID", userId);
                    if (!string.IsNullOrEmpty(password)) cmd.Parameters.AddWithValue("@Password", password);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();

                        ShowStatus("Profile details synchronized safely!", true);
                        LockFormState();
                        LoadUserProfileData();
                    }
                    catch (Exception ex)
                    {
                        ShowStatus("Database transaction failure: " + ex.Message, false);
                    }
                }
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            LockFormState();
            LoadUserProfileData();
        }

        private void LockFormState()
        {
            txtFullName.ReadOnly = true;
            txtFullName.CssClass = "w-full bg-gray-50 p-3 text-sm rounded-xl border border-gray-200 outline-none text-gray-700 font-medium";

            txtEmail.ReadOnly = true;
            txtEmail.CssClass = "w-full bg-gray-50 p-3 text-sm rounded-xl border border-gray-200 outline-none text-gray-700 font-medium";

            pnlUploadControls.Visible = false;
            pnlAvatarOverlay.Visible = false;
            pnlPasswordBlock.Visible = false;
            btnSaveChanges.Visible = false;
            btnCancelEdit.Visible = false;
            btnEditToggle.Visible = true;
            txtPassword.Text = "";
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            lblStatus.CssClass = isSuccess
                ? "block text-sm font-medium mb-6 p-4 rounded-xl shadow-sm bg-green-50 border border-green-200 text-green-700"
                : "block text-sm font-medium mb-6 p-4 rounded-xl shadow-sm bg-red-50 border border-red-200 text-red-700";
            lblStatus.Visible = true;
        }
    }
}