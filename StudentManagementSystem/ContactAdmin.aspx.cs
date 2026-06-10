using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentManagementSystem
{
    public partial class ContactAdmin : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            // SECURITY REMOVED: Anyone, including guests without accounts, can access this form now!
            if (!IsPostBack)
            {
                txtSenderEmail.Focus();
            }
        }

        protected void btnSendMessage_Click(object sender, EventArgs e)
        {
            // Capturing the email input directly from the text field instead of the session state
            string senderEmail = txtSenderEmail.Text.Trim();
            string subject = txtSubject.Text.Trim();
            string msgText = txtMessage.Text.Trim();

            if (string.IsNullOrWhiteSpace(senderEmail) || string.IsNullOrWhiteSpace(subject) || string.IsNullOrWhiteSpace(msgText))
            {
                ShowStatus("All form parameters (Your Email, Subject, and Message) are strictly required.", false);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "INSERT INTO AdminMessage (SenderEmail, Subject, MessageText, SubmissionDate) VALUES (@SenderEmail, @Subject, @MessageText, @SubDate)";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SenderEmail", senderEmail);
                    cmd.Parameters.AddWithValue("@Subject", subject);
                    cmd.Parameters.AddWithValue("@MessageText", msgText);
                    cmd.Parameters.AddWithValue("@SubDate", DateTime.Now);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();

                        ShowStatus("Your support ticket has been successfully dispatched! The administrator will review your request.", true);

                        // Clear out form inputs upon completion
                        txtSenderEmail.Text = string.Empty;
                        txtSubject.Text = string.Empty;
                        txtMessage.Text = string.Empty;
                    }
                    catch (Exception ex)
                    {
                        ShowStatus("Database submission error: " + ex.Message, false);
                    }
                }
            }
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            if (isSuccess)
            {
                lblStatus.ForeColor = System.Drawing.Color.MediumSeaGreen;
                lblStatus.BackColor = System.Drawing.Color.FromArgb(240, 253, 244); // Light Emerald Background
            }
            else
            {
                lblStatus.ForeColor = System.Drawing.Color.OrangeRed;
                lblStatus.BackColor = System.Drawing.Color.FromArgb(254, 242, 242); // Light Red Background
            }
            lblStatus.Visible = true;
        }
    }
}