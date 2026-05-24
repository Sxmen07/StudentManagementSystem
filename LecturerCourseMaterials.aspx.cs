using System;
using System.IO;
using System.Web.UI.WebControls;

namespace StudentManagementPersonal
{
    public partial class LecturerCourseMaterials : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text;
            string course = ddlCourse.SelectedValue;
            string desc = txtDescription.Text;
            string date = txtDate.Text;

            string fileName = "";

            if (fileUpload.HasFile)
            {
                fileName = Path.GetFileName(fileUpload.FileName);
                string path = Server.MapPath("~/Uploads/") + fileName;
                fileUpload.SaveAs(path);
            }

            Response.Write("<script>alert('Course material posted successfully!')</script>");
        }
    }
}