using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class CreateAccounts : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=SE_Assignment;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                BindUsersGrid();
            }
        }

        private void BindUsersGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT UserID, Username, Role FROM Users ORDER BY UserID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvUsers.DataSource = dt;
                        gvUsers.DataBind();
                    }
                }
            }
        }

        protected void btnCreateAccount_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtNewUsername.Text) || string.IsNullOrWhiteSpace(txtNewPassword.Text) || string.IsNullOrEmpty(ddlRole.SelectedValue))
            {
                lblStatus.Text = "All fields are required.";
                lblStatus.CssClass = "block text-xs font-medium mb-4 text-red-600";
                lblStatus.Visible = true;
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = string.IsNullOrEmpty(hfUserID.Value)
                    ? "INSERT INTO Users (Username, Password, Role) VALUES (@Username, @Password, @Role)"
                    : "UPDATE Users SET Username = @Username, Password = @Password, Role = @Role WHERE UserID = @UserID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", txtNewUsername.Text.Trim());
                    cmd.Parameters.AddWithValue("@Password", txtNewPassword.Text.Trim()); // Assignment plaintext format
                    cmd.Parameters.AddWithValue("@Role", ddlRole.SelectedValue);
                    if (!string.IsNullOrEmpty(hfUserID.Value))
                    {
                        cmd.Parameters.AddWithValue("@UserID", hfUserID.Value);
                    }

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        lblStatus.Text = string.IsNullOrEmpty(hfUserID.Value) ? "Account registered successfully!" : "Account updated successfully!";
                        lblStatus.CssClass = "block text-xs font-medium mb-4 text-green-600";
                        ClearForm();
                        BindUsersGrid();
                    }
                    catch (Exception ex)
                    {
                        lblStatus.Text = "Database Error: " + ex.Message;
                        lblStatus.CssClass = "block text-xs font-medium mb-4 text-red-600";
                    }
                    lblStatus.Visible = true;
                }
            }
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;

            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditUser")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT UserID, Username, Password, Role FROM Users WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", id);
                        conn.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                hfUserID.Value = dr["UserID"].ToString();
                                txtNewUsername.Text = dr["Username"].ToString();
                                txtNewPassword.Text = dr["Password"].ToString();
                                ddlRole.SelectedValue = dr["Role"].ToString();
                                btnCreateAccount.Text = "Update Account";
                                btnCancelAccount.Visible = true;
                                lblStatus.Visible = false;
                            }
                        }
                    }
                }
            }
            else if (e.CommandName == "DeleteUser")
            {
                // Prevent admin from deleting themselves accidentally mid-session
                if (Session["Username"] != null && Session["Username"].ToString() == gvUsers.Rows[((GridViewRow)((Button)e.CommandSource).NamingContainer).RowIndex].Cells[1].Text)
                {
                    lblStatus.Text = "Action denied: Cannot delete active session user profile.";
                    lblStatus.CssClass = "block text-xs font-medium mb-4 text-red-600";
                    lblStatus.Visible = true;
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM Users WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", id);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                ClearForm();
                BindUsersGrid();
                lblStatus.Text = "Account profile deleted successfully.";
                lblStatus.CssClass = "block text-xs font-medium mb-4 text-green-600";
                lblStatus.Visible = true;
            }
        }

        protected void btnCancelAccount_Click(object sender, EventArgs e)
        {
            ClearForm();
            lblStatus.Visible = false;
        }

        private void ClearForm()
        {
            hfUserID.Value = string.Empty;
            txtNewUsername.Text = string.Empty;
            txtNewPassword.Text = string.Empty;
            ddlRole.SelectedIndex = 0;
            btnCreateAccount.Text = "Register Account";
            btnCancelAccount.Visible = false;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}