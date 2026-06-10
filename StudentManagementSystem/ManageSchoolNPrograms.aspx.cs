using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageSchoolNPrograms : System.Web.UI.Page
    {
        // Reusing verified team connection profile parameters
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                RefreshAllDashboardModules();
            }
        }

        private void RefreshAllDashboardModules()
        {
            BindSemestersGrid();
            BindFacultiesGrid();
            PopulateFacultyDropdown();
            BindProgrammesGrid();
        }

        // =========================================================================
        // 1. SEMESTER MANAGEMENT LIFE ENGINE CYCLES
        // =========================================================================
        private void BindSemestersGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT SemesterID, Semester, StartMonthDay, EndMonthDay FROM Semester ORDER BY SemesterID ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            conn.Open();
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
            // Now reading manually typed input details from the user text field string directly
            string term = txtSemesterTerm.Text.Trim();
            string start = txtStartDay.Text.Trim();
            string end = txtEndDay.Text.Trim();

            if (string.IsNullOrWhiteSpace(term) || string.IsNullOrWhiteSpace(start) || string.IsNullOrWhiteSpace(end))
            {
                ShowSemStatus("All semester parameters and range fields are required.", false);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = string.IsNullOrEmpty(hfSemesterID.Value)
                    ? "INSERT INTO Semester (Semester, StartMonthDay, EndMonthDay) VALUES (@Semester, @Start, @End)"
                    : "UPDATE Semester SET Semester = @Semester, StartMonthDay = @Start, EndMonthDay = @End WHERE SemesterID = @ID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Semester", term);
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
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditSemester")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT SemesterID, Semester, StartMonthDay, EndMonthDay FROM Semester WHERE SemesterID = @ID";
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
                                    txtSemesterTerm.Text = dr["Semester"].ToString(); // Populating string back into the manual textbox
                                    txtStartDay.Text = dr["StartMonthDay"].ToString();
                                    txtEndDay.Text = dr["EndMonthDay"].ToString();
                                    btnSaveSemester.Text = "Update";
                                    btnCancelSemester.Visible = true;
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
            txtStartDay.Text = string.Empty;
            txtEndDay.Text = string.Empty;
            btnSaveSemester.Text = "Save";
            btnCancelSemester.Visible = false;
        }

        // =========================================================================
        // 2. FACULTY DIRECTORY MANAGEMENT INTERFACES
        // =========================================================================
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

        private void PopulateFacultyDropdown()
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
                            RefreshAllDashboardModules();
                        }
                        catch (Exception ex) { ShowSchoolStatus("Faculty is currently assigned to existing programs: " + ex.Message, false); }
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

        // =========================================================================
        // 3. EXPANDED ACADEMIC PROGRAMME CONTROLLER
        // =========================================================================
        private void BindProgrammesGrid()
        {
            string filterLevel = ddlFilterLevel != null ? ddlFilterLevel.SelectedValue : "All";
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT p.ProgrammeCode, p.ProgrammeName, p.Level, p.TotalCreditHours, f.FacultyName " +
                               "FROM Programme p LEFT JOIN Faculty f ON p.FacultyID = f.FacultyID ";
                if (filterLevel != "All") query += "WHERE p.Level = @Level ";
                query += "ORDER BY p.ProgrammeCode ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (filterLevel != "All") cmd.Parameters.AddWithValue("@Level", filterLevel);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvProgrammes.DataSource = dt;
                            gvProgrammes.DataBind();
                        }
                        catch (Exception ex) { ShowProgStatus("Grid load failure: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void gvProgrammes_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProgrammes.PageIndex = e.NewPageIndex;
            BindProgrammesGrid();
        }

        protected void ddlFilterLevel_SelectedIndexChanged(object sender, EventArgs e)
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
            string facultyId = ddlSchools.SelectedValue;
            string desc = txtDescription.Text.Trim();

            if (string.IsNullOrWhiteSpace(code) || string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(creditStr) || string.IsNullOrEmpty(facultyId))
            {
                ShowProgStatus("All principal tracking parameters are required.", false);
                return;
            }

            int.TryParse(creditStr, out int credits);
            bool isUpdate = (hfIsUpdateProg.Value == "true");

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = isUpdate
                    ? "UPDATE Programme SET ProgrammeName = @Name, Level = @Level, TotalCreditHours = @Credits, FacultyID = @FacultyID, Description = @Desc WHERE ProgrammeCode = @Code"
                    : "INSERT INTO Programme (ProgrammeCode, ProgrammeName, Level, TotalCreditHours, FacultyID, Description) VALUES (@Code, @Name, @Level, @Credits, @FacultyID, @Desc)";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Code", code);
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Level", level);
                    cmd.Parameters.AddWithValue("@Credits", credits);
                    cmd.Parameters.AddWithValue("@FacultyID", Convert.ToInt32(facultyId));
                    cmd.Parameters.AddWithValue("@Desc", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc);

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
                    string query = "SELECT ProgrammeCode, ProgrammeName, Level, TotalCreditHours, FacultyID, Description FROM Programme WHERE ProgrammeCode = @Code";
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
                                    txtProgrammeName.Text = dr["ProgrammeName"].ToString();
                                    ddlLevel.SelectedValue = dr["Level"].ToString();
                                    txtCreditHours.Text = dr["TotalCreditHours"].ToString();
                                    txtDescription.Text = dr["Description"].ToString();

                                    string savedFaculty = dr["FacultyID"].ToString();
                                    if (ddlSchools.Items.FindByValue(savedFaculty) != null) ddlSchools.SelectedValue = savedFaculty;

                                    txtProgCode.Enabled = false;
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
            txtProgrammeName.Text = string.Empty;
            ddlLevel.SelectedIndex = 0;
            txtCreditHours.Text = string.Empty;
            ddlSchools.SelectedIndex = 0;
            txtDescription.Text = string.Empty;
            txtProgCode.Enabled = true;
            hfIsUpdateProg.Value = "false";
            btnSaveProg.Text = "Save Programme";
            btnCancelProg.Visible = false;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void ShowSemStatus(string msg, bool ok) { lblSemesterStatus.Text = msg; lblSemesterStatus.ForeColor = ok ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed; lblSemesterStatus.Visible = true; }
        private void ShowSchoolStatus(string msg, bool ok) { lblSchoolStatus.Text = msg; lblSchoolStatus.ForeColor = ok ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed; lblSchoolStatus.Visible = true; }
        private void ShowProgStatus(string msg, bool ok) { lblProgStatus.Text = msg; lblProgStatus.ForeColor = ok ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed; lblProgStatus.Visible = true; }
    }
}