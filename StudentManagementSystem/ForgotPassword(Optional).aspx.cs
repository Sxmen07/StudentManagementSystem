using System;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace StudentManagementSystem
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtRecoveryEmail.Focus();
            }
        }

        protected void btnResetRequest_Click(object sender, EventArgs e)
        {
            string email = txtRecoveryEmail.Text.Trim();
            lblStatus.Visible = false;
            pnlSuccessDetails.Visible = false;

            if (string.IsNullOrWhiteSpace(email))
            {
                ShowStatus("Please enter your registered institutional email address.", false);
                return;
            }

            string tempPassword = CreateRandomString(8);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();
                    bool accountFound = false;

                    // =========================================================================
                    // TIER 1: SCAN & UPDATE STUDENT TABLE
                    // =========================================================================
                    string checkStudent = "SELECT COUNT(1) FROM Student WHERE StudentEmail = @Email";
                    using (SqlCommand cmd = new SqlCommand(checkStudent, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        if (count > 0)
                        {
                            string updateStudent = "UPDATE Student SET Password = @NewPass WHERE StudentEmail = @Email";
                            using (SqlCommand updateCmd = new SqlCommand(updateStudent, conn))
                            {
                                updateCmd.Parameters.AddWithValue("@NewPass", tempPassword);
                                updateCmd.Parameters.AddWithValue("@Email", email);
                                updateCmd.ExecuteNonQuery();
                            }
                            accountFound = true;
                        }
                    }

                    // =========================================================================
                    // TIER 2: SCAN & UPDATE LECTURER TABLE (IF NOT A STUDENT)
                    // =========================================================================
                    if (!accountFound)
                    {
                        string checkLecturer = "SELECT COUNT(1) FROM Lecturer WHERE LecturerEmail = @Email";
                        using (SqlCommand cmd = new SqlCommand(checkLecturer, conn))
                        {
                            cmd.Parameters.AddWithValue("@Email", email);
                            int count = Convert.ToInt32(cmd.ExecuteScalar());
                            if (count > 0)
                            {
                                string updateLecturer = "UPDATE Lecturer SET Password = @NewPass WHERE LecturerEmail = @Email";
                                using (SqlCommand updateCmd = new SqlCommand(updateLecturer, conn))
                                {
                                    updateCmd.Parameters.AddWithValue("@NewPass", tempPassword);
                                    updateCmd.Parameters.AddWithValue("@Email", email);
                                    updateCmd.ExecuteNonQuery();
                                }
                                accountFound = true;
                            }
                        }
                    }

                    // =========================================================================
                    // TIER 3: SCAN & UPDATE HEAD OF PROGRAMME TABLE
                    // =========================================================================
                    if (!accountFound)
                    {
                        string checkAdmin = "SELECT COUNT(1) FROM HeadofProgramme WHERE HopEmail = @Email";
                        using (SqlCommand cmd = new SqlCommand(checkAdmin, conn))
                        {
                            cmd.Parameters.AddWithValue("@Email", email);
                            int count = Convert.ToInt32(cmd.ExecuteScalar());
                            if (count > 0)
                            {
                                string updateAdmin = "UPDATE HeadofProgramme SET Password = @NewPass WHERE HopEmail = @Email";
                                using (SqlCommand updateCmd = new SqlCommand(updateAdmin, conn))
                                {
                                    updateCmd.Parameters.AddWithValue("@NewPass", tempPassword);
                                    updateCmd.Parameters.AddWithValue("@Email", email);
                                    updateCmd.ExecuteNonQuery();
                                }
                                accountFound = true;
                            }
                        }
                    }

                    // RENDER OUTPUT STATES
                    if (accountFound)
                    {
                        litTempPassword.Text = tempPassword;
                        pnlSuccessDetails.Visible = true;
                        txtRecoveryEmail.Text = string.Empty;
                        ShowStatus("Success! Account verified.", true);
                    }
                    else
                    {
                        ShowStatus("The email address provided does not match any records in our registration database.", false);
                    }
                }
                catch (Exception ex)
                {
                    ShowStatus("System processing failure: " + ex.Message, false);
                }
            }
        }

        // Helper tracking generator engine
        private string CreateRandomString(int length)
        {
            const string validChars = "ABCDEFGHJKLMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz0123456789☀️#$";
            StringBuilder res = new StringBuilder();
            Random rnd = new Random();
            while (0 < length--)
            {
                res.Append(validChars[rnd.Next(validChars.Length)]);
            }
            return res.ToString();
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