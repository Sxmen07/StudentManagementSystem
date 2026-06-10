using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class AdminInbox : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                BindInboxMessages();
            }
        }

        private void BindInboxMessages()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Pulling MessageID so the DataKeyNames grid array tracks item references precisely
                string query = "SELECT MessageID, SenderEmail, Subject, MessageText, SubmissionDate FROM AdminMessage ORDER BY SubmissionDate DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvAdminInbox.DataSource = dt;
                            gvAdminInbox.DataBind();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error connecting to message logs: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        // =========================================================================
        // PROCESS SOLVED ITEMS BATCH DELETION
        // =========================================================================
        protected void btnMarkSolved_Click(object sender, EventArgs e)
        {
            int solvedCount = 0;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string deleteQuery = "DELETE FROM AdminMessage WHERE MessageID = @MessageID";

                try
                {
                    conn.Open();

                    // Loop through each row in the GridView interface
                    foreach (GridViewRow row in gvAdminInbox.Rows)
                    {
                        CheckBox chk = (CheckBox)row.FindControl("chkSelect");

                        // If the row checkbox is checked, extract its DataKey ID and delete it
                        if (chk != null && chk.Checked)
                        {
                            int messageId = Convert.ToInt32(gvAdminInbox.DataKeys[row.RowIndex].Value);

                            using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                            {
                                cmd.Parameters.Clear();
                                cmd.Parameters.AddWithValue("@MessageID", messageId);
                                cmd.ExecuteNonQuery();
                                solvedCount++;
                            }
                        }
                    }

                    if (solvedCount > 0)
                    {
                        ShowStatus($"Successfully resolved and cleared {solvedCount} support ticket(s) from the log registry.", true);
                        BindInboxMessages(); // Re-bind grid data to drop the deleted records out of view
                    }
                    else
                    {
                        ShowStatus("No tickets were selected. Please check the boxes of the issues you have completed.", false);
                    }
                }
                catch (Exception ex)
                {
                    ShowStatus("An error occurred while cleaning rows: " + ex.Message, false);
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            if (isSuccess)
            {
                lblStatus.ForeColor = System.Drawing.Color.MediumSeaGreen;
                lblStatus.BackColor = System.Drawing.Color.FromArgb(240, 253, 244);
            }
            else
            {
                lblStatus.ForeColor = System.Drawing.Color.OrangeRed;
                lblStatus.BackColor = System.Drawing.Color.FromArgb(254, 242, 242);
            }
            lblStatus.Visible = true;
        }
    }
}