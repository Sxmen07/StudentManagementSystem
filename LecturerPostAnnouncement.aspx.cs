using System;

namespace StudentManagementSystemPersonal
{
    public partial class LecturerPostAnnouncement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void ddlSendOption_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlSendOption.SelectedValue == "Single Student")
            {
                pnlStudentSelect.Visible = true;
            }
            else
            {
                pnlStudentSelect.Visible = false;
            }
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text;
            string course = ddlCourse.SelectedValue;
            string message = txtMessage.Text;
            string type = ddlType.SelectedValue;

            string sendOption = ddlSendOption.SelectedValue;

            if (sendOption == "Single Student")
            {
                string student = ddlStudents.SelectedValue;

                Response.Write("<script>alert('Announcement sent to selected student!')</script>");
            }
            else
            {
                Response.Write("<script>alert('Announcement sent to all students!')</script>");
            }
        }
    }
}