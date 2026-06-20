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
            // Strict login security check matching Attendance.aspx logic
            if (Session["LecturerID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSidebarProfile();

                lblWelcomeName.Text = lblSidebarName.Text;

                LoadDashboardMetrics();
            }
        }

        private void LoadSidebarProfile()
        {
            // Bind text component details
            string lecturerName = Session["LecturerName"]?.ToString() ?? "Lecturer";
            lblSidebarName.Text = lecturerName;

            // Generate character initials fallback dynamically from session text
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

            // Database lookup query logic to fetch customized profile image pathway strings safely
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
                        litSideInitials.Visible = false; // Hide initials if image found
                        return;
                    }
                }
            }
            catch
            {
                // Graceful fallback to structural text initials if database fields are empty or fail
            }

            imgSidebar.Visible = false;
            litSideInitials.Visible = true;
        }

        private void LoadDashboardMetrics()
        {
            string lecturerID = Session["LecturerID"]?.ToString();

            // 1. Calculate Average Attendance Rate across all classes taught by this lecturer
            // Safely wraps expression in a subquery to guarantee a clean scalar return value
            string avgAttendanceQuery = @"
                SELECT ISNULL(
                    (SELECT CAST(AVG(CASE WHEN ar.AttendanceStatus IN ('Present', 'Late') THEN 1.0 ELSE 0.0 END) * 100 AS DECIMAL(5,1))
                     FROM AttendanceRecord ar
                     INNER JOIN Enrolment e ON ar.StudentID = e.StudentID AND ar.CourseOfferID = e.CourseOfferID
                     INNER JOIN CourseOffer co ON ar.CourseOfferID = co.CourseOfferID
                     WHERE co.LecturerID = @LID AND e.EnrolStatus = 'Enrolled'), 0.0)";

            SqlParameter[] p1 = { new SqlParameter("@LID", lecturerID) };
            object avgResult = DBHelper.ExecuteScalar(avgAttendanceQuery, p1);
            lblAvgAttendance.Text = (avgResult != null ? avgResult.ToString() : "0.0") + "%";

            // 2. Count distinct students with an overall attendance average below 80%
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

            SqlParameter[] p2 = { new SqlParameter("@LID", lecturerID) };
            object lowAttResult = DBHelper.ExecuteScalar(lowAttendanceQuery, p2);
            lblLowAttendanceCount.Text = lowAttResult != null ? lowAttResult.ToString() : "0";

            // 3. Count students whose combined assessment weighted performance total falls below 40%
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

            SqlParameter[] p3 = { new SqlParameter("@LID", lecturerID) };
            object failingResult = DBHelper.ExecuteScalar(failingQuery, p3);
            lblFailingCount.Text = failingResult != null ? failingResult.ToString() : "0";

            // Initialize control array bindings quietly to avoid back-end null object framework errors
            if (ddlCourseOffer != null)
            {
                ddlCourseOffer.Items.Clear();
                ddlCourseOffer.Items.Add(new ListItem("All Active Class Rosters", "0"));

                // Dynamically populate active dropdown course components belonging to this instructor
                string courseQuery = @"
                    SELECT co.CourseOfferID, c.CourseName + ' (' + s.Semester + ' ' + CAST(co.Year AS NVARCHAR) + ')' AS DisplayName
                    FROM CourseOffer co
                    INNER JOIN Course c ON c.CourseCode = co.CourseCode
                    INNER JOIN Semester s ON s.SemesterID = co.SemesterID
                    WHERE co.LecturerID = @LID AND co.OfferStatus = 'Available'";

                SqlParameter[] p4 = { new SqlParameter("@LID", lecturerID) };
                DataTable dtCourses = DBHelper.ExecuteQuery(courseQuery, p4);
                foreach (DataRow row in dtCourses.Rows)
                {
                    ddlCourseOffer.Items.Add(new ListItem(row["DisplayName"].ToString(), row["CourseOfferID"].ToString()));
                }
            }

            if (ddlExportType != null)
            {
                ddlExportType.SelectedIndex = 0;
            }
        }
    }
}