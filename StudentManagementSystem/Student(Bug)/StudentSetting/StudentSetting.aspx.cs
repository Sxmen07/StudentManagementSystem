using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystems.Student
{
    public partial class StudentSetting : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
            {
                Response.Redirect("/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProfile();
                uploadContainer.Visible = false; // initially hidden
            }
            else
            {
                // Maintain the state of upload container depending on if we are editing
                uploadContainer.Visible = btnSave.Visible;
            }
        }

        void LoadProfile()
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();

                string query = @"
                    SELECT S.*, Sem.Semester AS SemesterName, P.ProgrammeName 
                    FROM Student S
                    INNER JOIN Programme P ON S.ProgrammeCode = P.ProgrammeCode
                    INNER JOIN Semester Sem ON S.SemesterID = Sem.SemesterID
                    WHERE S.StudentEmail = @Email";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            txtStudentID.Text = dr["StudentID"].ToString();
                            txtStudentName.Text = dr["StudentName"].ToString();
                            txtStudentEmail.Text = dr["StudentEmail"].ToString();

                            string password = dr["Password"].ToString();
                            txtPassword.Text = password;
                            hdnPassword.Value = password;

                            txtPersonalEmail.Text = dr["PersonalEmail"]?.ToString();
                            txtContactNumber.Text = dr["ContactNo"]?.ToString();
                            txtProgrammeCode.Text = dr["ProgrammeCode"]?.ToString();
                            txtProgrammeName.Text = dr["ProgrammeName"]?.ToString();
                            txtIntakeSemester.Text = dr["SemesterName"]?.ToString();
                            txtIntakeYear.Text = dr["IntakeYear"]?.ToString();

                            // Load profile photo path safely
                            string photoPath = dr["ProfilePhotoPath"]?.ToString();
                            if (!string.IsNullOrEmpty(photoPath) && System.IO.File.Exists(Server.MapPath(photoPath)))
                            {
                                ProfilePicture.ImageUrl = photoPath + "?t=" + DateTime.Now.Ticks;
                            }
                            else
                            {
                                ProfilePicture.ImageUrl = "/Images/default-avatar.png?t=" + DateTime.Now.Ticks;
                            }
                            hdnPhotoPath.Value = photoPath;
                        }
                    }
                }
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            // Enable editable fields
            txtPersonalEmail.Enabled = true;
            txtPassword.Enabled = true;
            txtPassword.TextMode = TextBoxMode.SingleLine;
            txtPassword.Text = hdnPassword.Value;
            txtContactNumber.Enabled = true;

            btnSave.Visible = true;
            btnCancel.Visible = true;
            btnEdit.Visible = false;
            lblMessage.Text = "";
            uploadContainer.Visible = true;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
            {
                Response.Redirect("/Login.aspx");
                return;
            }

            string email = Session["UserEmail"].ToString();
            string relativeUrl = hdnPhotoPath.Value; // Keep the existing image path as default

            // 1. Check and handle file upload dynamically within the save action
            if (fileUpload.HasFile)
            {
                string ext = System.IO.Path.GetExtension(fileUpload.FileName).ToLower();
                if (ext != ".jpg" && ext != ".jpeg" && ext != ".png")
                {
                    lblMessage.Text = "Only JPG, JPEG, and PNG files are allowed.";
                    lblMessage.CssClass = "block mb-4 text-center p-2 rounded bg-red-100 text-red-700";
                    return;
                }

                try
                {
                    string folderPath = Server.MapPath("~/Uploads/ProfilePhotos/");
                    if (!System.IO.Directory.Exists(folderPath))
                    {
                        System.IO.Directory.CreateDirectory(folderPath);
                    }

                    int studentId = GetStudentId(email);
                    string fileName = $"student_{studentId}_{DateTime.Now:yyyyMMddHHmmss}{ext}";
                    string savePath = System.IO.Path.Combine(folderPath, fileName);

                    fileUpload.SaveAs(savePath);
                    relativeUrl = $"/Uploads/ProfilePhotos/{fileName}";
                    hdnPhotoPath.Value = relativeUrl;
                }
                catch (Exception ex)
                {
                    lblMessage.Text = "File upload failed: " + ex.Message;
                    lblMessage.CssClass = "block mb-4 text-center p-2 rounded bg-red-100 text-red-700";
                    return;
                }
            }

            // 2. Perform the single structural SQL update 
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = @"
                    UPDATE Student 
                    SET PersonalEmail = @PersonalEmail, 
                        Password = @Password, 
                        ContactNo = @ContactNo,
                        ProfilePhotoPath = @ProfilePhotoPath
                    WHERE StudentEmail = @Email";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@PersonalEmail", txtPersonalEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@Password", txtPassword.Text.Trim());
                    cmd.Parameters.AddWithValue("@ContactNo", txtContactNumber.Text.Trim());

                    if (string.IsNullOrEmpty(relativeUrl))
                        cmd.Parameters.AddWithValue("@ProfilePhotoPath", DBNull.Value);
                    else
                        cmd.Parameters.AddWithValue("@ProfilePhotoPath", relativeUrl);

                    cmd.Parameters.AddWithValue("@Email", email);

                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        hdnPassword.Value = txtPassword.Text.Trim();

                        // Switch back fields to read-only mode
                        txtPersonalEmail.Enabled = false;
                        txtPassword.Enabled = false;
                        txtPassword.TextMode = TextBoxMode.Password;
                        txtContactNumber.Enabled = false;

                        btnSave.Visible = false;
                        btnCancel.Visible = false;
                        btnEdit.Visible = true;
                        uploadContainer.Visible = false;

                        // Force fully refreshing the page to apply new image string across the Master Navigation layout
                        Response.Redirect(Request.RawUrl);
                    }
                    else
                    {
                        lblMessage.Text = "Error updating profile. Please try again.";
                        lblMessage.CssClass = "block mb-4 text-center p-2 rounded bg-red-100 text-red-700";
                    }
                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            LoadProfile();

            txtPassword.TextMode = TextBoxMode.Password;

            txtPersonalEmail.Enabled = false;
            txtPassword.Enabled = false;
            txtContactNumber.Enabled = false;

            btnEdit.Visible = true;
            btnSave.Visible = false;
            btnCancel.Visible = false;

            lblMessage.Text = "";
            uploadContainer.Visible = false;
        }

        private int GetStudentId(string email)
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT StudentID FROM Student WHERE StudentEmail = @Email", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
        }
    }
}