using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageCourses : System.Web.UI.Page
    {
        // Re-aligned connection parameters directly pointing to your team's live database name
        private string connString = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                PopulateProgrammeDropdowns();
                BindCoursesGrid();
            }
        }

        private void RefreshAllData()
        {
            PopulateProgrammeDropdowns();
            BindCoursesGrid();
        }

        // =========================================================================
        // REFRESH AND GRID-POPULATE ACTIVE SYLLABUS ENTRIES
        // =========================================================================
        private void BindCoursesGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Refactored to reference team-confirmed tables 'Course' and 'Programme'
                string query = "SELECT c.CourseCode, c.CourseName, c.CreditHours, p.ProgrammeName FROM Course c " +
                               "INNER JOIN Programme p ON c.ProgrammeCode = p.ProgrammeCode ";

                if (!string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue))
                {
                    query += "WHERE c.ProgrammeCode = @FilterProgCode ";
                }

                query += "ORDER BY c.CourseCode ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@FilterProgCode", ddlFilterProgramme.SelectedValue);
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvCourses.DataSource = dt;
                            gvCourses.DataBind();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error rendering curriculum directories: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        // =========================================================================
        // SYNC DROPDOWNS FROM LIVE DATABASE CURRICULUM SELECTION STRINGS
        // =========================================================================
        private void PopulateProgrammeDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Pulling directly from team unified table layout parameters
                string query = "SELECT ProgrammeCode, ProgrammeName FROM Programme ORDER BY ProgrammeName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            ddlProgrammes.Items.Clear();
                            ddlProgrammes.Items.Add(new ListItem("-- Choose Associated Program --", ""));

                            string currentSelectedFilter = ddlFilterProgramme.SelectedValue;
                            ddlFilterProgramme.Items.Clear();
                            ddlFilterProgramme.Items.Add(new ListItem("All Programmes", ""));

                            while (dr.Read())
                            {
                                string code = dr["ProgrammeCode"].ToString();
                                string name = dr["ProgrammeName"].ToString();

                                // Storing ProgrammeCode string as data values safely
                                ddlProgrammes.Items.Add(new ListItem($"[{code}] {name}", code));
                                ddlFilterProgramme.Items.Add(new ListItem(name, code));
                            }

                            if (ddlFilterProgramme.Items.FindByValue(currentSelectedFilter) != null)
                            {
                                ddlFilterProgramme.SelectedValue = currentSelectedFilter;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowStatus("Failed to load active curriculum routes: " + ex.Message, false);
                    }
                }
            }
        }

        protected void ddlFilterProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindCoursesGrid();
        }

        // =========================================================================
        // TRANSACTION WRITE ACTION CONTROLLER (INSERTION OR VALUE OVERWRITES)
        // =========================================================================
        protected void btnSaveCourse_Click(object sender, EventArgs e)
        {
            string code = txtCourseCode.Text.Trim().ToUpper();
            string name = txtCourseName.Text.Trim();
            string creditStr = txtCreditHours.Text.Trim();
            string progCode = ddlProgrammes.SelectedValue;
            string desc = txtDescription.Text.Trim();

            if (string.IsNullOrWhiteSpace(code) || string.IsNullOrWhiteSpace(name) || string.IsNullOrEmpty(progCode) || string.IsNullOrWhiteSpace(creditStr))
            {
                ShowStatus("All basic core fields are required before logging records.", false);
                return;
            }

            int.TryParse(creditStr, out int credits);
            bool isUpdate = !string.IsNullOrEmpty(hfOriginalCourseCode.Value);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "";
                if (isUpdate)
                {
                    // Update targeting original primary key string parameter fields
                    query = "UPDATE Course SET CourseCode = @CourseCode, CourseName = @CourseName, CreditHours = @CreditHours, ProgrammeCode = @ProgrammeCode, Description = @Desc WHERE CourseCode = @OrigCode";
                }
                else
                {
                    // Check duplicate constraint values before running inserts
                    string checkQuery = "SELECT COUNT(1) FROM Course WHERE CourseCode = @CourseCode";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@CourseCode", code);
                        try
                        {
                            conn.Open();
                            if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                            {
                                ShowStatus($"A module record with Course Code '{code}' already exists.", false);
                                return;
                            }
                        }
                        catch (Exception ex) { ShowStatus("Validation failure: " + ex.Message, false); return; }
                        finally { conn.Close(); }
                    }

                    query = "INSERT INTO Course (CourseCode, CourseName, CreditHours, ProgrammeCode, Description) VALUES (@CourseCode, @CourseName, @CreditHours, @ProgrammeCode, @Desc)";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseCode", code);
                    cmd.Parameters.AddWithValue("@CourseName", name);
                    cmd.Parameters.AddWithValue("@CreditHours", credits);
                    cmd.Parameters.AddWithValue("@ProgrammeCode", progCode);
                    cmd.Parameters.AddWithValue("@Desc", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc);
                    if (isUpdate)
                    {
                        cmd.Parameters.AddWithValue("@OrigCode", hfOriginalCourseCode.Value);
                    }

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowStatus(isUpdate ? "Course specifics updated successfully!" : "New module registered into curriculum maps!", true);
                        ClearCourseForm();
                        BindCoursesGrid();
                    }
                    catch (Exception ex)
                    {
                        ShowStatus("Database transaction update execution error: " + ex.Message, false);
                    }
                }
            }
        }

        // =========================================================================
        // DATA ROW COMMAND LINK INTERCEPT ACTION ROUTER (EDIT MODES / PURGES)
        // =========================================================================
        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;
            string targetCode = e.CommandArgument.ToString();

            if (e.CommandName == "EditCourse")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT CourseCode, CourseName, CreditHours, ProgrammeCode, Description FROM Course WHERE CourseCode = @CourseCode";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseCode", targetCode);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    hfOriginalCourseCode.Value = dr["CourseCode"].ToString();
                                    txtCourseCode.Text = dr["CourseCode"].ToString();
                                    txtCourseName.Text = dr["CourseName"].ToString();
                                    txtCreditHours.Text = dr["CreditHours"].ToString();
                                    txtDescription.Text = dr["Description"].ToString();
                                    ddlProgrammes.SelectedValue = dr["ProgrammeCode"].ToString();

                                    txtCourseCode.Enabled = true; // Primary Code fields open for structural re-mapping
                                    btnSaveCourse.Text = "Update Course";
                                    btnCancelCourse.Visible = true;
                                    ShowStatus("Course variables staged. Make updates and save configurations.", true);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Failed to fetch requested course file: " + ex.Message, false);
                        }
                    }
                }
            }
            else if (e.CommandName == "DeleteCourse")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // First, check if any CourseOffer records reference this course
                    string checkQuery = "SELECT COUNT(1) FROM CourseOffer WHERE CourseCode = @CourseCode";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@CourseCode", targetCode);
                        try
                        {
                            conn.Open();
                            int offerCount = (int)checkCmd.ExecuteScalar();
                            conn.Close();

                            if (offerCount > 0)
                            {
                                ShowStatus($"Cannot delete course '{targetCode}' – it is linked to {offerCount} active semester offer(s). Please remove or reassign those offers first.", false);
                                return;
                            }
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error checking course dependencies: " + ex.Message, false);
                            return;
                        }
                    }

                    // No dependencies – safe to delete
                    string deleteQuery = "DELETE FROM Course WHERE CourseCode = @CourseCode";
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseCode", targetCode);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowStatus("Module row purged successfully from records.", true);
                            ClearCourseForm();
                            BindCoursesGrid();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Wipe aborted. An unexpected error occurred: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        protected void btnCancelCourse_Click(object sender, EventArgs e)
        {
            ClearCourseForm();
        }

        private void ClearCourseForm()
        {
            hfOriginalCourseCode.Value = string.Empty;
            txtCourseCode.Text = string.Empty;
            txtCourseName.Text = string.Empty;
            txtDescription.Text = string.Empty;
            txtCreditHours.Text = "3";
            ddlProgrammes.SelectedIndex = 0;
            btnSaveCourse.Text = "Register Course";
            btnCancelCourse.Visible = false;
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