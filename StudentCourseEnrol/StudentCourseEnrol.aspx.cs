using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentCourseEnrol : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;
        private int _studentId = 0;
        private int _currentSemesterId = 0;
        private int _currentYear = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
                Response.Redirect("/Login.aspx");

            LoadStudentData();

            if (!IsPostBack)
            {
                LoadCurrentEnrollment();
                LoadDroppedCourses();
                LoadAvailableCourses();
                LoadAcademicHistory();
                LoadSummary();

                if (!IsEnrollmentPeriodOpen())
                {
                    DisableEnrollmentButtons();
                    ShowEnrollmentClosedMessage();
                }
                else
                {
                    ShowEnrollmentOpenMessage();
                }
            }
            else
            {
                // On postback, only update enrollment status and button states
                if (!IsEnrollmentPeriodOpen())
                {
                    DisableEnrollmentButtons();
                    ShowEnrollmentClosedMessage();
                }
                else
                {
                    ShowEnrollmentOpenMessage();
                }
            }
        }

        // -----------------------------------------------------------------
        // Helper: Check if enrollment is allowed for the current semester
        // -----------------------------------------------------------------
        private bool IsEnrollmentPeriodOpen()
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT EnrolStartDate, EnrolEndDate
                    FROM Semester
                    WHERE SemesterID = @SemesterID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@SemesterID", _currentSemesterId);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        if (dr.IsDBNull(0) || dr.IsDBNull(1))
                            return false;

                        string startMonthDay = dr.GetString(0);
                        string endMonthDay = dr.GetString(1);
                        string todayMonthDay = DateTime.Today.ToString("MM-dd");

                        return (string.Compare(todayMonthDay, startMonthDay) >= 0 &&
                                string.Compare(todayMonthDay, endMonthDay) <= 0);
                    }
                }
            }
            return false;
        }

        // -----------------------------------------------------------------
        // Disable all enrollment action buttons when period is closed
        // -----------------------------------------------------------------
        private void DisableEnrollmentButtons()
        {
            foreach (GridViewRow row in gvAvailable.Rows)
            {
                Button btn = (Button)row.FindControl("btnEnroll");
                if (btn != null)
                {
                    btn.Enabled = false;
                    btn.Text = "Closed";
                    btn.CssClass = "bg-gray-400 cursor-not-allowed text-white text-xs px-3 py-1 rounded";
                }
            }

            foreach (GridViewRow row in gvCurrentEnrolled.Rows)
            {
                Button btn = (Button)row.FindControl("btnDrop");
                if (btn != null)
                {
                    btn.Enabled = false;
                    btn.Text = "Closed";
                    btn.CssClass = "bg-gray-400 cursor-not-allowed text-white text-xs px-3 py-1 rounded";
                }
            }

            foreach (GridViewRow row in gvDropped.Rows)
            {
                Button btn = (Button)row.FindControl("btnReenroll");
                if (btn != null)
                {
                    btn.Enabled = false;
                    btn.Text = "Closed";
                    btn.CssClass = "bg-gray-400 cursor-not-allowed text-white text-xs px-3 py-1 rounded";
                }
            }
        }

        // -----------------------------------------------------------------
        // Show green "open" message
        // -----------------------------------------------------------------
        private void ShowEnrollmentOpenMessage()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string query = "SELECT EnrolStartDate, EnrolEndDate FROM Semester WHERE SemesterID = @SemesterID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@SemesterID", _currentSemesterId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read() && !dr.IsDBNull(0) && !dr.IsDBNull(1))
                        {
                            string start = DateTime.ParseExact(dr.GetString(0), "MM-dd", null).ToString("MMMM dd");
                            string end = DateTime.ParseExact(dr.GetString(1), "MM-dd", null).ToString("MMMM dd");
                            lblEnrollmentStatus.Text = $@"
                                <div class='bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded' role='alert'>
                                    <p class='font-bold'>✅ Enrollment Period Open</p>
                                    <p>You can enroll or drop courses from {start} to {end}.</p>
                                </div>";
                        }
                        else
                        {
                            lblEnrollmentStatus.Text = @"
                                <div class='bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded' role='alert'>
                                    <p class='font-bold'>✅ Enrollment Period Open</p>
                                    <p>You are within the enrollment window. Use the buttons below.</p>
                                </div>";
                        }
                    }
                }
            }
            catch
            {
                lblEnrollmentStatus.Text = @"
                    <div class='bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded' role='alert'>
                        <p class='font-bold'>✅ Enrollment Period Open</p>
                        <p>Please contact support if you see this message unexpectedly.</p>
                    </div>";
            }
        }

        // -----------------------------------------------------------------
        // Show yellow "closed" message
        // -----------------------------------------------------------------
        private void ShowEnrollmentClosedMessage()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string query = "SELECT EnrolStartDate, EnrolEndDate FROM Semester WHERE SemesterID = @SemesterID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@SemesterID", _currentSemesterId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read() && !dr.IsDBNull(0) && !dr.IsDBNull(1))
                        {
                            string start = DateTime.ParseExact(dr.GetString(0), "MM-dd", null).ToString("MMMM dd");
                            string end = DateTime.ParseExact(dr.GetString(1), "MM-dd", null).ToString("MMMM dd");
                            lblEnrollmentStatus.Text = $@"
                                <div class='bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 rounded' role='alert'>
                                    <p class='font-bold'>⛔ Enrollment Period Closed</p>
                                    <p>You can only enroll or drop courses from {start} to {end}.</p>
                                </div>";
                        }
                        else
                        {
                            lblEnrollmentStatus.Text = @"
                                <div class='bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 rounded' role='alert'>
                                    <p class='font-bold'>⛔ Enrollment Period Closed</p>
                                    <p>Enrollment is not available at this time. Please contact your academic advisor.</p>
                                </div>";
                        }
                    }
                }
            }
            catch
            {
                lblEnrollmentStatus.Text = @"
                    <div class='bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 rounded' role='alert'>
                        <p class='font-bold'>⛔ Enrollment Period Closed</p>
                        <p>Unable to retrieve enrollment dates. Please contact support.</p>
                    </div>";
            }
        }

        // -----------------------------------------------------------------
        // Load data methods
        // -----------------------------------------------------------------
        private void LoadStudentData()
        {
            string email = Session["UserEmail"].ToString();
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT StudentID, ProgrammeCode FROM Student WHERE StudentEmail = @Email";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Email", email);
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    _studentId = dr.GetInt32(0);
                    Session["StudentID"] = _studentId;
                }
                dr.Close();

                string currentMonthDay = DateTime.Now.ToString("MM-dd");
                string semQuery = "SELECT SemesterID FROM Semester WHERE @CurrentMonthDay BETWEEN StartMonthDay AND EndMonthDay";
                SqlCommand cmdSem = new SqlCommand(semQuery, conn);
                cmdSem.Parameters.AddWithValue("@CurrentMonthDay", currentMonthDay);
                object semObj = cmdSem.ExecuteScalar();
                if (semObj != null)
                    _currentSemesterId = Convert.ToInt32(semObj);
                _currentYear = DateTime.Now.Year;
            }
        }

        private void LoadCurrentEnrollment()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        co.CourseOfferID,
                        c.CourseCode,
                        c.CourseName,
                        ISNULL(l.LecturerName, 'TBA') AS Instructor,
                        c.CreditHours AS Credits
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
                    WHERE e.StudentID = @StudentID
                      AND e.EnrolStatus = 'Enrolled'
                      AND co.SemesterID = @SemesterID
                      AND co.Year = @Year
                    ORDER BY c.CourseCode";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                da.SelectCommand.Parameters.AddWithValue("@StudentID", _studentId);
                da.SelectCommand.Parameters.AddWithValue("@SemesterID", _currentSemesterId);
                da.SelectCommand.Parameters.AddWithValue("@Year", _currentYear);
                da.Fill(dt);
            }
            gvCurrentEnrolled.DataSource = dt;
            gvCurrentEnrolled.DataBind();
            lblNoCurrent.Visible = (dt.Rows.Count == 0);
        }

        private void LoadDroppedCourses()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        co.CourseOfferID,
                        c.CourseCode,
                        c.CourseName,
                        ISNULL(l.LecturerName, 'TBA') AS Instructor,
                        c.CreditHours AS Credits
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
                    WHERE e.StudentID = @StudentID
                      AND e.EnrolStatus = 'Dropped'
                      AND co.SemesterID = @SemesterID
                      AND co.Year = @Year
                    ORDER BY c.CourseCode";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                da.SelectCommand.Parameters.AddWithValue("@StudentID", _studentId);
                da.SelectCommand.Parameters.AddWithValue("@SemesterID", _currentSemesterId);
                da.SelectCommand.Parameters.AddWithValue("@Year", _currentYear);
                da.Fill(dt);
            }
            gvDropped.DataSource = dt;
            gvDropped.DataBind();
            lblNoDropped.Visible = (dt.Rows.Count == 0);
        }

        private void LoadAvailableCourses()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                int nextSemesterId = _currentSemesterId + 1;
                int displayYear = _currentYear;
                if (nextSemesterId > 3)
                {
                    nextSemesterId = 1;
                    displayYear++;
                }

                string query = @"
                    SELECT 
                        co.CourseOfferID,
                        c.CourseCode,
                        c.CourseName,
                        c.CreditHours AS Credits,
                        '' AS Schedule
                    FROM CourseOffer co
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    WHERE co.OfferStatus = 'Available'
                      AND co.SemesterID = @SemesterID
                      AND co.Year = @Year
                      AND NOT EXISTS (
                          SELECT 1 FROM Enrolment e 
                          WHERE e.StudentID = @StudentID 
                            AND e.CourseOfferID = co.CourseOfferID 
                            AND e.EnrolStatus = 'Enrolled'
                      )
                    ORDER BY c.CourseCode";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                da.SelectCommand.Parameters.AddWithValue("@StudentID", _studentId);
                da.SelectCommand.Parameters.AddWithValue("@SemesterID", nextSemesterId);
                da.SelectCommand.Parameters.AddWithValue("@Year", displayYear);
                da.Fill(dt);
            }
            gvAvailable.DataSource = dt;
            gvAvailable.DataBind();
            lblNoAvailable.Visible = (dt.Rows.Count == 0);
            lblTargetSemester.Text = GetSemesterName(_currentSemesterId + 1) + " " + _currentYear.ToString();
        }

        private string GetSemesterName(int semesterId)
        {
            switch (semesterId)
            {
                case 1: return "Spring";
                case 2: return "Summer";
                case 3: return "Fall";
                default: return "Next Semester";
            }
        }

        private void LoadAcademicHistory()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        s.Semester + ' ' + CAST(co.Year AS VARCHAR) AS SemesterYear,
                        c.CourseCode,
                        c.CourseName,
                        c.CreditHours AS Credits,
                        co.CourseOfferID
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    INNER JOIN Semester s ON co.SemesterID = s.SemesterID
                    WHERE e.StudentID = @StudentID
                      AND e.EnrolStatus = 'Enrolled'
                      AND co.SemesterID < @CurrentSemesterId
                    ORDER BY co.Year DESC, s.SemesterID DESC";

                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                da.SelectCommand.Parameters.AddWithValue("@StudentID", _studentId);
                da.SelectCommand.Parameters.AddWithValue("@CurrentSemesterId", _currentSemesterId);
                da.Fill(dt);
            }

            dt.Columns.Add("Grade", typeof(string));
            foreach (DataRow row in dt.Rows)
            {
                int courseOfferId = Convert.ToInt32(row["CourseOfferID"]);
                string grade = ComputeGradeForCourse(_studentId, courseOfferId);
                row["Grade"] = grade;
            }

            if (dt.Columns.Contains("CourseOfferID"))
                dt.Columns.Remove("CourseOfferID");

            gvHistory.DataSource = dt;
            gvHistory.DataBind();
            lblNoHistory.Visible = (dt.Rows.Count == 0);
        }

        private string ComputeGradeForCourse(int studentId, int courseOfferId)
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT SUM(a.Weightage) AS TotalWeight,
                           SUM(ISNULL(sa.ObtainedMark, 0) / NULLIF(a.MaxMarks, 0) * a.Weightage) AS WeightedPercentage
                    FROM Assessment a
                    LEFT JOIN StudentAssessment sa ON a.AssessmentID = sa.AssessmentID AND sa.StudentID = @StudentID
                    WHERE a.CourseOfferID = @CourseOfferID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                cmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        decimal totalWeight = dr["TotalWeight"] != DBNull.Value ? Convert.ToDecimal(dr["TotalWeight"]) : 0;
                        decimal weightedPercentage = dr["WeightedPercentage"] != DBNull.Value ? Convert.ToDecimal(dr["WeightedPercentage"]) : 0;
                        if (totalWeight >= 99.9m)
                        {
                            decimal percentage = (weightedPercentage / totalWeight) * 100;
                            return GetGradeFromPercentage(percentage);
                        }
                    }
                }
            }
            return "Incomplete";
        }

        private string GetGradeFromPercentage(decimal percentage)
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT Grade FROM GradeScale WHERE @Percentage BETWEEN MinMarks AND MaxMarks";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Percentage", percentage);
                object result = cmd.ExecuteScalar();
                if (result != null)
                    return result.ToString();
            }
            return "N/A";
        }

        private void LoadSummary()
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string creditsQuery = @"
                    SELECT SUM(c.CreditHours) 
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                      AND EXISTS (
                          SELECT 1 FROM Assessment a
                          WHERE a.CourseOfferID = co.CourseOfferID
                          HAVING SUM(a.Weightage) >= 99.9
                      )";
                SqlCommand cmdCredits = new SqlCommand(creditsQuery, conn);
                cmdCredits.Parameters.AddWithValue("@StudentID", _studentId);
                object creditsObj = cmdCredits.ExecuteScalar();
                int earned = creditsObj != DBNull.Value ? Convert.ToInt32(creditsObj) : 0;
                lblCreditsEarned.Text = earned.ToString();

                string progQuery = "SELECT TotalCreditHours FROM Programme p INNER JOIN Student s ON p.ProgrammeCode = s.ProgrammeCode WHERE s.StudentID = @StudentID";
                SqlCommand cmdProg = new SqlCommand(progQuery, conn);
                cmdProg.Parameters.AddWithValue("@StudentID", _studentId);
                object totalObj = cmdProg.ExecuteScalar();
                int totalRequired = totalObj != DBNull.Value ? Convert.ToInt32(totalObj) : 0;
                lblTotalRequiredCredits.Text = totalRequired.ToString();

                decimal cgpa = 0;
                string gpaQuery = @"
                    SELECT SUM(g.GradePoint * c.CreditHours) / SUM(c.CreditHours)
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
                        SELECT GradePoint FROM GradeScale WHERE (calc.WeightedPercentage / calc.TotalWeight * 100) BETWEEN MinMarks AND MaxMarks
                    ) g
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                      AND calc.TotalWeight >= 99.9";
                SqlCommand cmdGpa = new SqlCommand(gpaQuery, conn);
                cmdGpa.Parameters.AddWithValue("@StudentID", _studentId);
                object gpaObj = cmdGpa.ExecuteScalar();
                if (gpaObj != DBNull.Value && gpaObj != null)
                    cgpa = Math.Round(Convert.ToDecimal(gpaObj), 2);
                lblCurrentGPA.Text = cgpa.ToString("0.00");
            }
        }

        // -----------------------------------------------------------------
        // Enrollment action methods
        // -----------------------------------------------------------------
        protected void EnrollCourse_Click(object sender, EventArgs e)
        {
            if (!IsEnrollmentPeriodOpen())
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    "alert('Enrollment period is closed. You cannot enroll in new courses.');", true);
                return;
            }

            Button btn = (Button)sender;
            int courseOfferId = Convert.ToInt32(btn.CommandArgument);

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string checkSql = "SELECT EnrolStatus FROM Enrolment WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID";
                SqlCommand checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@StudentID", _studentId);
                checkCmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                object statusObj = checkCmd.ExecuteScalar();

                if (statusObj != null && statusObj.ToString() == "Dropped")
                {
                    string updateSql = "UPDATE Enrolment SET EnrolStatus = 'Enrolled', EnrolmentDate = GETDATE() WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID";
                    SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                    updateCmd.Parameters.AddWithValue("@StudentID", _studentId);
                    updateCmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                    updateCmd.ExecuteNonQuery();
                }
                else if (statusObj == null)
                {
                    string insertSql = @"
                        INSERT INTO Enrolment (StudentID, CourseOfferID, EnrolStatus, EnrolmentDate)
                        VALUES (@StudentID, @CourseOfferID, 'Enrolled', GETDATE())";
                    SqlCommand insertCmd = new SqlCommand(insertSql, conn);
                    insertCmd.Parameters.AddWithValue("@StudentID", _studentId);
                    insertCmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                    insertCmd.ExecuteNonQuery();
                }
            }

            LoadCurrentEnrollment();
            LoadDroppedCourses();
            LoadAvailableCourses();
            LoadAcademicHistory();
            LoadSummary();

            if (!IsEnrollmentPeriodOpen())
                DisableEnrollmentButtons();

            // Refresh the UpdatePanel
            upEnrollment.Update();
        }

        protected void DropCourse_Click(object sender, EventArgs e)
        {
            if (!IsEnrollmentPeriodOpen())
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    "alert('Drop period is closed. You cannot drop courses now.');", true);
                return;
            }

            Button btn = (Button)sender;
            int courseOfferId = Convert.ToInt32(btn.CommandArgument);
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string updateSql = "UPDATE Enrolment SET EnrolStatus = 'Dropped' WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID";
                SqlCommand cmd = new SqlCommand(updateSql, conn);
                cmd.Parameters.AddWithValue("@StudentID", _studentId);
                cmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                cmd.ExecuteNonQuery();
            }

            LoadCurrentEnrollment();
            LoadDroppedCourses();
            LoadAvailableCourses();
            LoadAcademicHistory();
            LoadSummary();

            if (!IsEnrollmentPeriodOpen())
                DisableEnrollmentButtons();

            // Refresh the UpdatePanel
            upEnrollment.Update();
        }

        protected void ReenrollCourse_Click(object sender, EventArgs e)
        {
            if (!IsEnrollmentPeriodOpen())
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    "alert('Re‑enrollment period is closed.');", true);
                return;
            }

            Button btn = (Button)sender;
            int courseOfferId = Convert.ToInt32(btn.CommandArgument);
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string updateSql = "UPDATE Enrolment SET EnrolStatus = 'Enrolled', EnrolmentDate = GETDATE() WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID";
                SqlCommand cmd = new SqlCommand(updateSql, conn);
                cmd.Parameters.AddWithValue("@StudentID", _studentId);
                cmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                cmd.ExecuteNonQuery();
            }

            LoadCurrentEnrollment();
            LoadDroppedCourses();
            LoadAvailableCourses();
            LoadAcademicHistory();
            LoadSummary();

            if (!IsEnrollmentPeriodOpen())
                DisableEnrollmentButtons();

            // Refresh the UpdatePanel
            upEnrollment.Update();
        }
    }
}
