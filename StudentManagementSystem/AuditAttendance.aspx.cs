using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class AuditAttendance : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                //txtDateFilter.Text = DateTime.Today.ToString("yyyy-MM-dd");
                PopulateSchools();
                PopulateLecturers();
                BindAttendanceMatrix();
            }
        }

        private void PopulateSchools()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT FacultyID, FacultyName FROM Faculty ORDER BY FacultyName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        ddlSchool.DataSource = cmd.ExecuteReader();
                        ddlSchool.DataValueField = "FacultyID";
                        ddlSchool.DataTextField = "FacultyName";
                        ddlSchool.DataBind();
                    }
                    catch { }
                }
            }
            ddlSchool.Items.Insert(0, new ListItem("All Schools", ""));
            ddlProgram.Items.Insert(0, new ListItem("Choose School First", ""));
            ddlCourse.Items.Insert(0, new ListItem("Choose Program First", ""));
        }

        private void PopulateLecturers()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT LecturerID, LecturerName FROM Lecturer ORDER BY LecturerName";
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
            ddlLecturer.Items.Insert(0, new ListItem("All Lecturers", ""));
        }

        protected void ddlSchool_OriginalChanged(object sender, EventArgs e)
        {
            ddlProgram.Items.Clear();
            if (ddlSchool.SelectedIndex > 0)
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT ProgrammeCode, ProgrammeName FROM Programme WHERE FacultyID = @FacID ORDER BY ProgrammeName";
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
            ddlProgram.Items.Insert(0, new ListItem("All Programs", ""));
            ddlCourse.Items.Clear();
            ddlCourse.Items.Insert(0, new ListItem("All Courses", ""));
            BindAttendanceMatrix();
        }

        protected void ddlProgram_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlCourse.Items.Clear();
            if (ddlProgram.SelectedIndex > 0)
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT CourseCode, CourseName FROM Course WHERE ProgrammeCode = @ProgCode ORDER BY CourseName";
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
            ddlCourse.Items.Insert(0, new ListItem("All Courses", ""));
            BindAttendanceMatrix();
        }

        protected void ddlSchool_SelectedIndexChanged(object sender, EventArgs e) { ddlSchool_OriginalChanged(sender, e); }
        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e) { BindAttendanceMatrix(); }
        protected void ddlLecturer_SelectedIndexChanged(object sender, EventArgs e) { BindAttendanceMatrix(); }
        protected void txtDateFilter_TextChanged(object sender, EventArgs e) { BindAttendanceMatrix(); }

        private void BindAttendanceMatrix()
        {
            DataTable dt = FetchFilteredAttendanceData();
            gvAttendance.DataSource = dt;
            gvAttendance.DataBind();

            int total = dt.Rows.Count;
            int presentAndLate = 0;
            int absent = 0;

            foreach (DataRow r in dt.Rows)
            {
                string status = r["AttendanceStatus"].ToString();
                if (status == "Present" || status == "Late") presentAndLate++;
                else if (status == "Absent") absent++;
            }

            litTotalStudents.Text = total.ToString();
            litTotalAbsent.Text = absent.ToString();
            litAttendBracket.Text = $"({presentAndLate} attend)";

            if (total > 0)
            {
                double rate = (presentAndLate * 100.0) / total;
                litAttendanceRate.Text = rate.ToString("0.0") + "%";
            }
            else
            {
                litAttendanceRate.Text = "0.0%";
            }
        }

        private DataTable FetchFilteredAttendanceData()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                StringBuilder sb = new StringBuilder("SELECT SchoolName, ProgrammeName, CourseCode, CourseName, LecturerName, StudentRoleID, StudentName, AttendanceStatus, ProfilePictureUrl FROM Vw_AdminAttendanceRegistry WHERE 1=1");

                if (ddlSchool.SelectedIndex > 0) sb.Append(" AND FacultyID = @FacID");
                if (ddlProgram.SelectedIndex > 0) sb.Append(" AND ProgrammeCode = @ProgCode");
                if (ddlCourse.SelectedIndex > 0) sb.Append(" AND CourseCode = @CourseCode");
                if (ddlLecturer.SelectedIndex > 0) sb.Append(" AND LecturerID = @LecID");
                if (!string.IsNullOrEmpty(txtDateFilter.Text)) sb.Append(" AND AttendanceDate = @Date");

                using (SqlCommand cmd = new SqlCommand(sb.ToString(), conn))
                {
                    if (ddlSchool.SelectedIndex > 0) cmd.Parameters.AddWithValue("@FacID", ddlSchool.SelectedValue);
                    if (ddlProgram.SelectedIndex > 0) cmd.Parameters.AddWithValue("@ProgCode", ddlProgram.SelectedValue);
                    if (ddlCourse.SelectedIndex > 0) cmd.Parameters.AddWithValue("@CourseCode", ddlCourse.SelectedValue);
                    if (ddlLecturer.SelectedIndex > 0) cmd.Parameters.AddWithValue("@LecID", ddlLecturer.SelectedValue);
                    if (!string.IsNullOrEmpty(txtDateFilter.Text)) cmd.Parameters.AddWithValue("@Date", txtDateFilter.Text);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) { da.Fill(dt); }
                }
            }
            return dt;
        }

        // ============================================
        // CLEANED UPInstitutional 4-COLUMN REPORTERS
        // ============================================
        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            DataTable dt = FetchFilteredAttendanceData();
            StringBuilder sb = new StringBuilder();

            // Pull selected descriptive parameters for metadata blocks
            string schoolLabel = ddlSchool.SelectedIndex > 0 ? ddlSchool.SelectedItem.Text : "All Schools";
            string programLabel = ddlProgram.SelectedIndex > 0 ? ddlProgram.SelectedItem.Text : "All Programmes";
            string courseLabel = ddlCourse.SelectedIndex > 0 ? ddlCourse.SelectedItem.Text : "All Courses";
            string lecturerLabel = ddlLecturer.SelectedIndex > 0 ? ddlLecturer.SelectedItem.Text : "All Faculty Staff";
            string attendanceDateLabel = !string.IsNullOrEmpty(txtDateFilter.Text) ? txtDateFilter.Text : "All Dates Logs";

            // Upper Context Block Configuration
            sb.AppendLine($"INSTITUTIONAL ATTENDANCE AUDIT LOG REPORT");
            sb.AppendLine($"School Context,{schoolLabel}");
            sb.AppendLine($"Programme Context,{programLabel}");
            sb.AppendLine($"Course Context,{courseLabel}");
            sb.AppendLine($"Assigned Lecturer,{lecturerLabel}");
            sb.AppendLine($"Attendance Target Date,{attendanceDateLabel}");
            sb.AppendLine(); // Spacer row line

            // 4-Column Header Definition
            sb.AppendLine("No.,Student Name,ID,Attendance");

            int indexCounter = 1;
            foreach (DataRow r in dt.Rows)
            {
                sb.AppendLine($"{indexCounter},\"{r["StudentName"]}\",{r["StudentRoleID"]},{r["AttendanceStatus"]}");
                indexCounter++;
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Attendance_Audit_Report.csv");
            Response.ContentType = "text/csv";
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = FetchFilteredAttendanceData();

            // Re-map dataset structures manually to force the clean 4-column specification framework
            DataTable excelCleanTable = new DataTable();
            excelCleanTable.Columns.Add("No.");
            excelCleanTable.Columns.Add("Student Name");
            excelCleanTable.Columns.Add("ID");
            excelCleanTable.Columns.Add("Attendance");

            int indexCounter = 1;
            foreach (DataRow r in dt.Rows)
            {
                excelCleanTable.Rows.Add(indexCounter, r["StudentName"], r["StudentRoleID"], r["AttendanceStatus"]);
                indexCounter++;
            }

            string schoolLabel = ddlSchool.SelectedIndex > 0 ? ddlSchool.SelectedItem.Text : "All Schools";
            string programLabel = ddlProgram.SelectedIndex > 0 ? ddlProgram.SelectedItem.Text : "All Programmes";
            string courseLabel = ddlCourse.SelectedIndex > 0 ? ddlCourse.SelectedItem.Text : "All Courses";
            string lecturerLabel = ddlLecturer.SelectedIndex > 0 ? ddlLecturer.SelectedItem.Text : "All Faculty Staff";
            string attendanceDateLabel = !string.IsNullOrEmpty(txtDateFilter.Text) ? txtDateFilter.Text : "All Dates Logs";

            GridView gv = new GridView { DataSource = excelCleanTable };
            gv.DataBind();

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Attendance_Audit_Report.xls");
            Response.ContentType = "application/ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter htw = new HtmlTextWriter(sw))
                {
                    // Construct an clean HTML presentation segment above the generated layout view sheet
                    Response.Write("<table border='1' style='font-family:Arial; font-size:11px;'>");
                    Response.Write($"<tr><td colspan='4' style='font-size:14px; font-weight:bold; background-color:#f2f2f2;'>INSTITUTIONAL ATTENDANCE REPORT SUMMARY</td></tr>");
                    Response.Write($"<tr><td><b>School:</b></td><td colspan='3'>{schoolLabel}</td></tr>");
                    Response.Write($"<tr><td><b>Programme:</b></td><td colspan='3'>{programLabel}</td></tr>");
                    Response.Write($"<tr><td><b>Course:</b></td><td colspan='3'>{courseLabel}</td></tr>");
                    Response.Write($"<tr><td><b>Lecturer Name:</b></td><td colspan='3'>{lecturerLabel}</td></tr>");
                    Response.Write($"<tr><td><b>Attendance Date:</b></td><td colspan='3'>{attendanceDateLabel}</td></tr>");
                    Response.Write("<tr><td colspan='4'></td></tr>"); // Spacer block
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
            DataTable dt = FetchFilteredAttendanceData();
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Attendance_Audit_Report.html");
            Response.ContentType = "text/html";

            string schoolLabel = ddlSchool.SelectedIndex > 0 ? ddlSchool.SelectedItem.Text : "All Schools";
            string programLabel = ddlProgram.SelectedIndex > 0 ? ddlProgram.SelectedItem.Text : "All Programmes";
            string courseLabel = ddlCourse.SelectedIndex > 0 ? ddlCourse.SelectedItem.Text : "All Courses";
            string lecturerLabel = ddlLecturer.SelectedIndex > 0 ? ddlLecturer.SelectedItem.Text : "All Faculty Staff";
            string attendanceDateLabel = !string.IsNullOrEmpty(txtDateFilter.Text) ? txtDateFilter.Text : "All Dates Logs";

            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><style>");
            sb.Append("body { font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 800px; margin: 0 auto; } ");
            sb.Append("h2 { font-size: 16px; font-weight: bold; margin-bottom: 12px; color: #111; text-transform: uppercase; } ");
            sb.Append(".meta-box { font-size: 11px; margin-bottom: 25px; line-height: 1.6; background-color: #fafafa; padding: 12px; border: 1px solid #eaeae8; border-radius: 8px; } ");
            sb.Append("table { width: 100%; border-collapse: collapse; margin-top: 10px; } ");
            sb.Append("th { border-bottom: 2px solid #111; padding: 8px; text-align: left; font-size: 11px; font-weight: bold; background-color: #f7f7f5; } ");
            sb.Append("td { border-bottom: 1px solid #e5e5e5; padding: 8px; font-size: 11px; vertical-align: top; } ");
            sb.Append(".num-col { width: 45px; text-align: center; } ");
            sb.Append(".id-col { width: 100px; font-weight: bold; } ");
            sb.Append(".status-col { width: 90px; font-weight: bold; } ");
            sb.Append("</style></head><body>");

            sb.Append("<h2>Attendance Audit Report Run</h2>");

            // Meta Metadata details row positioning block
            sb.Append("<div class='meta-box'>");
            sb.Append($"<b>School Context:</b> {schoolLabel}<br/>");
            sb.Append($"<b>Programme Target:</b> {programLabel}<br/>");
            sb.Append($"<b>Course Offer Unit:</b> {courseLabel}<br/>");
            sb.Append($"<b>Assigned Faculty Lecturer:</b> {lecturerLabel}<br/>");
            sb.Append($"<b>Attendance Tracking Date:</b> <u>{attendanceDateLabel}</u><br/>");
            sb.Append("</div>");

            sb.Append("<table><thead><tr>");
            sb.Append("<th class='num-col'>No.</th>");
            sb.Append("<th>Student Name</th>");
            sb.Append("<th class='id-col'>ID</th>");
            sb.Append("<th class='status-col'>Attendance</th>");
            sb.Append("</tr></thead><tbody>");

            int indexCounter = 1;
            foreach (DataRow r in dt.Rows)
            {
                sb.Append("<tr>");
                sb.Append($"<td class='num-col'>{indexCounter}</td>");
                sb.Append($"<td>{r["StudentName"]}</td>");
                sb.Append($"<td class='id-col'>{r["StudentRoleID"]}</td>");
                sb.Append($"<td class='status-col'>{r["AttendanceStatus"]}</td>");
                sb.Append("</tr>");
                indexCounter++;
            }

            sb.Append("</tbody></table></body></html>");

            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }
    }
}