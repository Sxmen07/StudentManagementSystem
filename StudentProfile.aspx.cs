using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem.Student
{
    public partial class StudentProfile : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
            {
                Response.Redirect("/StudeLogin.aspx");
            }
            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        void LoadProfile()
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();

                string query = @"
                                SELECT S.*, Sem.Semester AS SemesterName, P.ProgrammeName 
                                FROM Student S
                                INNER JOIN Programme P ON S.ProgrammeCode = P.ProgrammeCode
                                INNER JOIN Semester Sem ON S.SemesterID = Sem.SemesterID
                                WHERE S.StudentEmail = @Email";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    txtStudentID.Text = dr["StudentID"].ToString();
                    txtStudentName.Text = dr["StudentName"].ToString();
                    txtStudentEmail.Text = dr["StudentEmail"].ToString();

                    string password = dr["Password"].ToString();
                    txtPassword.Text = password;            // will be masked (TextMode=Password)
                    hdnPassword.Value = password;           // store real value for editing

                    txtPersonalEmail.Text = dr["PersonalEmail"].ToString();
                    txtContactNumber.Text = dr["ContactNo"].ToString();
                    txtProgrammeCode.Text = dr["ProgrammeCode"].ToString();
                    txtProgrammeName.Text = dr["ProgrammeName"].ToString();
                    txtIntakeSemester.Text = dr["SemesterName"].ToString();
                    txtIntakeYear.Text = dr["IntakeYear"].ToString();
                }
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            // Enable editing
            txtPersonalEmail.Enabled = true;
            txtPassword.Enabled = true;
            txtPassword.TextMode = TextBoxMode.SingleLine;
            txtPassword.Text = hdnPassword.Value;   // restore the real password
            txtContactNumber.Enabled = true;

            btnSave.Visible = true;
            btnCancel.Visible = true;
            btnEdit.Visible = false;
            lblMessage.Text = "";
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = @"
                                UPDATE Student 
                                SET PersonalEmail=@PersonalEmail, 
                                    Password=@Password, 
                                    ContactNo=@ContactNo 
                                WHERE StudentEmail=@Email";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@PersonalEmail", txtPersonalEmail.Text.Trim());
                cmd.Parameters.AddWithValue("@Password", txtPassword.Text.Trim());
                cmd.Parameters.AddWithValue("@ContactNo", txtContactNumber.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                int rows = cmd.ExecuteNonQuery();

                if (rows > 0)
                {
                    lblMessage.Text = "Profile updated successfully.";
                    lblMessage.CssClass = "block mb-4 text-center p-2 rounded bg-green-100 text-green-700";

                    // Update hidden field with new password
                    hdnPassword.Value = txtPassword.Text.Trim();

                    // Auto-hide message after 3 seconds
                    string script = "setTimeout(function() { var msg = document.getElementById('" + lblMessage.ClientID + "'); if(msg) msg.style.display = 'none'; }, 3000);";
                    ClientScript.RegisterStartupScript(this.GetType(), "hideLabel", script, true);

                    // Disable editing after saving
                    txtPersonalEmail.Enabled = false;
                    txtPassword.Enabled = false;
                    txtContactNumber.Enabled = false;
                    // Hide Save and Cancel button and show Edit button
                    btnSave.Visible = false;
                    btnCancel.Visible = false;
                    btnEdit.Visible = true;
                }
                else
                {
                    lblMessage.Text = "Error updating profile. Please try again.";
                    lblMessage.CssClass = "block mb-4 text-center p-2 rounded bg-red-100 text-red-700";
                    // Register the script to run when the page loads back in the browser
                    string script = "setTimeout(function() { document.getElementById('" + lblMessage.ClientID + "').style.display = 'none'; }, 3000);";
                    ClientScript.RegisterStartupScript(this.GetType(), "hideLabel", script, true);

                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            LoadProfile();

            // Reset password TextMode to masked
            txtPassword.TextMode = TextBoxMode.Password;

            // Reset edit mode
            txtPersonalEmail.Enabled = false;
            txtPassword.Enabled = false;
            txtContactNumber.Enabled = false;

            btnEdit.Visible = true;
            btnSave.Visible = false;
            btnCancel.Visible = false;

            lblMessage.Text = "";
        }
    }
}
