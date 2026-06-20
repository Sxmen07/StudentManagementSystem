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
    public partial class ManageTuitionFees : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        // Explicit variable sync bindings to safely avoid designer file conflicts
        protected global::System.Web.UI.WebControls.Literal litInvoiceProg;
        protected global::System.Web.UI.WebControls.Literal litInvoiceDate;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                PopulateProgrammesDropdown();
                PopulateFilterFacultyDropdown();
                BindPricingListGrid();
            }
        }

        private void PopulateProgrammesDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT ProgrammeCode, ProgrammeName FROM Programme ORDER BY ProgrammeName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        ddlProgrammes.DataSource = cmd.ExecuteReader();
                        ddlProgrammes.DataValueField = "ProgrammeCode";
                        ddlProgrammes.DataTextField = "ProgrammeName";
                        ddlProgrammes.DataBind();
                    }
                    catch { }
                }
            }
            ddlProgrammes.Items.Insert(0, new ListItem("-- Choose Programme Track --", ""));
        }

        private void PopulateFilterFacultyDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT FacultyID, FacultyName FROM Faculty ORDER BY FacultyName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        ddlSortFaculty.DataSource = cmd.ExecuteReader();
                        ddlSortFaculty.DataValueField = "FacultyID";
                        ddlSortFaculty.DataTextField = "FacultyName";
                        ddlSortFaculty.DataBind();
                    }
                    catch { }
                }
            }
            ddlSortFaculty.Items.Insert(0, new ListItem("All Faculties", "All"));
        }

        private DataTable GetFilteredPricingData()
        {
            string schoolFilter = ddlSortFaculty.SelectedValue;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT p.ProgrammeCode, p.ProgrammeName, ISNULL(p.PricePerCourse, 0) AS PricePerCourse, f.FacultyName FROM Programme p LEFT JOIN Faculty f ON p.FacultyID = f.FacultyID ";
                if (schoolFilter != "All") query += "WHERE p.FacultyID = @FacultyID ";
                query += "ORDER BY p.ProgrammeName ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (schoolFilter != "All") cmd.Parameters.AddWithValue("@FacultyID", Convert.ToInt32(schoolFilter));
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
            }
        }

        private void BindPricingListGrid()
        {
            gvProgPricingList.DataSource = GetFilteredPricingData();
            gvProgPricingList.DataBind();
        }

        protected void ddlSortFaculty_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindPricingListGrid();
        }

        protected void gvProgPricingList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SelectPrice")
            {
                string code = e.CommandArgument.ToString();
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT ProgrammeCode, PricePerCourse FROM Programme WHERE ProgrammeCode = @Code";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", code);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    ddlProgrammes.SelectedValue = dr["ProgrammeCode"].ToString();
                                    txtPricePerCourse.Text = Convert.ToDecimal(dr["PricePerCourse"]).ToString("F2");
                                    hfSelectedProgCode.Value = code;
                                    btnUpdatePrice.Text = "Update Rate";
                                    btnCancelEdit.Visible = true;
                                    lblPriceStatus.Visible = false;
                                }
                            }
                        }
                        catch { }
                    }
                }
            }
        }

        protected void btnUpdatePrice_Click(object sender, EventArgs e)
        {
            string code = ddlProgrammes.SelectedValue;
            string rateStr = txtPricePerCourse.Text.Trim();

            if (string.IsNullOrEmpty(code) || string.IsNullOrWhiteSpace(rateStr))
            {
                ShowPriceMessage("Please choose a valid programme track and specify a pricing rate.", false);
                return;
            }

            decimal.TryParse(rateStr, out decimal coreRate);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "UPDATE Programme SET PricePerCourse = @Rate WHERE ProgrammeCode = @Code";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Rate", coreRate);
                    cmd.Parameters.AddWithValue("@Code", code);
                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowPriceMessage("Standard unit pricing rate updated successfully!", true);
                        ClearEditForm();
                        BindPricingListGrid();
                    }
                    catch (Exception ex) { ShowPriceMessage("Pricing synchronization failure: " + ex.Message, false); }
                }
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e) { ClearEditForm(); }
        private void ClearEditForm()
        {
            txtPricePerCourse.Text = "";
            ddlProgrammes.SelectedIndex = 0;
            hfSelectedProgCode.Value = "";
            btnUpdatePrice.Text = "Update Pricing Rate";
            btnCancelEdit.Visible = false;
        }

        protected void btnCalculateAdminBilling_Click(object sender, EventArgs e)
        {
            string rawInputId = txtSearchStudentID.Text.Trim().ToUpper();
            if (string.IsNullOrWhiteSpace(rawInputId) || !rawInputId.StartsWith("S"))
            {
                ShowAdminBillError("Please enter a valid Student Identifier starting with 'S' (e.g., S1001).");
                return;
            }

            if (!int.TryParse(rawInputId.Substring(1), out int computedDisplayId)) return;
            int trueDatabaseId = computedDisplayId - 1000;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string studentQuery = @"
                    SELECT s.StudentID, s.StudentName, s.SemesterID, p.ProgrammeName, ISNULL(p.PricePerCourse, 0) AS PricePerCourse, sem.Semester, sem.AcademicYear, s.DisplayID
                    FROM Student s
                    INNER JOIN Semester sem ON s.SemesterID = sem.SemesterID
                    INNER JOIN Programme p ON sem.SemesterID = p.FacultyID
                    WHERE s.StudentID = @StudentID";

                using (SqlCommand cmd = new SqlCommand(studentQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", trueDatabaseId);
                    try
                    {
                        conn.Open();
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                ViewState["AdminBillSID"] = rdr["StudentID"].ToString();
                                ViewState["AdminBillSemID"] = rdr["SemesterID"].ToString();
                                litInvoiceStudentName.Text = rdr["StudentName"].ToString();
                                litInvoiceDisplayID.Text = rdr["DisplayID"].ToString();
                                litInvoiceSemester.Text = $"{rdr["Semester"]} {rdr["AcademicYear"]}";
                                litInvoiceProg.Text = rdr["ProgrammeName"].ToString();
                                litInvoiceDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                                decimal unitPrice = Convert.ToDecimal(rdr["PricePerCourse"]);
                                rdr.Close();

                                string payStatus = ResolvePaymentStatusFromDatabase(trueDatabaseId, Convert.ToInt32(ViewState["AdminBillSemID"]), conn);
                                litInvoicePaymentStatus.Text = payStatus;

                                LoadEnrolledCoursesMatrix(trueDatabaseId, unitPrice, conn);
                                lblAdminBillStatus.Visible = false;
                                pnlAdminInvoiceStatementView.Visible = true;
                            }
                            else
                            {
                                ShowAdminBillError("No student account found matching the given profile code.");
                            }
                        }
                    }
                    catch (Exception ex) { ShowAdminBillError("Database error: " + ex.Message); }
                }
            }
        }

        private string ResolvePaymentStatusFromDatabase(int studentId, int semesterId, SqlConnection conn)
        {
            string query = "SELECT TOP 1 PaymentStatus FROM InvoiceReceipt WHERE StudentID = @SID AND SemesterID = @SemID ORDER BY InvoiceID DESC";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@SID", studentId);
                cmd.Parameters.AddWithValue("@SemID", semesterId);
                object status = cmd.ExecuteScalar();
                return status != null ? status.ToString() : "PENDING";
            }
        }

        protected void btnMarkAsPaid_Click(object sender, EventArgs e)
        {
            if (ViewState["AdminBillSID"] == null) return;
            int sid = Convert.ToInt32(ViewState["AdminBillSID"]);
            int semId = Convert.ToInt32(ViewState["AdminBillSemID"]);
            decimal total = Convert.ToDecimal(ViewState["AdminBillFinalTotal"]);

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
                        litInvoicePaymentStatus.Text = "PAID";
                    }
                    catch { }
                }
            }
        }

        private void LoadEnrolledCoursesMatrix(int studentId, decimal unitPrice, SqlConnection openConn)
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
                    gvInvoiceItems.DataSource = dt;
                    gvInvoiceItems.DataBind();

                    decimal finalTotal = dt.Rows.Count * unitPrice;
                    litInvoiceTotalAmount.Text = finalTotal.ToString("N2");
                    ViewState["AdminBillFinalTotal"] = finalTotal;
                }
            }
        }

        protected void btnGeneratePDFInvoice_Click(object sender, EventArgs e)
        {
            if (ViewState["AdminBillSID"] == null) return;

            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><style>body{font-family:Arial,sans-serif; padding:50px; color:#2F2F2F;} table{width:100%; border-collapse:collapse; margin-top:20px;} th,td{border:1px solid #EBEBE9; padding:12px; font-size:12px;} th{background-color:#F7F7F5; color:#7C7B77;} .tot{text-align:right; font-size:18px; font-weight:900; margin-top:20px;}</style></head><body>");
            sb.Append("<h2>Official Academic Invoice Statement</h2>");
            sb.Append($"<p>Student Name: <b>{litInvoiceStudentName.Text}</b> ({litInvoiceDisplayID.Text})<br/>Term Block: {litInvoiceSemester.Text}<br/>Payment Status: <b>{litInvoicePaymentStatus.Text}</b><br/>Issued Date: {litInvoiceDate.Text}</p>");
            sb.Append("<table><tr><th>No</th><th>Course Code</th><th>Module Description</th><th style='text-align:right;'>Price</th></tr>");

            int num = 1;
            foreach (GridViewRow row in gvInvoiceItems.Rows)
            {
                sb.Append($"<tr><td style='text-align:center;'>{num}</td><td>{row.Cells[0].Text}</td><td>{row.Cells[1].Text}</td><td style='text-align:right;'>{row.Cells[2].Text}</td></tr>");
                num++;
            }
            sb.Append($"</table><div class='tot'>TOTAL TERM BALANCES: RM {litInvoiceTotalAmount.Text}</div>");
            sb.Append("<script>window.onload = function() { window.print(); }</script></body></html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        protected void lnkExportCSV_Click(object sender, EventArgs e)
        {
            DataTable dt = GetFilteredPricingData();
            StringBuilder sb = new StringBuilder();
            sb.AppendLine($"Title: Lists of Charges for {ddlSortFaculty.SelectedItem.Text}");
            sb.AppendLine($"Exported Date: {DateTime.Now:yyyy-MM-dd}");
            sb.AppendLine();
            sb.AppendLine("No,Program Name,Price/subject");

            int counter = 1;
            foreach (DataRow row in dt.Rows)
            {
                sb.AppendLine($"{counter},\"{row["ProgrammeName"]}\",RM {Convert.ToDecimal(row["PricePerCourse"]):F2}");
                counter++;
            }
            Response.Clear();
            Response.AddHeader("content-disposition", "attachment;filename=PricingReport.csv");
            Response.ContentType = "text/csv";
            Response.Write(sb.ToString());
            Response.End();
        }

        protected void lnkExportExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = GetFilteredPricingData();
            Response.Clear();
            Response.AddHeader("content-disposition", "attachment;filename=PricingReport.xls");
            Response.ContentType = "application/vnd.ms-excel";

            StringWriter sw = new StringWriter();
            HtmlTextWriter hw = new HtmlTextWriter(sw);

            hw.Write($"<h3>Title: Lists of Charges for {HttpUtility.HtmlEncode(ddlSortFaculty.SelectedItem.Text)}</h3>");
            hw.Write($"<p>Exported Date: {DateTime.Now:yyyy-MM-dd}</p><br/>");
            hw.Write("<table border='1' style='font-family:Arial; font-size:12px;'>");
            hw.Write("<tr style='background-color:#F7F7F5; font-weight:bold;'><th>No</th><th>Program Name</th><th>Price/subject</th></tr>");

            int counter = 1;
            foreach (DataRow row in dt.Rows)
            {
                hw.Write($"<tr><td style='text-align:center;'>{counter}</td><td>{HttpUtility.HtmlEncode(row["ProgrammeName"])}</td><td style='text-align:right;'>RM {Convert.ToDecimal(row["PricePerCourse"]):N2}</td></tr>");
                counter++;
            }
            hw.Write("</table>");
            Response.Write(sw.ToString());
            Response.End();
        }

        protected void lnkExportPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetFilteredPricingData();
            StringBuilder sb = new StringBuilder();

            sb.Append("<html><head><style>body{font-family:Arial,sans-serif; padding:40px;} table{width:100%; border-collapse:collapse; margin-top:15px;} th,td{border:1px solid #ccc; padding:10px; font-size:12px;} th{background-color:#f4f4f5; text-align:left;}</style></head><body>");
            sb.Append($"<h2>Title: Lists of Charges for {HttpUtility.HtmlEncode(ddlSortFaculty.SelectedItem.Text)}</h2>");
            sb.Append($"<p>Exported Date: {DateTime.Now:yyyy-MM-dd}</p>");
            sb.Append("<table><tr><th style='width:10%; text-align:center;'>No</th><th>Program Name</th><th style='width:25%; text-align:right;'>Price/subject</th></tr>");

            int counter = 1;
            foreach (DataRow row in dt.Rows)
            {
                sb.Append($"<tr><td style='text-align:center;'>{counter}</td><td>{HttpUtility.HtmlEncode(row["ProgrammeName"])}</td><td style='text-align:right; font-weight:bold;'>RM {Convert.ToDecimal(row["PricePerCourse"]):N2}</td></tr>");
                counter++;
            }
            sb.Append("</table><script>window.onload = function() { window.print(); }</script></body></html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        private void ShowPriceMessage(string msg, bool ok) { lblPriceStatus.Text = msg; lblPriceStatus.ForeColor = ok ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed; lblPriceStatus.Visible = true; }
        private void ShowAdminBillError(string msg) { lblAdminBillStatus.Text = msg; lblAdminBillStatus.Visible = true; pnlAdminInvoiceStatementView.Visible = false; }
    }
}