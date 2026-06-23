using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class TrackStudentGrades : System.Web.UI.Page
    {
        // Pinned straight to your team's live local database instance
        private string connString = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                BindStudentGradesGrid();
            }
        }

        // =========================================================================
        // COMPUTE PERFORMANCE METRICS DIRECTLY FROM STUDENT ASSESSMENT
        // =========================================================================
        private void BindStudentGradesGrid()
        {
            string filterStatus = ddlFilterStatus.SelectedValue;
            string sortOrder = ddlSortExpression.SelectedValue;

            string query = @"
        WITH CourseGradePoints AS (
            SELECT 
                s.StudentID,
                s.StudentName,
                s.StudentEmail,
                s.ProgrammeCode,
                co.CourseOfferID,
                c.CreditHours,
                -- Weighted percentage for the course
                SUM( (sa.ObtainedMark * 1.0 / a.MaxMarks) * a.Weightage ) AS CoursePercentage
            FROM Student s
            INNER JOIN Enrolment e ON s.StudentID = e.StudentID
            INNER JOIN CourseOffer co ON e.CourseOfferID = co.CourseOfferID
            INNER JOIN Course c ON co.CourseCode = c.CourseCode
            INNER JOIN StudentAssessment sa ON s.StudentID = sa.StudentID
            INNER JOIN Assessment a ON sa.AssessmentID = a.AssessmentID
            WHERE a.CourseOfferID = co.CourseOfferID
            GROUP BY s.StudentID, s.StudentName, s.StudentEmail, s.ProgrammeCode, co.CourseOfferID, c.CreditHours
        ),
        StudentCGPA AS (
            SELECT 
                StudentID,
                StudentName,
                StudentEmail,
                ProgrammeCode,
                SUM(gs.GradePoint * CreditHours) AS TotalGradePoints,
                SUM(CreditHours) AS TotalCredits
            FROM CourseGradePoints cgp
            CROSS APPLY (
                SELECT TOP 1 GradePoint 
                FROM GradeScale 
                WHERE cgp.CoursePercentage BETWEEN MinMarks AND MaxMarks
            ) gs
            GROUP BY StudentID, StudentName, StudentEmail, ProgrammeCode
        )
        SELECT 
            StudentID,
            StudentName,
            StudentEmail,
            ProgrammeCode,
            CASE WHEN TotalCredits > 0 THEN TotalGradePoints / TotalCredits ELSE 0.00 END AS EstimatedCGPA,
            CASE 
                WHEN TotalCredits > 0 AND (TotalGradePoints / TotalCredits) >= 2.50 THEN 'Normal'
                WHEN TotalCredits > 0 AND (TotalGradePoints / TotalCredits) >= 2.00 THEN 'In Risk'
                ELSE 'Warning'
            END AS StandingStatus
        FROM StudentCGPA ";

            // Apply filters
            if (filterStatus != "All")
            {
                if (filterStatus == "Normal")
                    query += " WHERE (TotalGradePoints / NULLIF(TotalCredits, 0)) >= 2.50 ";
                else if (filterStatus == "In Risk")
                    query += " WHERE (TotalGradePoints / NULLIF(TotalCredits, 0)) >= 2.00 AND (TotalGradePoints / NULLIF(TotalCredits, 0)) < 2.50 ";
                else if (filterStatus == "Warning")
                    query += " WHERE (TotalGradePoints / NULLIF(TotalCredits, 0)) < 2.00 ";
            }

            query += " ORDER BY " + sortOrder;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvStudentGrades.DataSource = dt;
                            gvStudentGrades.DataBind();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error calculating student performance metrics: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        // =========================================================================
        // BADGE GENERATOR ROW BIND (Injects Green, Yellow, Red Tailwind Classes)
        // =========================================================================
        protected void gvStudentGrades_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Label lblBadge = (Label)e.Row.FindControl("lblStandingBadge");
                if (lblBadge != null)
                {
                    string standing = lblBadge.Text;

                    if (standing == "Normal")
                    {
                        lblBadge.CssClass += " bg-emerald-50 text-emerald-700 border border-emerald-200";
                    }
                    else if (standing == "In Risk")
                    {
                        lblBadge.CssClass += " bg-amber-50 text-amber-700 border border-amber-200";
                    }
                    else if (standing == "Warning")
                    {
                        lblBadge.CssClass += " bg-red-50 text-red-700 border border-red-200";
                    }
                }
            }
        }

        protected void ddlFilterStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvStudentGrades.PageIndex = 0;
            BindStudentGradesGrid();
        }

        protected void ddlSortExpression_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindStudentGradesGrid();
        }

        protected void gvStudentGrades_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvStudentGrades.PageIndex = e.NewPageIndex;
            BindStudentGradesGrid();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            lblStatus.ForeColor = isSuccess ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed;
            lblStatus.Visible = true;
        }
    }
}