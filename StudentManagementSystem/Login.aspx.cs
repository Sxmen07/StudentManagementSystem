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
                    // ADDED: HopID added to the SELECT query
                    string hopQuery = "SELECT HopID, UserRole, HopName FROM HeadofProgramme WHERE HopEmail = @Email AND Password = @Password";
                    using (SqlCommand cmd = new SqlCommand(hopQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // ADDED: Saving the ID into Session["UserID"]
                                Session["UserID"] = reader["HopID"].ToString();
                                Session["Username"] = reader["HopName"].ToString();
                                Session["UserRole"] = reader["UserRole"].ToString(); // Will be 'Admin'
                                Response.Redirect("AdminDashboard.aspx");
                                return;
                            }
                        }
                    }

                    // 2. Check if the user is a Lecturer
                    // ADDED: LecturerID added to the SELECT query
                    string lecQuery = "SELECT LecturerID, UserRole, LecturerName FROM Lecturer WHERE LecturerEmail = @Email AND Password = @Password";
                    using (SqlCommand cmd = new SqlCommand(lecQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // ADDED: Saving the ID into Session["UserID"]
                                Session["UserID"] = reader["LecturerID"].ToString();
                                Session["Username"] = reader["LecturerName"].ToString();
                                Session["UserRole"] = reader["UserRole"].ToString();
                                Response.Redirect("LecturerDashboard.aspx");
                                return;
                            }
                        }
                    }

                    // 3. Check if the user is a Student
                    // ADDED: StudentID added to the SELECT query
                    string studQuery = "SELECT StudentID, UserRole, StudentName FROM Student WHERE StudentEmail = @Email AND Password = @Password";
                    using (SqlCommand cmd = new SqlCommand(studQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", username);
                        cmd.Parameters.AddWithValue("@Password", password);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // ADDED: Saving the ID into Session["UserID"]
                                Session["UserID"] = reader["StudentID"].ToString();
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