using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LecturerPortal
{
    public partial class LectDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Strict login security check matching Attendance.aspx logic
            if (Session["LecturerID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadSidebarProfile();
                LoadDashboardMetrics();
                RenderPerformanceChart();
            }
        }

        private void LoadSidebarProfile()
        {
            // Bind text component details
            string lecturerName = Session["LecturerName"]?.ToString() ?? "Lecturer";
            lblSidebarName.Text = lecturerName;

            // Generate character initials fallback dynamically from session text
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

            // Database lookup query logic to fetch customized profile image pathway strings safely
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
                        litSideInitials.Visible = false; // Hide initials if image found
                        return;
                    }
                }
            }
            catch
            {
                // Graceful fallback to structural text initials if database fields are empty or fail
            }

            imgSidebar.Visible = false;
            litSideInitials.Visible = true;
        }

        private void LoadDashboardMetrics()
        {
            // Mock assignments for tracking displays safely
            lblAvgAttendance.Text = "84.5%";
            lblLowAttendanceCount.Text = "3";
            lblFailingCount.Text = "2";

            // Initialize control array bindings quietly to avoid back-end null object framework errors
            if (ddlCourseOffer != null)
            {
                ddlCourseOffer.Items.Clear();
                ddlCourseOffer.Items.Add(new ListItem("All Active Class Rosters", "0"));
            }
            if (ddlExportType != null)
            {
                ddlExportType.SelectedIndex = 0;
            }
        }

        private void RenderPerformanceChart()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<script>");
            sb.Append("var ctx = document.getElementById('dashboardChart').getContext('2d');");
            sb.Append("var myChart = new Chart(ctx, {");
            sb.Append("    type: 'bar',");
            sb.Append("    data: {");
            sb.Append("        labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'],");
            sb.Append("        datasets: [{");
            sb.Append("            label: 'Average Attendance Rate %',");
            sb.Append("            data: [92, 88, 85, 81, 84],");
            sb.Append("            backgroundColor: '#1d4ed8',");
            sb.Append("            borderRadius: 6");
            sb.Append("        }]");
            sb.Append("    },");
            sb.Append("    options: {");
            sb.Append("        responsive: true,");
            sb.Append("        scales: { y: { min: 0, max: 100 } }");
            sb.Append("    }");
            sb.Append("});");
            sb.Append("</script>");

            litChartScript.Text = sb.ToString();
        }
    }
}