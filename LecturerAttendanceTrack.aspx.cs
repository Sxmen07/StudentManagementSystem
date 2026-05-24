using System;
using System.Data;
using System.Web.UI.WebControls;

namespace StudentManagementPersonal
{
    public partial class LecturerAttendanceTrack : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAttendance();
            }
        }

        private void LoadAttendance()
        {
            DataTable dt = new DataTable();

            dt.Columns.Add("StudentID");
            dt.Columns.Add("StudentName");
            dt.Columns.Add("Course");

            dt.Rows.Add("ST001", "Adrian Lim", "CS401");
            dt.Rows.Add("ST002", "Sarah Tan", "CS401");
            dt.Rows.Add("ST003", "Daniel Lee", "CS402");
            dt.Rows.Add("ST004", "Amanda Wong", "CS403");

            gvAttendance.DataSource = dt;
            gvAttendance.DataBind();

            lblTotalStudents.Text = dt.Rows.Count.ToString();
        }

        protected void btnSaveAttendance_Click(object sender, EventArgs e)
        {
            int present = 0;
            int absent = 0;

            foreach (GridViewRow row in gvAttendance.Rows)
            {
                DropDownList ddl =
                    (DropDownList)row.FindControl("ddlStatus");

                string status = ddl.SelectedValue;

                if (status == "Present")
                    present++;

                if (status == "Absent")
                    absent++;
            }

            lblPresentRate.Text =
                ((present * 100) / gvAttendance.Rows.Count) + "%";

            lblAbsent.Text = absent.ToString();

            Response.Write("<script>alert('Attendance Saved Successfully!')</script>");
        }
    }
}