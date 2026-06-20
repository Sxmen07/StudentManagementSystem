using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class StudentTuitionInvoices : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Student")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Pull active user session directly to display personalized info seamlessly
                int activeStudentId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;

                if (activeStudentId > 0)
                {
                    bool loadSuccess = RunAutomaticFeeAssessment(activeStudentId);

                    // FIXED: Automatic runtime integration - displays print layout instantly on landing
                    if (loadSuccess)
                    {
                        TriggerInjectedPrintEngine();
                    }
                }
                else
                {
                    ShowEmptyState("Operational profile context missing. Access denied.");
                }
            }
        }

        private bool RunAutomaticFeeAssessment(int studentId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string studentQuery = @"
                    SELECT s.StudentID, s.StudentName, s.SemesterID, p.ProgrammeName, p.PricePerCourse, sem.Semester, s.DisplayID
                    FROM Student s
                    INNER JOIN Semester sem ON s.SemesterID = sem.SemesterID
                    INNER JOIN Programme p ON sem.SemesterID = p.FacultyID
                    WHERE s.StudentID = @StudentID";

                using (SqlCommand cmd = new SqlCommand(studentQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    try
                    {
                        conn.Open();
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                ViewState["StudentSID"] = rdr["StudentID"].ToString();
                                ViewState["StudentSemID"] = rdr["SemesterID"].ToString();
                                litStudentName.Text = rdr["StudentName"].ToString();
                                litStudentDisplayID.Text = rdr["DisplayID"].ToString();
                                litStudentSemester.Text = rdr["Semester"].ToString();
                                litStudentProg.Text = rdr["ProgrammeName"].ToString();
                                litStudentDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                                decimal unitPrice = Convert.ToDecimal(rdr["PricePerCourse"]);
                                rdr.Close();

                                LoadStudentCourses(studentId, unitPrice, conn);
                                pnlStudentInvoiceView.Visible = true;
                                lblStudentBillStatus.Visible = false;
                                return true;
                            }
                            else
                            {
                                ShowEmptyState("No matching financial registration parameters logged for your current term enrollment.");
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowEmptyState("Error querying fee parameters: " + ex.Message);
                    }
                }
            }
            return false;
        }

        private void LoadStudentCourses(int studentId, decimal unitPrice, SqlConnection openConn)
        {
            string courseQuery = @"
                SELECT c.CourseCode, c.CourseName, @Price AS UnitPrice
                FROM CourseOffer co
                INNER JOIN Course c ON co.CourseID = c.CourseID
                WHERE co.CourseID = @StudentID";

            using (SqlCommand cmd = new SqlCommand(courseQuery, openConn))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                cmd.Parameters.AddWithValue("@Price", unitPrice);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvStudentInvoiceItems.DataSource = dt;
                    gvStudentInvoiceItems.DataBind();

                    decimal totalAmount = dt.Rows.Count * unitPrice;
                    litStudentTotalAmount.Text = totalAmount.ToString("N2");
                    ViewState["StudentFinalTotal"] = totalAmount;
                }
            }
        }

        protected void lnkRecoverPrint_Click(object sender, EventArgs e)
        {
            // Manual click fallback parameter loop
            if (ViewState["StudentSID"] != null)
            {
                TriggerInjectedPrintEngine();
            }
        }

        private void TriggerInjectedPrintEngine()
        {
            if (gvStudentInvoiceItems.Rows.Count == 0) return;

            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><title>My Statement Invoice</title><style>");
            sb.Append("body{font-family:Arial,sans-serif; padding:50px; color:#2F2F2F;} table{width:100%; border-collapse:collapse; margin-top:20px;} th,td{border:1px solid #EBEBE9; padding:12px; font-size:12px;} th{background-color:#F7F7F5; color:#7C7B77;} .tot{text-align:right; font-size:18px; font-weight:900; margin-top:20px;}</style></head><body>");
            sb.Append("<h2>Official Term Enrollment Invoice Statement</h2>");
            sb.Append($"<p>Student Name: <b>{litStudentName.Text}</b> ({litStudentDisplayID.Text})<br/>Current Term Block: {litStudentSemester.Text}<br/>Date Generated: {litStudentDate.Text}</p>");
            sb.Append("<table><tr><th>Code</th><th>Module Enrolled</th><th style='text-align:right;'>Price</th></tr>");
            foreach (GridViewRow row in gvStudentInvoiceItems.Rows)
            {
                sb.Append($"<tr><td>{row.Cells[0].Text}</td><td>{row.Cells[1].Text}</td><td style='text-align:right;'>{row.Cells[2].Text}</td></tr>");
            }
            sb.Append($"</table><div class='tot'>TOTAL TERM BALANCES DUE: RM {litStudentTotalAmount.Text}</div>");
            sb.Append("<script>window.onload = function() { window.print(); }</script></body></html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        private void ShowEmptyState(string msg) { lblStudentBillStatus.Text = msg; lblStudentBillStatus.Visible = true; pnlStudentInvoiceView.Visible = false; }
    }
}