using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class TrackStudentGrades : System.Web.UI.Page
    {
        // Pinned straight to your team's live local database instance
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

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

            // Refactored to map accurately to your 'StudentAssessment' structure 
            // and apply the three tier classification thresholds cleanly.
            string query = @"
                SELECT 
                    StudentID, 
                    StudentName, 
                    StudentEmail, 
                    ProgrammeCode, 
                    ISNULL(EstimatedCGPA, 4.00) AS EstimatedCGPA, 
                    CASE 
                        WHEN ISNULL(EstimatedCGPA, 4.00) >= 2.50 THEN 'Normal'
                        WHEN ISNULL(EstimatedCGPA, 4.00) >= 2.00 THEN 'In Risk'
                        ELSE 'Warning'
                    END AS StandingStatus
                FROM (
                    SELECT 
                        s.StudentID, 
                        s.StudentName, 
                        s.StudentEmail, 
                        s.ProgrammeCode,
                        (
                            -- Directly averaging the grade points achieved by the student 
                            -- from rows stored inside the StudentAssessment record tables
                            SELECT AVG(sa.GradePoint) 
                            FROM StudentAssessment sa
                            WHERE sa.StudentID = s.StudentID
                        ) AS EstimatedCGPA
                    FROM Student s
                ) AS StudentPerformanceSummary ";

            // Apply admin filter drops
            if (filterStatus != "All")
            {
                if (filterStatus == "Normal") query += " WHERE ISNULL(EstimatedCGPA, 4.00) >= 2.50 ";
                else if (filterStatus == "In Risk") query += " WHERE ISNULL(EstimatedCGPA, 4.00) >= 2.00 AND ISNULL(EstimatedCGPA, 4.00) < 2.50 ";
                else if (filterStatus == "Warning") query += " WHERE ISNULL(EstimatedCGPA, 4.00) < 2.00 ";
            }

            // Bind sorting expressions
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