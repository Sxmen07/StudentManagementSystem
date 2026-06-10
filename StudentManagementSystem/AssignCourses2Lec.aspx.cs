using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class AssignCourses2Lec : System.Web.UI.Page
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
                txtYear.Text = DateTime.Now.Year.ToString(); // Default to current calendar year
                PopulateFormDropdowns();
                BindAssignmentsGrid();
                CalculateSummaryMetrics();
            }
        }

        // =========================================================================
        // POPULATE ALL ENTRY DROPDOWN MENUS DYNAMICALLY FROM CORE DB TABLES
        // =========================================================================
        private void PopulateFormDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();

                    // 1. Fetch Lecturers List
                    using (SqlCommand cmd = new SqlCommand("SELECT LecturerID, LecturerName FROM Lecturer ORDER BY LecturerName ASC", conn))
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        ddlLecturers.Items.Clear();
                        ddlLecturers.Items.Add(new ListItem("-- Choose Lecturer --", ""));

                        string selectedFilter = ddlFilterLecturer.SelectedValue;
                        ddlFilterLecturer.Items.Clear();
                        ddlFilterLecturer.Items.Add(new ListItem("All Faculty Lecturers", ""));

                        while (dr.Read())
                        {
                            string id = dr["LecturerID"].ToString();
                            string name = dr["LecturerName"].ToString();
                            ddlLecturers.Items.Add(new ListItem(name, id));
                            ddlFilterLecturer.Items.Add(new ListItem(name, id));
                        }
                        if (ddlFilterLecturer.Items.FindByValue(selectedFilter) != null) ddlFilterLecturer.SelectedValue = selectedFilter;
                    }

                    // 2. Fetch Courses List
                    using (SqlCommand cmd = new SqlCommand("SELECT CourseCode, CourseName FROM Course ORDER BY CourseCode ASC", conn))
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        ddlCourses.Items.Clear();
                        ddlCourses.Items.Add(new ListItem("-- Choose Course Module --", ""));
                        while (dr.Read())
                        {
                            ddlCourses.Items.Add(new ListItem($"[{dr["CourseCode"]}] {dr["CourseName"]}", dr["CourseCode"].ToString()));
                        }
                    }

                    // 3. Fetch Semester Calendar Blocks
                    using (SqlCommand cmd = new SqlCommand("SELECT SemesterID, Semester FROM Semester ORDER BY SemesterID ASC", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        ddlSemesters.DataSource = dt;
                        ddlSemesters.DataValueField = "SemesterID";
                        ddlSemesters.DataTextField = "Semester";
                        ddlSemesters.DataBind();
                    }
                }
                catch (Exception ex) { ShowStatus("Staging dropped mapping indices failure: " + ex.Message, false); }
            }
        }

        // =========================================================================
        // GRIDVIEW REFRESH AND JOIN DATA RETRIEVAL LOOP
        // =========================================================================
        private void BindAssignmentsGrid()
        {
            string filterLec = ddlFilterLecturer.SelectedValue;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"SELECT co.CourseOfferID, l.LecturerName, co.OfferStatus, 
                                 '[' + c.CourseCode + '] ' + c.CourseName AS CourseDetails,
                                 s.Semester + ' Term (' + CAST(co.Year AS VARCHAR) + ')' AS TermDetails 
                                 FROM CourseOffer co
                                 INNER JOIN Lecturer l ON co.LecturerID = l.LecturerID
                                 INNER JOIN Course c ON co.CourseCode = c.CourseCode
                                 INNER JOIN Semester s ON co.SemesterID = s.SemesterID ";

                if (!string.IsNullOrEmpty(filterLec)) query += "WHERE co.LecturerID = @FilterLecID ";
                query += "ORDER BY co.CourseOfferID DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrEmpty(filterLec)) cmd.Parameters.AddWithValue("@FilterLecID", filterLec);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvAssignments.DataSource = dt;
                            gvAssignments.DataBind();
                        }
                        catch (Exception ex) { ShowStatus("Error assembling allocation list: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void ddlFilterLecturer_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvAssignments.PageIndex = 0;
            BindAssignmentsGrid();
        }

        protected void gvProgrammes_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAssignments.PageIndex = e.NewPageIndex;
            BindAssignmentsGrid();
        }

        // =========================================================================
        // SAVE (INSERT) OR UPDATE EXECUTIONS HANDLING MAPS
        // =========================================================================
        protected void btnSaveAssignment_Click(object sender, EventArgs e)
        {
            string lecturerId = ddlLecturers.SelectedValue;
            string courseCode = ddlCourses.SelectedValue;
            string semesterId = ddlSemesters.SelectedValue;
            string yearStr = txtYear.Text.Trim();
            string status = ddlStatus.SelectedValue;

            if (string.IsNullOrEmpty(lecturerId) || string.IsNullOrEmpty(courseCode) || string.IsNullOrEmpty(yearStr))
            {
                ShowStatus("Please map both Lecturer, Course Module, and structural year fields before saving.", false);
                return;
            }

            int.TryParse(yearStr, out int year);
            bool isUpdate = !string.IsNullOrEmpty(hfCourseOfferID.Value);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "";
                if (isUpdate)
                {
                    query = "UPDATE CourseOffer SET CourseCode = @CourseCode, SemesterID = @SemesterID, Year = @Year, OfferStatus = @OfferStatus, LecturerID = @LecturerID WHERE CourseOfferID = @ID";
                }
                else
                {
                    // Guard checkpoint constraint logic to prevent double booking the identical course to a lecturer in the same term
                    string duplicateCheck = "SELECT COUNT(1) FROM CourseOffer WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND Year = @Year AND LecturerID = @LecturerID";
                    using (SqlCommand checkCmd = new SqlCommand(duplicateCheck, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@CourseCode", courseCode);
                        checkCmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(semesterId));
                        checkCmd.Parameters.AddWithValue("@Year", year);
                        checkCmd.Parameters.AddWithValue("@LecturerID", Convert.ToInt32(lecturerId));
                        try
                        {
                            conn.Open();
                            if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                            {
                                ShowStatus("Duplicate Assignment Error: This lecturer is already assigned to teach this course during this exact term cycle row.", false);
                                return;
                            }
                        }
                        catch (Exception ex) { ShowStatus("Pre-transaction fail: " + ex.Message, false); return; }
                        finally { conn.Close(); }
                    }

                    query = "INSERT INTO CourseOffer (CourseCode, SemesterID, Year, OfferStatus, LecturerID) VALUES (@CourseCode, @SemesterID, @Year, @OfferStatus, @LecturerID)";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseCode", courseCode);
                    cmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(semesterId));
                    cmd.Parameters.AddWithValue("@Year", year);
                    cmd.Parameters.AddWithValue("@OfferStatus", status);
                    cmd.Parameters.AddWithValue("@LecturerID", Convert.ToInt32(lecturerId));
                    if (isUpdate) cmd.Parameters.AddWithValue("@ID", Convert.ToInt32(hfCourseOfferID.Value));

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowStatus(isUpdate ? "Teaching assignation modified successfully!" : "Course offer successfully scheduled to faculty lecturer!", true);
                        ClearAssignmentForm();
                        BindAssignmentsGrid();
                        CalculateSummaryMetrics();
                    }
                    catch (Exception ex) { ShowStatus("Database write execution error: " + ex.Message, false); }
                }
            }
        }

        // =========================================================================
        // ROW ACTION HUB LINKS (EDIT MANAGEMENT / PURGES)
        // =========================================================================
        protected void gvAssignments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditAssignment")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT CourseOfferID, CourseCode, SemesterID, Year, OfferStatus, LecturerID FROM CourseOffer WHERE CourseOfferID = @ID";
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
                                    hfCourseOfferID.Value = dr["CourseOfferID"].ToString();
                                    ddlLecturers.SelectedValue = dr["LecturerID"].ToString();
                                    ddlCourses.SelectedValue = dr["CourseCode"].ToString();
                                    ddlSemesters.SelectedValue = dr["SemesterID"].ToString();
                                    txtYear.Text = dr["Year"].ToString();
                                    ddlStatus.SelectedValue = dr["OfferStatus"].ToString();

                                    btnSaveAssignment.Text = "Update Assignment";
                                    btnCancelEdit.Visible = true;
                                    ShowStatus("Duty details loaded. Modify fields and click update to save.", true);
                                }
                            }
                        }
                        catch (Exception ex) { ShowStatus("Error pulling duty record: " + ex.Message, false); }
                    }
                }
            }
            else if (e.CommandName == "DeleteAssignment")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM CourseOffer WHERE CourseOfferID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", id);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowStatus("Teaching assignment row cleared cleanly.", true);
                            ClearAssignmentForm();
                            BindAssignmentsGrid();
                            CalculateSummaryMetrics();
                        }
                        catch (Exception ex) { ShowStatus("Purge failed. Constraint active row check: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void gvAssignments_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAssignments.PageIndex = e.NewPageIndex;
            BindAssignmentsGrid();
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e) { ClearAssignmentForm(); }

        private void ClearAssignmentForm()
        {
            hfCourseOfferID.Value = string.Empty;
            ddlLecturers.SelectedIndex = 0;
            ddlCourses.SelectedIndex = 0;
            ddlSemesters.SelectedIndex = 0;
            txtYear.Text = DateTime.Now.Year.ToString();
            ddlStatus.SelectedIndex = 0;
            btnSaveAssignment.Text = "Confirm Assignment";
            btnCancelEdit.Visible = false;
        }

        // =========================================================================
        // AGGREGATE SUMMARY CALCULATOR METRICS FOR THE SYSTEM CARDS
        // =========================================================================
        private void CalculateSummaryMetrics()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"SELECT COUNT(1) AS Total, 
                                 SUM(CASE WHEN OfferStatus = 'Available' THEN 1 ELSE 0 END) AS Active,
                                 SUM(CASE WHEN OfferStatus = 'Not Available' THEN 1 ELSE 0 END) AS Inactive 
                                 FROM CourseOffer";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read() && dr["Total"] != DBNull.Value)
                            {
                                litTotalAllocations.Text = dr["Total"].ToString();
                                litActiveOffers.Text = dr["Active"].ToString();
                                litInactiveOffers.Text = dr["Inactive"].ToString();
                            }
                        }
                    }
                    catch { /* Handle fallback empty parameters cleanly */ }
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
            lblStatus.ForeColor = isSuccess ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed;
            lblStatus.Visible = true;
        }
    }
}