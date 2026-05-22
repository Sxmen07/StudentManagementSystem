using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class Attendance : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null) Response.Redirect("Login.aspx");
            lblWelcome.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadProgrammes();
            }
        }

        //Programms
        private void LoadProgrammes()
        {
            //Only load programmes that have course offers assigned to this lecturer
            string query = @"SELECT DISTINCT p.ProgrammeCode, p.ProgrammeName
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

        //Courses
        protected void ddlProgramme_Changed(object sender, EventArgs e)
        {
            ddlCourseOffer.Items.Clear();

            if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                // Load course offers for this lecturer under this programme
                string query = @"SELECT co.CourseOfferID,
                                        c.CourseName + ' (' + s.Semester + ' ' + CAST(co.Year AS NVARCHAR) + ')' AS DisplayName
                                 FROM CourseOffer co
                                 INNER JOIN Course c ON c.CourseCode = co.CourseCode
                                 INNER JOIN Semester s ON s.SemesterID = co.SemesterID
                                 WHERE co.LecturerID = @LID
                                   AND c.ProgrammeCode = @PCode
                                   AND co.OfferStatus = 'Available'";

                SqlParameter[] p = {
                    new SqlParameter("@LID",   Session["LecturerID"]),
                    new SqlParameter("@PCode", ddlProgramme.SelectedValue)
                };

                DataTable dt = DBHelper.ExecuteQuery(query, p);
                ddlCourseOffer.DataSource = dt;
                ddlCourseOffer.DataTextField = "DisplayName";
                ddlCourseOffer.DataValueField = "CourseOfferID";
                ddlCourseOffer.DataBind();
                ddlCourseOffer.Items.Insert(0, new ListItem("-- Select Course --", "0"));
            }
            else
            {
                ddlCourseOffer.Items.Add(new ListItem("-- Select Course --", "0"));
            }
        }

        //Load students for selected course offer
        protected void btnLoad_Click(object sender, EventArgs e)
        {
            if (ddlCourseOffer.SelectedValue == "0")
            {
                lblStatus.Text = "⚠ Please select a course.";
                return;
            }

            hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;

            //Load students enrolled in this course offer
            string query = @"SELECT s.StudentID, s.StudentName, s.StudentEmail
                             FROM Student s
                             INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                             WHERE e.CourseOfferID = @COID
                               AND e.EnrolStatus = 'Enrolled'
                             ORDER BY s.StudentName";

            SqlParameter[] p = { new SqlParameter("@COID", ddlCourseOffer.SelectedValue) };
            DataTable dt = DBHelper.ExecuteQuery(query, p);

            gvAttendance.DataSource = dt;
            gvAttendance.DataBind();
            btnSave.Visible = true;
            lblStatus.Text = "";
        }

        //Attendance status for each student on the selected date
        protected void gvAttendance_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int studentID = (int)gvAttendance.DataKeys[e.Row.RowIndex].Value;
                string courseOfferID = hfCourseOfferID.Value;
                string date = txtDate.Text;

                if (string.IsNullOrEmpty(courseOfferID) || courseOfferID == "0") return;

                string query = @"SELECT AttendanceStatus FROM AttendanceRecord
                                 WHERE StudentID = @SID
                                   AND CourseOfferID = @COID
                                   AND AttendanceDate = @Date";

                SqlParameter[] p = {
                    new SqlParameter("@SID",  studentID),
                    new SqlParameter("@COID", courseOfferID),
                    new SqlParameter("@Date", date)
                };

                object result = DBHelper.ExecuteScalar(query, p);
                if (result != null)
                {
                    DropDownList ddl = (DropDownList)e.Row.FindControl("ddlStatus");
                    if (ddl != null) ddl.SelectedValue = result.ToString();
                }
            }
        }

        //Save attendance records for all students
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string courseOfferID = hfCourseOfferID.Value;
            string date = txtDate.Text;

            if (string.IsNullOrEmpty(courseOfferID) || courseOfferID == "0") return;

            foreach (GridViewRow row in gvAttendance.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;

                int studentID = (int)gvAttendance.DataKeys[row.RowIndex].Value;
                DropDownList ddl = (DropDownList)row.FindControl("ddlStatus");
                string status = ddl.SelectedValue;

                //Upsert using MERGE
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
                    new SqlParameter("@SID",    studentID),
                    new SqlParameter("@COID",   courseOfferID),
                    new SqlParameter("@Date",   date),
                    new SqlParameter("@Status", status)
                };
                DBHelper.ExecuteNonQuery(query, p);
            }

            lblStatus.Text = "✔ Attendance saved for " + date + "!";
        }
    }
}