using System;
using System.Data.SqlClient;
using System.Configuration;

namespace StudentManagementSystem
{
    public partial class Login : System.Web.UI.Page
    {
        // Replace this connection string with your local machine's SQL details
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=SE_Assignment;Trusted_Connection=True;";

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

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Please fill in all fields.";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Select both the password and the role assigned by the admin
                string query = "SELECT Role FROM Users WHERE Username = @Username AND Password = @Password";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Username", username);
                cmd.Parameters.AddWithValue("@Password", password); // In production, hash this!

                try
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar(); // Gets the first column (Role) if found

                    if (result != null)
                    {
                        string userRole = result.ToString();

                        // SECURITY: Store user details securely on the server
                        Session["Username"] = username;
                        Session["UserRole"] = userRole;

                        // ROLE-BASED ROUTING: Direct to respective dashboards
                        if (userRole == "Admin")
                        {
                            Response.Redirect("AdminDashboard.aspx");
                        }
                        else if (userRole == "Student")
                        {
                            Response.Redirect("StudentDashboard.aspx");
                        }
                        else if (userRole == "Lecturer")
                        {
                            Response.Redirect("LecturerDashboard.aspx");
                        }
                    }
                    else
                    {
                        lblError.Text = "Invalid username or password.";
                    }
                }
                catch (Exception ex)
                {
                    lblError.Text = "Database Error: " + ex.Message;
                }
            }
        }
    }
}