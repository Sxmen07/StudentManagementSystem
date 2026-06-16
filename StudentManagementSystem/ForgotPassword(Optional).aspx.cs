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
                txtRecoveryEmail.Focus(); //
            }
        }

        protected void btnResetRequest_Click(object sender, EventArgs e)
        {
            string email = txtRecoveryEmail.Text.Trim(); //
            string identityNo = txtIdentityNumber.Text.Trim(); //
            lblStatus.Visible = false; //
            pnlSuccessDetails.Visible = false; //
            pnlFormFields.Visible = true; //

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(identityNo)) //
            {
                ShowStatus("Verification blocked: Please fill in both your email and IC/Passport number.", false); //
                return;
            }

            // Generate an 8-character numeric security token
            string tempToken = CreateRandomNumericToken(8);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open(); //
                    bool accountFound = false; //

                    // =========================================================================
                    // TIER 1: SCAN STUDENT INDEX (Sets token expiration window strictly to 120 seconds)
                    // =========================================================================
                    string checkStudent = "SELECT COUNT(1) FROM Student WHERE StudentEmail = @Email AND IdentityNumber = @IDNum"; //
                    using (SqlCommand cmd = new SqlCommand(checkStudent, conn)) //
                    {
                        cmd.Parameters.AddWithValue("@Email", email); //
                        cmd.Parameters.AddWithValue("@IDNum", identityNo); //
                        int count = Convert.ToInt32(cmd.ExecuteScalar()); //
                        if (count > 0) //
                        {
                            // RESTRICTION UPGRADE: Storing token and adding a strict 120 seconds expiration timestamp matrix window
                            string updateStudent = "UPDATE Student SET ResetToken = @Token, ResetTokenExpiresAt = DATEADD(second, 120, GETDATE()) WHERE StudentEmail = @Email";
                            using (SqlCommand updateCmd = new SqlCommand(updateStudent, conn))
                            {
                                updateCmd.Parameters.AddWithValue("@Token", tempToken);
                                updateCmd.Parameters.AddWithValue("@Email", email);
                                updateCmd.ExecuteNonQuery();
                            }
                            accountFound = true; //
                        }
                    }

                    // =========================================================================
                    // TIER 2: SCAN LECTURER INDEX
                    // =========================================================================
                    if (!accountFound) //
                    {
                        string checkLecturer = "SELECT COUNT(1) FROM Lecturer WHERE LecturerEmail = @Email AND IdentityNumber = @IDNum"; //
                        using (SqlCommand cmd = new SqlCommand(checkLecturer, conn)) //
                        {
                            cmd.Parameters.AddWithValue("@Email", email); //
                            cmd.Parameters.AddWithValue("@IDNum", identityNo); //
                            int count = Convert.ToInt32(cmd.ExecuteScalar()); //
                            if (count > 0) //
                            {
                                string updateLecturer = "UPDATE Lecturer SET ResetToken = @Token, ResetTokenExpiresAt = DATEADD(second, 120, GETDATE()) WHERE LecturerEmail = @Email";
                                using (SqlCommand updateCmd = new SqlCommand(updateLecturer, conn))
                                {
                                    updateCmd.Parameters.AddWithValue("@Token", tempToken);
                                    updateCmd.Parameters.AddWithValue("@Email", email);
                                    updateCmd.ExecuteNonQuery();
                                }
                                accountFound = true; //
                            }
                        }
                    }

                    // =========================================================================
                    // TIER 3: SCAN HEAD OF PROGRAMME (ADMIN) INDEX
                    // =========================================================================
                    if (!accountFound) //
                    {
                        string checkAdmin = "SELECT COUNT(1) FROM HeadofProgramme WHERE HopEmail = @Email AND IdentityNumber = @IDNum"; //
                        using (SqlCommand cmd = new SqlCommand(checkAdmin, conn)) //
                        {
                            cmd.Parameters.AddWithValue("@Email", email); //
                            cmd.Parameters.AddWithValue("@IDNum", identityNo); //
                            int count = Convert.ToInt32(cmd.ExecuteScalar()); //
                            if (count > 0) //
                            {
                                string updateAdmin = "UPDATE HeadofProgramme SET ResetToken = @Token, ResetTokenExpiresAt = DATEADD(second, 120, GETDATE()) WHERE HopEmail = @Email";
                                using (SqlCommand updateCmd = new SqlCommand(updateAdmin, conn))
                                {
                                    updateCmd.Parameters.AddWithValue("@Token", tempToken);
                                    updateCmd.Parameters.AddWithValue("@Email", email);
                                    updateCmd.ExecuteNonQuery();
                                }
                                accountFound = true; //
                            }
                        }
                    }

                    if (accountFound) //
                    {
                        litTempPassword.Text = tempToken; //
                        pnlSuccessDetails.Visible = true; //
                        pnlFormFields.Visible = false; //

                        txtRecoveryEmail.Text = string.Empty; //
                        txtIdentityNumber.Text = string.Empty; //
                        ShowStatus("Identity verified successfully! Your temporary password is valid for exactly 120 seconds.", true);
                    }
                    else
                    {
                        ShowStatus("The provided credentials do not match any records in our registration database.", false); //
                    }
                }
                catch (Exception ex)
                {
                    ShowStatus("System processing failure: " + ex.Message, false); //
                }
            }
        }

        // Upgraded helper: Generates clean numeric OTP tokens for clear display presentation
        private string CreateRandomNumericToken(int length)
        {
            const string validChars = "0123456789";
            StringBuilder res = new StringBuilder(); //
            Random rnd = new Random(); //
            while (0 < length--) //
            {
                res.Append(validChars[rnd.Next(validChars.Length)]); //
            }
            return res.ToString(); //
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message; //
            if (isSuccess) //
            {
                lblStatus.ForeColor = System.Drawing.Color.MediumSeaGreen; //
                lblStatus.BackColor = System.Drawing.Color.FromArgb(240, 253, 244); //
            }
            else
            {
                lblStatus.ForeColor = System.Drawing.Color.OrangeRed; //
                lblStatus.BackColor = System.Drawing.Color.FromArgb(254, 242, 242); //
            }
            lblStatus.Visible = true; //
        }
    }
}