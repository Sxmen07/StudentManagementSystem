using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class Attendance : Page
    {
        // Setup function for page load
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null)
                Response.Redirect("Login.aspx");

            lblSidebarName.Text = Session["LecturerName"]?.ToString();
            lblWelcomeName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadSidebarProfilePic();
                LoadProgrammes();
            }
        }

        private void LoadSidebarProfilePic()
        {
            string lecturerName = Session["LecturerName"]?.ToString() ?? "Lecturer";
            lblSidebarName.Text = lecturerName;

            // Compute fallback initials string matching LectProfile styling routines
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

        // Populates the first drop-down menu with academic major programmes taught by this lecturer
        private void LoadProgrammes()
        {
            string query = @"
                SELECT DISTINCT p.ProgrammeCode, p.ProgrammeName
                FROM Programme p
                INNER JOIN Course c ON c.ProgrammeCode = p.ProgrammeCode
                INNER JOIN CourseOffer co ON co.CourseCode = c.CourseCode
                WHERE co.LecturerID = @LID";

            SqlParameter[] p = { new SqlParameter("@LID", Session["LecturerID"]) };
            DataTable dt = DBHelper.ExecuteQuery(query, p);

            ddlProgramme.DataSource = dt;
            ddlProgramme.DataTextField = "ProgrammeName"; // What the human sees
            ddlProgramme.DataValueField = "ProgrammeCode"; // What the code processes
            ddlProgramme.DataBind();

            // Insert a default placeholder row at position 0
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
            ddlCourseOffer.Items.Clear();
            ddlCourseOffer.Items.Add(new ListItem("-- Select Course --", "0"));
        }

        // when a lecturer picks a Programme to load matching courses
        protected void ddlProgramme_Changed(object sender, EventArgs e)
        {
            ddlCourseOffer.Items.Clear(); // Empty out historical selections

            if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                // Find all active class schedules (CourseOffer) matching selected programme and lecturer
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
            pnlTable.Visible = false;   // Hide tracking workspace panels until they hit Load
            pnlHistory.Visible = false;
            pnlExportOptions.Visible = false; // Stale CourseOfferID is no longer valid for export until reloaded
        }

        // Load Student List
        protected void btnLoad_Click(object sender, EventArgs e)
        {
            if (ddlCourseOffer.SelectedValue == "0")
            {
                lblStatus.Text = "Please select a course.";
                pnlTable.Visible = false;
                return;
            }

            // Stash Selected CourseOfferID into a invisible storage field to remember it during panel posts
            hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;

            // Fetch students enrolled in this course, plus their attendance status for the picked date (if saved before)
            string query = @"
                SELECT s.StudentID, s.StudentName, ar.AttendanceStatus
                FROM Student s
                INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                LEFT JOIN AttendanceRecord ar ON ar.StudentID = s.StudentID
                    AND ar.CourseOfferID = @COID
                    AND ar.AttendanceDate = @Date
                WHERE e.CourseOfferID = @COID
                AND e.EnrolStatus = 'Enrolled'
                ORDER BY s.StudentName";

            SqlParameter[] p = {
                new SqlParameter("@COID", ddlCourseOffer.SelectedValue),
                new SqlParameter("@Date", txtDate.Text)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, p);
            rptStudents.DataSource = dt;
            rptStudents.DataBind(); // Sends the structural dataset down into the frontend Repeater grid

            pnlTable.Visible = true; // Show tracking sheet workspace
            pnlHistory.Visible = false;
            pnlExportOptions.Visible = true; // Report can only be generated once a course's data is actually loaded
            lblStatus.Text = "";
            lblExportStatus.Text = "";
        }


        // Special system hook that processes each single row inside the student table as it renders
        protected void rptStudents_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            // Ignore headers/footers, only adjust standard data items
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            string existingStatus = row["AttendanceStatus"] == DBNull.Value ? null : row["AttendanceStatus"].ToString();

            // Locate check boxes built inside the frontend HTML architecture
            CheckBox chkPresent = (CheckBox)e.Item.FindControl("chkPresent");
            CheckBox chkAbsent = (CheckBox)e.Item.FindControl("chkAbsent");
            CheckBox chkLate = (CheckBox)e.Item.FindControl("chkLate");

            // Look up existing database markers to check the right boxes automatically
            chkPresent.Checked = existingStatus == "Present";
            chkAbsent.Checked = existingStatus == "Absent";
            chkLate.Checked = existingStatus == "Late";
        }

        // Processes massive checkbox sheet selections and saves them safely to SQL tables
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string courseOfferID = hfCourseOfferID.Value;
            string date = txtDate.Text;
            int savedCount = 0;

            // Loop through every student entry layout displayed on screen
            foreach (RepeaterItem item in rptStudents.Items)
            {
                if (item.ItemType != ListItemType.Item && item.ItemType != ListItemType.AlternatingItem) continue;

                // Identify structural element states inside the row
                HiddenField hfStudentID = (HiddenField)item.FindControl("hfStudentID");
                CheckBox chkPresent = (CheckBox)item.FindControl("chkPresent");
                CheckBox chkAbsent = (CheckBox)item.FindControl("chkAbsent");
                CheckBox chkLate = (CheckBox)item.FindControl("chkLate");

                int studentID = Convert.ToInt32(hfStudentID.Value);
                string status = null;

                // Assign status string variable depending on what box is ticked
                if (chkPresent.Checked) status = "Present";
                else if (chkAbsent.Checked) status = "Absent";
                else if (chkLate.Checked) status = "Late";

                if (status != null)
                {
                    // MERGE construct: If tracking combo exists, update it. If brand new entry, insert it.
                    string mergeQuery = @"
                        MERGE AttendanceRecord AS target
                        USING (SELECT @SID AS StudentID, @COID AS CourseOfferID, @Date AS AttendanceDate) AS source
                        ON (target.StudentID = source.StudentID AND target.CourseOfferID = source.CourseOfferID AND target.AttendanceDate = source.AttendanceDate)
                        WHEN MATCHED THEN
                            UPDATE SET AttendanceStatus = @Status
                        WHEN NOT MATCHED THEN
                            INSERT (StudentID, CourseOfferID, AttendanceDate, AttendanceStatus)
                            VALUES (source.StudentID, source.CourseOfferID, source.AttendanceDate, @Status);";

                    SqlParameter[] p = {
                        new SqlParameter("@SID", studentID),
                        new SqlParameter("@COID", courseOfferID),
                        new SqlParameter("@Date", date),
                        new SqlParameter("@Status", status)
                    };

                    DBHelper.ExecuteNonQuery(mergeQuery, p);
                    savedCount++;
                }
            }

            lblStatus.Text = $"✔ Successfully captured attendance for {savedCount} students.";
            lblStatus.ForeColor = System.Drawing.Color.Green;
        }

        // Gathers metric percentages and generates table history of attendance for this course
        protected void btnViewHistory_Click(object sender, EventArgs e)
        {
            if (ddlCourseOffer.SelectedValue == "0") return;

            string courseOfferID = ddlCourseOffer.SelectedValue;

            // Pull cumulative statistical variables via query logic grouping
            string query = @"
                SELECT s.StudentID, s.StudentName,
                       COUNT(CASE WHEN ar.AttendanceStatus = 'Present' THEN 1 END) AS PresentCount,
                       COUNT(CASE WHEN ar.AttendanceStatus = 'Absent' THEN 1 END) AS AbsentCount,
                       COUNT(CASE WHEN ar.AttendanceStatus = 'Late' THEN 1 END) AS LateCount,
                       COUNT(ar.AttendanceID) AS TotalClasses,
                       CAST(CASE WHEN COUNT(ar.AttendanceID) = 0 THEN 0 
                            ELSE (COUNT(CASE WHEN ar.AttendanceStatus = 'Present' OR ar.AttendanceStatus = 'Late' THEN 1 END) * 100.0) / COUNT(ar.AttendanceID) 
                       END AS DECIMAL(5,1)) AS AttendanceRate
                FROM Student s
                INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                LEFT JOIN AttendanceRecord ar ON ar.StudentID = s.StudentID AND ar.CourseOfferID = @COID
                WHERE e.CourseOfferID = @COID AND e.EnrolStatus = 'Enrolled'
                GROUP BY s.StudentID, s.StudentName
                ORDER BY s.StudentName";

            SqlParameter[] p = { new SqlParameter("@COID", courseOfferID) };
            DataTable dt = DBHelper.ExecuteQuery(query, p);

            // Constructing a standard HTML string explicitly inside backend processes
            StringBuilder html = new StringBuilder();
            html.Append("<table><thead><tr>");
            html.Append("<th>No</th><th>Student ID</th><th>Student Name</th><th>Present</th><th>Absent</th><th>Late</th><th>Total Classes</th><th>Attendance Rate</th>");
            html.Append("</tr></thead><tbody>");

            int no = 1;
            foreach (DataRow row in dt.Rows)
            {
                html.Append("<tr>");
                html.Append("<td>" + no + "</td>");
                html.Append("<td class='student-id'>" + row["StudentID"] + "</td>");
                html.Append("<td>" + Server.HtmlEncode(row["StudentName"].ToString()) + "</td>");
                html.Append("<td>" + row["PresentCount"] + "</td>");
                html.Append("<td>" + row["AbsentCount"] + "</td>");
                html.Append("<td>" + row["LateCount"] + "</td>");
                html.Append("<td>" + row["TotalClasses"] + "</td>");
                html.Append("<td><strong>" + row["AttendanceRate"] + "%</strong></td>");
                html.Append("</tr>");
                no++;
            }

            if (dt.Rows.Count == 0)
                html.Append("<tr><td colspan='8' style='text-align:center;color:#aaa;padding:30px;'>No attendance history found.</td></tr>");

            html.Append("</tbody></table>");

            // Pour the completed string structure directly out to an object placeholder on the .aspx frontend
            litAttendanceHistory.Text = html.ToString();
            lblHistoryStatus.Text = "";
            pnlHistory.Visible = true;
            pnlTable.Visible = false;
        }

        protected void btnDownloadReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfCourseOfferID.Value)) return;

            // Direct database projection; numeric calculations are performed natively by the SQL engine
            string query = @"SELECT 
                        s.StudentID AS [Student ID], 
                        s.StudentName AS [Student Name],
                        SUM(CASE WHEN ar.AttendanceStatus = 'Present' THEN 1 ELSE 0 END) AS [Present Count],
                        SUM(CASE WHEN ar.AttendanceStatus = 'Late' THEN 1 ELSE 0 END) AS [Late Count],
                        SUM(CASE WHEN ar.AttendanceStatus = 'Absent' THEN 1 ELSE 0 END) AS [Absent Count],
                        CASE WHEN COUNT(ar.AttendanceID) = 0 THEN 0
                             ELSE (SUM(CASE WHEN ar.AttendanceStatus IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) / COUNT(ar.AttendanceID)
                        END AS [Attendance Rate (%)]
                     FROM Student s
                     INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                     LEFT JOIN AttendanceRecord ar ON ar.StudentID = s.StudentID AND ar.CourseOfferID = e.CourseOfferID
                     WHERE e.CourseOfferID = @COID AND e.EnrolStatus = 'Enrolled'
                     GROUP BY s.StudentID, s.StudentName
                     ORDER BY s.StudentName";

            DataTable dt = DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@COID", hfCourseOfferID.Value) });
            string format = ddlExportType.SelectedValue;
            string filename = $"Attendance_Report_{hfCourseOfferID.Value}_{DateTime.Now:yyyyMMdd}";
            string title = "Attendance Summary Report";

            if (format == "csv")
                ReportExporter.ExportToCSV(dt, filename, title);
            else
                ReportExporter.ExportToOfficeHTML(dt, filename + "." + format, format, title);
        }
    }
}