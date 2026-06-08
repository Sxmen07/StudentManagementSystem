using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace StudentManagementSystem.Student
{
    public partial class StudentDashboard : Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
            {
                Response.Redirect("/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            int studentId = GetStudentIdFromSession();
            if (studentId == 0) return;

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 1. Student personal info
                string studentQuery = @"
                    SELECT s.StudentName, s.StudentID, p.ProgrammeName, p.TotalCreditHours
                    FROM Student s
                    INNER JOIN Programme p ON s.ProgrammeCode = p.ProgrammeCode
                    WHERE s.StudentID = @StudentID";
                using (SqlCommand cmd = new SqlCommand(studentQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblStudentName.Text = dr["StudentName"].ToString();
                            lblStudentID.Text = dr["StudentID"].ToString();
                            lblProgramme.Text = dr["ProgrammeName"].ToString();
                            lblTotalCredits.Text = dr["TotalCreditHours"].ToString();
                        }
                    }
                }

                // 2. Current courses (enrolled, not yet ended)
                string coursesQuery = @"
                    SELECT co.CourseOfferID, c.CourseCode, c.CourseName, l.LecturerName AS Instructor
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
                    INNER JOIN Semester s ON co.SemesterID = s.SemesterID
                    WHERE e.StudentID = @StudentID 
                      AND e.EnrolStatus = 'Enrolled'
                      AND DATEFROMPARTS(co.Year, CAST(LEFT(s.EndMonthDay,2) AS INT), CAST(RIGHT(s.EndMonthDay,2) AS INT)) >= GETDATE()
                    ORDER BY c.CourseCode";
                using (SqlCommand cmd = new SqlCommand(coursesQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        rptCurrentCourses.DataSource = dr;
                        rptCurrentCourses.DataBind();
                    }
                }

                // 3. Academic snapshot: completed credits, semester GPA, CGPA
                // Completed credits (courses with total assessment weight >= 99.9%)
                string creditsQuery = @"
                    SELECT SUM(C.CreditHours) AS CompletedCredits
                    FROM (
                        SELECT DISTINCT co.CourseOfferID
                        FROM Enrolment e
                        INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                        INNER JOIN Assessment a ON co.CourseOfferID = a.CourseOfferID
                        GROUP BY co.CourseOfferID
                        HAVING SUM(a.Weightage) >= 99.9
                    ) complete
                    INNER JOIN CourseOffer co ON complete.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    INNER JOIN Enrolment e ON co.CourseOfferID = e.CourseOfferID
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'";
                int completedCredits = 0;
                using (SqlCommand cmd = new SqlCommand(creditsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value)
                        completedCredits = Convert.ToInt32(result);
                }
                lblCredits.Text = completedCredits.ToString();

                // Get current semester GPA and CGPA (simplified)
                string gpaQuery = @"
                    SELECT TOP 1 
                        CO.Year, S.SemesterID,
                        SUM(CASE WHEN total.WeightageTotal >= 99.9 THEN total.GradePoint * C.CreditHours ELSE 0 END) / 
                        NULLIF(SUM(CASE WHEN total.WeightageTotal >= 99.9 THEN C.CreditHours ELSE 0 END), 0) AS SemesterGPA
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    INNER JOIN Semester s ON co.SemesterID = s.SemesterID
                    CROSS APPLY (
                        SELECT SUM(a.Weightage) AS WeightageTotal, 
                               CASE WHEN SUM(a.Weightage) >= 99.9 THEN 
                                   (SELECT TOP 1 GradePoint FROM GradeScale WHERE (SUM(SA.ObtainedMark / NULLIF(A.MaxMarks,0) * a.Weightage) BETWEEN MinMarks AND MaxMarks))
                               ELSE 0 END AS GradePoint
                        FROM Assessment a
                        LEFT JOIN StudentAssessment SA ON a.AssessmentID = SA.AssessmentID AND SA.StudentID = e.StudentID
                        WHERE a.CourseOfferID = co.CourseOfferID
                    ) total
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                    GROUP BY CO.Year, S.SemesterID
                    ORDER BY CO.Year DESC, S.SemesterID DESC";
                decimal currentGPA = 0;
                using (SqlCommand cmd = new SqlCommand(gpaQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                        currentGPA = Math.Round(Convert.ToDecimal(result), 2);
                }
                lblSemesterGPA.Text = currentGPA.ToString("0.00");

                // CGPA overall
                string cgpaQuery = @"
                    SELECT SUM(total.GradePoint * C.CreditHours) / NULLIF(SUM(CASE WHEN total.WeightageTotal >= 99.9 THEN C.CreditHours ELSE 0 END), 0) AS CGPA
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    CROSS APPLY (
                        SELECT SUM(a.Weightage) AS WeightageTotal, 
                               CASE WHEN SUM(a.Weightage) >= 99.9 THEN 
                                   (SELECT TOP 1 GradePoint FROM GradeScale WHERE (SUM(SA.ObtainedMark / NULLIF(A.MaxMarks,0) * a.Weightage) BETWEEN MinMarks AND MaxMarks))
                               ELSE 0 END AS GradePoint
                        FROM Assessment a
                        LEFT JOIN StudentAssessment SA ON a.AssessmentID = SA.AssessmentID AND SA.StudentID = e.StudentID
                        WHERE a.CourseOfferID = co.CourseOfferID
                    ) total
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                    HAVING SUM(CASE WHEN total.WeightageTotal >= 99.9 THEN C.CreditHours ELSE 0 END) > 0";
                decimal cgpa = 0;
                using (SqlCommand cmd = new SqlCommand(cgpaQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                        cgpa = Math.Round(Convert.ToDecimal(result), 2);
                }
                lblCGPA.Text = cgpa.ToString("0.00");

                // 4. Attendance Summary
                string attendanceQuery = @"
                    SELECT 
                        c.CourseCode,
                        ROUND(100.0 * SUM(CASE WHEN ar.AttendanceStatus IN ('Present', 'Late') THEN 1 ELSE 0 END) / COUNT(*), 1) AS AttendancePercentage
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    LEFT JOIN AttendanceRecord ar ON e.StudentID = ar.StudentID AND co.CourseOfferID = ar.CourseOfferID
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                    GROUP BY c.CourseCode";
                List<AttendanceItem> attendanceItems = new List<AttendanceItem>();
                using (SqlCommand cmd = new SqlCommand(attendanceQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            attendanceItems.Add(new AttendanceItem
                            {
                                CourseCode = dr["CourseCode"].ToString(),
                                AttendancePercentage = dr["AttendancePercentage"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["AttendancePercentage"])
                            });
                        }
                    }
                }
                rptAttendanceByCourse.DataSource = attendanceItems;
                rptAttendanceByCourse.DataBind();

                decimal overall = 0;
                if (attendanceItems.Count > 0)
                {
                    foreach (var item in attendanceItems)
                        overall += item.AttendancePercentage;
                    overall /= attendanceItems.Count;
                }
                lblOverallAttendance.Text = Math.Round(overall, 1).ToString() + "%";
                ViewState["AttendanceWidth"] = overall.ToString("0") + "%";

                // 5. Notifications – latest 5
                string notifQuery = @"
                    SELECT TOP 5 a.Title, a.CreatedDate, ISNULL(nrs.IsRead, 0) AS IsRead
                    FROM Announcement a
                    LEFT JOIN NotificationReadStatus nrs ON a.AnnouncementID = nrs.AnnouncementID AND nrs.StudentID = @StudentID
                    WHERE a.TargetType = 'All' OR (a.TargetType = 'CourseCode' AND a.TargetValue IN (SELECT DISTINCT CourseCode FROM CourseOffer co INNER JOIN Enrolment e ON co.CourseOfferID = e.CourseOfferID WHERE e.StudentID = @StudentID))
                    ORDER BY a.CreatedDate DESC";
                using (SqlCommand cmd = new SqlCommand(notifQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        rptNotifications.DataSource = dr;
                        rptNotifications.DataBind();
                    }
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
            {
                conn.Open();
                string query = "SELECT StudentID FROM Student WHERE StudentEmail = @Email";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        int id = Convert.ToInt32(result);
                        Session["StudentID"] = id;
                        return id;
                    }
                }
            }
            return 0;
        }

        protected string GetAttendanceBarWidth()
        {
            return ViewState["AttendanceWidth"]?.ToString() ?? "0%";
        }

        public class AttendanceItem
        {
            public string CourseCode { get; set; }
            public decimal AttendancePercentage { get; set; }
        }
    }
}