using System;
using System.Data.SqlClient;
using System.Configuration;

namespace StudentManagementSystem
{
    public partial class Login : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Session.Clear();
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            {
                lblError.Text = "Please enter both credentials.";
                lblError.Visible = true;
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();

                    // =========================================================================
                    // 1. TIER 1 CHECK: HEAD OF PROGRAMME (ADMIN) VALIDATION
                    // =========================================================================
                    string hopQuery = @"
                        SELECT HopID, UserRole, HopName FROM HeadofProgramme 
                        WHERE HopEmail = @Email 
                        AND (
                            Password = @Password 
                            OR (ResetToken = @Password AND ResetTokenExpiresAt >= GETDATE())
                        )";

                    using (SqlCommand cmd = new SqlCommand(hopQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["UserID"] = reader["HopID"].ToString();
                                Session["Username"] = reader["HopName"].ToString();
                                Session["UserRole"] = reader["UserRole"].ToString();

                                Response.Redirect("AdminDashboard.aspx");
                                return;
                            }
                        }
                    }

                    // =========================================================================
                    // 2. TIER 2 CHECK: LECTURER VALIDATION
                    // =========================================================================
                    string lecQuery = @"
                        SELECT LecturerID, UserRole, LecturerName FROM Lecturer 
                        WHERE LecturerEmail = @Email 
                        AND (
                            Password = @Password 
                            OR (ResetToken = @Password AND ResetTokenExpiresAt >= GETDATE())
                        )";

                    using (SqlCommand cmd = new SqlCommand(lecQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["LecturerID"] = reader["LecturerID"].ToString();
                                Session["UserID"] = reader["LecturerID"].ToString();
                                Session["Username"] = reader["LecturerName"].ToString();
                                Session["UserRole"] = reader["UserRole"].ToString();

                                Response.Redirect("~/LecturerPortal/LectDashboard.aspx");
                                return;
                            }
                        }
                    }

                    // =========================================================================
                    // 3. TIER 3 CHECK: STUDENT VALIDATION
                    // =========================================================================
                    string studQuery = @"
                        SELECT StudentID, UserRole, StudentName FROM Student 
                        WHERE StudentEmail = @Email 
                        AND (
                            Password = @Password 
                            OR (ResetToken = @Password AND ResetTokenExpiresAt >= GETDATE())
                        )";

                    using (SqlCommand cmd = new SqlCommand(studQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["StudentID"] = reader["StudentID"].ToString();
                                Session["UserID"] = reader["StudentID"].ToString();
                                Session["Username"] = reader["StudentName"].ToString();
                                Session["UserRole"] = reader["UserRole"].ToString();
                                Session["UserEmail"] = username;

                                Response.Redirect("~/Student/StudentDashboard/StudentDashboard.aspx");
                                return;
                            }
                        }
                    }

                    // If credentials fail both password and temporary token checks:
                    lblError.Text = "Invalid email or password / temporary token may have expired.";
                    lblError.Visible = true;
                }
                catch (Exception ex)
                {
                    lblError.Text = "Database Error: " + ex.Message;
                    lblError.Visible = true;
                }
            }
        }
    }
}