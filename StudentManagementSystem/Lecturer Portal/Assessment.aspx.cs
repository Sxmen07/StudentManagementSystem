using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class Assessment : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null)
                Response.Redirect("Login.aspx");

            lblSidebarName.Text = Session["LecturerName"]?.ToString();

            if (!IsPostBack)
                LoadProgrammes();
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
            pnlTable.Visible = false;
            pnlAssessmentModal.Visible = false;
        }

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            if (ddlCourseOffer.SelectedValue == "0")
            {
                ShowError("Please select a course.");
                pnlTable.Visible = false;
                return;
            }

            hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;
            pnlTable.Visible = true;
            pnlAssessmentModal.Visible = false;

            RenderAssessmentTable();
        }

        protected void btnOpenAssessmentModal_Click(object sender, EventArgs e)
        {
            pnlTable.Visible = true;
            pnlAssessmentModal.Visible = true;

            if (string.IsNullOrEmpty(hfCourseOfferID.Value))
                hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;

            BindAssessmentGrid();
            RenderAssessmentTable();
        }

        protected void btnCloseAssessmentModal_Click(object sender, EventArgs e)
        {
            pnlAssessmentModal.Visible = false;
            RenderAssessmentTable();
        }

        protected void btnAddAssessment_Click(object sender, EventArgs e)
        {
            pnlTable.Visible = true;
            pnlAssessmentModal.Visible = true;

            if (string.IsNullOrEmpty(hfCourseOfferID.Value))
                hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;

            string assessmentName = txtAssessmentName.Text.Trim();

            if (assessmentName == "")
            {
                ShowError("Enter assessment name.");
                BindAssessmentGrid();
                RenderAssessmentTable();
                return;
            }

            decimal maxMarks;
            if (!decimal.TryParse(txtMaxMarks.Text, out maxMarks) || maxMarks <= 0)
            {
                ShowError("Enter valid max marks.");
                BindAssessmentGrid();
                RenderAssessmentTable();
                return;
            }

            decimal weightage;
            if (!decimal.TryParse(txtWeightage.Text, out weightage) || weightage <= 0)
            {
                ShowError("Enter valid weightage.");
                BindAssessmentGrid();
                RenderAssessmentTable();
                return;
            }

            if (IsFinalExamName(assessmentName) && FinalExamExists(hfCourseOfferID.Value))
            {
                ShowError("Only one Final Exam is allowed.");
                BindAssessmentGrid();
                RenderAssessmentTable();
                return;
            }

            if (GetTotalWeightage(hfCourseOfferID.Value) + weightage > 100)
            {
                ShowError("Total assessment weightage cannot exceed 100%.");
                BindAssessmentGrid();
                RenderAssessmentTable();
                return;
            }

            string query = @"
                INSERT INTO Assessment
                (AssessmentName, MaxMarks, Weightage, CourseOfferID)
                VALUES
                (@Name, @MaxMarks, @Weightage, @COID)";

            SqlParameter[] p = {
                new SqlParameter("@Name", assessmentName),
                new SqlParameter("@MaxMarks", maxMarks),
                new SqlParameter("@Weightage", weightage),
                new SqlParameter("@COID", hfCourseOfferID.Value)
            };

            DBHelper.ExecuteNonQuery(query, p);

            txtAssessmentName.Text = "";
            txtMaxMarks.Text = "";
            txtWeightage.Text = "";

            ShowSuccess("Assessment column added.");
            BindAssessmentGrid();
            RenderAssessmentTable();
        }

        protected void btnSaveScores_Click(object sender, EventArgs e)
        {
            pnlTable.Visible = true;

            string courseOfferID = hfCourseOfferID.Value;
            DataTable students = GetStudents(courseOfferID);
            DataTable assessments = GetAssessments(courseOfferID);

            foreach (DataRow student in students.Rows)
            {
                int studentID = Convert.ToInt32(student["StudentID"]);

                foreach (DataRow assessment in assessments.Rows)
                {
                    int assessmentID = Convert.ToInt32(assessment["AssessmentID"]);
                    decimal maxMarks = Convert.ToDecimal(assessment["MaxMarks"]);

                    string fieldName = "mark_" + assessmentID + "_" + studentID;

                    decimal obtainedMark = 0;
                    decimal.TryParse(Request.Form[fieldName], out obtainedMark);

                    if (obtainedMark < 0)
                        obtainedMark = 0;

                    if (obtainedMark > maxMarks)
                        obtainedMark = maxMarks;

                    SaveStudentMark(assessmentID, studentID, obtainedMark);
                }
            }

            ShowSuccess("Assessment marks saved.");
            RenderAssessmentTable();
        }

        protected void gvAssessments_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvAssessments.EditIndex = e.NewEditIndex;
            pnlAssessmentModal.Visible = true;
            BindAssessmentGrid();
        }

        protected void gvAssessments_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvAssessments.EditIndex = -1;
            pnlAssessmentModal.Visible = true;
            BindAssessmentGrid();
        }

        protected void gvAssessments_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int assessmentID = Convert.ToInt32(gvAssessments.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvAssessments.Rows[e.RowIndex];

            string assessmentName = ((TextBox)row.Cells[0].Controls[0]).Text.Trim();

            decimal maxMarks;
            decimal weightage;

            decimal.TryParse(((TextBox)row.Cells[1].Controls[0]).Text, out maxMarks);
            decimal.TryParse(((TextBox)row.Cells[2].Controls[0]).Text, out weightage);

            if (assessmentName == "" || maxMarks <= 0 || weightage <= 0)
            {
                ShowError("Enter valid assessment details.");
                pnlAssessmentModal.Visible = true;
                BindAssessmentGrid();
                return;
            }

            if (IsFinalExamName(assessmentName) && FinalExamExistsExceptCurrent(hfCourseOfferID.Value, assessmentID))
            {
                ShowError("Only one Final Exam is allowed.");
                pnlAssessmentModal.Visible = true;
                BindAssessmentGrid();
                return;
            }

            if (GetTotalWeightageExceptCurrent(hfCourseOfferID.Value, assessmentID) + weightage > 100)
            {
                ShowError("Total assessment weightage cannot exceed 100%.");
                pnlAssessmentModal.Visible = true;
                BindAssessmentGrid();
                return;
            }

            string query = @"
                UPDATE Assessment
                SET AssessmentName = @Name,
                    MaxMarks = @MaxMarks,
                    Weightage = @Weightage
                WHERE AssessmentID = @AID";

            SqlParameter[] p = {
                new SqlParameter("@Name", assessmentName),
                new SqlParameter("@MaxMarks", maxMarks),
                new SqlParameter("@Weightage", weightage),
                new SqlParameter("@AID", assessmentID)
            };

            DBHelper.ExecuteNonQuery(query, p);

            gvAssessments.EditIndex = -1;
            pnlAssessmentModal.Visible = true;

            ShowSuccess("Assessment column updated.");
            BindAssessmentGrid();
            RenderAssessmentTable();
        }

        protected void gvAssessments_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int assessmentID = Convert.ToInt32(gvAssessments.DataKeys[e.RowIndex].Value);

            SqlParameter[] deleteScoreParams = {
                new SqlParameter("@AID", assessmentID)
            };

            DBHelper.ExecuteNonQuery(
                "DELETE FROM StudentAssessment WHERE AssessmentID = @AID",
                deleteScoreParams
            );

            SqlParameter[] deleteAssessmentParams = {
                new SqlParameter("@AID", assessmentID)
            };

            DBHelper.ExecuteNonQuery(
                "DELETE FROM Assessment WHERE AssessmentID = @AID",
                deleteAssessmentParams
            );

            pnlAssessmentModal.Visible = true;

            ShowSuccess("Assessment column deleted.");
            BindAssessmentGrid();
            RenderAssessmentTable();
        }

        private void BindAssessmentGrid()
        {
            gvAssessments.DataSource = GetAssessments(hfCourseOfferID.Value);
            gvAssessments.DataBind();
        }

        private void RenderAssessmentTable()
        {
            string courseOfferID = hfCourseOfferID.Value;

            DataTable students = GetStudents(courseOfferID);
            DataTable assessments = GetAssessments(courseOfferID);
            DataTable marks = GetMarks(courseOfferID);

            lblTotalWeightage.Text = GetTotalWeightage(courseOfferID).ToString("0.##") + "%";

            StringBuilder html = new StringBuilder();

            html.Append("<table>");
            html.Append("<thead><tr>");
            html.Append("<th>No</th>");
            html.Append("<th>Student ID</th>");
            html.Append("<th>Student Name</th>");

            foreach (DataRow assessment in assessments.Rows)
            {
                html.Append("<th>");
                html.Append(Server.HtmlEncode(assessment["AssessmentName"].ToString()));
                html.Append("<br/>Max: ");
                html.Append(Convert.ToDecimal(assessment["MaxMarks"]).ToString("0.##"));
                html.Append("<br/>");
                html.Append(Convert.ToDecimal(assessment["Weightage"]).ToString("0.##"));
                html.Append("%</th>");
            }

            html.Append("<th>Total %</th>");
            html.Append("</tr></thead>");
            html.Append("<tbody>");

            int no = 1;

            foreach (DataRow student in students.Rows)
            {
                int studentID = Convert.ToInt32(student["StudentID"]);
                decimal totalPercentage = 0;

                html.Append("<tr>");
                html.Append("<td>" + no + "</td>");
                html.Append("<td class='student-id'>" + studentID + "</td>");
                html.Append("<td>" + Server.HtmlEncode(student["StudentName"].ToString()) + "</td>");

                foreach (DataRow assessment in assessments.Rows)
                {
                    int assessmentID = Convert.ToInt32(assessment["AssessmentID"]);
                    decimal maxMarks = Convert.ToDecimal(assessment["MaxMarks"]);
                    decimal weightage = Convert.ToDecimal(assessment["Weightage"]);
                    decimal obtainedMark = FindMark(marks, assessmentID, studentID);

                    decimal percentage = 0;

                    if (maxMarks > 0)
                        percentage = obtainedMark / maxMarks * weightage;

                    totalPercentage += percentage;

                    html.Append("<td>");
                    html.Append("<input class='mark-input' type='number' step='0.01' min='0' max='");
                    html.Append(maxMarks.ToString("0.##", CultureInfo.InvariantCulture));
                    html.Append("' data-weight='");
                    html.Append(weightage.ToString("0.##", CultureInfo.InvariantCulture));
                    html.Append("' name='mark_");
                    html.Append(assessmentID);
                    html.Append("_");
                    html.Append(studentID);
                    html.Append("' value='");
                    html.Append(obtainedMark.ToString("0.##", CultureInfo.InvariantCulture));
                    html.Append("' oninput='updateTotals()' />");
                    html.Append("</td>");
                }

                html.Append("<td class='total-cell'>");
                html.Append(totalPercentage.ToString("0.##"));
                html.Append("%</td>");
                html.Append("</tr>");

                no++;
            }

            if (students.Rows.Count == 0)
            {
                int colspan = 4 + assessments.Rows.Count;
                html.Append("<tr><td colspan='" + colspan + "' style='text-align:center;color:#aaa;padding:30px;'>No enrolled students found.</td></tr>");
            }

            html.Append("</tbody></table>");

            litAssessmentTable.Text = html.ToString();
        }

        private void SaveStudentMark(int assessmentID, int studentID, decimal obtainedMark)
        {
            string checkQuery = @"
                SELECT COUNT(*)
                FROM StudentAssessment
                WHERE AssessmentID = @AID
                AND StudentID = @SID";

            SqlParameter[] checkParams = {
                new SqlParameter("@AID", assessmentID),
                new SqlParameter("@SID", studentID)
            };

            int exists = Convert.ToInt32(DBHelper.ExecuteScalar(checkQuery, checkParams));

            if (exists > 0)
            {
                string updateQuery = @"
                    UPDATE StudentAssessment
                    SET ObtainedMark = @Mark
                    WHERE AssessmentID = @AID
                    AND StudentID = @SID";

                SqlParameter[] updateParams = {
                    new SqlParameter("@Mark", obtainedMark),
                    new SqlParameter("@AID", assessmentID),
                    new SqlParameter("@SID", studentID)
                };

                DBHelper.ExecuteNonQuery(updateQuery, updateParams);
            }
            else
            {
                string insertQuery = @"
                    INSERT INTO StudentAssessment
                    (AssessmentID, StudentID, ObtainedMark)
                    VALUES
                    (@AID, @SID, @Mark)";

                SqlParameter[] insertParams = {
                    new SqlParameter("@AID", assessmentID),
                    new SqlParameter("@SID", studentID),
                    new SqlParameter("@Mark", obtainedMark)
                };

                DBHelper.ExecuteNonQuery(insertQuery, insertParams);
            }
        }

        private DataTable GetStudents(string courseOfferID)
        {
            string query = @"
                SELECT s.StudentID, s.StudentName
                FROM Student s
                INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                WHERE e.CourseOfferID = @COID
                AND e.EnrolStatus = 'Enrolled'
                ORDER BY s.StudentName";

            SqlParameter[] p = {
                new SqlParameter("@COID", courseOfferID)
            };

            return DBHelper.ExecuteQuery(query, p);
        }

        private DataTable GetAssessments(string courseOfferID)
        {
            string query = @"
                SELECT AssessmentID, AssessmentName, MaxMarks, Weightage
                FROM Assessment
                WHERE CourseOfferID = @COID
                ORDER BY AssessmentID";

            SqlParameter[] p = {
                new SqlParameter("@COID", courseOfferID)
            };

            return DBHelper.ExecuteQuery(query, p);
        }

        private DataTable GetMarks(string courseOfferID)
        {
            string query = @"
                SELECT a.AssessmentID, sa.StudentID, sa.ObtainedMark
                FROM Assessment a
                INNER JOIN StudentAssessment sa ON sa.AssessmentID = a.AssessmentID
                WHERE a.CourseOfferID = @COID";

            SqlParameter[] p = {
                new SqlParameter("@COID", courseOfferID)
            };

            return DBHelper.ExecuteQuery(query, p);
        }

        private decimal GetTotalWeightage(string courseOfferID)
        {
            string query = @"
                SELECT ISNULL(SUM(Weightage), 0)
                FROM Assessment
                WHERE CourseOfferID = @COID";

            SqlParameter[] p = {
                new SqlParameter("@COID", courseOfferID)
            };

            return Convert.ToDecimal(DBHelper.ExecuteScalar(query, p));
        }

        private decimal GetTotalWeightageExceptCurrent(string courseOfferID, int assessmentID)
        {
            string query = @"
                SELECT ISNULL(SUM(Weightage), 0)
                FROM Assessment
                WHERE CourseOfferID = @COID
                AND AssessmentID <> @AID";

            SqlParameter[] p = {
                new SqlParameter("@COID", courseOfferID),
                new SqlParameter("@AID", assessmentID)
            };

            return Convert.ToDecimal(DBHelper.ExecuteScalar(query, p));
        }

        private bool FinalExamExists(string courseOfferID)
        {
            string query = @"
                SELECT COUNT(*)
                FROM Assessment
                WHERE CourseOfferID = @COID
                AND LOWER(AssessmentName) = 'final exam'";

            SqlParameter[] p = {
                new SqlParameter("@COID", courseOfferID)
            };

            return Convert.ToInt32(DBHelper.ExecuteScalar(query, p)) > 0;
        }

        private bool FinalExamExistsExceptCurrent(string courseOfferID, int assessmentID)
        {
            string query = @"
                SELECT COUNT(*)
                FROM Assessment
                WHERE CourseOfferID = @COID
                AND AssessmentID <> @AID
                AND LOWER(AssessmentName) = 'final exam'";

            SqlParameter[] p = {
                new SqlParameter("@COID", courseOfferID),
                new SqlParameter("@AID", assessmentID)
            };

            return Convert.ToInt32(DBHelper.ExecuteScalar(query, p)) > 0;
        }

        private bool IsFinalExamName(string assessmentName)
        {
            return assessmentName.Trim().Equals("Final Exam", StringComparison.OrdinalIgnoreCase);
        }

        private decimal FindMark(DataTable marks, int assessmentID, int studentID)
        {
            foreach (DataRow row in marks.Rows)
            {
                if (Convert.ToInt32(row["AssessmentID"]) == assessmentID &&
                    Convert.ToInt32(row["StudentID"]) == studentID)
                {
                    return Convert.ToDecimal(row["ObtainedMark"]);
                }
            }

            return 0;
        }

        private void ShowSuccess(string message)
        {
            lblStatus.Text = message;
            lblStatus.CssClass = "success-msg";
        }

        private void ShowError(string message)
        {
            lblStatus.Text = message;
            lblStatus.CssClass = "error-msg";
        }
    }
}