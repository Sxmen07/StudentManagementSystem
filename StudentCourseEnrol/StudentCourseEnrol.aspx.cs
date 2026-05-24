using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentCourseEnrol : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
                Response.Redirect("/StudeLogin.aspx");

            if (!IsPostBack)
            {
                    LoadAvailableCourses();
                    LoadEnrolledCourses();
                    LoadCourseHistory();
            }
        }

        private void LoadAvailableCourses(string searchTerm = null)
        {
            string studentEmail = Session["UserEmail"].ToString();

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();

                // 1. Get student's ProgrammeCode AND StudentID
                string getStudentInfo = "SELECT ProgrammeCode, StudentID FROM Student WHERE StudentEmail = @Email";
                SqlCommand cmdInfo = new SqlCommand(getStudentInfo, con);
                cmdInfo.Parameters.AddWithValue("@Email", studentEmail);
                SqlDataReader drInfo = cmdInfo.ExecuteReader();
                if (!drInfo.Read())
                {
                    gvCourses.DataSource = null;
                    gvCourses.DataBind();
                    return;
                }
                string programmeCode = drInfo["ProgrammeCode"].ToString();
                int studentId = Convert.ToInt32(drInfo["StudentID"]);
                drInfo.Close();

                // 2. Determine current active semester based on today's date
                int currentYear = DateTime.Now.Year;
                string currentMonthDay = DateTime.Now.ToString("MM-dd");
                string getActiveSemesterQuery = @"
            SELECT SemesterID 
            FROM Semester 
            WHERE @CurrentMonthDay BETWEEN StartMonthDay AND EndMonthDay";
                SqlCommand cmdSem = new SqlCommand(getActiveSemesterQuery, con);
                cmdSem.Parameters.AddWithValue("@CurrentMonthDay", currentMonthDay);
                object semIdObj = cmdSem.ExecuteScalar();
                if (semIdObj == null)
                {
                    gvCourses.DataSource = null;
                    gvCourses.DataBind();
                    return;
                }
                int currentSemesterId = Convert.ToInt32(semIdObj);

                // 3. Build query: available courses NOT already enrolled by this student
                string query = @"
            SELECT 
                c.CourseCode,
                c.CourseName,
                c.Description AS CourseDescription,
                s.Semester AS SemesterName,
                l.LecturerName,
                c.CreditHours AS Credits
            FROM CourseOffer co
            INNER JOIN Course c ON co.CourseCode = c.CourseCode
            INNER JOIN Semester s ON co.SemesterID = s.SemesterID
            LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
            LEFT JOIN Enrolment e ON e.CourseOfferID = co.CourseOfferID 
                                   AND e.StudentID = @StudentID
                                   AND e.EnrolStatus = 'Enrolled'
            WHERE co.OfferStatus = 'Available'
              AND c.ProgrammeCode = @ProgrammeCode
              AND co.SemesterID = @SemesterID
              AND co.Year = @Year
              AND e.EnrolmentID IS NULL";   // ← excludes already enrolled courses

                if (!string.IsNullOrEmpty(searchTerm))
                {
                    query += " AND (c.CourseCode LIKE @Search OR c.CourseName LIKE @Search)";
                }

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                cmd.Parameters.AddWithValue("@ProgrammeCode", programmeCode);
                cmd.Parameters.AddWithValue("@SemesterID", currentSemesterId);
                cmd.Parameters.AddWithValue("@Year", currentYear);
                if (!string.IsNullOrEmpty(searchTerm))
                {
                    cmd.Parameters.AddWithValue("@Search", "%" + searchTerm + "%");
                }

                SqlDataReader dr = cmd.ExecuteReader();
                gvCourses.DataSource = dr;
                gvCourses.DataBind();
            }
        }

        private void LoadEnrolledCourses()
        {
            string studentEmail = Session["UserEmail"].ToString();
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                // Get StudentID and current semester ID (same logic as LoadAvailableCourses)
                string getStudentIdAndSem = @"
            SELECT s.StudentID, s.SemesterID 
            FROM Student s 
            WHERE s.StudentEmail = @Email";
                SqlCommand cmd = new SqlCommand(getStudentIdAndSem, con);
                cmd.Parameters.AddWithValue("@Email", studentEmail);
                SqlDataReader dr = cmd.ExecuteReader();
                if (!dr.Read())
                {
                    gvEnrolledCourses.DataSource = null;
                    gvEnrolledCourses.DataBind();
                    return;
                }
                int studentId = dr.GetInt32(0);
                int studentSemesterId = dr.GetInt32(1);
                dr.Close();

                // Get current active semester (based on date)
                string currentMonthDay = DateTime.Now.ToString("MM-dd");
                string getActiveSemester = @"
            SELECT SemesterID FROM Semester 
            WHERE @CurrentMonthDay BETWEEN StartMonthDay AND EndMonthDay";
                SqlCommand cmdSem = new SqlCommand(getActiveSemester, con);
                cmdSem.Parameters.AddWithValue("@CurrentMonthDay", currentMonthDay);
                object semIdObj = cmdSem.ExecuteScalar();
                if (semIdObj == null)
                {
                    gvEnrolledCourses.DataSource = null;
                    gvEnrolledCourses.DataBind();
                    return;
                }
                int currentSemesterId = Convert.ToInt32(semIdObj);
                int currentYear = DateTime.Now.Year;

                // Query enrolled courses for that semester
                string query = @"
            SELECT 
                c.CourseCode, c.CourseName, c.Description AS CourseDescription,
                s.Semester AS SemesterName, l.LecturerName, c.CreditHours AS Credits
            FROM Enrolment e
            INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
            INNER JOIN Course c ON co.CourseCode = c.CourseCode
            INNER JOIN Semester s ON co.SemesterID = s.SemesterID
            LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
            WHERE e.StudentID = @StudentID
              AND e.EnrolStatus = 'Enrolled'
              AND co.SemesterID = @SemesterID
              AND co.Year = @Year";
                SqlCommand cmdEnroll = new SqlCommand(query, con);
                cmdEnroll.Parameters.AddWithValue("@StudentID", studentId);
                cmdEnroll.Parameters.AddWithValue("@SemesterID", currentSemesterId);
                cmdEnroll.Parameters.AddWithValue("@Year", currentYear);
                SqlDataReader drEnroll = cmdEnroll.ExecuteReader();
                gvEnrolledCourses.DataSource = drEnroll;
                gvEnrolledCourses.DataBind();
            }
        }

        private void LoadCourseHistory()
        {
            string studentEmail = Session["UserEmail"].ToString();
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                // Get StudentID
                string getStudentId = "SELECT StudentID FROM Student WHERE StudentEmail = @Email";
                SqlCommand cmdId = new SqlCommand(getStudentId, con);
                cmdId.Parameters.AddWithValue("@Email", studentEmail);
                object idObj = cmdId.ExecuteScalar();
                if (idObj == null)
                {
                    gvCourseHistory.DataSource = null;
                    gvCourseHistory.DataBind();
                    return;
                }
                int studentId = Convert.ToInt32(idObj);

                string query = @"
            SELECT 
                c.CourseCode, c.CourseName, c.Description AS CourseDescription,
                s.Semester AS SemesterName, l.LecturerName, c.CreditHours AS Credits,
                e.EnrolmentDate
            FROM Enrolment e
            INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
            INNER JOIN Course c ON co.CourseCode = c.CourseCode
            INNER JOIN Semester s ON co.SemesterID = s.SemesterID
            LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
            WHERE e.StudentID = @StudentID
            ORDER BY co.Year DESC, s.SemesterID DESC";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                SqlDataReader dr = cmd.ExecuteReader();
                gvCourseHistory.DataSource = dr;
                gvCourseHistory.DataBind();
            }
        }

        protected void btnEnrollCourse_Click(object sender, EventArgs e)
        {
            string studentEmail = Session["UserEmail"].ToString();
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                // Get StudentID
                string getStudentId = "SELECT StudentID FROM Student WHERE StudentEmail = @Email";
                SqlCommand cmdId = new SqlCommand(getStudentId, con);
                cmdId.Parameters.AddWithValue("@Email", studentEmail);
                int studentId = Convert.ToInt32(cmdId.ExecuteScalar());

                // Loop through each row in gvCourses
                foreach (GridViewRow row in gvCourses.Rows)
                {
                    CheckBox chk = (CheckBox)row.FindControl("chkEnroll");
                    if (chk != null && chk.Checked)
                    {
                        // Get CourseCode from the row (first cell)
                        string courseCode = row.Cells[0].Text;
                        // Get current semester and year (same logic as LoadAvailableCourses)
                        int currentYear = DateTime.Now.Year;
                        string currentMonthDay = DateTime.Now.ToString("MM-dd");
                        string getSemesterId = @"
                    SELECT SemesterID FROM Semester 
                    WHERE @CurrentMonthDay BETWEEN StartMonthDay AND EndMonthDay";
                        SqlCommand cmdSem = new SqlCommand(getSemesterId, con);
                        cmdSem.Parameters.AddWithValue("@CurrentMonthDay", currentMonthDay);
                        int semesterId = Convert.ToInt32(cmdSem.ExecuteScalar());

                        // Get CourseOfferID for that course, semester, year
                        string getOfferId = @"
                    SELECT CourseOfferID FROM CourseOffer 
                    WHERE CourseCode = @CourseCode 
                      AND SemesterID = @SemesterID 
                      AND Year = @Year";
                        SqlCommand cmdOffer = new SqlCommand(getOfferId, con);
                        cmdOffer.Parameters.AddWithValue("@CourseCode", courseCode);
                        cmdOffer.Parameters.AddWithValue("@SemesterID", semesterId);
                        cmdOffer.Parameters.AddWithValue("@Year", currentYear);
                        object offerIdObj = cmdOffer.ExecuteScalar();
                        if (offerIdObj == null) continue;
                        int courseOfferId = Convert.ToInt32(offerIdObj);

                        // Check if already enrolled
                        string checkEnrol = @"
                    SELECT COUNT(*) FROM Enrolment 
                    WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID";
                        SqlCommand cmdCheck = new SqlCommand(checkEnrol, con);
                        cmdCheck.Parameters.AddWithValue("@StudentID", studentId);
                        cmdCheck.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                        int exists = (int)cmdCheck.ExecuteScalar();
                        if (exists == 0)
                        {
                            string insertSql = @"
                        INSERT INTO Enrolment (StudentID, CourseOfferID, EnrolStatus, EnrolmentDate)
                        VALUES (@StudentID, @CourseOfferID, 'Enrolled', GETDATE())";
                            SqlCommand cmdInsert = new SqlCommand(insertSql, con);
                            cmdInsert.Parameters.AddWithValue("@StudentID", studentId);
                            cmdInsert.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                            cmdInsert.ExecuteNonQuery();
                        }
                    }
                }
            }
            // Refresh all grids after enrollment
            LoadAvailableCourses();
            LoadEnrolledCourses();
            LoadCourseHistory();
        }

        protected void btnResetEnroll_Click(object sender, EventArgs e)
        {
            LoadAvailableCourses();
        }


    }
}
