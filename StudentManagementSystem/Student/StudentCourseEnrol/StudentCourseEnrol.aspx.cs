using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
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

        private enum Tab { MyEnrollments, Available, Dropped, History, PaymentHistory }
        private Tab ActiveTab
        {
            get { return ViewState["ActiveTab"] == null ? Tab.MyEnrollments : (Tab)ViewState["ActiveTab"]; }
            set { ViewState["ActiveTab"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Ensure the form can accept file uploads (in case master page lacks it)
            Page.Form.Enctype = "multipart/form-data";

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
            LoadPaymentHistory();
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
                      AND co.SemesterID >= @CurrentSemesterId
                    ORDER BY co.SemesterID, co.Year, c.CourseCode";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentID", _studentId);
                cmd.Parameters.AddWithValue("@CurrentSemesterId", _currentSemesterId);
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

                // Disable Drop buttons if enrollment is closed
                if (!IsEnrollmentPeriodOpen())
                {
                    foreach (GridViewRow row in gvMyEnrollments.Rows)
                    {
                        Button btnDrop = (Button)row.FindControl("btnDrop");
                        if (btnDrop != null)
                        {
                            btnDrop.Enabled = false;
                            btnDrop.CssClass = "px-3.5 py-1.5 text-xs font-semibold text-gray-400 bg-gray-100 border border-gray-200 rounded-lg cursor-not-allowed";
                            btnDrop.Text = "Closed";
                        }
                    }
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

                gvAvailable.DataSource = dt;
                gvAvailable.DataBind();

                // Disable Enroll buttons if enrollment is closed
                if (!IsEnrollmentPeriodOpen())
                {
                    foreach (GridViewRow row in gvAvailable.Rows)
                    {
                        Button btnEnroll = (Button)row.FindControl("btnEnroll");
                        if (btnEnroll != null)
                        {
                            btnEnroll.Enabled = false;
                            btnEnroll.CssClass = "px-5 py-1.5 text-xs font-semibold text-gray-400 bg-gray-100 border border-gray-200 rounded-lg cursor-not-allowed";
                            btnEnroll.Text = "Closed";
                        }
                    }
                }

                lblNoAvailable.Visible = (dt.Rows.Count == 0);
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

                // Disable Re‑enroll buttons if enrollment is closed
                if (!IsEnrollmentPeriodOpen())
                {
                    foreach (GridViewRow row in gvDropped.Rows)
                    {
                        Button btnReenroll = (Button)row.FindControl("btnReenroll");
                        if (btnReenroll != null)
                        {
                            btnReenroll.Enabled = false;
                            btnReenroll.CssClass = "px-4 py-1.5 text-xs font-semibold text-gray-400 bg-gray-100 border border-gray-200 rounded-lg cursor-not-allowed";
                            btnReenroll.Text = "Closed";
                        }
                    }
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

        // =============================================================
        // PAYMENT HISTORY (view‑only)
        // =============================================================
        private void LoadPaymentHistory()
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                string sql = @"
                    SELECT 
                        pr.ReferenceID,
                        s.Semester + ' ' + CAST(pr.SemesterID AS VARCHAR) AS SemesterDisplay,
                        pr.Amount,
                        pr.PaymentDate,
                        pr.UploadDate,
                        pr.PaymentProof,
                        pr.StudentStatus,
                        pr.VerifiedStatus,
                        pr.Comments
                    FROM PaymentRecord pr
                    INNER JOIN Semester s ON pr.SemesterID = s.SemesterID
                    WHERE pr.StudentID = @StudentID
                    ORDER BY pr.UploadDate DESC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentID", _studentId);
                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                sda.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    gvPaymentHistory.DataSource = dt;
                    gvPaymentHistory.DataBind();
                    gvPaymentHistory.Visible = true;
                    lblNoPayments.Visible = false;
                }
                else
                {
                    gvPaymentHistory.Visible = false;
                    lblNoPayments.Visible = true;
                }
            }
        }

        // =============================================================
        // BADGE HELPERS FOR PAYMENT GRID
        // =============================================================
        protected string GetStudentStatusBadge(string status)
        {
            switch (status)
            {
                case "Success": return "px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800";
                case "Failed": return "px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800";
                case "Pending": return "px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800";
                default: return "px-2 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-600";
            }
        }

        protected string GetVerifiedStatusBadge(string status)
        {
            switch (status)
            {
                case "Verified": return "px-2 py-1 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-800";
                case "Rejected": return "px-2 py-1 text-xs font-semibold rounded-full bg-rose-100 text-rose-800";
                case "Pending": return "px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800";
                default: return "px-2 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-600";
            }
        }

        // =============================================================
        // TAB VISIBILITY & NAVIGATION
        // =============================================================
        private void UpdateTabVisibility()
        {
            pnlMyEnrollments.Visible = (ActiveTab == Tab.MyEnrollments);
            pnlAvailable.Visible = (ActiveTab == Tab.Available);
            pnlDropped.Visible = (ActiveTab == Tab.Dropped);
            pnlHistory.Visible = (ActiveTab == Tab.History);
            pnlPaymentHistory.Visible = (ActiveTab == Tab.PaymentHistory);

            // Show floating payment button only on MyEnrollments
            DataTable dt = ViewState["EnrolledCourses"] as DataTable;
            pnlFloatingPayment.Visible = (dt != null && dt.Rows.Count > 0);

            string activeStyle = "px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px border-indigo-600 text-indigo-600 bg-indigo-50/40 rounded-t-lg";
            string inactiveStyle = "px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300";

            btnMyEnrollments.CssClass = (ActiveTab == Tab.MyEnrollments) ? activeStyle : inactiveStyle;
            btnAvailable.CssClass = (ActiveTab == Tab.Available) ? activeStyle : inactiveStyle;
            btnDropped.CssClass = (ActiveTab == Tab.Dropped) ? activeStyle : inactiveStyle;
            btnHistory.CssClass = (ActiveTab == Tab.History) ? activeStyle : inactiveStyle;
            btnPaymentHistory.CssClass = (ActiveTab == Tab.PaymentHistory) ? activeStyle : inactiveStyle;
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
            string today = DateTime.Now.ToString("MM-dd");
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT EnrolStartDate, EnrolEndDate
                    FROM Semester
                    WHERE @Today BETWEEN StartMonthDay AND EndMonthDay";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Today", today);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        string start = dr["EnrolStartDate"]?.ToString();
                        string end = dr["EnrolEndDate"]?.ToString();
                        if (!string.IsNullOrEmpty(start) && !string.IsNullOrEmpty(end))
                        {
                            return string.Compare(today, start) >= 0 && string.Compare(today, end) <= 0;
                        }
                    }
                }
            }
            return false;
        }

        // =============================================================
        // TAB CLICK EVENTS
        // =============================================================
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

        protected void tabPaymentHistory_Click(object sender, EventArgs e)
        {
            ActiveTab = Tab.PaymentHistory;
            LoadPaymentHistory();
            UpdateTabVisibility();
        }

        // =============================================================
        // ENROLLMENT ACTIONS (Enroll, Drop, Re‑enroll)
        // =============================================================
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

        // =============================================================
        // PAYMENT ACTIONS (Invoice Modal + Upload) – with try-catch
        // =============================================================
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

            txtPayAmount.Text = "";
            txtPayDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            lblModalStatus.Text = "";
            lblModalStatus.ForeColor = System.Drawing.Color.Black;

            ScriptManager.RegisterStartupScript(this, GetType(), "showPaymentModal", "openPaymentModal();", true);
        }

        protected void btnConfirmPayment_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate amount
                if (!decimal.TryParse(txtPayAmount.Text, out decimal amount) || amount <= 0)
                {
                    lblModalStatus.Text = "Please enter a valid amount.";
                    lblModalStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                // Validate file
                if (!fuPaymentProof.HasFile)
                {
                    lblModalStatus.Text = "Please upload a payment receipt.";
                    lblModalStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                // Validate file type and size
                string extension = Path.GetExtension(fuPaymentProof.FileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".pdf" };
                if (!Array.Exists(allowedExtensions, ext => ext == extension))
                {
                    lblModalStatus.Text = "Only JPG, PNG, and PDF files are allowed.";
                    lblModalStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                if (fuPaymentProof.PostedFile.ContentLength > 5 * 1024 * 1024) // 5MB
                {
                    lblModalStatus.Text = "File size must be under 5MB.";
                    lblModalStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                // Save file
                string folder = Server.MapPath("~/Uploads/Payments/");
                if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

                string fileName = "payment_" + DateTime.Now.Ticks + extension;
                string savePath = Path.Combine(folder, fileName);
                fuPaymentProof.SaveAs(savePath);
                string fileUrl = "~/Uploads/Payments/" + fileName;

                // Generate reference ID
                string refId = GenerateReferenceID();

                // Insert into PaymentRecord
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    string sql = @"
                        INSERT INTO PaymentRecord 
                            (StudentID, SemesterID, ReferenceID, Amount, PaymentDate, UploadDate, PaymentProof, StudentStatus, VerifiedStatus)
                        VALUES 
                            (@StudentID, @SemesterID, @RefID, @Amount, @PaymentDate, GETDATE(), @Proof, 'Pending', 'Pending')";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@StudentID", _studentId);
                    cmd.Parameters.AddWithValue("@SemesterID", _currentSemesterId);
                    cmd.Parameters.AddWithValue("@RefID", refId);
                    cmd.Parameters.AddWithValue("@Amount", amount);
                    cmd.Parameters.AddWithValue("@PaymentDate", DateTime.TryParse(txtPayDate.Text, out DateTime payDate) ? (object)payDate : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Proof", fileUrl);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Clear modal and close
                lblModalStatus.Text = "Payment submitted! Reference: " + refId;
                lblModalStatus.ForeColor = System.Drawing.Color.Green;

                // Refresh payment history
                LoadPaymentHistory();

                // Close modal after a short delay (client-side)
                string script = @"
                    setTimeout(function() {
                        closePaymentModal();
                    }, 2000);
                    alert('Payment submitted successfully. Reference ID: " + refId + @"');
                ";
                ScriptManager.RegisterStartupScript(this, GetType(), "paymentSubmitted", script, true);
            }
            catch (Exception ex)
            {
                lblModalStatus.Text = "Error: " + ex.Message;
                lblModalStatus.ForeColor = System.Drawing.Color.Red;
            }
        }

        private string GenerateReferenceID()
        {
            string prefix = "PAY";
            string date = DateTime.Now.ToString("yyyyMM");
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT COUNT(*) FROM PaymentRecord WHERE ReferenceID LIKE @Pattern";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Pattern", prefix + "-" + date + "%");
                int count = Convert.ToInt32(cmd.ExecuteScalar()) + 1;
                return $"{prefix}-{date}-{count:D4}";
            }
        }
    }
}