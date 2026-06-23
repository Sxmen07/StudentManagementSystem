using System;
using System.Configuration;
using System.Data;
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
                LoadPreferences();
                ApplyPreferences();
            }
        }

        private void LoadDashboardData()
        {
            int studentId = GetStudentIdFromSession();
            if (studentId == 0) return;

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // Student name
                string nameQuery = "SELECT StudentName FROM Student WHERE StudentID = @StudentID";
                using (SqlCommand cmd = new SqlCommand(nameQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    object nameObj = cmd.ExecuteScalar();
                    lblWelcomeName.Text = nameObj?.ToString() ?? "Student";
                }

                // Total required credits
                string totalCreditsQuery = @"
                    SELECT p.TotalCreditHours
                    FROM Student s
                    INNER JOIN Programme p ON s.ProgrammeCode = p.ProgrammeCode
                    WHERE s.StudentID = @StudentID";
                using (SqlCommand cmd = new SqlCommand(totalCreditsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    object totalObj = cmd.ExecuteScalar();
                    lblTotalCredits.Text = totalObj != DBNull.Value ? totalObj.ToString() : "0";
                }

                // Current courses
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
                lblNoCurrentCourses.Visible = (rptCurrentCourses.Items.Count == 0);

                // Completed credits
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

                // CGPA (overall)
                string cgpaQuery = @"
                    SELECT SUM(g.GradePoint * c.CreditHours) / NULLIF(SUM(CASE WHEN calc.TotalWeight >= 99.9 THEN c.CreditHours ELSE 0 END), 0) AS CGPA
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    CROSS APPLY (
                        SELECT SUM(a.Weightage) AS TotalWeight,
                               SUM(ISNULL(sa.ObtainedMark, 0) / NULLIF(a.MaxMarks, 0) * a.Weightage) AS WeightedPercentage
                        FROM Assessment a
                        LEFT JOIN StudentAssessment sa ON a.AssessmentID = sa.AssessmentID AND sa.StudentID = e.StudentID
                        WHERE a.CourseOfferID = co.CourseOfferID
                    ) calc
                    CROSS APPLY (
                        SELECT TOP 1 GradePoint FROM GradeScale WHERE (calc.WeightedPercentage / calc.TotalWeight * 100) BETWEEN MinMarks AND MaxMarks
                    ) g
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                    HAVING SUM(CASE WHEN calc.TotalWeight >= 99.9 THEN c.CreditHours ELSE 0 END) > 0";
                decimal cgpa = 0;
                using (SqlCommand cmd = new SqlCommand(cgpaQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                        cgpa = Math.Round(Convert.ToDecimal(result), 2);
                }
                lblCGPA.Text = cgpa.ToString("0.00");

                // Semester GPA (current semester)
                int currentSemesterId = GetCurrentSemesterId();
                int currentYear = DateTime.Now.Year;
                string semesterGpaQuery = @"
                    SELECT SUM(g.GradePoint * c.CreditHours) / NULLIF(SUM(c.CreditHours), 0) AS SemesterGPA
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    CROSS APPLY (
                        SELECT SUM(a.Weightage) AS TotalWeight,
                               SUM(ISNULL(sa.ObtainedMark, 0) / NULLIF(a.MaxMarks, 0) * a.Weightage) AS WeightedPercentage
                        FROM Assessment a
                        LEFT JOIN StudentAssessment sa ON a.AssessmentID = sa.AssessmentID AND sa.StudentID = e.StudentID
                        WHERE a.CourseOfferID = co.CourseOfferID
                    ) calc
                    CROSS APPLY (
                        SELECT TOP 1 GradePoint FROM GradeScale WHERE (calc.WeightedPercentage / calc.TotalWeight * 100) BETWEEN MinMarks AND MaxMarks
                    ) g
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                      AND co.SemesterID = @SemesterID AND co.Year = @Year
                      AND calc.TotalWeight >= 99.9";
                decimal semesterGpa = 0;
                using (SqlCommand cmd = new SqlCommand(semesterGpaQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    cmd.Parameters.AddWithValue("@SemesterID", currentSemesterId);
                    cmd.Parameters.AddWithValue("@Year", currentYear);
                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                        semesterGpa = Math.Round(Convert.ToDecimal(result), 2);
                }
                lblSemesterGPA.Text = semesterGpa.ToString("0.00");

                // Attendance
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
                decimal attendancePercent = Math.Round(overall, 1);
                lblOverallAttendance.Text = attendancePercent.ToString("0.0") + "%";
                lblOverallAttendanceBar.Text = attendancePercent.ToString("0.0") + "%";
                hfAttendanceWidth.Value = attendancePercent.ToString("0.0");

                // Set colour for overall attendance bar
                string barColor = "bg-red-600"; // default red (low)
                if (attendancePercent >= 75)
                    barColor = "bg-green-600";
                else if (attendancePercent >= 50)
                    barColor = "bg-yellow-500";
                hfAttendanceColor.Value = barColor;

                // Notifications
                string notifQuery = @"
                    SELECT TOP 5 
                        a.AnnouncementID,
                        a.Title, 
                        a.CreatedDate, 
                        ISNULL(nrs.IsRead, 0) AS IsRead
                    FROM Announcement a
                    LEFT JOIN NotificationReadStatus nrs ON a.AnnouncementID = nrs.AnnouncementID AND nrs.StudentID = @StudentID
                    WHERE a.TargetType = 'All' 
                       OR (a.TargetType = 'CourseCode' AND a.TargetValue IN (
                           SELECT DISTINCT CourseCode 
                           FROM CourseOffer co 
                           INNER JOIN Enrolment e ON co.CourseOfferID = e.CourseOfferID 
                           WHERE e.StudentID = @StudentID
                       ))
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
                lblNoNotifications.Visible = (rptNotifications.Items.Count == 0);
            }
        }

        private void LoadPreferences()
        {
            int studentId = GetStudentIdFromSession();
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT ShowCurrentCourses, ShowAcademicSnapshot, ShowAttendance, ShowNotifications, ShowQuickActions FROM DashboardPreferences WHERE StudentID = @StudentID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            chkShowCurrentCourses.Checked = dr.GetBoolean(0);
                            chkShowAcademicSnapshot.Checked = dr.GetBoolean(1);
                            chkShowAttendance.Checked = dr.GetBoolean(2);
                            chkShowNotifications.Checked = dr.GetBoolean(3);
                            chkShowQuickActions.Checked = dr.GetBoolean(4);
                        }
                        else
                        {
                            // Default all true
                            chkShowCurrentCourses.Checked = true;
                            chkShowAcademicSnapshot.Checked = true;
                            chkShowAttendance.Checked = true;
                            chkShowNotifications.Checked = true;
                            chkShowQuickActions.Checked = true;
                        }
                    }
                }

                string checkExists = "SELECT COUNT(1) FROM DashboardPreferences WHERE StudentID = @StudentID";
                using (SqlCommand cmdCheck = new SqlCommand(checkExists, conn))
                {
                    cmdCheck.Parameters.AddWithValue("@StudentID", studentId);
                    int count = (int)cmdCheck.ExecuteScalar();
                    if (count == 0)
                    {
                        string insert = "INSERT INTO DashboardPreferences (StudentID, ShowCurrentCourses, ShowAcademicSnapshot, ShowAttendance, ShowNotifications, ShowQuickActions) VALUES (@StudentID, 1, 1, 1, 1, 1)";
                        using (SqlCommand cmdInsert = new SqlCommand(insert, conn))
                        {
                            cmdInsert.Parameters.AddWithValue("@StudentID", studentId);
                            cmdInsert.ExecuteNonQuery();
                        }
                    }
                }
            }
        }

        private void ApplyPreferences()
        {
            pnlCurrentCourses.Visible = chkShowCurrentCourses.Checked;
            pnlAttendance.Visible = chkShowAttendance.Checked;
            pnlNotifications.Visible = chkShowNotifications.Checked;
            pnlQuickActions.Visible = chkShowQuickActions.Checked;
        }

        protected void btnSavePreferences_Click(object sender, EventArgs e)
        {
            int studentId = GetStudentIdFromSession();
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string update = @"
                    UPDATE DashboardPreferences 
                    SET ShowCurrentCourses = @C,
                        ShowAcademicSnapshot = @A,
                        ShowAttendance = @Att,
                        ShowNotifications = @N,
                        ShowQuickActions = @Q
                    WHERE StudentID = @StudentID";
                SqlCommand cmd = new SqlCommand(update, conn);
                cmd.Parameters.AddWithValue("@C", chkShowCurrentCourses.Checked);
                cmd.Parameters.AddWithValue("@A", chkShowAcademicSnapshot.Checked);
                cmd.Parameters.AddWithValue("@Att", chkShowAttendance.Checked);
                cmd.Parameters.AddWithValue("@N", chkShowNotifications.Checked);
                cmd.Parameters.AddWithValue("@Q", chkShowQuickActions.Checked);
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                cmd.ExecuteNonQuery();
            }
            ApplyPreferences();
            ClientScript.RegisterStartupScript(this.GetType(), "hideDropdown", "closeDropdown();", true);
        }

        private int GetCurrentSemesterId()
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string currentMonthDay = DateTime.Now.ToString("MM-dd");
                string query = "SELECT SemesterID FROM Semester WHERE @CurrentMonthDay BETWEEN StartMonthDay AND EndMonthDay";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@CurrentMonthDay", currentMonthDay);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : 1;
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

        public class AttendanceItem
        {
            public string CourseCode { get; set; }
            public decimal AttendancePercentage { get; set; }
        }
    }
}