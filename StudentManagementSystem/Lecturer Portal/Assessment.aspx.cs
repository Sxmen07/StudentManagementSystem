using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class Assessment : Page
    {
        // Default execution point when page renders
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
            }
            else
            {
                // Panel.Visible isn't persisted across postbacks automatically, so re-derive it here
                // from the hidden field (already restored from posted form data by this point).
                // Individual handlers below also flip it true the moment they first populate hfCourseOfferID.
                pnlExportOptions.Visible = !string.IsNullOrEmpty(hfCourseOfferID.Value);
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
                // Fallback softly to text block initials placeholder if image read fails
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
                // Fallback softly to text block initials placeholder if image read fails
            }

            imgSidebar.Visible = false;
            litSideInitials.Visible = true;
        }

        // Retrieves qualification list structures available for assignment evaluations
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

        // Stacks downstream updates loading matching course instances for a chosen programme
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
            hfCourseOfferID.Value = ""; // Invalidate any previously loaded course - it no longer matches the selection
            pnlTable.Visible = false;
            pnlAssessmentModal.Visible = false;
            pnlExportOptions.Visible = false;
            lblStatus.Text = ""; // Clear out stale warning messages
        }

        // Fires when "Load Grid" command triggers from UI actions
        protected void btnLoad_Click(object sender, EventArgs e)
        {
            // Robust validation checking BOTH dropdown constraints simultaneously
            if (string.IsNullOrEmpty(ddlProgramme.SelectedValue) ||
                string.IsNullOrEmpty(ddlCourseOffer.SelectedValue) ||
                ddlCourseOffer.SelectedValue == "0")
            {
                ShowError("Please select both a programme and a course.");
                pnlTable.Visible = false;
                pnlAssessmentModal.Visible = false;
                pnlExportOptions.Visible = false;
                return;
            }

            hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;
            pnlTable.Visible = true;
            pnlAssessmentModal.Visible = false;
            pnlExportOptions.Visible = true;
            lblExportStatus.Text = "";

            RenderAssessmentTable(); // Calls dynamic construction loops
        }

        // Unveils settings overlay panel to add, edit, or clear columns
        protected void btnOpenAssessmentModal_Click(object sender, EventArgs e)
        {
            // Preventive validation before attempting to render setup panels
            if (string.IsNullOrEmpty(ddlProgramme.SelectedValue) ||
                string.IsNullOrEmpty(ddlCourseOffer.SelectedValue) ||
                ddlCourseOffer.SelectedValue == "0")
            {
                ShowError("Please select both a programme and a course.");
                pnlTable.Visible = false;
                pnlAssessmentModal.Visible = false;
                pnlExportOptions.Visible = false;
                return;
            }

            pnlTable.Visible = true;
            pnlAssessmentModal.Visible = true;
            pnlExportOptions.Visible = true;

            if (string.IsNullOrEmpty(hfCourseOfferID.Value))
                hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;

            BindAssessmentGrid();    // Populate the standard inner configuration data sheet
            RenderAssessmentTable();  // Redraw matrix layout fields
        }

        // Restores primary spreadsheet interfaces, dismissing configuration screens
        protected void btnCloseAssessmentModal_Click(object sender, EventArgs e)
        {
            pnlAssessmentModal.Visible = false;
            RenderAssessmentTable();
        }

        // Creates a new column scheme ruleset (e.g., Assignment 1, Quiz)
        protected void btnAddAssessment_Click(object sender, EventArgs e)
        {
            pnlTable.Visible = true;
            pnlAssessmentModal.Visible = true;

            if (string.IsNullOrEmpty(hfCourseOfferID.Value))
                hfCourseOfferID.Value = ddlCourseOffer.SelectedValue;

            string assessmentName = txtAssessmentName.Text.Trim();

            // Validation Rule 1: Text box blank check
            if (assessmentName == "")
            {
                ShowError("Enter assessment name.");
                BindAssessmentGrid(); RenderAssessmentTable(); return;
            }

            // Validation Rule 2: Max possible score structure formatting check
            decimal maxMarks;
            if (!decimal.TryParse(txtMaxMarks.Text, out maxMarks) || maxMarks <= 0)
            {
                ShowError("Enter valid max marks.");
                BindAssessmentGrid(); RenderAssessmentTable(); return;
            }

            // Validation Rule 3: Evaluation weight formatting check
            decimal weightage;
            if (!decimal.TryParse(txtWeightage.Text, out weightage) || weightage <= 0)
            {
                ShowError("Enter valid weightage.");
                BindAssessmentGrid(); RenderAssessmentTable(); return;
            }

            // Validation Rule 4: Prevent multiple Final Exam column creation definitions
            if (IsFinalExamName(assessmentName) && FinalExamExists(hfCourseOfferID.Value))
            {
                ShowError("Only one Final Exam is allowed.");
                BindAssessmentGrid(); RenderAssessmentTable(); return;
            }

            // Validation Rule 5: Block combined weight allocations exceeding 100% caps
            if (GetTotalWeightage(hfCourseOfferID.Value) + weightage > 100)
            {
                ShowError("Total assessment weightage cannot exceed 100%.");
                BindAssessmentGrid(); RenderAssessmentTable(); return;
            }

            // Insert new structural tracking entity record row to database schema
            string query = @"
                INSERT INTO Assessment (AssessmentName, MaxMarks, Weightage, CourseOfferID)
                VALUES (@Name, @MaxMarks, @Weightage, @COID)";

            SqlParameter[] p = {
                new SqlParameter("@Name", assessmentName),
                new SqlParameter("@MaxMarks", maxMarks),
                new SqlParameter("@Weightage", weightage),
                new SqlParameter("@COID", hfCourseOfferID.Value)
            };

            DBHelper.ExecuteNonQuery(query, p);

            // Clean data entries for subsequent column allocations
            txtAssessmentName.Text = ""; txtMaxMarks.Text = ""; txtWeightage.Text = "";

            ShowSuccess("Assessment column added.");
            BindAssessmentGrid();
            RenderAssessmentTable();
        }

        // Reads the dynamic numeric text inputs across grid panels and posts entries to SQL
        protected void btnSaveScores_Click(object sender, EventArgs e)
        {
            pnlTable.Visible = true;

            string courseOfferID = hfCourseOfferID.Value;
            DataTable students = GetStudents(courseOfferID);
            DataTable assessments = GetAssessments(courseOfferID);

            // Row processing tracking matrix logic loops
            foreach (DataRow student in students.Rows)
            {
                int studentID = Convert.ToInt32(student["StudentID"]);

                foreach (DataRow assessment in assessments.Rows)
                {
                    int assessmentID = Convert.ToInt32(assessment["AssessmentID"]);
                    decimal maxMarks = Convert.ToDecimal(assessment["MaxMarks"]);

                    // Trace generated input name tokens matching layout fields (mark_ID_ID)
                    string fieldName = "mark_" + assessmentID + "_" + studentID;

                    decimal obtainedMark = 0;
                    decimal.TryParse(Request.Form[fieldName], out obtainedMark);

                    // Ensure grades stay within valid ranges (0 to maximum defined points)
                    if (obtainedMark < 0) obtainedMark = 0;
                    if (obtainedMark > maxMarks) obtainedMark = maxMarks;

                    SaveStudentMark(assessmentID, studentID, obtainedMark); // Upsert scores
                }
            }

            ShowSuccess("Assessment marks saved.");
            RenderAssessmentTable();
        }

        // Puts a column row into an inline editable layout field state
        protected void gvAssessments_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvAssessments.EditIndex = e.NewEditIndex;
            pnlAssessmentModal.Visible = true;
            BindAssessmentGrid();
        }

        // Safely cancels cell edit focus interactions without modifying data sets
        protected void gvAssessments_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvAssessments.EditIndex = -1;
            pnlAssessmentModal.Visible = true;
            BindAssessmentGrid();
        }

        // Saves modified target row configurations, validation thresholds, and properties
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
                pnlAssessmentModal.Visible = true; BindAssessmentGrid(); return;
            }

            if (IsFinalExamName(assessmentName) && FinalExamExistsExceptCurrent(hfCourseOfferID.Value, assessmentID))
            {
                ShowError("Only one Final Exam is allowed.");
                pnlAssessmentModal.Visible = true; BindAssessmentGrid(); return;
            }

            if (GetTotalWeightageExceptCurrent(hfCourseOfferID.Value, assessmentID) + weightage > 100)
            {
                ShowError("Total assessment weightage cannot exceed 100%.");
                pnlAssessmentModal.Visible = true; BindAssessmentGrid(); return;
            }

            string query = @"
                UPDATE Assessment SET AssessmentName = @Name, MaxMarks = @MaxMarks, Weightage = @Weightage 
                WHERE AssessmentID = @AID";

            SqlParameter[] p = {
                new SqlParameter("@Name", assessmentName),
                new SqlParameter("@MaxMarks", maxMarks),
                new SqlParameter("@Weightage", weightage),
                new SqlParameter("@AID", assessmentID)
            };

            DBHelper.ExecuteNonQuery(query, p);
            gvAssessments.EditIndex = -1; // Clear edit cell flags
            pnlAssessmentModal.Visible = true;
            ShowSuccess("Assessment column updated.");
            BindAssessmentGrid();
            RenderAssessmentTable();
        }

        // Drops columns from tracking sheets, erasing dependencies from storage records
        protected void gvAssessments_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int assessmentID = Convert.ToInt32(gvAssessments.DataKeys[e.RowIndex].Value);

            // Delete dependent student grades first to respect foreign key constraint actions
            SqlParameter[] deleteScoreParams = { new SqlParameter("@AID", assessmentID) };
            DBHelper.ExecuteNonQuery("DELETE FROM StudentAssessment WHERE AssessmentID = @AID", deleteScoreParams);

            // Delete the assessment definition column record
            SqlParameter[] deleteAssessmentParams = { new SqlParameter("@AID", assessmentID) };
            DBHelper.ExecuteNonQuery("DELETE FROM Assessment WHERE AssessmentID = @AID", deleteAssessmentParams);

            pnlAssessmentModal.Visible = true;
            ShowSuccess("Assessment column deleted.");
            BindAssessmentGrid();
            RenderAssessmentTable();
        }

        // Pulls structural schema items and populates settings grids
        private void BindAssessmentGrid()
        {
            gvAssessments.DataSource = GetAssessments(hfCourseOfferID.Value);
            gvAssessments.DataBind();
        }

        // Dynamically renders the core score-entry table structure with text box controls and interactive overall total column
        private void RenderAssessmentTable()
        {
            string courseOfferID = hfCourseOfferID.Value;
            DataTable students = GetStudents(courseOfferID);
            DataTable assessments = GetAssessments(courseOfferID);
            DataTable marks = GetMarks(courseOfferID);

            // Set aggregate total percentage allocations label indicator on panel summaries
            lblTotalWeightage.Text = GetTotalWeightage(courseOfferID).ToString("0.##") + "%";

            StringBuilder html = new StringBuilder();
            html.Append("<table>");
            html.Append("<thead><tr><th>No</th><th>Student ID</th><th>Student Name</th>");

            // Render a header cell for each assessment column
            foreach (DataRow ass in assessments.Rows)
            {
                html.Append($"<th>{Server.HtmlEncode(ass["AssessmentName"].ToString())}<br/><small>Max: {ass["MaxMarks"]} ({ass["Weightage"]}%)</small></th>");
            }

            // Append the overall calculated dynamic cumulative summary tracking column header
            html.Append("<th>Total (%)</th>");
            html.Append("</tr></thead><tbody>");

            // Render row item panels listing students and their respective grade inputs
            int index = 1;
            foreach (DataRow student in students.Rows)
            {
                int studentID = Convert.ToInt32(student["StudentID"]);
                html.Append("<tr>");
                html.Append($"<td>{index}</td>");
                html.Append($"<td>{studentID}</td>");
                html.Append($"<td>{Server.HtmlEncode(student["StudentName"].ToString())}</td>");

                decimal totalWeightPercentage = 0;

                // Render matching grade boxes containing accurate data entries
                foreach (DataRow ass in assessments.Rows)
                {
                    int assessmentID = Convert.ToInt32(ass["AssessmentID"]);
                    decimal maxMarks = Convert.ToDecimal(ass["MaxMarks"]);
                    decimal weightage = Convert.ToDecimal(ass["Weightage"]);
                    decimal markValue = FindMark(marks, assessmentID, studentID);
                    string inputFieldName = $"mark_{assessmentID}_{studentID}";

                    // Calculate active cumulative row totals matching export engine definitions
                    if (maxMarks > 0)
                    {
                        totalWeightPercentage += (markValue / maxMarks) * weightage;
                    }

                    html.Append($"<td><input type='number' step='0.01' name='{inputFieldName}' value='{markValue.ToString("0.##")}' class='score-input'/></td>");
                }

                // Render the calculated on-screen row total percentage field
                html.Append($"<td style='font-weight:bold; color:#111; background-color:#fcfdfd;'>{totalWeightPercentage.ToString("0.00")}%</td>");
                html.Append("</tr>");
                index++;
            }

            // Render a fallback message row if no students are enrolled
            if (students.Rows.Count == 0)
            {
                int totalCols = assessments.Rows.Count + 4; // Adjusted to account for the new total percentage column
                html.Append($"<tr><td colspan='{totalCols}' style='text-align:center;color:#aaa;padding:20px;'>No enrolled students found.</td></tr>");
            }

            html.Append("</tbody></table>");
            litAssessmentTable.Text = html.ToString(); // Push generated code to the browser layout
        }

        // Helper: Fetches students enrolled in the class offering
        private DataTable GetStudents(string courseOfferID)
        {
            string query = @"SELECT s.StudentID, s.StudentName FROM Student s
                             INNER JOIN Enrolment e ON e.StudentID = s.StudentID
                             WHERE e.CourseOfferID = @COID AND e.EnrolStatus = 'Enrolled' ORDER BY s.StudentName";
            return DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@COID", courseOfferID) });
        }

        // Helper: Fetches all assessment columns set up for this course offering
        private DataTable GetAssessments(string courseOfferID)
        {
            string query = "SELECT * FROM Assessment WHERE CourseOfferID = @COID ORDER BY AssessmentID";
            return DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@COID", courseOfferID) });
        }

        // Helper: Fetches all recorded student scores for this course offering
        private DataTable GetMarks(string courseOfferID)
        {
            string query = @"SELECT sa.* FROM StudentAssessment sa
                             INNER JOIN Assessment a ON a.AssessmentID = sa.AssessmentID
                             WHERE a.CourseOfferID = @COID";
            return DBHelper.ExecuteQuery(query, new[] { new SqlParameter("@COID", courseOfferID) });
        }

        // Helper: Saves or updates a student's score using an upsert (MERGE) statement
        private void SaveStudentMark(int assessmentID, int studentID, decimal mark)
        {
            string query = @"
                MERGE StudentAssessment AS target
                USING (SELECT @AID AS AssessmentID, @SID AS StudentID) AS source
                ON (target.AssessmentID = source.AssessmentID AND target.StudentID = source.StudentID)
                WHEN MATCHED THEN
                    UPDATE SET ObtainedMark = @Mark
                WHEN NOT MATCHED THEN
                    INSERT (AssessmentID, StudentID, ObtainedMark)
                    VALUES (source.AssessmentID, source.StudentID, @Mark);";

            SqlParameter[] p = {
                new SqlParameter("@AID", assessmentID),
                new SqlParameter("@SID", studentID),
                new SqlParameter("@Mark", mark)
            };
            DBHelper.ExecuteNonQuery(query, p);
        }

        // Helper: Sums up the total weight percentages allocated to this course offering
        private decimal GetTotalWeightage(string courseOfferID)
        {
            string query = "SELECT ISNULL(SUM(Weightage), 0) FROM Assessment WHERE CourseOfferID = @COID";
            return Convert.ToDecimal(DBHelper.ExecuteScalar(query, new[] { new SqlParameter("@COID", courseOfferID) }));
        }

        // Helper: Sums up weight percentages excluding the current assessment being updated
        private decimal GetTotalWeightageExceptCurrent(string courseOfferID, int assessmentID)
        {
            string query = "SELECT ISNULL(SUM(Weightage), 0) FROM Assessment WHERE CourseOfferID = @COID AND AssessmentID <> @AID";
            SqlParameter[] p = { new SqlParameter("@COID", courseOfferID), new SqlParameter("@AID", assessmentID) };
            return Convert.ToDecimal(DBHelper.ExecuteScalar(query, p));
        }

        // Helper: Checks if a Final Exam column has already been created for this course offering
        private bool FinalExamExists(string courseOfferID)
        {
            string query = "SELECT COUNT(*) FROM Assessment WHERE CourseOfferID = @COID AND LOWER(AssessmentName) = 'final exam'";
            return Convert.ToInt32(DBHelper.ExecuteScalar(query, new[] { new SqlParameter("@COID", courseOfferID) })) > 0;
        }

        // Helper: Checks if another Final Exam exists, excluding the current assessment row
        private bool FinalExamExistsExceptCurrent(string courseOfferID, int assessmentID)
        {
            string query = "SELECT COUNT(*) FROM Assessment WHERE CourseOfferID = @COID AND AssessmentID <> @AID AND LOWER(AssessmentName) = 'final exam'";
            SqlParameter[] p = { new SqlParameter("@COID", courseOfferID), new SqlParameter("@AID", assessmentID) };
            return Convert.ToInt32(DBHelper.ExecuteScalar(query, p)) > 0;
        }

        // Helper: Checks if an assessment string matches the term "Final Exam" (ignores casing)
        private bool IsFinalExamName(string name)
        {
            return name.Trim().Equals("Final Exam", StringComparison.OrdinalIgnoreCase);
        }

        // Helper: Scans a data table to locate a saved score value matching specific IDs
        private decimal FindMark(DataTable marks, int assessmentID, int studentID)
        {
            foreach (DataRow row in marks.Rows)
            {
                if (Convert.ToInt32(row["AssessmentID"]) == assessmentID && Convert.ToInt32(row["StudentID"]) == studentID)
                    return Convert.ToDecimal(row["ObtainedMark"]);
            }
            return 0; // Return zero if no mark has been saved yet
        }

        protected void btnDownloadReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfCourseOfferID.Value))
            {
                lblExportStatus.Text = "Please load a course's student list before exporting a report.";
                return;
            }

            lblExportStatus.Text = "";

            string courseOfferID = hfCourseOfferID.Value;
            DataTable students = GetStudents(courseOfferID);
            DataTable assessments = GetAssessments(courseOfferID);
            DataTable marks = GetMarks(courseOfferID);

            // Layout definition with exactly 3 columns (Student Name, Assessment, Marks)
            DataTable reportTable = new DataTable();
            reportTable.Columns.Add("Student Name");
            reportTable.Columns.Add("Assessment");
            reportTable.Columns.Add("Marks");

            foreach (DataRow student in students.Rows)
            {
                int studentID = Convert.ToInt32(student["StudentID"]);
                string studentName = student["StudentName"].ToString();

                // 1. Calculate overall weighted metric summary beforehand
                decimal totalWeightPercentage = 0;
                foreach (DataRow ass in assessments.Rows)
                {
                    int assessmentID = Convert.ToInt32(ass["AssessmentID"]);
                    decimal maxMarks = Convert.ToDecimal(ass["MaxMarks"]);
                    decimal weightage = Convert.ToDecimal(ass["Weightage"]);
                    decimal markValue = FindMark(marks, assessmentID, studentID);

                    if (maxMarks > 0)
                        totalWeightPercentage += (markValue / maxMarks) * weightage;
                }
                string totalText = totalWeightPercentage.ToString("0.00") + "%";

                // Fallback handle if no active dynamic assignment structural items exist yet
                if (assessments.Rows.Count == 0)
                {
                    DataRow newRow = reportTable.NewRow();
                    newRow["Student Name"] = studentName;
                    newRow["Assessment"] = "-";
                    newRow["Marks"] = "-";
                    reportTable.Rows.Add(newRow);

                    // Place total row right underneath the fallback entry row
                    DataRow totalRow = reportTable.NewRow();
                    totalRow["Student Name"] = "";
                    totalRow["Assessment"] = "Total Assessment Percentage";
                    totalRow["Marks"] = totalText;
                    reportTable.Rows.Add(totalRow);
                    continue;
                }

                // 2. Append all granular individual record detail items
                foreach (DataRow ass in assessments.Rows)
                {
                    int assessmentID = Convert.ToInt32(ass["AssessmentID"]);
                    decimal maxMarks = Convert.ToDecimal(ass["MaxMarks"]);
                    decimal markValue = FindMark(marks, assessmentID, studentID);

                    DataRow newRow = reportTable.NewRow();
                    newRow["Student Name"] = studentName;
                    newRow["Assessment"] = ass["AssessmentName"];
                    newRow["Marks"] = $"{markValue.ToString("0.##")}/{maxMarks.ToString("0.##")}";
                    reportTable.Rows.Add(newRow);
                }

                // 3. Append the overall dynamic total metric summary row AT THE BOTTOM of the last assessment item
                DataRow summaryRow = reportTable.NewRow();
                summaryRow["Student Name"] = ""; // Left empty to seamlessly group with the student block above it
                summaryRow["Assessment"] = "Total Assessment Percentage";
                summaryRow["Marks"] = totalText;
                reportTable.Rows.Add(summaryRow);
            }

            string format = ddlExportType.SelectedValue;
            string filename = $"Assessment_Performance_Report_{courseOfferID}_{DateTime.Now:yyyyMMdd}";
            string title = "Assessment Performance Report";

            if (format == "csv")
                ReportExporter.ExportToCSV(reportTable, filename, title);
            else
                ReportExporter.ExportToOfficeHTML(reportTable, filename + "." + format, format, title);
        }

        // Formats confirmation messages on the tracking dashboard layout
        private void ShowSuccess(string msg) { lblStatus.Text = msg; lblStatus.CssClass = "success-msg"; }
        // Formats alert problem descriptions on the tracking dashboard layout
        private void ShowError(string msg) { lblStatus.Text = msg; lblStatus.CssClass = "error-msg"; }
    }
}