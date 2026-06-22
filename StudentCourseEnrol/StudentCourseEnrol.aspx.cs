using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentCourseEnrol : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;
        private int _studentId = 0;
        private int _currentSemesterId = 0;
        private int _currentYear = 0;

        private enum Tab { MyEnrollments, Available, Dropped, History }
        private Tab ActiveTab
        {
            get { return ViewState["ActiveTab"] == null ? Tab.MyEnrollments : (Tab)ViewState["ActiveTab"]; }
            set { ViewState["ActiveTab"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
                Response.Redirect("/Login.aspx");

            LoadStudentData();

            if (!IsPostBack)
            {
                ActiveTab = Tab.MyEnrollments;
                LoadAllData();
                UpdateTabVisibility();
                UpdateEnrollmentStatus();
            }
            else
            {
                UpdateEnrollmentStatus();
            }
        }

        private void LoadStudentData()
        {
            // 1. Get StudentID
            if (Session["UserEmail"] != null)
            {
                string email = Session["UserEmail"].ToString();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    string query = "SELECT StudentID FROM Student WHERE StudentEmail = @Email";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@Email", email);
                    conn.Open();
                    object res = cmd.ExecuteScalar();
                    if (res != null) _studentId = Convert.ToInt32(res);
                    conn.Close();
                }
            }

            // 2. Determine current semester from today's date
            string today = DateTime.Now.ToString("MM-dd");
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT TOP 1 SemesterID, AcademicYear AS [Year]
                    FROM Semester
                    WHERE @Today BETWEEN StartMonthDay AND EndMonthDay
                    ORDER BY AcademicYear DESC, SemesterID DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Today", today);
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    if (sdr.Read())
                    {
                        _currentSemesterId = Convert.ToInt32(sdr["SemesterID"]);
                        _currentYear = Convert.ToInt32(sdr["Year"]);
                    }
                    else
                    {
                        // Fallback: latest semester
                        string fallbackQuery = "SELECT TOP 1 SemesterID, AcademicYear FROM Semester ORDER BY AcademicYear DESC, SemesterID DESC";
                        SqlCommand fallbackCmd = new SqlCommand(fallbackQuery, conn);
                        using (SqlDataReader fallbackReader = fallbackCmd.ExecuteReader())
                        {
                            if (fallbackReader.Read())
                            {
                                _currentSemesterId = Convert.ToInt32(fallbackReader["SemesterID"]);
                                _currentYear = Convert.ToInt32(fallbackReader["AcademicYear"]);
                            }
                        }
                    }
                }
            }

            if (_currentSemesterId == 0) _currentSemesterId = 1;
            if (_currentYear == 0) _currentYear = DateTime.Now.Year;
        }

        private void LoadAllData()
        {
            LoadHeaderStats();
            LoadMyEnrollments();
            LoadAvailableCourses();
            LoadDroppedCourses();
            LoadAcademicHistory();
        }

        private void LoadHeaderStats()
        {
            lblTargetSemester.Text = "Semester " + _currentSemesterId + ", " + _currentYear;

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string progQuery = @"
                    SELECT TOP 1 TotalCreditHours 
                    FROM Programme p
                    INNER JOIN Student s ON p.ProgrammeCode = s.ProgrammeCode
                    WHERE s.StudentID = @StudentID";
                SqlCommand cmdProg = new SqlCommand(progQuery, conn);
                cmdProg.Parameters.AddWithValue("@StudentID", _studentId);
                object total = cmdProg.ExecuteScalar();
                lblTotalRequiredCredits.Text = total != null ? total.ToString() : "0";

                string countEnrolled = "SELECT COUNT(*) FROM Enrolment WHERE StudentID = @StudentID AND EnrolStatus = 'Enrolled'";
                SqlCommand cmd1 = new SqlCommand(countEnrolled, conn);
                cmd1.Parameters.AddWithValue("@StudentID", _studentId);
                lblEnrollmentCount.Text = cmd1.ExecuteScalar().ToString();

                string sumCredits = @"
                    SELECT ISNULL(SUM(c.CreditHours), 0) 
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Enrolled'
                      AND EXISTS (
                          SELECT 1 FROM Assessment a
                          WHERE a.CourseOfferID = co.CourseOfferID
                          HAVING SUM(a.Weightage) >= 99.9
                      )";
                SqlCommand cmd2 = new SqlCommand(sumCredits, conn);
                cmd2.Parameters.AddWithValue("@StudentID", _studentId);
                lblCreditsEarned.Text = cmd2.ExecuteScalar().ToString();

                string gpaQuery = @"
                    SELECT ISNULL(SUM(g.GradePoint * c.CreditHours) / SUM(c.CreditHours), 0)
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
                decimal gpa = gpaObj != null ? Convert.ToDecimal(gpaObj) : 0;
                lblCurrentGPA.Text = gpa.ToString("F2");
            }
        }

        private void LoadMyEnrollments()
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                string sql = @"
            SELECT 
                co.CourseOfferID,
                c.CourseCode,
                c.CourseName,
                c.CreditHours AS Credits,
                ISNULL(l.LecturerName, 'TBA') AS LecturerName,
                ISNULL(p.PricePerCourse, 0) AS Price
            FROM Enrolment e
            INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
            INNER JOIN Course c ON co.CourseCode = c.CourseCode
            LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
            INNER JOIN Programme p ON c.ProgrammeCode = p.ProgrammeCode
            WHERE e.StudentID = @StudentID 
              AND e.EnrolStatus = 'Enrolled'
              AND co.SemesterID = @CurrentSemesterId";   // ← Added semester filter

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentID", _studentId);
                cmd.Parameters.AddWithValue("@CurrentSemesterId", _currentSemesterId);  // ← New parameter
                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                sda.Fill(dt);

                ViewState["EnrolledCourses"] = dt;

                if (dt.Rows.Count > 0)
                {
                    gvMyEnrollments.DataSource = dt;
                    gvMyEnrollments.DataBind();
                    gvMyEnrollments.Visible = true;
                    lblNoEnrollments.Visible = false;
                    pnlFloatingPayment.Visible = (ActiveTab == Tab.MyEnrollments);
                }
                else
                {
                    gvMyEnrollments.Visible = false;
                    lblNoEnrollments.Visible = true;
                    pnlFloatingPayment.Visible = false;
                }
            }
        }

        private void LoadAvailableCourses()
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                string sql = @"
                    SELECT 
                        co.CourseOfferID,
                        c.CourseCode,
                        c.CourseName,
                        c.CreditHours AS Credits,
                        ISNULL(l.LecturerName, 'TBA') AS LecturerName,
                        co.MaxCapacity AS Capacity,
                        (co.MaxCapacity - (SELECT COUNT(*) FROM Enrolment e2 WHERE e2.CourseOfferID = co.CourseOfferID AND e2.EnrolStatus = 'Enrolled')) AS AvailableSlots,
                        CAST(co.MaxCapacity - (SELECT COUNT(*) FROM Enrolment e2 WHERE e2.CourseOfferID = co.CourseOfferID AND e2.EnrolStatus = 'Enrolled') AS VARCHAR) + '/' + CAST(co.MaxCapacity AS VARCHAR) AS CapacityInfo
                    FROM CourseOffer co
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    LEFT JOIN Lecturer l ON co.LecturerID = l.LecturerID
                    WHERE co.CourseOfferID NOT IN (
                        SELECT CourseOfferID FROM Enrolment WHERE StudentID = @StudentID AND EnrolStatus = 'Enrolled'
                    )";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentID", _studentId);
                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                sda.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    gvAvailable.DataSource = dt;
                    gvAvailable.DataBind();
                    gvAvailable.Visible = true;
                    lblNoAvailable.Visible = false;
                }
                else
                {
                    gvAvailable.Visible = false;
                    lblNoAvailable.Visible = true;
                }
            }
        }

        private void LoadDroppedCourses()
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                string sql = @"
                    SELECT 
                        co.CourseOfferID,
                        c.CourseCode,
                        c.CourseName,
                        c.CreditHours AS Credits
                    FROM Enrolment e
                    INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
                    INNER JOIN Course c ON co.CourseCode = c.CourseCode
                    WHERE e.StudentID = @StudentID AND e.EnrolStatus = 'Dropped'";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentID", _studentId);
                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                sda.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    gvDropped.DataSource = dt;
                    gvDropped.DataBind();
                    gvDropped.Visible = true;
                    lblNoDropped.Visible = false;
                }
                else
                {
                    gvDropped.Visible = false;
                    lblNoDropped.Visible = true;
                }
            }
        }

        private void LoadAcademicHistory()
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                string sql = @"
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

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentID", _studentId);
                cmd.Parameters.AddWithValue("@CurrentSemesterId", _currentSemesterId);
                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                sda.Fill(dt);

                // Add Grade column
                dt.Columns.Add("Grade", typeof(string));
                foreach (DataRow row in dt.Rows)
                {
                    int coId = Convert.ToInt32(row["CourseOfferID"]);
                    row["Grade"] = ComputeGradeForCourse(_studentId, coId);
                }
                if (dt.Columns.Contains("CourseOfferID"))
                    dt.Columns.Remove("CourseOfferID");

                if (dt.Rows.Count > 0)
                {
                    gvHistory.DataSource = dt;
                    gvHistory.DataBind();
                    gvHistory.Visible = true;
                    lblNoHistory.Visible = false;
                }
                else
                {
                    gvHistory.Visible = false;
                    lblNoHistory.Visible = true;
                }
            }
        }

        private string ComputeGradeForCourse(int studentId, int courseOfferId)
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        SUM(a.Weightage) AS TotalWeight,
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

        private void UpdateTabVisibility()
        {
            pnlMyEnrollments.Visible = (ActiveTab == Tab.MyEnrollments);
            pnlAvailable.Visible = (ActiveTab == Tab.Available);
            pnlDropped.Visible = (ActiveTab == Tab.Dropped);
            pnlHistory.Visible = (ActiveTab == Tab.History);

            DataTable dt = ViewState["EnrolledCourses"] as DataTable;
            pnlFloatingPayment.Visible = (ActiveTab == Tab.MyEnrollments && dt != null && dt.Rows.Count > 0);

            string activeStyle = "px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px border-indigo-600 text-indigo-600 bg-indigo-50/40 rounded-t-lg";
            string inactiveStyle = "px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300";

            btnMyEnrollments.CssClass = (ActiveTab == Tab.MyEnrollments) ? activeStyle : inactiveStyle;
            btnAvailable.CssClass = (ActiveTab == Tab.Available) ? activeStyle : inactiveStyle;
            btnDropped.CssClass = (ActiveTab == Tab.Dropped) ? activeStyle : inactiveStyle;
            btnHistory.CssClass = (ActiveTab == Tab.History) ? activeStyle : inactiveStyle;
        }

        private void UpdateEnrollmentStatus()
        {
            if (IsEnrollmentPeriodOpen())
            {
                lblEnrollmentStatus.Text = "Open — Early Registration Window Active";
                lblEnrollmentStatus.ForeColor = System.Drawing.Color.FromName("#10b981");
            }
            else
            {
                lblEnrollmentStatus.Text = "Closed — Read Only Mode";
                lblEnrollmentStatus.ForeColor = System.Drawing.Color.FromName("#ef4444");
            }
        }

        private bool IsEnrollmentPeriodOpen()
        {
            // You can add logic here to check if current date is within enrollment window.
            // For now, we return true.
            return true;
        }

        protected void tabMyEnrollments_Click(object sender, EventArgs e)
        {
            ActiveTab = Tab.MyEnrollments;
            LoadMyEnrollments();
            UpdateTabVisibility();
        }

        protected void tabAvailable_Click(object sender, EventArgs e)
        {
            ActiveTab = Tab.Available;
            LoadAvailableCourses();
            UpdateTabVisibility();
        }

        protected void tabDropped_Click(object sender, EventArgs e)
        {
            ActiveTab = Tab.Dropped;
            LoadDroppedCourses();
            UpdateTabVisibility();
        }

        protected void tabHistory_Click(object sender, EventArgs e)
        {
            ActiveTab = Tab.History;
            LoadAcademicHistory();
            UpdateTabVisibility();
        }

        protected void EnrollCourse_Click(object sender, EventArgs e)
        {
            if (!IsEnrollmentPeriodOpen()) return;

            Button btn = (Button)sender;
            int courseOfferId = Convert.ToInt32(btn.CommandArgument);

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string checkSql = "SELECT COUNT(*) FROM Enrolment WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID";
                SqlCommand checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@StudentID", _studentId);
                checkCmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

                if (exists > 0)
                {
                    string updateSql = "UPDATE Enrolment SET EnrolStatus = 'Enrolled', EnrolmentDate = GETDATE() WHERE StudentID = @StudentID AND CourseOfferID = @CourseOfferID";
                    SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                    updateCmd.Parameters.AddWithValue("@StudentID", _studentId);
                    updateCmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                    updateCmd.ExecuteNonQuery();
                }
                else
                {
                    string insertSql = "INSERT INTO Enrolment (StudentID, CourseOfferID, EnrolStatus, EnrolmentDate) VALUES (@StudentID, @CourseOfferID, 'Enrolled', GETDATE())";
                    SqlCommand insertCmd = new SqlCommand(insertSql, conn);
                    insertCmd.Parameters.AddWithValue("@StudentID", _studentId);
                    insertCmd.Parameters.AddWithValue("@CourseOfferID", courseOfferId);
                    insertCmd.ExecuteNonQuery();
                }
            }

            LoadAllData();
            UpdateTabVisibility();
        }

        protected void DropCourse_Click(object sender, EventArgs e)
        {
            if (!IsEnrollmentPeriodOpen()) return;

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

            LoadAllData();
            UpdateTabVisibility();
        }

        protected void ReenrollCourse_Click(object sender, EventArgs e)
        {
            if (!IsEnrollmentPeriodOpen()) return;

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

            LoadAllData();
            UpdateTabVisibility();
        }

        protected void btnPayAll_Click(object sender, EventArgs e)
        {
            DataTable dt = ViewState["EnrolledCourses"] as DataTable;
            if (dt == null || dt.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('No enrolled courses to pay for.');", true);
                return;
            }

            rptPaymentCourses.DataSource = dt;
            rptPaymentCourses.DataBind();

            decimal total = 0;
            foreach (DataRow row in dt.Rows)
            {
                if (row["Price"] != DBNull.Value)
                    total += Convert.ToDecimal(row["Price"]);
            }
            lblModalTotal.Text = total.ToString("N2");

            ScriptManager.RegisterStartupScript(this, GetType(), "showPaymentModal", "openPaymentModal();", true);
        }

        protected void btnConfirmPayment_Click(object sender, EventArgs e)
        {
            string script = @"alert('Payment successful for all enrolled courses!'); closePaymentModal();";
            ScriptManager.RegisterStartupScript(this, GetType(), "paymentSuccess", script, true);

            LoadMyEnrollments();
        }
    }
}
