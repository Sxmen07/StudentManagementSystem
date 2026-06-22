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
    public partial class ManageSchoolNPrograms : System.Web.UI.Page
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
                ViewState["SemesterSortDirection"] = "DESC";
                PopulateFilterFacultyDropdown();
                RefreshAllDashboardModules();
            }
        }

        private void RefreshAllDashboardModules()
        {
            BindSemestersGrid();
            BindFacultiesGrid();
            PopulateFacultyDropdowns();
            BindProgrammesGrid();
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
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            ddlFilterSchool.Items.Clear();
                            ddlFilterSchool.Items.Add(new ListItem("All Faculties", "All"));
                            while (dr.Read())
                            {
                                ddlFilterSchool.Items.Add(new ListItem(dr["FacultyName"].ToString(), dr["FacultyID"].ToString()));
                            }
                        }
                    }
                    catch { }
                }
            }
        }

        private void PopulateFacultyDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT FacultyID, FacultyName FROM Faculty ORDER BY FacultyName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            ddlSchools.Items.Clear();
                            ddlSchools.Items.Add(new ListItem("-- Choose Faculty --", ""));
                            while (dr.Read())
                            {
                                ddlSchools.Items.Add(new ListItem(dr["FacultyName"].ToString(), dr["FacultyID"].ToString()));
                            }
                        }
                    }
                    catch (Exception ex) { ShowSchoolStatus("Dropdown loading failure: " + ex.Message, false); }
                }
            }
        }

        private void BindSemestersGrid()
        {
            string direction = ViewState["SemesterSortDirection"].ToString();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = $"SELECT TOP 4 SemesterID, Semester, AcademicYear, StartMonthDay, EndMonthDay FROM Semester ORDER BY AcademicYear {direction}, SemesterID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvSemesters.DataSource = dt;
                            gvSemesters.DataBind();
                        }
                        catch (Exception ex) { ShowSemStatus("Error displaying terms: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void btnSaveSemester_Click(object sender, EventArgs e)
        {
            string term = txtSemesterTerm.Text.Trim();
            string yearStr = txtAcademicYear.Text.Trim();
            string start = txtStartDay.Text.Trim();
            string end = txtEndDay.Text.Trim();

            if (string.IsNullOrWhiteSpace(term) || string.IsNullOrWhiteSpace(yearStr) || string.IsNullOrWhiteSpace(start) || string.IsNullOrWhiteSpace(end))
            {
                ShowSemStatus("All semester parameters and range fields are required.", false);
                return;
            }

            int.TryParse(yearStr, out int year);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = string.IsNullOrEmpty(hfSemesterID.Value)
                    ? "INSERT INTO Semester (Semester, AcademicYear, StartMonthDay, EndMonthDay) VALUES (@Semester, @Year, @Start, @End)"
                    : "UPDATE Semester SET Semester = @Semester, AcademicYear = @Year, StartMonthDay = @Start, EndMonthDay = @End WHERE SemesterID = @ID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Semester", term);
                    cmd.Parameters.AddWithValue("@Year", year);
                    cmd.Parameters.AddWithValue("@Start", start);
                    cmd.Parameters.AddWithValue("@End", end);
                    if (!string.IsNullOrEmpty(hfSemesterID.Value)) cmd.Parameters.AddWithValue("@ID", hfSemesterID.Value);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowSemStatus("Semester configurations updated!", true);
                        ClearSemesterForm();
                        BindSemestersGrid();
                    }
                    catch (Exception ex) { ShowSemStatus("Save failure: " + ex.Message, false); }
                }
            }
        }

        protected void gvSemesters_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SortYear")
            {
                string currentDir = ViewState["SemesterSortDirection"].ToString();
                ViewState["SemesterSortDirection"] = (currentDir == "DESC") ? "ASC" : "DESC";
                BindSemestersGrid();
                return;
            }

            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditSemester")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT SemesterID, Semester, AcademicYear, StartMonthDay, EndMonthDay FROM Semester WHERE SemesterID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", id);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    hfSemesterID.Value = dr["SemesterID"].ToString();
                                    txtSemesterTerm.Text = dr["Semester"].ToString();
                                    txtAcademicYear.Text = dr["AcademicYear"].ToString();
                                    txtStartDay.Text = dr["StartMonthDay"].ToString();
                                    txtEndDay.Text = dr["EndMonthDay"].ToString();
                                    btnSaveSemester.Text = "Update";
                                    btnCancelSemester.Visible = true;
                                    lblSemesterStatus.Visible = false;
                                }
                            }
                        }
                        catch (Exception ex) { ShowSemStatus("Extraction error: " + ex.Message, false); }
                    }
                }
            }
            else if (e.CommandName == "DeleteSemester")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM Semester WHERE SemesterID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", id);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowSemStatus("Term record removed.", true);
                            ClearSemesterForm();
                            BindSemestersGrid();
                        }
                        catch (Exception ex) { ShowSemStatus("Wipe failed due to foreign dependencies: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void btnCancelSemester_Click(object sender, EventArgs e) { ClearSemesterForm(); }
        private void ClearSemesterForm()
        {
            hfSemesterID.Value = string.Empty;
            txtSemesterTerm.Text = string.Empty;
            txtAcademicYear.Text = string.Empty;
            txtStartDay.Text = string.Empty;
            txtEndDay.Text = string.Empty;
            btnSaveSemester.Text = "Save Term";
            btnCancelSemester.Visible = false;
        }

        private void BindFacultiesGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT FacultyID, FacultyName FROM Faculty ORDER BY FacultyID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvSchools.DataSource = dt;
                            gvSchools.DataBind();
                        }
                        catch (Exception ex) { ShowSchoolStatus("Grid rendering error: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void btnSaveSchool_Click(object sender, EventArgs e)
        {
            string schoolName = txtSchoolName.Text.Trim();
            if (string.IsNullOrWhiteSpace(schoolName))
            {
                ShowSchoolStatus("Faculty label text string required.", false);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = string.IsNullOrEmpty(hfSchoolID.Value)
                    ? "INSERT INTO Faculty (FacultyName) VALUES (@Name)"
                    : "UPDATE Faculty SET FacultyName = @Name WHERE FacultyID = @ID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Name", schoolName);
                    if (!string.IsNullOrEmpty(hfSchoolID.Value)) cmd.Parameters.AddWithValue("@ID", hfSchoolID.Value);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowSchoolStatus("Faculty record saved successfully!", true);
                        ClearSchoolForm();
                        PopulateFilterFacultyDropdown();
                        RefreshAllDashboardModules();
                    }
                    catch (Exception ex) { ShowSchoolStatus("Operation write failed: " + ex.Message, false); }
                }
            }
        }

        protected void gvSchools_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditSchool")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT FacultyID, FacultyName FROM Faculty WHERE FacultyID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", id);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    hfSchoolID.Value = dr["FacultyID"].ToString();
                                    txtSchoolName.Text = dr["FacultyName"].ToString();
                                    btnSaveSchool.Text = "Update";
                                    btnCancelSchool.Visible = true;
                                    lblSchoolStatus.Visible = false;
                                }
                            }
                        }
                        catch (Exception ex) { ShowSchoolStatus("Data extraction error: " + ex.Message, false); }
                    }
                }
            }
            else if (e.CommandName == "DeleteSchool")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM Faculty WHERE FacultyID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", id);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowSchoolStatus("Faculty record deleted from indexes.", true);
                            ClearSchoolForm();
                            PopulateFilterFacultyDropdown();
                            RefreshAllDashboardModules();
                        }
                        catch (Exception ex) { ShowSchoolStatus("Faculty dependency constraint conflict: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void btnCancelSchool_Click(object sender, EventArgs e) { ClearSchoolForm(); }
        private void ClearSchoolForm()
        {
            hfSchoolID.Value = string.Empty;
            txtSchoolName.Text = string.Empty;
            btnSaveSchool.Text = "Save Faculty";
            btnCancelSchool.Visible = false;
        }

        private DataTable GetFilteredProgrammes()
        {
            string filterLevel = ddlFilterLevel.SelectedValue;
            string filterSchool = ddlFilterSchool.SelectedValue;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT p.ProgrammeCode, p.ProgrammeName, p.Level, p.TotalCreditHours, ISNULL(p.PricePerCourse, 0) AS PricePerCourse, f.FacultyName " +
                               "FROM Programme p LEFT JOIN Faculty f ON p.FacultyID = f.FacultyID WHERE 1=1 ";

                if (filterLevel != "All") query += "AND p.Level = @Level ";
                if (filterSchool != "All") query += "AND p.FacultyID = @FacultyID ";
                query += "ORDER BY p.Level ASC, p.ProgrammeName ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (filterLevel != "All") cmd.Parameters.AddWithValue("@Level", filterLevel);
                    if (filterSchool != "All") cmd.Parameters.AddWithValue("@FacultyID", Convert.ToInt32(filterSchool));

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
            }
        }

        private void BindProgrammesGrid()
        {
            try
            {
                gvProgrammes.DataSource = GetFilteredProgrammes();
                gvProgrammes.DataBind();
                lblProgStatus.Visible = false;
            }
            catch (Exception ex) { ShowProgStatus("Grid load failure: " + ex.Message, false); }
        }

        protected void Filters_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvProgrammes.PageIndex = 0;
            BindProgrammesGrid();
        }

        protected void btnSaveProg_Click(object sender, EventArgs e)
        {
            string code = txtProgCode.Text.Trim().ToUpper();
            string name = txtProgrammeName.Text.Trim();
            string level = ddlLevel.SelectedValue;
            string creditStr = txtCreditHours.Text.Trim();
            string priceStr = txtPricePerCourse.Text.Trim();
            string facultyId = ddlSchools.SelectedValue;
            string desc = txtDescription.Text.Trim();

            if (string.IsNullOrWhiteSpace(code) || string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(creditStr) || string.IsNullOrEmpty(facultyId))
            {
                ShowProgStatus("All principal tracking parameters are required.", false);
                return;
            }

            int.TryParse(creditStr, out int credits);
            decimal.TryParse(priceStr, out decimal pricePerCourse);
            bool isUpdate = (hfIsUpdateProg.Value == "true");

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = isUpdate
                    ? "UPDATE Programme SET ProgrammeCode = @NewCode, ProgrammeName = @Name, Level = @Level, TotalCreditHours = @Credits, FacultyID = @FacultyID, Description = @Desc, PricePerCourse = @Price WHERE ProgrammeCode = @OrigCode"
                    : "INSERT INTO Programme (ProgrammeCode, ProgrammeName, Level, TotalCreditHours, FacultyID, Description, PricePerCourse) VALUES (@NewCode, @Name, @Level, @Credits, @FacultyID, @Desc, @Price)";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NewCode", code);
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Level", level);
                    cmd.Parameters.AddWithValue("@Credits", credits);
                    cmd.Parameters.AddWithValue("@Price", pricePerCourse);
                    cmd.Parameters.AddWithValue("@FacultyID", Convert.ToInt32(facultyId));
                    cmd.Parameters.AddWithValue("@Desc", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc);
                    if (isUpdate) cmd.Parameters.AddWithValue("@OrigCode", hfOriginalProgCode.Value);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowProgStatus("Program synchronized cleanly!", true);
                        ClearProgrammeForm();
                        BindProgrammesGrid();
                    }
                    catch (Exception ex) { ShowProgStatus("Database update crash: " + ex.Message, false); }
                }
            }
        }

        protected void gvProgrammes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;
            string targetCode = e.CommandArgument.ToString();

            if (e.CommandName == "EditProg")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT ProgrammeCode, ProgrammeName, Level, TotalCreditHours, FacultyID, Description, ISNULL(PricePerCourse,0) AS PricePerCourse FROM Programme WHERE ProgrammeCode = @Code";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", targetCode);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    txtProgCode.Text = dr["ProgrammeCode"].ToString();
                                    hfOriginalProgCode.Value = dr["ProgrammeCode"].ToString();
                                    txtProgrammeName.Text = dr["ProgrammeName"].ToString();
                                    ddlLevel.SelectedValue = dr["Level"].ToString();
                                    txtCreditHours.Text = dr["TotalCreditHours"].ToString();
                                    txtPricePerCourse.Text = Convert.ToDecimal(dr["PricePerCourse"]).ToString("F2");
                                    txtDescription.Text = dr["Description"].ToString();

                                    string savedFaculty = dr["FacultyID"].ToString();
                                    if (ddlSchools.Items.FindByValue(savedFaculty) != null) ddlSchools.SelectedValue = savedFaculty;

                                    txtProgCode.Enabled = true;
                                    hfIsUpdateProg.Value = "true";
                                    btnSaveProg.Text = "Update";
                                    btnCancelProg.Visible = true;
                                    ShowProgStatus("Staging programmatic configurations.", true);
                                }
                            }
                        }
                        catch (Exception ex) { ShowProgStatus("Extraction fail: " + ex.Message, false); }
                    }
                }
            }
            else if (e.CommandName == "DeleteProg")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM Programme WHERE ProgrammeCode = @Code";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", targetCode);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowProgStatus("Program dropped cleanly.", true);
                            BindProgrammesGrid();
                        }
                        catch (Exception ex) { ShowProgStatus("Wipe aborted due to dependencies: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void btnCancelProg_Click(object sender, EventArgs e) { ClearProgrammeForm(); }
        private void ClearProgrammeForm()
        {
            txtProgCode.Text = string.Empty;
            hfOriginalProgCode.Value = string.Empty;
            txtProgrammeName.Text = string.Empty;
            ddlLevel.SelectedIndex = 0;
            txtCreditHours.Text = string.Empty;
            txtPricePerCourse.Text = string.Empty;
            ddlSchools.SelectedIndex = 0;
            txtDescription.Text = string.Empty;
            txtProgCode.Enabled = true;
            hfIsUpdateProg.Value = "false";
            btnSaveProg.Text = "Save Programme";
            btnCancelProg.Visible = false;
        }

        private string GetDocumentMainTitle()
        {
            return ddlFilterSchool.SelectedValue == "All" ? "Lists of Charges for All Faculties" : $"Lists of Charges for {ddlFilterSchool.SelectedItem.Text}";
        }

        private string GetDocumentSubHeader()
        {
            return ddlFilterSchool.SelectedValue == "All" ? "All Faculties" : $"Faculty: {ddlFilterSchool.SelectedItem.Text}";
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            DataTable dt = GetFilteredProgrammes();
            StringBuilder sb = new StringBuilder();
            sb.AppendLine(GetDocumentMainTitle());
            sb.AppendLine(GetDocumentSubHeader());
            sb.AppendLine($"Exported Date: {DateTime.Now:yyyy-MM-dd}");
            sb.AppendLine();
            sb.AppendLine("No,Qualifications,Name,Price/Subject");

            int counter = 1;
            foreach (DataRow row in dt.Rows)
            {
                sb.AppendLine($"{counter},{EscapeCsvField(row["Level"].ToString())},{EscapeCsvField(row["ProgrammeName"].ToString())},RM {Convert.ToDecimal(row["PricePerCourse"]):F2}");
                counter++;
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=ProgrammesReport.csv");
            Response.ContentType = "text/csv";
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        private string EscapeCsvField(string field)
        {
            if (field.Contains(",") || field.Contains("\"") || field.Contains("\n") || field.Contains("\r"))
            {
                return "\"" + field.Replace("\"", "\"\"") + "\"";
            }
            return field;
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = GetFilteredProgrammes();
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=ProgrammesReport.xls");
            Response.ContentType = "application/vnd.ms-excel";

            StringWriter sw = new StringWriter();
            HtmlTextWriter hw = new HtmlTextWriter(sw);

            hw.Write($"<h2>{HttpUtility.HtmlEncode(GetDocumentMainTitle())}</h2>");
            hw.Write($"<h4>{HttpUtility.HtmlEncode(GetDocumentSubHeader())}</h4>");
            hw.Write($"<p>Exported Date: {DateTime.Now:yyyy-MM-dd}</p><br/>");
            hw.Write("<table border='1' style='font-family:Arial; font-size:12px;'>");
            hw.Write("<tr style='background-color:#F7F7F5; font-weight:bold;'><th>No</th><th>Qualifications</th><th>Name</th><th>Price/Subject</th></tr>");

            int counter = 1;
            foreach (DataRow row in dt.Rows)
            {
                hw.Write("<tr>");
                hw.Write($"<td style='text-align:center;'>{counter}</td>");
                hw.Write($"<td>{HttpUtility.HtmlEncode(row["Level"])}</td>");
                hw.Write($"<td>{HttpUtility.HtmlEncode(row["ProgrammeName"])}</td>");
                hw.Write($"<td style='text-align:right;'>RM {Convert.ToDecimal(row["PricePerCourse"]):N2}</td>");
                hw.Write("</tr>");
                counter++;
            }
            hw.Write("</table>");

            Response.Output.Write(sw.ToString());
            Response.Flush();
            Response.End();
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetFilteredProgrammes();
            StringBuilder sb = new StringBuilder();

            sb.Append("<html><head><title>Print Layout Directory</title><style>");
            sb.Append("body { font-family: 'Segoe UI', Arial, sans-serif; padding: 40px; color: #2F2F2F; background-color: #ffffff; }");
            sb.Append("table { width: 100%; border-collapse: collapse; margin-top: 25px; }");
            sb.Append("th, td { border: 1px solid #EBEBE9; padding: 12px 16px; font-size: 13px; text-align: left; }");
            sb.Append("th { background-color: #F7F7F5; color: #7C7B77; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; font-size: 11px; }");
            sb.Append("h2 { margin: 0; font-size: 22px; color: #111625; font-weight: 700; letter-spacing: -0.02em; }");
            sb.Append("h4 { margin: 6px 0 0 0; font-size: 14px; color: #4B5563; font-weight: 600; }");
            sb.Append("p { font-size: 12px; color: #7C7B77; margin-top: 4px; }");
            sb.Append("tr:nth-child(even) { background-color: #FBFBFA; }");
            sb.Append("</style></head><body>");

            // FIXED: Removed literal text label strings to create a pure structural hierarchy print outline
            sb.Append($"<h2>{HttpUtility.HtmlEncode(GetDocumentMainTitle())}</h2>");
            sb.Append($"<h4>{HttpUtility.HtmlEncode(GetDocumentSubHeader())}</h4>");
            sb.Append($"<p>Filtered Report Registers • Generated on {DateTime.Now:yyyy-MM-dd • hh:mm tt}</p>");

            sb.Append("<table><tr><th style='width: 10%; text-align: center;'>No</th><th style='width: 25%;'>Qualifications</th><th>Name</th><th style='width: 20%; text-align: right;'>Price/Subject</th></tr>");

            int counter = 1;
            foreach (DataRow row in dt.Rows)
            {
                sb.Append("<tr>");
                sb.Append($"<td style='text-align: center; font-weight: 700; color: #A1A1AA;'>{counter}</td>");
                sb.Append($"<td style='font-weight: 600; color: #4B5563;'>{HttpUtility.HtmlEncode(row["Level"])}</td>");
                sb.Append($"<td style='font-weight: 500; color: #111827;'>{HttpUtility.HtmlEncode(row["ProgrammeName"])}</td>");
                sb.Append($"<td style='text-align: right; font-weight: 700; color: #111827;'>RM {Convert.ToDecimal(row["PricePerCourse"]):N2}</td>");
                sb.Append("</tr>");
                counter++;
            }
            sb.Append("</table>");
            sb.Append("<script type='text/javascript'>window.onload = function() { window.print(); }</script></body></html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        private void ShowSemStatus(string msg, bool ok) { lblSemesterStatus.Text = msg; lblSemesterStatus.ForeColor = ok ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed; lblSemesterStatus.Visible = true; }
        private void ShowSchoolStatus(string msg, bool ok) { lblSchoolStatus.Text = msg; lblSchoolStatus.ForeColor = ok ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed; lblSchoolStatus.Visible = true; }
        private void ShowProgStatus(string msg, bool ok) { lblProgStatus.Text = msg; lblProgStatus.ForeColor = ok ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed; lblProgStatus.Visible = true; }

        protected void gvProgrammes_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProgrammes.PageIndex = e.NewPageIndex;
            BindProgrammesGrid();
        }
    }
}