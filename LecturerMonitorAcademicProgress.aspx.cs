using System;
using System.Data;

namespace StudentManagementPersonal
{
    public partial class LecturerMonitorAcademicProgress : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardCards();
                LoadStudentProgress();
            }
        }

        private void LoadDashboardCards()
        {
            lblTotalStudents.Text = "42";
            lblAverageAttendance.Text = "88%";
            lblAverageGrade.Text = "B+";
            lblRiskStudents.Text = "5";
        }

        private void LoadStudentProgress()
        {
            DataTable dt = new DataTable();

            dt.Columns.Add("StudentID");
            dt.Columns.Add("StudentName");
            dt.Columns.Add("Attendance");
            dt.Columns.Add("CurrentGrade");
            dt.Columns.Add("Status");

            dt.Rows.Add("ST001", "Adrian Aris", "92", "A", "Good");
            dt.Rows.Add("ST002", "Beatrice Jensen", "68", "D", "At Risk");
            dt.Rows.Add("ST003", "Caleb Montgomery", "75", "C", "At Risk");
            dt.Rows.Add("ST004", "Diana Rodriguez", "95", "A+", "Good");
            dt.Rows.Add("ST005", "Ethan Lim", "89", "B+", "Good");

            gvProgress.DataSource = dt;
            gvProgress.DataBind();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadStudentProgress();

            Response.Write("<script>alert('Filter Applied')</script>");
        }
    }
}