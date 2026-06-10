using System;
using System.Data.SqlClient;
using System.Configuration;

namespace StudentManagementSystem
{
    public partial class Login : System.Web.UI.Page
    {
        // Replace this connection string with your local machine's SQL details
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Clear any old session data when the user visits the login page
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

                    // 1. Check if the user is a Head of Programme (Admin)
                    string hopQuery = "SELECT UserRole, HopName FROM HeadofProgramme WHERE HopEmail = @Email AND Password = @Password";
                    using (SqlCommand cmd = new SqlCommand(hopQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password); // Note: Hash this later if required
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["Username"] = reader["HopName"].ToString();
                                Session["UserRole"] = reader["UserRole"].ToString(); // Will be 'Admin'
                                Response.Redirect("AdminDashboard.aspx");
                                return;
                            }
                        }
                    }

                    // 2. Check if the user is a Lecturer
                    string lecQuery = "SELECT UserRole, LecturerName FROM Lecturer WHERE LecturerEmail = @Email AND Password = @Password";
                    using (SqlCommand cmd = new SqlCommand(lecQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["Username"] = reader["LecturerName"].ToString();
                                Session["UserRole"] = reader["UserRole"].ToString();
                                Response.Redirect("LecturerDashboard.aspx"); // Or wherever your team sends lecturers
                                return;
                            }
                        }
                    }

                    // 3. Check if the user is a Student
                    string studQuery = "SELECT UserRole, StudentName FROM Student WHERE StudentEmail = @Email AND Password = @Password";
                    using (SqlCommand cmd = new SqlCommand(studQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["Username"] = reader["StudentName"].ToString();
                                Session["UserRole"] = reader["UserRole"].ToString();
                                Response.Redirect("StudentDashboard.aspx");
                                return;
                            }
                        }
                    }

                    // If it loops through all three and finds nothing:
                    lblError.Text = "Invalid email or password.";
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