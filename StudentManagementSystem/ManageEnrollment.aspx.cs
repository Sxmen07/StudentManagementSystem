using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls; // FIXED: Ensures DataControlRowType compiles perfectly across all build profiles

namespace StudentManagementSystem
{
    public partial class ManageEnrollment : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                PopulateStagingSchools();
                PopulateSemesters();
                PopulateLecturers();

                PopulateSortingSchools();
                PopulateSortingProgrammes(null);
                PopulateSortingLecturers();

                BindCourseOffersGrid();
            }
        }

        private void PopulateStagingSchools()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT FacultyID, FacultyName FROM Faculty ORDER BY FacultyName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        DataTable dt = new DataTable();
                        dt.Load(cmd.ExecuteReader());
                        ddlSchool.DataSource = dt;
                        ddlSchool.DataValueField = "FacultyID";
                        ddlSchool.DataTextField = "FacultyName";
                        ddlSchool.DataBind();
                    }
                    catch { }
                }
            }
            ddlSchool.Items.Insert(0, new ListItem("-- Select Hosting School --", ""));
            ddlProgram.Items.Insert(0, new ListItem("Choose School First", ""));
            ddlCourse.Items.Insert(0, new ListItem("Choose Program First", ""));
        }

        private void PopulateSemesters()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT SemesterID, (Semester + ' - ' + StartMonthDay) AS SemName FROM Semester ORDER BY SemesterID ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        ddlSemester.DataSource = cmd.ExecuteReader();
                        ddlSemester.DataValueField = "SemesterID";
                        ddlSemester.DataTextField = "SemName";
                        ddlSemester.DataBind();
                    }
                    catch { }
                }
            }
            ddlSemester.Items.Insert(0, new ListItem("-- Select Target Term --", ""));
        }

        private void PopulateLecturers()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT LecturerID, LecturerName FROM Lecturer ORDER BY LecturerName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        ddlLecturer.DataSource = cmd.ExecuteReader();
                        ddlLecturer.DataValueField = "LecturerID";
                        ddlLecturer.DataTextField = "LecturerName";
                        ddlLecturer.DataBind();
                    }
                    catch { }
                }
            }
            ddlLecturer.Items.Insert(0, new ListItem("-- Allocate Lecturer Lead --", ""));
        }

        private void PopulateSortingSchools()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT FacultyID, FacultyName FROM Faculty ORDER BY FacultyName ASC", conn))
                {
                    try
                    {
                        conn.Open();
                        ddlSortSchool.DataSource = cmd.ExecuteReader();
                        ddlSortSchool.DataValueField = "FacultyID";
                        ddlSortSchool.DataTextField = "FacultyName";
                        ddlSortSchool.DataBind();
                    }
                    catch { }
                }
            }
            ddlSortSchool.Items.Insert(0, new ListItem("All Schools", ""));
        }

        private void PopulateSortingProgrammes(int? facultyId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT ProgrammeCode, ProgrammeName FROM Programme ";
                if (facultyId.HasValue) query += "WHERE FacultyID = @FacID ";
                query += "ORDER BY ProgrammeName ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (facultyId.HasValue) cmd.Parameters.AddWithValue("@FacID", facultyId.Value);
                    try
                    {
                        conn.Open();
                        ddlSortProgram.DataSource = cmd.ExecuteReader();
                        ddlSortProgram.DataValueField = "ProgrammeCode";
                        ddlSortProgram.DataTextField = "ProgrammeName";
                        ddlSortProgram.DataBind();
                    }
                    catch { }
                }
            }
            ddlSortProgram.Items.Insert(0, new ListItem("All Programs", ""));
        }

        private void PopulateSortingLecturers()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT LecturerID, LecturerName FROM Lecturer ORDER BY LecturerName ASC", conn))
                {
                    try
                    {
                        conn.Open();
                        ddlSortLecturer.DataSource = cmd.ExecuteReader();
                        ddlSortLecturer.DataValueField = "LecturerID";
                        ddlSortLecturer.DataTextField = "LecturerName";
                        ddlSortLecturer.DataBind();
                    }
                    catch { }
                }
            }
            ddlSortLecturer.Items.Insert(0, new ListItem("All Lecturers", ""));
        }

        protected void ddlSchool_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlProgram.Items.Clear();
            ddlCourse.Items.Clear();
            ddlCourse.Items.Insert(0, new ListItem("Choose Program First", ""));

            if (ddlSchool.SelectedIndex > 0)
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT ProgrammeCode, ProgrammeName FROM Programme WHERE FacultyID = @FacID ORDER BY ProgrammeName ASC";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@FacID", ddlSchool.SelectedValue);
                        try
                        {
                            conn.Open();
                            ddlProgram.DataSource = cmd.ExecuteReader();
                            ddlProgram.DataValueField = "ProgrammeCode";
                            ddlProgram.DataTextField = "ProgrammeName";
                            ddlProgram.DataBind();
                        }
                        catch { }
                    }
                }
            }
            ddlProgram.Items.Insert(0, new ListItem("-- Select Program --", ""));
        }

        protected void ddlProgram_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlCourse.Items.Clear();
            if (ddlProgram.SelectedIndex > 0)
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT CourseCode, CourseName FROM Course WHERE ProgrammeCode = @ProgCode ORDER BY CourseName ASC";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ProgCode", ddlProgram.SelectedValue);
                        try
                        {
                            conn.Open();
                            ddlCourse.DataSource = cmd.ExecuteReader();
                            ddlCourse.DataValueField = "CourseCode";
                            ddlCourse.DataTextField = "CourseName";
                            ddlCourse.DataBind();
                        }
                        catch { }
                    }
                }
            }
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
        }

        protected void ddlSortSchool_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlSortSchool.SelectedIndex > 0)
                PopulateSortingProgrammes(Convert.ToInt32(ddlSortSchool.SelectedValue));
            else
                PopulateSortingProgrammes(null);

            BindCourseOffersGrid();
        }

        protected void ddlSortProgram_SelectedIndexChanged(object sender, EventArgs e) { BindCourseOffersGrid(); }
        protected void ddlSortLecturer_SelectedIndexChanged(object sender, EventArgs e) { BindCourseOffersGrid(); }

        private void BindCourseOffersGrid()
        {
            gvCourseOffers.DataSource = FetchFilteredCapacityOffers();
            gvCourseOffers.DataBind();
        }

        private DataTable FetchFilteredCapacityOffers()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                StringBuilder sb = new StringBuilder("SELECT CourseOfferID, CourseCode, CourseName, ProgrammeName, SchoolName, Semester, LecturerID, LecturerName, MaxCapacity, TotalEnrolled FROM Vw_EnrollmentCapacityRegistry WHERE 1=1");

                if (ddlSortSchool.SelectedIndex > 0) sb.Append(" AND FacultyID = @SortFacID");
                if (ddlSortProgram.SelectedIndex > 0) sb.Append(" AND ProgrammeCode = @SortProgCode");
                if (ddlSortLecturer.SelectedIndex > 0) sb.Append(" AND LecturerID = @SortLecID");

                sb.Append(" ORDER BY TotalEnrolled DESC");

                using (SqlCommand cmd = new SqlCommand(sb.ToString(), conn))
                {
                    if (ddlSortSchool.SelectedIndex > 0) cmd.Parameters.AddWithValue("@SortFacID", ddlSortSchool.SelectedValue);
                    if (ddlSortProgram.SelectedIndex > 0) cmd.Parameters.AddWithValue("@SortProgCode", ddlSortProgram.SelectedValue);
                    if (ddlSortLecturer.SelectedIndex > 0) cmd.Parameters.AddWithValue("@SortLecID", ddlSortLecturer.SelectedValue);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) { da.Fill(dt); }
                }
            }
            return dt;
        }

        protected void gvCourseOffers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvCourseOffers.EditIndex = e.NewEditIndex;
            BindCourseOffersGrid();
        }

        protected void gvCourseOffers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvCourseOffers.EditIndex = -1;
            BindCourseOffersGrid();
        }

        protected void gvCourseOffers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // FIXED: Reference changed to clear DataControlFieldType build errors safely
            if (e.Row.RowType == DataControlRowType.DataRow && gvCourseOffers.EditIndex == e.Row.RowIndex)
            {
                DropDownList ddlGridLecturer = (DropDownList)e.Row.FindControl("ddlGridLecturer");
                HiddenField hfHiddenLecturerID = (HiddenField)e.Row.FindControl("hfHiddenLecturerID");

                if (ddlGridLecturer != null && hfHiddenLecturerID != null)
                {
                    using (SqlConnection conn = new SqlConnection(connString))
                    {
                        string query = "SELECT LecturerID, LecturerName FROM Lecturer ORDER BY LecturerName ASC";
                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            try
                            {
                                conn.Open();
                                ddlGridLecturer.DataSource = cmd.ExecuteReader();
                                ddlGridLecturer.DataValueField = "LecturerID";
                                ddlGridLecturer.DataTextField = "LecturerName";
                                ddlGridLecturer.DataBind();

                                if (ddlGridLecturer.Items.FindByValue(hfHiddenLecturerID.Value) != null)
                                {
                                    ddlGridLecturer.SelectedValue = hfHiddenLecturerID.Value;
                                }
                            }
                            catch { }
                        }
                    }
                }
            }
        }

        protected void gvCourseOffers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int offerId = Convert.ToInt32(gvCourseOffers.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvCourseOffers.Rows[e.RowIndex];

            DropDownList ddlGridLecturer = (DropDownList)row.FindControl("ddlGridLecturer");
            TextBox txtGridMaxCapacity = (TextBox)row.FindControl("txtGridMaxCapacity");

            if (ddlGridLecturer == null || txtGridMaxCapacity == null) return;

            int newLecturerId = Convert.ToInt32(ddlGridLecturer.SelectedValue);
            int.TryParse(txtGridMaxCapacity.Text.Trim(), out int newCapacity);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string capCheckQuery = "SELECT TotalEnrolled FROM Vw_EnrollmentCapacityRegistry WHERE CourseOfferID = @ID";
                using (SqlCommand checkCmd = new SqlCommand(capCheckQuery, conn))
                {
                    checkCmd.Parameters.AddWithValue("@ID", offerId);
                    try
                    {
                        conn.Open();
                        int activeEnrolled = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (newCapacity < activeEnrolled)
                        {
                            ShowStatus($"Validation conflict error: Seating size ({newCapacity}) cannot be lower than the amount of students currently registered ({activeEnrolled}).", false);
                            return;
                        }
                    }
                    catch { }
                    finally { conn.Close(); }
                }

                string updateQuery = "UPDATE CourseOffer SET LecturerID = @LecID, MaxCapacity = @MaxCap WHERE CourseOfferID = @ID";
                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@LecID", newLecturerId);
                    cmd.Parameters.AddWithValue("@MaxCap", newCapacity);
                    cmd.Parameters.AddWithValue("@ID", offerId);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowStatus("Course offer structural configurations modified and synchronized successfully!", true);

                        gvCourseOffers.EditIndex = -1;
                        BindCourseOffersGrid();
                    }
                    catch (Exception ex) { ShowStatus("Database runtime transaction failure: " + ex.Message, false); }
                }
            }
        }

        protected void btnOpenEnrollment_Click(object sender, EventArgs e)
        {
            string courseCode = ddlCourse.SelectedValue;
            string semId = ddlSemester.SelectedValue;
            string lecId = ddlLecturer.SelectedValue;
            string capacityStr = txtMaxCapacity.Text.Trim();

            if (ddlCourse.SelectedIndex <= 0 || ddlSemester.SelectedIndex <= 0 || ddlLecturer.SelectedIndex <= 0 || string.IsNullOrEmpty(capacityStr))
            {
                ShowStatus("Validation error: Complete all staging parameters first.", false);
                return;
            }

            int.TryParse(capacityStr, out int maxCapacity);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string checkQuery = "SELECT COUNT(1) FROM CourseOffer WHERE CourseCode = @CourseCode AND SemesterID = @SemID";
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                {
                    checkCmd.Parameters.AddWithValue("@CourseCode", courseCode);
                    checkCmd.Parameters.AddWithValue("@SemID", semId);
                    try
                    {
                        conn.Open();
                        if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                        {
                            ShowStatus($"This specific course module section [{courseCode}] is already open for this intake.", false);
                            return;
                        }
                    }
                    catch { }
                    finally { conn.Close(); }
                }

                string insertQuery = "INSERT INTO CourseOffer (CourseCode, SemesterID, LecturerID, Year, MaxCapacity) VALUES (@CourseCode, @SemID, @LecID, 2026, @MaxCap)";
                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseCode", courseCode);
                    cmd.Parameters.AddWithValue("@SemID", Convert.ToInt32(semId));
                    cmd.Parameters.AddWithValue("@LecID", Convert.ToInt32(lecId));
                    cmd.Parameters.AddWithValue("@MaxCap", maxCapacity);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowStatus("Course offering successfully deployed with customized intake metrics!", true);
                        ResetPlanningFormState();
                        BindCourseOffersGrid();
                    }
                    catch (Exception ex) { ShowStatus("Database communication fault: " + ex.Message, false); }
                }
            }
        }

        protected void gvCourseOffers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "CloseOffer")
            {
                int offerId = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM CourseOffer WHERE CourseOfferID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", offerId);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowStatus("Course slot closed cleanly. Student admission tracking vectors dropped.", true);
                            BindCourseOffersGrid();
                        }
                        catch (Exception ex) { ShowStatus("Wipe aborted. Records are currently linked to this node: " + ex.Message, false); }
                    }
                }
            }
        }

        private void ResetPlanningFormState()
        {
            ddlCourse.SelectedIndex = 0;
            txtMaxCapacity.Text = "40";
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            DataTable dt = FetchFilteredCapacityOffers();
            StringBuilder sb = new StringBuilder();

            string schoolContext = ddlSortSchool.SelectedIndex > 0 ? ddlSortSchool.SelectedItem.Text : "All Schools";
            string programContext = ddlSortProgram.SelectedIndex > 0 ? ddlSortProgram.SelectedItem.Text : "All Programmes";

            string topCourse = dt.Rows.Count > 0 ? dt.Rows[0]["CourseName"].ToString() : "N/A";
            string lowestCourse = dt.Rows.Count > 0 ? dt.Rows[dt.Rows.Count - 1]["CourseName"].ToString() : "N/A";

            sb.AppendLine("ENROLMENT STATISTICS TRENDS ANALYTICS REPORT");
            sb.AppendLine($"School Context Summary,{schoolContext}");
            sb.AppendLine($"Programme Target Filter,{programContext}");
            sb.AppendLine($"Generated Academic Date,{DateTime.Today:yyyy-MM-dd}");
            sb.AppendLine();
            sb.AppendLine($"HIGHEST DEMAND COHORT (Most Enrolled),\"{topCourse}\"");
            sb.AppendLine($"LOWEST ENROLMENT MODULE (Most Empty Seats),\"{lowestCourse}\"");
            sb.AppendLine();

            sb.AppendLine("Course Code,Course Module Title,Intake Semester,Assigned Lecturer,Total Seats,Enrolled Students,Empty Seats,Enrolled Percentage");
            foreach (DataRow row in dt.Rows)
            {
                int max = Convert.ToInt32(row["MaxCapacity"]);
                int current = Convert.ToInt32(row["TotalEnrolled"]);
                int empty = max - current;
                double pct = max > 0 ? (current * 100.0) / max : 0.0;

                sb.AppendLine($"\"{row["CourseCode"]}\",\"{row["CourseName"]}\",\"{row["Semester"]}\",\"{row["LecturerName"]}\",{max},{current},{empty},{pct:0.0}%");
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Enrolment_Pipeline_Analytics.csv");
            Response.ContentType = "text/csv";
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = FetchFilteredCapacityOffers();
            DataTable cleanGrid = new DataTable();

            cleanGrid.Columns.Add("Course Code");
            cleanGrid.Columns.Add("Course Title");
            cleanGrid.Columns.Add("Intake Semester");
            cleanGrid.Columns.Add("Assigned Lecturer");
            cleanGrid.Columns.Add("Total Seats");
            cleanGrid.Columns.Add("Enrolled Students");
            cleanGrid.Columns.Add("Empty Seats");
            cleanGrid.Columns.Add("Enrolled Percentage");

            foreach (DataRow row in dt.Rows)
            {
                int max = Convert.ToInt32(row["MaxCapacity"]);
                int current = Convert.ToInt32(row["TotalEnrolled"]);
                int empty = max - current;
                double pct = max > 0 ? (current * 100.0) / max : 0.0;

                cleanGrid.Rows.Add(row["CourseCode"], row["CourseName"], row["Semester"], row["LecturerName"], max, current, empty, pct.ToString("0.0") + "%");
            }

            string topCourse = dt.Rows.Count > 0 ? dt.Rows[0]["CourseName"].ToString() : "N/A";
            string lowestCourse = dt.Rows.Count > 0 ? dt.Rows[dt.Rows.Count - 1]["CourseName"].ToString() : "N/A";

            GridView gv = new GridView { DataSource = cleanGrid };
            gv.DataBind();

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Enrolment_Pipeline_Analytics.xls");
            Response.ContentType = "application/ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter htw = new HtmlTextWriter(sw))
                {
                    Response.Write("<table border='1' style='font-family:Arial; font-size:11px;'>");
                    Response.Write("<tr><td colspan='8' style='font-size:14px; font-weight:bold; background-color:#eaeae8;'>CURRICULUM ENROLMENT ANALYSIS AND DEMAND TRENDS</td></tr>");
                    Response.Write($"<tr><td colspan='2'><b>School Scope:</b></td><td colspan='6'>{(ddlSortSchool.SelectedIndex > 0 ? ddlSortSchool.SelectedItem.Text : "All Schools")}</td></tr>");
                    Response.Write($"<tr><td colspan='2'><b>Programme Scope:</b></td><td colspan='6'>{(ddlSortProgram.SelectedItem.Text != "All Programs" ? ddlSortProgram.SelectedItem.Text : "All Programmes")}</td></tr>");
                    Response.Write($"<tr><td colspan='2'><b>Highest Enrolment Trend:</b></td><td colspan='6'>{topCourse}</td></tr>");
                    Response.Write($"<tr><td colspan='2'><b>Highest Vacancies Trend:</b></td><td colspan='6'>{lowestCourse}</td></tr>");
                    Response.Write("<tr><td colspan='8'></td></tr>");
                    Response.Write("</table>");

                    gv.RenderControl(htw);
                    Response.Output.Write(sw.ToString());
                    Response.Flush();
                    Response.End();
                }
            }
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = FetchFilteredCapacityOffers();
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Enrolment_Pipeline_Analytics.html");
            Response.ContentType = "text/html";

            string topCourse = dt.Rows.Count > 0 ? dt.Rows[0]["CourseName"].ToString() : "N/A";
            string lowestCourse = dt.Rows.Count > 0 ? dt.Rows[dt.Rows.Count - 1]["CourseName"].ToString() : "N/A";

            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><style>");
            sb.Append("body { font-family: Arial, sans-serif; padding: 25px; color: #333; max-width: 850px; margin: 0 auto; } ");
            sb.Append("h2 { font-size: 16px; font-weight: bold; margin-bottom: 2px; text-transform: uppercase; letter-spacing: 0.5px; } ");
            sb.Append(".trend-box { font-size: 11px; color: #444; background-color: #f7f9fc; padding: 12px; border: 1px solid #dbe2ef; border-radius: 8px; margin-bottom: 20px; line-height: 1.8; } ");
            sb.Append("table { width: 100%; border-collapse: collapse; margin-top: 10px; } ");
            sb.Append("th { border-bottom: 2px solid #111; padding: 8px; text-align: left; font-size: 11px; font-weight: bold; background-color: #f7f7f5; } ");
            sb.Append("td { border-bottom: 1px solid #e5e5e5; padding: 8px; font-size: 11px; vertical-align: middle; } ");
            sb.Append(".text-center { text-align: center; } ");
            sb.Append("</style></head><body>");

            sb.Append("<h2>Curriculum Enrolment Trend Analysis Report</h2>");

            sb.Append("<div class='trend-box'>");
            sb.Append($"<b>School Context Scope:</b> {(ddlSortSchool.SelectedIndex > 0 ? ddlSortSchool.SelectedItem.Text : "All Schools")}<br/>");
            sb.Append($"<b>Programme Target Context:</b> {(ddlSortProgram.SelectedItem.Text != "All Programs" ? ddlSortProgram.SelectedItem.Text : "All Programmes")}<br/>");
            sb.Append($"<b>🔥 Highest Demand Course Enrolment:</b> <span style='color:#1e40af; font-weight:bold;'>{topCourse}</span><br/>");
            sb.Append($"<b>⚠️ Highest Empty Seats Counter:</b> <span style='color:#991b1b; font-weight:bold;'>{lowestCourse}</span><br/>");
            sb.Append("</div>");

            sb.Append("<table><thead><tr>");
            sb.Append("<th>Code</th><th>Course Module Title</th><th>Semester</th><th>Lecturer</th><th class='text-center'>Total Seats</th><th class='text-center'>Enrolled</th><th class='text-center'>Empty</th><th class='text-center'>Ratio</th>");
            sb.Append("</tr></thead><tbody>");

            foreach (DataRow row in dt.Rows)
            {
                int max = Convert.ToInt32(row["MaxCapacity"]);
                int current = Convert.ToInt32(row["TotalEnrolled"]);
                int empty = max - current;
                double pct = max > 0 ? (current * 100.0) / max : 0.0;

                sb.Append("<tr>");
                sb.Append($"<td><b>{row["CourseCode"]}</b></td>");
                sb.Append($"<td>{row["CourseName"]}</td>");
                sb.Append($"<td>{row["Semester"]}</td>");
                sb.Append($"<td>{row["LecturerName"]}</td>");
                sb.Append($"<td class='text-center'>{max}</td>");
                sb.Append($"<td class='text-center'>{current}</td>");
                sb.Append($"<td class='text-center'>{empty}</td>");
                sb.Append($"<td class='text-center'><b>{pct:0.0}%</b></td>");
                sb.Append("</tr>");
            }

            sb.Append("</tbody></table></body></html>");

            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            lblStatus.BackColor = isSuccess ? Color.FromArgb(240, 253, 244) : Color.FromArgb(254, 242, 242);
            lblStatus.ForeColor = isSuccess ? Color.MediumSeaGreen : Color.OrangeRed;
            lblStatus.Visible = true;
        }
    }
}