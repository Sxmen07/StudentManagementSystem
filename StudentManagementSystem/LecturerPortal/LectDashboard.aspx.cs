using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class LectDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSidebarProfile();
                lblWelcomeName.Text = lblSidebarName.Text;
                LoadDashboardData();
                BuildChartScript();
            }
        }

        private void LoadSidebarProfile()
        {
            string lecturerName = Session["LecturerName"]?.ToString() ?? "Lecturer";
            lblSidebarName.Text = lecturerName;

            if (!string.IsNullOrEmpty(lecturerName))
            {
                string[] parts = lecturerName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length > 1)
                    litSideInitials.Text = (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper();
                else
                    litSideInitials.Text = parts[0][0].ToString().ToUpper();
            }
            else
            {
                litSideInitials.Text = "LE";
            }

            try
            {
                string query = "SELECT ProfileImagePath FROM Lecturer WHERE LecturerID = @ID";
                SqlParameter[] p = { new SqlParameter("@ID", Session["LecturerID"]) };
                DataTable dt = DBHelper.ExecuteQuery(query, p);

                if (dt.Rows.Count > 0 && dt.Rows[0]["ProfileImagePath"] != DBNull.Value)
                {
                    string imgPath = dt.Rows[0]["ProfileImagePath"].ToString();
                    if (!string.IsNullOrEmpty(imgPath) && File.Exists(Server.MapPath(imgPath)))
                    {
                        imgSidebar.ImageUrl = imgPath + "?t=" + DateTime.Now.Ticks;
                        imgSidebar.Visible = true;
                        litSideInitials.Visible = false;
                        return;
                    }
                }
            }
            catch { }

            imgSidebar.Visible = false;
            litSideInitials.Visible = true;
        }

        private void LoadDashboardData()
        {
            string lecturerID = Session["LecturerID"]?.ToString();

            // --- 1. Summary Metrics ---

            // Average attendance
            string avgAttendanceQuery = @"
                SELECT ISNULL(
                    (SELECT CAST(AVG(CASE WHEN ar.AttendanceStatus IN ('Present', 'Late') THEN 1.0 ELSE 0.0 END) * 100 AS DECIMAL(5,1))
                     FROM AttendanceRecord ar
                     INNER JOIN Enrolment e ON ar.StudentID = e.StudentID AND ar.CourseOfferID = e.CourseOfferID
                     INNER JOIN CourseOffer co ON ar.CourseOfferID = co.CourseOfferID
                     WHERE co.LecturerID = @LID AND e.EnrolStatus = 'Enrolled'), 0.0)";
            object avgResult = DBHelper.ExecuteScalar(avgAttendanceQuery, new[] { new SqlParameter("@LID", lecturerID) });
            lblAvgAttendance.Text = (avgResult != null ? avgResult.ToString() : "0.0") + "%";

            // Low attendance count
            string lowAttendanceQuery = @"
                SELECT COUNT(*) FROM (
                    SELECT ar.StudentID, AVG(CASE WHEN ar.AttendanceStatus IN ('Present', 'Late') THEN 1.0 ELSE 0.0 END) * 100 AS StudentAvg
                    FROM AttendanceRecord ar
                    INNER JOIN Enrolment e ON ar.StudentID = e.StudentID AND ar.CourseOfferID = e.CourseOfferID
                    INNER JOIN CourseOffer co ON ar.CourseOfferID = co.CourseOfferID
                    WHERE co.LecturerID = @LID AND e.EnrolStatus = 'Enrolled'
                    GROUP BY ar.StudentID
                ) AS SubQuery 
                WHERE StudentAvg < 80.0";
            object lowAttResult = DBHelper.ExecuteScalar(lowAttendanceQuery, new[] { new SqlParameter("@LID", lecturerID) });
            lblLowAttendanceCount.Text = lowAttResult != null ? lowAttResult.ToString() : "0";

            // Failing students (assessment < 40%)
            string failingQuery = @"
                SELECT COUNT(*) FROM (
                    SELECT sa.StudentID,
                           SUM(CASE WHEN a.MaxMarks > 0 THEN (sa.ObtainedMark / a.MaxMarks) * a.Weightage ELSE 0 END) AS TotalPercentage
                    FROM StudentAssessment sa
                    INNER JOIN Assessment a ON sa.AssessmentID = a.AssessmentID
                    INNER JOIN CourseOffer co ON a.CourseOfferID = co.CourseOfferID
                    INNER JOIN Enrolment e ON sa.StudentID = e.StudentID AND co.CourseOfferID = e.CourseOfferID
                    WHERE co.LecturerID = @LID AND e.EnrolStatus = 'Enrolled'
                    GROUP BY sa.StudentID
                ) AS GradeQuery 
                WHERE TotalPercentage < 40.0";
            object failingResult = DBHelper.ExecuteScalar(failingQuery, new[] { new SqlParameter("@LID", lecturerID) });
            lblFailingCount.Text = failingResult != null ? failingResult.ToString() : "0";

            // Total enrolled students across all courses taught by this lecturer
            string totalStudentsQuery = @"
                SELECT COUNT(DISTINCT e.StudentID)
                FROM Enrolment e
                INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                WHERE co.LecturerID = @LID AND e.EnrolStatus = 'Enrolled'";
            object totalStudents = DBHelper.ExecuteScalar(totalStudentsQuery, new[] { new SqlParameter("@LID", lecturerID) });
            lblTotalStudents.Text = totalStudents != null ? totalStudents.ToString() : "0";

            // --- 2. Course List with Stats ---
            string courseQuery = @"
                SELECT 
                    co.CourseOfferID,
                    c.CourseCode,
                    c.CourseName,
                    COUNT(DISTINCT e.StudentID) AS EnrolledCount,
                    ISNULL(
                        (SELECT CAST(AVG(CASE WHEN ar.AttendanceStatus IN ('Present', 'Late') THEN 1.0 ELSE 0.0 END) * 100 AS DECIMAL(5,1))
                         FROM AttendanceRecord ar
                         INNER JOIN Enrolment e2 ON ar.StudentID = e2.StudentID AND ar.CourseOfferID = e2.CourseOfferID
                         WHERE e2.CourseOfferID = co.CourseOfferID AND e2.EnrolStatus = 'Enrolled'), 0.0) AS AttendanceRate,
                    ISNULL(
                        (SELECT CAST(AVG(
                            CASE WHEN a.MaxMarks > 0 THEN (sa.ObtainedMark / a.MaxMarks) * a.Weightage ELSE 0 END
                         ) AS DECIMAL(5,1))
                         FROM StudentAssessment sa
                         INNER JOIN Assessment a ON sa.AssessmentID = a.AssessmentID
                         INNER JOIN Enrolment e3 ON sa.StudentID = e3.StudentID AND a.CourseOfferID = e3.CourseOfferID
                         WHERE a.CourseOfferID = co.CourseOfferID AND e3.EnrolStatus = 'Enrolled'), 0.0) AS AvgGrade
                FROM CourseOffer co
                INNER JOIN Course c ON co.CourseCode = c.CourseCode
                LEFT JOIN Enrolment e ON co.CourseOfferID = e.CourseOfferID AND e.EnrolStatus = 'Enrolled'
                WHERE co.LecturerID = @LID AND co.OfferStatus = 'Available'
                GROUP BY co.CourseOfferID, c.CourseCode, c.CourseName
                ORDER BY c.CourseName";
            DataTable dtCourses = DBHelper.ExecuteQuery(courseQuery, new[] { new SqlParameter("@LID", lecturerID) });
            rptCourses.DataSource = dtCourses;
            rptCourses.DataBind();
            lblCourseCount.Text = dtCourses.Rows.Count.ToString();

            // --- 3. Recent Activity (Announcements & Assessment saves) ---
            string activityQuery = @"
                SELECT TOP 10
                    '📢' AS Icon,
                    a.Title AS Title,
                    a.Description AS Description,
                    a.CreatedDate AS EventDate,
                    'Announcement' AS Type
                FROM Announcement a
                WHERE a.TargetValue IN (SELECT CourseCode FROM CourseOffer WHERE LecturerID = @LID)
                   OR a.TargetType = 'All'
                UNION ALL
                SELECT TOP 10
                    '📝' AS Icon,
                    'Assessment updated: ' + ass.AssessmentName AS Title,
                    'Marks saved for ' + ass.CourseOfferID AS Description,
                    GETDATE() AS EventDate,
                    'Assessment' AS Type
                FROM Assessment ass
                WHERE ass.CourseOfferID IN (SELECT CourseOfferID FROM CourseOffer WHERE LecturerID = @LID)
                ORDER BY EventDate DESC";
            // Note: This is a simplified query; we can also log actual save events. For now we use a placeholder.
            // Better: create a Log table, but we'll simulate with announcements and a static entry.
            // We'll combine with a static list for demo purposes. Better to query from a real activity log.
            // For the sake of this demo, we'll fetch recent announcements only and add a dummy activity.
            string annQuery = @"
                SELECT TOP 8
                    '📢' AS Icon,
                    Title,
                    Description,
                    CreatedDate AS EventDate
                FROM Announcement
                WHERE TargetValue IN (SELECT CourseCode FROM CourseOffer WHERE LecturerID = @LID)
                   OR TargetType = 'All'
                ORDER BY CreatedDate DESC";
            DataTable dtActivity = DBHelper.ExecuteQuery(annQuery, new[] { new SqlParameter("@LID", lecturerID) });

            // Add a dummy activity for demonstration (if needed)
            if (dtActivity.Rows.Count == 0)
            {
                // Add a placeholder
                DataRow row = dtActivity.NewRow();
                row["Icon"] = "📝";
                row["Title"] = "No recent announcements";
                row["Description"] = "Check back later for updates.";
                row["EventDate"] = DateTime.Now;
                dtActivity.Rows.Add(row);
            }

            // Convert to human-readable time
            dtActivity.Columns.Add("TimeAgo", typeof(string));
            foreach (DataRow row in dtActivity.Rows)
            {
                DateTime dt = Convert.ToDateTime(row["EventDate"]);
                TimeSpan ts = DateTime.Now - dt;
                string timeAgo;
                if (ts.TotalMinutes < 1)
                    timeAgo = "Just now";
                else if (ts.TotalHours < 1)
                    timeAgo = (int)ts.TotalMinutes + "m ago";
                else if (ts.TotalDays < 1)
                    timeAgo = (int)ts.TotalHours + "h ago";
                else if (ts.TotalDays < 7)
                    timeAgo = (int)ts.TotalDays + "d ago";
                else
                    timeAgo = dt.ToString("dd MMM yyyy");
                row["TimeAgo"] = timeAgo;
                // Truncate description if too long
                string desc = row["Description"]?.ToString() ?? "";
                if (desc.Length > 80) desc = desc.Substring(0, 80) + "...";
                row["Description"] = desc;
            }

            rptActivities.DataSource = dtActivity;
            rptActivities.DataBind();
        }

        private void BuildChartScript()
        {
            // Fetch attendance data per course for chart
            string lecturerID = Session["LecturerID"]?.ToString();
            string query = @"
                SELECT 
                    c.CourseCode + ' - ' + c.CourseName AS CourseLabel,
                    CAST(ISNULL(
                        (SELECT AVG(CASE WHEN ar.AttendanceStatus IN ('Present', 'Late') THEN 1.0 ELSE 0.0 END) * 100
                         FROM AttendanceRecord ar
                         INNER JOIN Enrolment e ON ar.StudentID = e.StudentID AND ar.CourseOfferID = e.CourseOfferID
                         WHERE e.CourseOfferID = co.CourseOfferID AND e.EnrolStatus = 'Enrolled'), 0.0) AS DECIMAL(5,1)) AS AttendanceRate
                FROM CourseOffer co
                INNER JOIN Course c ON co.CourseCode = c.CourseCode
                WHERE co.LecturerID = @LID AND co.OfferStatus = 'Available'
                ORDER BY c.CourseName";
            DataTable dt = DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@LID", lecturerID) });

            StringBuilder labels = new StringBuilder();
            StringBuilder data = new StringBuilder();
            foreach (DataRow row in dt.Rows)
            {
                labels.Append($"\"{row["CourseLabel"].ToString().Replace("\"", "\\\"")}\",");
                data.Append($"{row["AttendanceRate"].ToString()},\n");
            }
            if (labels.Length > 0) labels.Length--; // remove last comma
            if (data.Length > 0) data.Length--;

            string script = $@"
            <script>
                document.addEventListener('DOMContentLoaded', function() {{
                    var ctx = document.getElementById('attendanceChart').getContext('2d');
                    var chart = new Chart(ctx, {{
                        type: 'bar',
                        data: {{
                            labels: [{labels.ToString()}],
                            datasets: [{{
                                label: 'Attendance Rate (%)',
                                data: [{data.ToString()}],
                                backgroundColor: 'rgba(0, 203, 212, 0.6)',
                                borderColor: 'rgba(0, 203, 212, 1)',
                                borderWidth: 1
                            }}]
                        }},
                        options: {{
                            responsive: true,
                            maintainAspectRatio: true,
                            plugins: {{
                                legend: {{ display: false }}
                            }},
                            scales: {{
                                y: {{
                                    beginAtZero: true,
                                    max: 100,
                                    ticks: {{ callback: function(value) {{ return value + '%'; }} }}
                                }}
                            }}
                        }}
                    }});
                }});
            </script>";
            litChartScript.Text = script;
        }
    }
}