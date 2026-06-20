using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class LecturerMonitorAcademicProgress : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null)
                Response.Redirect("Login.aspx");

            lblSidebarName.Text = Session["LecturerName"]?.ToString();
            lblWelcomeName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                LoadSidebarProfilePic();
                LoadProgrammes();
                ResetDashboardCards();
            }
        }

        private void LoadSidebarProfilePic()
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
            catch
            {
                // Fallback softly to showing text placeholder characters on query exception errors
            }

            imgSidebar.Visible = false;
            litSideInitials.Visible = true;
        }

        private void LoadProgrammes()
        {
            string query = @"
                SELECT DISTINCT p.ProgrammeCode, p.ProgrammeName
                FROM Programme p
                INNER JOIN Course c ON c.ProgrammeCode = p.ProgrammeCode
                INNER JOIN CourseOffer co ON co.CourseCode = c.CourseCode
                WHERE co.LecturerID = @LID";

            SqlParameter[] p = {
                new SqlParameter("@LID", Session["LecturerID"])
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);

            ddlProgramme.DataSource = dt;
            ddlProgramme.DataTextField = "ProgrammeName";
            ddlProgramme.DataValueField = "ProgrammeCode";
            ddlProgramme.DataBind();

            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
            ddlCourseOffer.Items.Clear();
            ddlCourseOffer.Items.Add(new ListItem("-- Select Course --", "0"));
        }

        protected void ddlProgramme_Changed(object sender, EventArgs e)
        {
            ddlCourseOffer.Items.Clear();

            if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                string query = @"
                    SELECT co.CourseOfferID,
                           c.CourseName + ' (' + s.Semester + ' ' + CAST(co.Year AS NVARCHAR) + ')' AS DisplayName
                    FROM CourseOffer co
                    INNER JOIN Course c ON c.CourseCode = co.CourseCode
                    INNER JOIN Semester s ON s.SemesterID = co.SemesterID
                    WHERE co.LecturerID = @LID
                    AND c.ProgrammeCode = @PCode
                    AND co.OfferStatus = 'Available'";

                SqlParameter[] p = {
                    new SqlParameter("@LID", Session["LecturerID"]),
                    new SqlParameter("@PCode", ddlProgramme.SelectedValue)
                };

                DataTable dt = DBHelper.ExecuteQuery(query, p);

                ddlCourseOffer.DataSource = dt;
                ddlCourseOffer.DataTextField = "DisplayName";
                ddlCourseOffer.DataValueField = "CourseOfferID";
                ddlCourseOffer.DataBind();
            }

            ddlCourseOffer.Items.Insert(0, new ListItem("-- Select Course --", "0"));
            gvProgress.DataSource = null;
            gvProgress.DataBind();
            ResetDashboardCards();
            lblStatus.Text = "";
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadStudentProgress();
        }

        private void LoadStudentProgress()
        {
            if (ddlCourseOffer.SelectedValue == "0")
            {
                lblStatus.Text = "Please select a course.";
                lblStatus.CssClass = "error-msg";
                gvProgress.DataSource = null;
                gvProgress.DataBind();
                ResetDashboardCards();
                return;
            }

            DataTable dt = GetProgressData(ddlCourseOffer.SelectedValue, txtSearch.Text.Trim());

            DataView view = dt.DefaultView;

            if (ddlFilter.SelectedValue == "At Risk")
                view.RowFilter = "Status = 'At Risk'";
            else if (ddlFilter.SelectedValue == "Good")
                view.RowFilter = "Status = 'Good'";

            if (ddlSort.SelectedValue == "Attendance")
                view.Sort = "Attendance DESC";
            else if (ddlSort.SelectedValue == "Assessment")
                view.Sort = "AssessmentPercentage DESC";
            else if (ddlSort.SelectedValue == "Grade")
                view.Sort = "AssessmentPercentage DESC";
            else
                view.Sort = "StudentName ASC";

            DataTable filtered = view.ToTable();

            gvProgress.DataSource = filtered;
            gvProgress.DataBind();

            LoadDashboardCards(filtered);
            lblStatus.Text = "";
        }

        private DataTable GetProgressData(string courseOfferID, string search)
        {
            string query = @"
                WITH AttendanceSummary AS
                (
                    SELECT
                        StudentID,
                        CourseOfferID,
                        COUNT(*) AS TotalClasses,
                        SUM(CASE WHEN AttendanceStatus IN ('Present', 'Late') THEN 1 ELSE 0 END) AS AttendedClasses
                    FROM AttendanceRecord
                    WHERE CourseOfferID = @COID
                    GROUP BY StudentID, CourseOfferID
                ),
                AssessmentSummary AS
                (
                    SELECT
                        sa.StudentID,
                        a.CourseOfferID,
                        SUM(
                            CASE
                                WHEN a.MaxMarks > 0
                                THEN (CAST(sa.ObtainedMark AS DECIMAL(10,2)) / CAST(a.MaxMarks AS DECIMAL(10,2))) * a.Weightage
                                ELSE 0
                            END
                        ) AS AssessmentPercentage
                    FROM Assessment a
                    INNER JOIN StudentAssessment sa ON sa.AssessmentID = a.AssessmentID
                    WHERE a.CourseOfferID = @COID
                    GROUP BY sa.StudentID, a.CourseOfferID
                )
                SELECT
                    s.StudentID,
                    s.StudentName,
                    CAST(
                        CASE
                            WHEN ISNULL(att.TotalClasses, 0) = 0 THEN 0
                            ELSE 100.0 * att.AttendedClasses / att.TotalClasses
                        END
                    AS DECIMAL(5,2)) AS Attendance,
                    CAST(ISNULL(asm.AssessmentPercentage, 0) AS DECIMAL(5,2)) AS AssessmentPercentage,
                    CASE
                        WHEN ISNULL(asm.AssessmentPercentage, 0) >= 90 THEN 'A+'
                        WHEN ISNULL(asm.AssessmentPercentage, 0) >= 80 THEN 'A'
                        WHEN ISNULL(asm.AssessmentPercentage, 0) >= 75 THEN 'B+'
                        WHEN ISNULL(asm.AssessmentPercentage, 0) >= 70 THEN 'B'
                        WHEN ISNULL(asm.AssessmentPercentage, 0) >= 65 THEN 'C+'
                        WHEN ISNULL(asm.AssessmentPercentage, 0) >= 60 THEN 'C'
                        WHEN ISNULL(asm.AssessmentPercentage, 0) >= 50 THEN 'D'
                        ELSE 'F'
                    END AS CurrentGrade,
                    CASE
                        WHEN
                            CASE
                                WHEN ISNULL(att.TotalClasses, 0) = 0 THEN 0
                                ELSE 100.0 * att.AttendedClasses / att.TotalClasses
                            END < 70
                            OR ISNULL(asm.AssessmentPercentage, 0) < 50
                        THEN 'At Risk'
                        ELSE 'Good'
                    END AS Status
                FROM Student s
                INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                LEFT JOIN AttendanceSummary att
                    ON att.StudentID = s.StudentID
                    AND att.CourseOfferID = e.CourseOfferID
                LEFT JOIN AssessmentSummary asm
                    ON asm.StudentID = s.StudentID
                    AND asm.CourseOfferID = e.CourseOfferID
                WHERE e.CourseOfferID = @COID
                AND e.EnrolStatus = 'Enrolled'
                AND (
                    @Search = ''
                    OR s.StudentName LIKE @SearchLike
                    OR CAST(s.StudentID AS NVARCHAR(20)) LIKE @SearchLike
                )
                ORDER BY s.StudentName";

            SqlParameter[] p = {
                new SqlParameter("@COID", courseOfferID),
                new SqlParameter("@Search", search),
                new SqlParameter("@SearchLike", "%" + search + "%")
            };

            return DBHelper.ExecuteQuery(query, p);
        }

        private void LoadDashboardCards(DataTable dt)
        {
            int totalStudents = dt.Rows.Count;
            int riskStudents = 0;
            decimal attendanceTotal = 0;
            decimal assessmentTotal = 0;

            foreach (DataRow row in dt.Rows)
            {
                attendanceTotal += Convert.ToDecimal(row["Attendance"]);
                assessmentTotal += Convert.ToDecimal(row["AssessmentPercentage"]);

                if (row["Status"].ToString() == "At Risk")
                    riskStudents++;
            }

            decimal averageAttendance = totalStudents > 0 ? attendanceTotal / totalStudents : 0;
            decimal averageAssessment = totalStudents > 0 ? assessmentTotal / totalStudents : 0;

            lblTotalStudents.Text = totalStudents.ToString();
            lblAverageAttendance.Text = averageAttendance.ToString("0.##") + "%";
            lblAverageGrade.Text = GetGrade(averageAssessment);
            lblRiskStudents.Text = riskStudents.ToString();
        }

        private void ResetDashboardCards()
        {
            lblTotalStudents.Text = "0";
            lblAverageAttendance.Text = "0%";
            lblAverageGrade.Text = "-";
            lblRiskStudents.Text = "0";
        }

        private string GetGrade(decimal percentage)
        {
            if (percentage >= 90) return "A+";
            if (percentage >= 80) return "A";
            if (percentage >= 75) return "B+";
            if (percentage >= 70) return "B";
            if (percentage >= 65) return "C+";
            if (percentage >= 60) return "C";
            if (percentage >= 50) return "D";
            return "F";
        }
    }
}