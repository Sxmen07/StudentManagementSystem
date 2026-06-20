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
    public partial class StudentTuitionInvoicesTest : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int targetTestId = 1;
                bool loadSuccess = RunAutomaticFeeAssessment(targetTestId);

                if (loadSuccess && ViewState["CurrentPaymentStatus"].ToString() == "PAID")
                {
                    lnkRecoverPrint.Visible = true;
                }
            }
        }

        private bool RunAutomaticFeeAssessment(int studentId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string studentQuery = @"
                    SELECT TOP 1 s.StudentID, s.StudentName, s.SemesterID, p.ProgrammeName, ISNULL(p.PricePerCourse, 0) AS PricePerCourse, sem.Semester, sem.AcademicYear, s.DisplayID
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
                                litStudentSemester.Text = $"{rdr["Semester"]} {rdr["AcademicYear"]}";
                                litStudentProg.Text = rdr["ProgrammeName"].ToString();
                                litStudentDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                                decimal unitPrice = Convert.ToDecimal(rdr["PricePerCourse"]);
                                rdr.Close();

                                string status = ResolvePaymentStatus(studentId, Convert.ToInt32(ViewState["StudentSemID"]), conn);
                                ViewState["CurrentPaymentStatus"] = status;

                                if (status == "PAID")
                                {
                                    txtUiPaymentStatus.InnerText = "PAID";
                                    txtUiPaymentStatus.Attributes["class"] = "text-emerald-600 font-bold";
                                    badgeStatus.InnerText = "Verified Fee Receipt";
                                    badgeStatus.Attributes["class"] = "text-emerald-600 text-[10px] font-bold uppercase bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-100";
                                    btnPayTuition.Visible = false;
                                    lnkRecoverPrint.Visible = true;
                                }

                                LoadStudentCourses(studentId, unitPrice, conn);
                                return true;
                            }
                        }
                    }
                    catch (Exception ex) { lblStudentBillStatus.Text = "Query error: " + ex.Message; lblStudentBillStatus.Visible = true; }
                }
            }
            return false;
        }

        private string ResolvePaymentStatus(int studentId, int semesterId, SqlConnection conn)
        {
            string query = "SELECT TOP 1 PaymentStatus FROM InvoiceReceipt WHERE StudentID = @SID AND SemesterID = @SemID ORDER BY InvoiceID DESC";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@SID", studentId);
                cmd.Parameters.AddWithValue("@SemID", semesterId);
                object res = cmd.ExecuteScalar();
                return res != null ? res.ToString() : "PENDING";
            }
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

        protected void btnPayTuition_Click(object sender, EventArgs e)
        {
            if (ViewState["StudentSID"] == null) return;
            int sid = Convert.ToInt32(ViewState["StudentSID"]);
            int semId = Convert.ToInt32(ViewState["StudentSemID"]);
            decimal total = Convert.ToDecimal(ViewState["StudentFinalTotal"]);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    IF EXISTS(SELECT 1 FROM InvoiceReceipt WHERE StudentID=@SID AND SemesterID=@SemID)
                        UPDATE InvoiceReceipt SET PaymentStatus='PAID' WHERE StudentID=@SID AND SemesterID=@SemID
                    ELSE
                        INSERT INTO InvoiceReceipt (StudentID, SemesterID, TotalAmount, PaymentStatus) VALUES (@SID, @SemID, @Total, 'PAID')";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SID", sid);
                    cmd.Parameters.AddWithValue("@SemID", semId);
                    cmd.Parameters.AddWithValue("@Total", total);
                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();

                        txtUiPaymentStatus.InnerText = "PAID";
                        txtUiPaymentStatus.Attributes["class"] = "text-emerald-600 font-bold";
                        badgeStatus.InnerText = "Verified Fee Receipt";
                        badgeStatus.Attributes["class"] = "text-emerald-600 text-[10px] font-bold uppercase bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-100";
                        btnPayTuition.Visible = false;
                        lnkRecoverPrint.Visible = true;
                        ViewState["CurrentPaymentStatus"] = "PAID";

                        TriggerInjectedPrintEngine();
                    }
                    catch { }
                }
            }
        }

        protected void lnkRecoverPrint_Click(object sender, EventArgs e)
        {
            if (ViewState["StudentSID"] != null && ViewState["CurrentPaymentStatus"].ToString() == "PAID")
            {
                TriggerInjectedPrintEngine();
            }
        }

        private void TriggerInjectedPrintEngine()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><style>body{font-family:Arial,sans-serif; padding:50px;} table{width:100%; border-collapse:collapse; margin-top:20px;} th,td{border:1px solid #EBEBE9; padding:12px;} th{background-color:#F7F7F5; color:#7C7B77;} .status-paid{color:green; font-weight:bold;}</style></head><body>");
            sb.Append("<h2>Official Enrollment Fee Receipt Summary</h2>");
            sb.Append($"<p>Student Name: <b>{litStudentName.Text}</b> ({litStudentDisplayID.Text})<br/>Semester Term: {litStudentSemester.Text}<br/>Payment Status: <span class='status-paid'>PAID</span><br/>Receipt Date: {litStudentDate.Text}</p>");
            sb.Append("<table><tr><th>No</th><th>Course Code</th><th>Course Title</th><th style='text-align:right;'>Paid Amount</th></tr>");

            int num = 1;
            foreach (GridViewRow row in gvStudentInvoiceItems.Rows)
            {
                sb.Append($"<tr><td style='text-align:center;'>{num}</td><td>{row.Cells[1].Text}</td><td>{row.Cells[2].Text}</td><td style='text-align:right;'>{row.Cells[3].Text}</td></tr>");
                num++;
            }
            sb.Append($"</table><h3 style='text-align:right; margin-top:25px;'>TOTAL PAID CONFIRMED: RM {litStudentTotalAmount.Text}</h3>");
            sb.Append("<script>window.onload = function() { window.print(); }</script></body></html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }
    }
}