using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class FinanceVerification : Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadPendingPayments();
        }

        private void LoadPendingPayments()
        {
            string sql = @"
                SELECT 
                    pr.PaymentID,
                    pr.ReferenceID,
                    s.StudentName,
                    sem.Semester + ' ' + CAST(pr.SemesterID AS VARCHAR) AS SemesterDisplay,
                    pr.Amount,
                    pr.PaymentDate,
                    pr.UploadDate,
                    pr.PaymentProof,
                    pr.StudentStatus,
                    pr.VerifiedStatus
                FROM PaymentRecord pr
                INNER JOIN Student s ON pr.StudentID = s.StudentID
                INNER JOIN Semester sem ON pr.SemesterID = sem.SemesterID
                WHERE pr.VerifiedStatus = 'Pending'
                ORDER BY pr.UploadDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }

            gvPayments.DataSource = dt;
            gvPayments.DataBind();
        }

        protected void gvPayments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Optionally disable buttons for rows that are already verified/rejected
                // But we only load 'Pending' so all are actionable.
            }
        }

        protected void btnAction_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string command = btn.CommandName; // "Verify" or "Reject"
            int paymentId = Convert.ToInt32(btn.CommandArgument);

            // Find the row and get the comment
            GridViewRow row = (GridViewRow)btn.NamingContainer;
            TextBox txtComment = (TextBox)row.FindControl("txtComment");
            string comment = txtComment.Text.Trim();

            string verifiedStatus = (command == "Verify") ? "Verified" : "Rejected";
            string studentStatus = (command == "Verify") ? "Success" : "Failed";

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"
                    UPDATE PaymentRecord 
                    SET VerifiedStatus = @VerifiedStatus,
                        StudentStatus = @StudentStatus,
                        VerifiedDate = GETDATE(),
                        Comments = @Comments
                    WHERE PaymentID = @PaymentID";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@VerifiedStatus", verifiedStatus);
                cmd.Parameters.AddWithValue("@StudentStatus", studentStatus);
                cmd.Parameters.AddWithValue("@Comments", string.IsNullOrEmpty(comment) ? (object)DBNull.Value : comment);
                cmd.Parameters.AddWithValue("@PaymentID", paymentId);
                cmd.ExecuteNonQuery();

                // If verified, optionally update InvoiceReceipt
                if (command == "Verify")
                {
                    // Update InvoiceReceipt if exists for this student and semester
                    string updateInvoice = @"
                        UPDATE InvoiceReceipt 
                        SET PaymentStatus = 'PAID'
                        WHERE StudentID = (SELECT StudentID FROM PaymentRecord WHERE PaymentID = @PaymentID)
                        AND SemesterID = (SELECT SemesterID FROM PaymentRecord WHERE PaymentID = @PaymentID)";
                    SqlCommand cmdInvoice = new SqlCommand(updateInvoice, conn);
                    cmdInvoice.Parameters.AddWithValue("@PaymentID", paymentId);
                    cmdInvoice.ExecuteNonQuery();
                }
            }

            ShowStatus($"Payment {command}ed successfully.", "success");
            LoadPendingPayments();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadPendingPayments();
            lblStatus.Visible = false;
        }

        private void ShowStatus(string msg, string type)
        {
            lblStatus.Text = msg;
            lblStatus.CssClass = "status-area " + (type == "success" ? "status-success" : "status-error");
            lblStatus.Visible = true;
        }

        // Helper methods for badges
        protected string GetStudentBadge(string status)
        {
            switch (status)
            {
                case "Success": return "badge badge-success";
                case "Failed": return "badge badge-failed";
                case "Pending": return "badge badge-pending";
                default: return "badge";
            }
        }

        protected string GetVerifiedBadge(string status)
        {
            switch (status)
            {
                case "Verified": return "badge badge-verified";
                case "Rejected": return "badge badge-rejected";
                case "Pending": return "badge badge-pending-blue";
                default: return "badge";
            }
        }
    }
}