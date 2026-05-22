using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace LecturerPortal
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text.Trim();

            // Hash the password the same way it was stored
            string query = @"SELECT LecturerID, Username FROM Lecturers 
                             WHERE Email = @Email 
                             AND PasswordHash = @Password";

            SqlParameter[] parameters = {
                new SqlParameter("@Email", email),
                new SqlParameter("@Password", password)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                // Store lecturer info in session
                Session["LecturerID"] = dt.Rows[0]["LecturerID"].ToString();
                Session["Username"] = dt.Rows[0]["Username"].ToString();
                Response.Redirect("Dashboard.aspx");
            }
            else
            {
                lblError.Text = "Invalid email or password.";
                lblError.Visible = true;
            }
        }
    }
}