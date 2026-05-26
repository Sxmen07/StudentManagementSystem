using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.DataVisualization.Charting;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentAttendance : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        public class CourseAttendance
        {
            public int CourseOfferID { get; set; }
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public DataTable AttendanceTable { get; set; }
            public int PresentCount { get; set; }
            public int LateCount { get; set; }
            public int AbsentCount { get; set; }
            public DateTime SemesterEndDate { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
                Response.Redirect("/StudeLogin.aspx");

            if (!IsPostBack)
            {
                LoadAttendanceData();
            }
        }

        private void LoadAttendanceData()
        {
            int studentId = GetStudentIdFromSession();
            if (studentId == 0) return;

            List<CourseAttendance> allCourses = new List<CourseAttendance>();

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
                ORDER BY co.Year DESC, s.SemesterID DESC, ar.AttendanceDate;
            ";

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
                                AttendanceTable = new DataTable(),
                                SemesterEndDate = semesterEnd,
                                PresentCount = 0,
                                LateCount = 0,
                                AbsentCount = 0
                            };
                            groups[offerId].AttendanceTable.Columns.Add("AttendanceDate", typeof(DateTime));
                            groups[offerId].AttendanceTable.Columns.Add("AttendanceStatus", typeof(string));
                        }

                        if (row["AttendanceDate"] != DBNull.Value)
                        {
                            var rowToAdd = groups[offerId].AttendanceTable.NewRow();
                            rowToAdd["AttendanceDate"] = Convert.ToDateTime(row["AttendanceDate"]);
                            rowToAdd["AttendanceStatus"] = row["AttendanceStatus"].ToString();
                            groups[offerId].AttendanceTable.Rows.Add(rowToAdd);

                            string status = row["AttendanceStatus"].ToString();
                            if (status == "Present") groups[offerId].PresentCount++;
                            else if (status == "Late") groups[offerId].LateCount++;
                            else if (status == "Absent") groups[offerId].AbsentCount++;
                        }
                    }
                    allCourses = new List<CourseAttendance>(groups.Values);
                }
            }

            DateTime today = DateTime.Today;
            List<CourseAttendance> currentCourses = allCourses.FindAll(c => c.SemesterEndDate >= today);
            List<CourseAttendance> historyCourses = allCourses.FindAll(c => c.SemesterEndDate < today);

            rptCurrentCourses.DataSource = currentCourses;
            rptCurrentCourses.DataBind();
            rptHistoryCourses.DataSource = historyCourses;
            rptHistoryCourses.DataBind();

            lblNoCurrent.Visible = (currentCourses.Count == 0);
            lblNoHistory.Visible = (historyCourses.Count == 0);
        }

        private int GetStudentIdFromSession()
        {
            if (Session["StudentID"] != null)
                return Convert.ToInt32(Session["StudentID"]);

            string email = Session["UserEmail"]?.ToString();
            if (string.IsNullOrEmpty(email)) return 0;

            string query = "SELECT StudentID FROM Student WHERE StudentEmail = @Email";
            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(query, conn))
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

        // Current Courses Repeater - with chart
        protected void rptCurrentCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                CourseAttendance data = (CourseAttendance)e.Item.DataItem;
                GridView gv = (GridView)e.Item.FindControl("gvAttendance");
                Label lblCode = (Label)e.Item.FindControl("lblCourseCode");
                Label lblName = (Label)e.Item.FindControl("lblCourseName");
                Label lblSummary = (Label)e.Item.FindControl("lblSummary");
                Chart chart = (Chart)e.Item.FindControl("chartAttendance");

                lblCode.Text = data.CourseCode;
                lblName.Text = data.CourseName;
                gv.DataSource = data.AttendanceTable;
                gv.DataBind();

                // Populate chart
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

                // Build summary text
                int total = data.PresentCount + data.LateCount + data.AbsentCount;
                double percent = total > 0 ? (double)(data.PresentCount + data.LateCount) / total * 100 : 0;
                lblSummary.Text = $"Present: {data.PresentCount} | Late: {data.LateCount} | Absent: {data.AbsentCount} | Attendance Rate: {percent:F1}%";
            }
        }

        // History Courses Repeater - with chart
        protected void rptHistoryCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                CourseAttendance data = (CourseAttendance)e.Item.DataItem;
                GridView gv = (GridView)e.Item.FindControl("gvAttendance");
                Label lblCode = (Label)e.Item.FindControl("lblCourseCode");
                Label lblName = (Label)e.Item.FindControl("lblCourseName");
                Label lblSummary = (Label)e.Item.FindControl("lblSummary");
                Chart chart = (Chart)e.Item.FindControl("chartAttendance");

                lblCode.Text = data.CourseCode;
                lblName.Text = data.CourseName;
                gv.DataSource = data.AttendanceTable;
                gv.DataBind();

                // Populate chart
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

                // Build summary text
                int total = data.PresentCount + data.LateCount + data.AbsentCount;
                double percent = total > 0 ? (double)(data.PresentCount + data.LateCount) / total * 100 : 0;
                lblSummary.Text = $"Present: {data.PresentCount} | Late: {data.LateCount} | Absent: {data.AbsentCount} | Attendance Rate: {percent:F1}%";
            }
        }

        protected void gvAttendance_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Status column is second column (index 1)
                TableCell statusCell = e.Row.Cells[1];
                string status = statusCell.Text.Trim();

                // Clear the existing text and replace with a span
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
    }
}