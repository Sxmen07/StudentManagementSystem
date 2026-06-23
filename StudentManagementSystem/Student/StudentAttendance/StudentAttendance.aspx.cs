using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.DataVisualization.Charting;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentAttendance : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        public class DailyRecord
        {
            public DateTime AttendanceDate { get; set; }
            public string AttendanceStatus { get; set; }
        }

        public class CourseAttendance
        {
            public int CourseOfferID { get; set; }
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public List<DailyRecord> DailyRecords { get; set; }
            public int PresentCount { get; set; }
            public int LateCount { get; set; }
            public int AbsentCount { get; set; }
            public DateTime SemesterEndDate { get; set; }
            public double OverallRate { get; set; }
            public DateTime FirstAttendanceDate { get; set; }
            public DateTime LastAttendanceDate { get; set; }
            public int TotalWeeks { get; set; }
        }

        private bool IsCurrentTabActive
        {
            get { return ViewState["IsCurrentTabActive"] == null ? true : (bool)ViewState["IsCurrentTabActive"]; }
            set { ViewState["IsCurrentTabActive"] = value; }
        }

        private Dictionary<string, int> SelectedWeeksState
        {
            get
            {
                if (ViewState["SelectedWeeksState"] == null)
                {
                    ViewState["SelectedWeeksState"] = new Dictionary<string, int>();
                }
                return (Dictionary<string, int>)ViewState["SelectedWeeksState"];
            }
            set { ViewState["SelectedWeeksState"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
                Response.Redirect("/Login.aspx");

            if (!IsPostBack)
            {
                IsCurrentTabActive = true;
                LoadAndBindCurrent();
                UpdateTabVisibility();
            }
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectWeek")
            {
                int targetWeek = Convert.ToInt32(e.CommandArgument);
                HiddenField hfCourseOfferID = (HiddenField)e.Item.FindControl("hfCourseOfferID");

                if (hfCourseOfferID != null)
                {
                    string courseOfferId = hfCourseOfferID.Value;

                    SelectedWeeksState[courseOfferId] = targetWeek;
                    ViewState["SelectedWeeksState"] = SelectedWeeksState;

                    if (IsCurrentTabActive)
                        LoadAndBindCurrent();
                    else
                        LoadAndBindHistory();

                    // Instruct UpdatePanel to refresh its rendering structure smoothly without page reload
                    upAttendance.Update();
                }
            }
        }

        private void LoadAndBindCurrent()
        {
            List<CourseAttendance> currentCourses = LoadAttendanceData().FindAll(c => c.SemesterEndDate >= DateTime.Today);
            rptCurrentCourses.DataSource = currentCourses;
            rptCurrentCourses.DataBind();
            lblNoCurrent.Visible = (currentCourses.Count == 0);
            UpdateSummaryCards(currentCourses);
        }

        private void LoadAndBindHistory()
        {
            List<CourseAttendance> historyCourses = LoadAttendanceData().FindAll(c => c.SemesterEndDate < DateTime.Today);
            rptHistoryCourses.DataSource = historyCourses;
            rptHistoryCourses.DataBind();
            lblNoHistory.Visible = (historyCourses.Count == 0);

            // If you want summary cards to reflect history only:
            UpdateSummaryCards(historyCourses);
        }

        private List<CourseAttendance> LoadAttendanceData()
        {
            int studentId = GetStudentIdFromSession();
            if (studentId == 0) return new List<CourseAttendance>();

            string query = @"
                SELECT 
                    co.CourseOfferID,
                    c.CourseCode,
                    c.CourseName,
                    ar.AttendanceDate,
                    ar.AttendanceStatus,
                    s.EndMonthDay,
                    co.Year
                FROM Enrolment e
                INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                INNER JOIN Course c ON co.CourseCode = c.CourseCode
                LEFT JOIN AttendanceRecord ar ON ar.CourseOfferID = co.CourseOfferID AND ar.StudentID = e.StudentID
                INNER JOIN Semester s ON co.SemesterID = s.SemesterID
                WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                ORDER BY co.Year DESC, s.SemesterID DESC, ar.AttendanceDate;";

            List<CourseAttendance> allCourses = new List<CourseAttendance>();

            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    DataTable dt = new DataTable();
                    dt.Load(reader);

                    var groups = new Dictionary<int, CourseAttendance>();
                    foreach (DataRow row in dt.Rows)
                    {
                        int offerId = Convert.ToInt32(row["CourseOfferID"]);
                        if (!groups.ContainsKey(offerId))
                        {
                            string endMonthDay = row["EndMonthDay"].ToString();
                            int year = Convert.ToInt32(row["Year"]);
                            DateTime semesterEnd = DateTime.Parse($"{year}-{endMonthDay}");

                            groups[offerId] = new CourseAttendance
                            {
                                CourseOfferID = offerId,
                                CourseCode = row["CourseCode"].ToString(),
                                CourseName = row["CourseName"].ToString(),
                                DailyRecords = new List<DailyRecord>(),
                                SemesterEndDate = semesterEnd,
                                PresentCount = 0,
                                LateCount = 0,
                                AbsentCount = 0,
                                FirstAttendanceDate = DateTime.MaxValue,
                                LastAttendanceDate = DateTime.MinValue
                            };
                        }

                        if (row["AttendanceDate"] != DBNull.Value)
                        {
                            DateTime date = Convert.ToDateTime(row["AttendanceDate"]);
                            string status = row["AttendanceStatus"].ToString();

                            var course = groups[offerId];
                            course.DailyRecords.Add(new DailyRecord
                            {
                                AttendanceDate = date,
                                AttendanceStatus = status
                            });

                            if (date < course.FirstAttendanceDate) course.FirstAttendanceDate = date;
                            if (date > course.LastAttendanceDate) course.LastAttendanceDate = date;

                            if (status == "Present") course.PresentCount++;
                            else if (status == "Late") course.LateCount++;
                            else if (status == "Absent") course.AbsentCount++;
                        }
                    }

                    foreach (var course in groups.Values)
                    {
                        course.DailyRecords.Sort((a, b) => a.AttendanceDate.CompareTo(b.AttendanceDate));
                        int total = course.PresentCount + course.LateCount + course.AbsentCount;
                        course.OverallRate = total > 0 ? (double)(course.PresentCount + course.LateCount) / total * 100 : 0;

                        if (course.DailyRecords.Count > 0)
                        {
                            DateTime first = course.FirstAttendanceDate;
                            DateTime last = course.LastAttendanceDate;
                            course.TotalWeeks = (int)Math.Ceiling((last - first).TotalDays / 7) + 1;
                        }
                        else
                        {
                            course.TotalWeeks = 1;
                        }
                    }

                    allCourses = new List<CourseAttendance>(groups.Values);
                }
            }
            return allCourses;
        }

        private DateTime GetWeekEnd(DateTime weekStart)
        {
            return weekStart.AddDays(6);
        }

        private List<DailyRecord> GetRecordsForWeek(List<DailyRecord> allRecords, DateTime weekStart)
        {
            DateTime weekEnd = GetWeekEnd(weekStart);
            return allRecords.FindAll(r => r.AttendanceDate >= weekStart && r.AttendanceDate <= weekEnd);
        }

        private void UpdateSummaryCards(List<CourseAttendance> courses)
        {
            int totalPresent = 0, totalLate = 0, totalAbsent = 0;
            int totalRecords = 0;
            foreach (var c in courses)
            {
                totalPresent += c.PresentCount;
                totalLate += c.LateCount;
                totalAbsent += c.AbsentCount;
                totalRecords += c.PresentCount + c.LateCount + c.AbsentCount;
            }
            double overall = totalRecords > 0 ? (double)(totalPresent + totalLate) / totalRecords * 100 : 0;

            lblOverallAttendance.Text = overall.ToString("F1") + "%";
            lblTotalPresent.Text = totalPresent.ToString();
            lblTotalLate.Text = totalLate.ToString();
            lblTotalAbsent.Text = totalAbsent.ToString();
        }

        private void UpdateTabVisibility()
        {
            if (IsCurrentTabActive)
            {
                pnlCurrent.Visible = true;
                pnlHistory.Visible = false;
                btnCurrent.CssClass = "text-base font-semibold transition duration-200 tab-active";
                btnHistory.CssClass = "text-base font-semibold transition duration-200 tab-inactive";
            }
            else
            {
                pnlCurrent.Visible = false;
                pnlHistory.Visible = true;
                btnCurrent.CssClass = "text-base font-semibold transition duration-200 tab-inactive";
                btnHistory.CssClass = "text-base font-semibold transition duration-200 tab-active";
            }
        }

        protected void btnCurrent_Click(object sender, EventArgs e)
        {
            IsCurrentTabActive = true;
            LoadAndBindCurrent();
            UpdateTabVisibility();
            upAttendance.Update();
        }

        protected void btnHistory_Click(object sender, EventArgs e)
        {
            IsCurrentTabActive = false;
            LoadAndBindHistory();
            UpdateTabVisibility();
            upAttendance.Update();
        }

        private void ProcessRowRendering(RepeaterItem item, CourseAttendance data)
        {
            GridView gvDaily = (GridView)item.FindControl("gvDailyAttendance");
            Label lblCode = (Label)item.FindControl("lblCourseCode");
            Label lblName = (Label)item.FindControl("lblCourseName");
            Label lblSummary = (Label)item.FindControl("lblSummary");
            Label lblRecordCount = (Label)item.FindControl("lblRecordCount");
            Label lblWeekRange = (Label)item.FindControl("lblWeekRange");
            Label lblWeekSummary = (Label)item.FindControl("lblWeekSummary");
            ListView lvWeekButtons = (ListView)item.FindControl("lvWeekButtons");
            Chart chart = (Chart)item.FindControl("chartAttendance");

            lblCode.Text = data.CourseCode;
            lblName.Text = data.CourseName;

            int total = data.PresentCount + data.LateCount + data.AbsentCount;
            lblRecordCount.Text = $"{total} records";

            // --- Check if there are NO records ---
            if (data.DailyRecords.Count == 0)
            {
                lblWeekRange.Text = "No attendance records";
                lblWeekSummary.Text = "No data available for this course.";
                gvDaily.DataSource = null;
                gvDaily.DataBind();
                lvWeekButtons.DataSource = null;
                lvWeekButtons.DataBind();

                // Still show the chart and summary (all zeros)
                if (chart != null)
                {
                    Series series = chart.Series["Attendance"];
                    series.Points.Clear();
                    series.Points.AddXY("Present", data.PresentCount);
                    series.Points.AddXY("Late", data.LateCount);
                    series.Points.AddXY("Absent", data.AbsentCount);
                    series.Points[0].Color = System.Drawing.Color.FromArgb(40, 167, 69);
                    series.Points[1].Color = System.Drawing.Color.FromArgb(255, 193, 7);
                    series.Points[2].Color = System.Drawing.Color.FromArgb(220, 53, 69);
                }
                lblSummary.Text = $"Present: 0 | Late: 0 | Absent: 0 | Attendance Rate: 0.0%";
                return;
            }

            // --- Normal flow for courses with records ---
            string courseKey = data.CourseOfferID.ToString();
            if (!SelectedWeeksState.ContainsKey(courseKey))
            {
                SelectedWeeksState[courseKey] = 1;
            }
            int currentSelectedWeek = SelectedWeeksState[courseKey];

            if (currentSelectedWeek > data.TotalWeeks) currentSelectedWeek = data.TotalWeeks;
            if (currentSelectedWeek < 1) currentSelectedWeek = 1;

            int weekOffsetIndex = currentSelectedWeek - 1;

            // FirstAttendanceDate is guaranteed to be valid here (because we have records)
            DateTime weekStart = data.FirstAttendanceDate.AddDays(weekOffsetIndex * 7);
            if (weekStart < data.FirstAttendanceDate) weekStart = data.FirstAttendanceDate;

            DateTime weekEnd = GetWeekEnd(weekStart);
            if (weekEnd > data.LastAttendanceDate) weekEnd = data.LastAttendanceDate;

            lblWeekRange.Text = $"{weekStart:MMM dd} - {weekEnd:MMM dd, yyyy}";

            List<int> weekNumbers = new List<int>();
            for (int i = 1; i <= data.TotalWeeks; i++)
            {
                weekNumbers.Add(i);
            }

            lvWeekButtons.Attributes["data-selected-week"] = currentSelectedWeek.ToString();
            lvWeekButtons.DataSource = weekNumbers;
            lvWeekButtons.DataBind();

            var weekRecords = GetRecordsForWeek(data.DailyRecords, weekStart);
            if (weekRecords.Count > 0)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("AttendanceDate", typeof(DateTime));
                dt.Columns.Add("AttendanceStatus", typeof(string));
                foreach (var record in weekRecords)
                {
                    dt.Rows.Add(record.AttendanceDate, record.AttendanceStatus);
                }
                gvDaily.DataSource = dt;
                gvDaily.DataBind();

                int weekPresent = weekRecords.FindAll(r => r.AttendanceStatus == "Present").Count;
                int weekLate = weekRecords.FindAll(r => r.AttendanceStatus == "Late").Count;
                int weekAbsent = weekRecords.FindAll(r => r.AttendanceStatus == "Absent").Count;
                int weekTotal = weekPresent + weekLate + weekAbsent;
                double weekRate = weekTotal > 0 ? (double)(weekPresent + weekLate) / weekTotal * 100 : 0;

                lblWeekSummary.Text = $"Present: {weekPresent} | Late: {weekLate} | Absent: {weekAbsent} | Week Rate: {weekRate:F1}%";
            }
            else
            {
                gvDaily.DataSource = null;
                gvDaily.DataBind();
                lblWeekSummary.Text = "No attendance records for this week.";
            }

            // Overall chart
            if (chart != null)
            {
                Series series = chart.Series["Attendance"];
                series.Points.Clear();
                series.Points.AddXY("Present", data.PresentCount);
                series.Points.AddXY("Late", data.LateCount);
                series.Points.AddXY("Absent", data.AbsentCount);
                series.Points[0].Color = System.Drawing.Color.FromArgb(40, 167, 69);
                series.Points[1].Color = System.Drawing.Color.FromArgb(255, 193, 7);
                series.Points[2].Color = System.Drawing.Color.FromArgb(220, 53, 69);
            }

            lblSummary.Text = $"Present: {data.PresentCount} | Late: {data.LateCount} | Absent: {data.AbsentCount} | Attendance Rate: {data.OverallRate:F1}%";
        }

        protected void lvWeekButtons_ItemDataBound(object sender, ListViewItemEventArgs e)
        {
            if (e.Item.ItemType == ListViewItemType.DataItem)
            {
                ListView lv = (ListView)sender;
                string activeWeekStr = lv.Attributes["data-selected-week"];

                LinkButton btnWeek = (LinkButton)e.Item.FindControl("btnWeekSelect");
                if (btnWeek != null && btnWeek.Text == activeWeekStr)
                {
                    btnWeek.CssClass = "btn-week-badge btn-week-badge-active";
                }
            }
        }

        protected void rptCurrentCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                CourseAttendance data = (CourseAttendance)e.Item.DataItem;
                ProcessRowRendering(e.Item, data);
            }
        }

        protected void rptHistoryCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                CourseAttendance data = (CourseAttendance)e.Item.DataItem;
                ProcessRowRendering(e.Item, data);
            }
        }

        protected void gvDailyAttendance_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                TableCell statusCell = e.Row.Cells[1];
                string status = statusCell.Text.Trim();
                statusCell.Text = "";

                switch (status)
                {
                    case "Present":
                        statusCell.Controls.Add(new LiteralControl($"<span class='badge-present'>{status}</span>"));
                        break;
                    case "Late":
                        statusCell.Controls.Add(new LiteralControl($"<span class='badge-late'>{status}</span>"));
                        break;
                    case "Absent":
                        statusCell.Controls.Add(new LiteralControl($"<span class='badge-absent'>{status}</span>"));
                        break;
                    default:
                        statusCell.Controls.Add(new LiteralControl($"<span>{status}</span>"));
                        break;
                }
            }
        }

        private int GetStudentIdFromSession()
        {
            if (Session["StudentID"] != null)
                return Convert.ToInt32(Session["StudentID"]);

            string email = Session["UserEmail"]?.ToString();
            if (string.IsNullOrEmpty(email)) return 0;

            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand("SELECT StudentID FROM Student WHERE StudentEmail = @Email", conn))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null)
                {
                    int id = Convert.ToInt32(result);
                    Session["StudentID"] = id;
                    return id;
                }
            }
            return 0;
        }

        // ============================================================
        // EXPORT HANDLERS
        // ============================================================

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            List<CourseAttendance> allCourses = LoadAttendanceData();
            // Filter based on active tab
            List<CourseAttendance> courses = IsCurrentTabActive
                ? allCourses.FindAll(c => c.SemesterEndDate >= DateTime.Today)
                : allCourses.FindAll(c => c.SemesterEndDate < DateTime.Today);

            StringBuilder sb = new StringBuilder();
            string tabLabel = IsCurrentTabActive ? "Current Courses" : "History Courses";
            sb.AppendLine($"ATTENDANCE REPORT - {tabLabel}");
            sb.AppendLine($"Generated: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine();

            foreach (var course in courses)
            {
                sb.AppendLine($"Course: {course.CourseCode} - {course.CourseName}");
                sb.AppendLine("Date,Status");
                foreach (var record in course.DailyRecords)
                {
                    sb.AppendLine($"{record.AttendanceDate:yyyy-MM-dd},{record.AttendanceStatus}");
                }
                int total = course.PresentCount + course.LateCount + course.AbsentCount;
                sb.AppendLine($"Summary: Present={course.PresentCount}, Late={course.LateCount}, Absent={course.AbsentCount}, Total={total}, Rate={course.OverallRate:F1}%");
                sb.AppendLine(); // blank line between courses
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Attendance_Report.csv");
            Response.ContentType = "text/csv";
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            List<CourseAttendance> allCourses = LoadAttendanceData();
            List<CourseAttendance> courses = IsCurrentTabActive
                ? allCourses.FindAll(c => c.SemesterEndDate >= DateTime.Today)
                : allCourses.FindAll(c => c.SemesterEndDate < DateTime.Today);

            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><style>");
            sb.Append("body { font-family: Arial; }");
            sb.Append("table { border-collapse: collapse; width: 100%; margin-top: 10px; }");
            sb.Append("th, td { border: 1px solid #ddd; padding: 6px; font-size: 11px; }");
            sb.Append("th { background-color: #f2f2f2; font-weight: bold; }");
            sb.Append("h3 { margin-bottom: 5px; }");
            sb.Append(".course-header { background-color: #e6f0fa; font-weight: bold; }");
            sb.Append(".summary-row { background-color: #f9f9f9; font-style: italic; }");
            sb.Append("</style></head><body>");

            string tabLabel = IsCurrentTabActive ? "Current Courses" : "History Courses";
            sb.Append($"<h3>Attendance Report - {tabLabel}</h3>");
            sb.Append($"<p>Generated: {DateTime.Now:yyyy-MM-dd HH:mm:ss}</p>");

            foreach (var course in courses)
            {
                sb.Append($"<h4>{course.CourseCode} - {course.CourseName}</h4>");
                sb.Append("<table>");
                sb.Append("<tr><th>Date</th><th>Status</th></tr>");
                foreach (var record in course.DailyRecords)
                {
                    sb.Append($"<tr><td>{record.AttendanceDate:yyyy-MM-dd}</td><td>{record.AttendanceStatus}</td></tr>");
                }
                int total = course.PresentCount + course.LateCount + course.AbsentCount;
                sb.Append($"<tr class='summary-row'><td colspan='2'>Summary: Present={course.PresentCount}, Late={course.LateCount}, Absent={course.AbsentCount}, Total={total}, Rate={course.OverallRate:F1}%</td></tr>");
                sb.Append("</table><br/>");
            }

            sb.Append("</body></html>");

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Attendance_Report.xls");
            Response.ContentType = "application/vnd.ms-excel";
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            List<CourseAttendance> allCourses = LoadAttendanceData();
            List<CourseAttendance> courses = IsCurrentTabActive
                ? allCourses.FindAll(c => c.SemesterEndDate >= DateTime.Today)
                : allCourses.FindAll(c => c.SemesterEndDate < DateTime.Today);

            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><style>");
            sb.Append("body { font-family: Arial, sans-serif; padding: 20px; }");
            sb.Append("h2 { font-size: 18px; margin-bottom: 5px; }");
            sb.Append("h4 { margin-bottom: 3px; }");
            sb.Append("table { width: 100%; border-collapse: collapse; font-size: 11px; margin-top: 5px; }");
            sb.Append("th { background-color: #f0f0f0; border: 1px solid #aaa; padding: 5px; text-align: left; }");
            sb.Append("td { border: 1px solid #ddd; padding: 5px; }");
            sb.Append(".summary { background-color: #f9f9f9; font-style: italic; }");
            sb.Append("</style></head><body>");

            string tabLabel = IsCurrentTabActive ? "Current Courses" : "History Courses";
            sb.Append($"<h2>Attendance Report - {tabLabel}</h2>");
            sb.Append($"<p><i>Generated: {DateTime.Now:yyyy-MM-dd HH:mm:ss}</i></p>");

            foreach (var course in courses)
            {
                sb.Append($"<h4>{course.CourseCode} - {course.CourseName}</h4>");
                sb.Append("<table><thead><tr><th>Date</th><th>Status</th></tr></thead><tbody>");
                foreach (var record in course.DailyRecords)
                {
                    sb.Append($"<tr><td>{record.AttendanceDate:yyyy-MM-dd}</td><td>{record.AttendanceStatus}</td></tr>");
                }
                int total = course.PresentCount + course.LateCount + course.AbsentCount;
                sb.Append($"<tr class='summary'><td colspan='2'>Summary: Present={course.PresentCount}, Late={course.LateCount}, Absent={course.AbsentCount}, Total={total}, Rate={course.OverallRate:F1}%</td></tr>");
                sb.Append("</tbody></table><br/>");
            }

            sb.Append("</body></html>");

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Attendance_Report.pdf");
            Response.ContentType = "application/pdf";
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }
    }
}