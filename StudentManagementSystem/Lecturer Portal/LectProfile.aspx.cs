using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace LecturerPortal
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null) Response.Redirect("Login.aspx");

            lblSidebarName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                LoadProfile();
                SetViewMode(); // Always start in view mode
            }
        }

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

        // Lock all fields — view only
        private void SetViewMode()
        {
            txtName.ReadOnly = true;
            txtEmail.ReadOnly = true;
            txtContact.ReadOnly = true;
            txtDepartment.ReadOnly = true;
            txtPassword.ReadOnly = true;

            // Style them as view fields
            txtName.CssClass = "field-input";
            txtEmail.CssClass = "field-input";
            txtContact.CssClass = "field-input";
            txtDepartment.CssClass = "field-input";
            txtPassword.CssClass = "field-input";

            btnEdit.Visible = true;
            btnSave.Visible = false;
            btnCancel.Visible = false;
        }

        // Unlock all fields — edit mode
        private void SetEditMode()
        {
            txtName.ReadOnly = false;
            txtEmail.ReadOnly = false;
            txtContact.ReadOnly = false;
            txtDepartment.ReadOnly = false;
            txtPassword.ReadOnly = false;

            btnEdit.Visible = false;
            btnSave.Visible = true;
            btnCancel.Visible = true;

            lblEditNotice.Text = "⚠ You are now in edit mode. Make your changes and click Save.";
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            lblStatus.Text = "";
            SetEditMode();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string query;
            SqlParameter[] parameters;

            if (!string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                query = @"UPDATE Lecturer SET
                            LecturerName = @Name,
                            LecturerEmail = @Email,
                            Password = @Password,
                            ContactNo = @Contact,
                            Department = @Dept
                          WHERE LecturerID = @ID";

                parameters = new SqlParameter[] {
                    new SqlParameter("@Name",     txtName.Text.Trim()),
                    new SqlParameter("@Email",    txtEmail.Text.Trim()),
                    new SqlParameter("@Password", txtPassword.Text),
                    new SqlParameter("@Contact",  txtContact.Text.Trim()),
                    new SqlParameter("@Dept",     txtDepartment.Text.Trim()),
                    new SqlParameter("@ID",       Session["LecturerID"])
                };
            }
            else
            {
                query = @"UPDATE Lecturer SET
                            LecturerName = @Name,
                            LecturerEmail = @Email,
                            ContactNo = @Contact,
                            Department = @Dept
                          WHERE LecturerID = @ID";

                parameters = new SqlParameter[] {
                    new SqlParameter("@Name",    txtName.Text.Trim()),
                    new SqlParameter("@Email",   txtEmail.Text.Trim()),
                    new SqlParameter("@Contact", txtContact.Text.Trim()),
                    new SqlParameter("@Dept",    txtDepartment.Text.Trim()),
                    new SqlParameter("@ID",      Session["LecturerID"])
                };
            }

            DBHelper.ExecuteNonQuery(query, parameters);
            Session["LecturerName"] = txtName.Text.Trim();
            lblSidebarName.Text = txtName.Text.Trim();

            lblStatus.Text = "✔ Profile updated successfully!";
            SetViewMode(); // Return to view mode after saving
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            // Reload from DB to discard any typed changes
            LoadProfile();
            lblStatus.Text = "";
            SetViewMode();
        }
    }
}