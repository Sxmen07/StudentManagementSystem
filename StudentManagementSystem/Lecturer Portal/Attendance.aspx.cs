using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class Attendance : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null)
                Response.Redirect("Login.aspx");

            lblSidebarName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadProgrammes();
            }
        }

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
            pnlTable.Visible = false;
            pnlHistory.Visible = false;
        }

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            if (ddlCourseOffer.SelectedValue == "0")
            {
                lblStatus.Text = "Please select a course.";
                pnlTable.Visible = false;
                return;
            }

            hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;

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
            rptStudents.DataBind();

            pnlTable.Visible = true;
            pnlHistory.Visible = false;
            lblStatus.Text = "";
        }

        protected void rptStudents_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem)
                return;

            DataRowView row = (DataRowView)e.Item.DataItem;
            string existingStatus = row["AttendanceStatus"] == DBNull.Value ? null : row["AttendanceStatus"].ToString();

            CheckBox chkPresent = (CheckBox)e.Item.FindControl("chkPresent");
            CheckBox chkAbsent = (CheckBox)e.Item.FindControl("chkAbsent");
            CheckBox chkLate = (CheckBox)e.Item.FindControl("chkLate");

            chkPresent.Checked = existingStatus == "Present";
            chkAbsent.Checked = existingStatus == "Absent";
            chkLate.Checked = existingStatus == "Late";
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string courseOfferID = hfCourseOfferID.Value;
            string date = txtDate.Text;
            int saved = 0;

            foreach (RepeaterItem item in rptStudents.Items)
            {
                if (item.ItemType != ListItemType.Item &&
                    item.ItemType != ListItemType.AlternatingItem)
                    continue;

                HiddenField hiddenID = item.FindControl("hfStudentID") as HiddenField;
                if (hiddenID == null)
                    continue;

                int studentID = int.Parse(hiddenID.Value);

                CheckBox chkPresent = (CheckBox)item.FindControl("chkPresent");
                CheckBox chkAbsent = (CheckBox)item.FindControl("chkAbsent");
                CheckBox chkLate = (CheckBox)item.FindControl("chkLate");

                string status = chkPresent.Checked ? "Present"
                              : chkAbsent.Checked ? "Absent"
                              : chkLate.Checked ? "Late"
                              : "Absent";

                string query = @"
                    MERGE AttendanceRecord AS target
                    USING (SELECT @SID AS StudentID, @COID AS CourseOfferID, @Date AS AttendanceDate) AS src
                    ON target.StudentID = src.StudentID
                    AND target.CourseOfferID = src.CourseOfferID
                    AND target.AttendanceDate = src.AttendanceDate
                    WHEN MATCHED THEN
                        UPDATE SET AttendanceStatus = @Status
                    WHEN NOT MATCHED THEN
                        INSERT (StudentID, CourseOfferID, AttendanceDate, AttendanceStatus)
                        VALUES (@SID, @COID, @Date, @Status);";

                SqlParameter[] p = {
                    new SqlParameter("@SID", studentID),
                    new SqlParameter("@COID", courseOfferID),
                    new SqlParameter("@Date", date),
                    new SqlParameter("@Status", status)
                };

                DBHelper.ExecuteNonQuery(query, p);
                saved++;
            }

            lblStatus.Text = "Attendance saved for " + saved + " students on " + date + ".";
        }

        protected void btnHistory_Click(object sender, EventArgs e)
        {
            if (ddlCourseOffer.SelectedValue == "0")
            {
                lblHistoryStatus.Text = "Please select a course first.";
                pnlHistory.Visible = true;
                return;
            }

            string query = @"
                SELECT s.StudentID, s.StudentName,
                       SUM(CASE WHEN ar.AttendanceStatus = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
                       SUM(CASE WHEN ar.AttendanceStatus = 'Absent' THEN 1 ELSE 0 END) AS AbsentCount,
                       SUM(CASE WHEN ar.AttendanceStatus = 'Late' THEN 1 ELSE 0 END) AS LateCount,
                       COUNT(ar.AttendanceDate) AS TotalClasses,
                       CAST(
                           CASE WHEN COUNT(ar.AttendanceDate) = 0 THEN 0
                           ELSE 100.0 * SUM(CASE WHEN ar.AttendanceStatus IN ('Present', 'Late') THEN 1 ELSE 0 END) / COUNT(ar.AttendanceDate)
                           END AS DECIMAL(5,2)
                       ) AS AttendanceRate
                FROM Student s
                INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                LEFT JOIN AttendanceRecord ar ON ar.StudentID = s.StudentID
                    AND ar.CourseOfferID = e.CourseOfferID
                WHERE e.CourseOfferID = @COID
                AND e.EnrolStatus = 'Enrolled'
                GROUP BY s.StudentID, s.StudentName
                ORDER BY s.StudentName";

            SqlParameter[] p = { new SqlParameter("@COID", ddlCourseOffer.SelectedValue) };
            DataTable dt = DBHelper.ExecuteQuery(query, p);

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

            litAttendanceHistory.Text = html.ToString();
            lblHistoryStatus.Text = "";
            pnlHistory.Visible = true;
            pnlTable.Visible = false;
        }
    }
}