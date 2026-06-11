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
            // Protect page against unauthenticated access attempts
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
            if (role == "Admin") query = "SELECT HopID AS ID, HopName AS Name, HopEmail AS Email, ProfilePictureUrl FROM HeadofProgramme WHERE HopID = @ID";
            else if (role == "Lecturer") query = "SELECT LecturerID AS ID, LecturerName AS Name, LecturerEmail AS Email, ProfilePictureUrl FROM Lecturer WHERE LecturerID = @ID";
            else if (role == "Student") query = "SELECT StudentID AS ID, StudentName AS Name, StudentEmail AS Email, ProfilePictureUrl FROM Student WHERE StudentID = @ID";

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

                                // Load uploaded avatar file tracker path, or fall back to default design asset icon
                                string picUrl = reader["ProfilePictureUrl"].ToString();
                                imgAvatar.ImageUrl = !string.IsNullOrEmpty(picUrl) ? picUrl : "~/profile_upload/default-avatar.jpg";
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
            // Enable text box entries for updating modifications
            txtFullName.ReadOnly = false;
            txtFullName.CssClass = "w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors";

            txtEmail.ReadOnly = false;
            txtEmail.CssClass = "w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors";

            // Unveil file target upload panels
            pnlPhotoUpload.Visible = true;
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

            string avatarPath = imgAvatar.ImageUrl;

            // Handle file profile upload stream transactions
            if (fuAvatar.HasFile)
            {
                try
                {
                    string ext = Path.GetExtension(fuAvatar.FileName).ToLower();
                    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
                    {
                        // Ensure an upload storage folder directory exists safely in local system directory tracks
                        string folderPath = Server.MapPath("~/Uploads/");
                        if (!Directory.Exists(folderPath))
                        {
                            Directory.CreateDirectory(folderPath);
                        }

                        // Save file tracking name configuration uniquely using internal ID patterns to prevent asset collisions
                        string fileName = role + "_" + userId + ext;
                        string savePath = folderPath + fileName;
                        fuAvatar.SaveAs(savePath);

                        avatarPath = "~/Uploads/" + fileName;
                    }
                    else
                    {
                        ShowStatus("Validation block: Only image asset extension files (.jpg, .jpeg, .png) are supported.", false);
                        return;
                    }
                }
                catch (Exception ex)
                {
                    ShowStatus("Asset deployment streaming engine failure: " + ex.Message, false);
                    return;
                }
            }

            // Route dynamic profile modifications save streams back to respective schemas
            string query = "";
            if (role == "Admin")
            {
                query = !string.IsNullOrEmpty(password)
                    ? "UPDATE HeadofProgramme SET HopName = @Name, HopEmail = @Email, Password = @Password, ProfilePictureUrl = @Pic WHERE HopID = @ID"
                    : "UPDATE HeadofProgramme SET HopName = @Name, HopEmail = @Email, ProfilePictureUrl = @Pic WHERE HopID = @ID";
            }
            else if (role == "Lecturer")
            {
                query = !string.IsNullOrEmpty(password)
                    ? "UPDATE Lecturer SET LecturerName = @Name, LecturerEmail = @Email, Password = @Password, ProfilePictureUrl = @Pic WHERE LecturerID = @ID"
                    : "UPDATE Lecturer SET LecturerName = @Name, LecturerEmail = @Email, ProfilePictureUrl = @Pic WHERE LecturerID = @ID";
            }
            else if (role == "Student")
            {
                query = !string.IsNullOrEmpty(password)
                    ? "UPDATE Student SET StudentName = @Name, StudentEmail = @Email, Password = @Password, ProfilePictureUrl = @Pic WHERE StudentID = @ID"
                    : "UPDATE Student SET StudentName = @Name, StudentEmail = @Email, ProfilePictureUrl = @Pic WHERE StudentID = @ID";
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Pic", avatarPath);
                    cmd.Parameters.AddWithValue("@ID", userId);
                    if (!string.IsNullOrEmpty(password))
                    {
                        cmd.Parameters.AddWithValue("@Password", password);
                    }

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();

                        // Sync localized layout view vectors
                        ShowStatus("Profile structural details synchronized safely!", true);
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
            txtFullName.CssClass = "w-full bg-zinc-100 p-2.5 text-sm rounded border border-[#EBEBE9] outline-none text-[#2F2F2F]";

            txtEmail.ReadOnly = true;
            txtEmail.CssClass = "w-full bg-zinc-100 p-2.5 text-sm rounded border border-[#EBEBE9] outline-none text-[#2F2F2F]";

            pnlPhotoUpload.Visible = false;
            pnlPasswordBlock.Visible = false;
            btnSaveChanges.Visible = false;
            btnCancelEdit.Visible = false;
            btnEditToggle.Visible = true;
            lblStatus.Visible = false;
            txtPassword.Text = "";
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