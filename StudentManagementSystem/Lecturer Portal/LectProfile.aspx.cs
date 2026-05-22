using System;
using System.Data;
using System.Data.SqlClient;

namespace LecturerPortal
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null) Response.Redirect("Login.aspx");
            lblWelcome.Text = Session["LecturerName"]?.ToString();
            if (!IsPostBack) LoadProfile();
        }

        //Load lecturer profile
        private void LoadProfile()
        {
            string query = "SELECT * FROM Lecturer WHERE LecturerID = @ID";
            SqlParameter[] p = { new SqlParameter("@ID", Session["LecturerID"]) };
            DataTable dt = DBHelper.ExecuteQuery(query, p);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                txtName.Text = row["LecturerName"].ToString();
                txtEmail.Text = row["LecturerEmail"].ToString();
                txtContact.Text = row["ContactNo"].ToString();
                txtDepartment.Text = row["Department"].ToString();
            }
        }

        //Update profile with optional password change
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string query;
            SqlParameter[] parameters;

            if (!string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                query = @"UPDATE Lecturer SET 
                            LecturerName=@Name, LecturerEmail=@Email,
                            Password=@Password, ContactNo=@Contact, Department=@Dept
                          WHERE LecturerID=@ID";

                parameters = new SqlParameter[] {
                    new SqlParameter("@Name",     txtName.Text),
                    new SqlParameter("@Email",    txtEmail.Text),
                    new SqlParameter("@Password", txtPassword.Text),
                    new SqlParameter("@Contact",  txtContact.Text),
                    new SqlParameter("@Dept",     txtDepartment.Text),
                    new SqlParameter("@ID",       Session["LecturerID"])
                };
            }
            else
            //No password change
            {
                query = @"UPDATE Lecturer SET 
                            LecturerName=@Name, LecturerEmail=@Email,
                            ContactNo=@Contact, Department=@Dept
                          WHERE LecturerID=@ID";

                parameters = new SqlParameter[] {
                    new SqlParameter("@Name",    txtName.Text),
                    new SqlParameter("@Email",   txtEmail.Text),
                    new SqlParameter("@Contact", txtContact.Text),
                    new SqlParameter("@Dept",    txtDepartment.Text),
                    new SqlParameter("@ID",      Session["LecturerID"])
                };
            }

            //Execute update
            DBHelper.ExecuteNonQuery(query, parameters);
            Session["LecturerName"] = txtName.Text;
            lblWelcome.Text = txtName.Text;
            lblStatus.Text = "✔ Profile updated successfully!";
        }
    }
}