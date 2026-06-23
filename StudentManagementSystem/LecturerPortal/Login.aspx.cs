using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace LecturerPortal
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        //Button click
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                string email = txtEmail.Text.Trim();
                string password = txtPassword.Text.Trim();

                string query = @"SELECT LecturerID, LecturerName, Department 
                                 FROM Lecturer 
                                 WHERE LecturerEmail = @Email 
                                 AND Password = @Password";

                SqlParameter[] parameters = {
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Password", password)
                };

            //Execute query
                DataTable dt = DBHelper.ExecuteQuery(query, parameters);

                if (dt.Rows.Count > 0)
                {
                //Store lecturer info in session
                    Session["LecturerID"] = dt.Rows[0]["LecturerID"].ToString();
                    Session["LecturerName"] = dt.Rows[0]["LecturerName"].ToString();
                    Session["Department"] = dt.Rows[0]["Department"].ToString();
                    Response.Redirect("LectProfile.aspx");
                }
                else
                {
                    lblError.Text = "Invalid email or password.";
                    lblError.Visible = true;
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Error: " + ex.Message;
                lblError.Visible = true;
            }
        }
    }
}