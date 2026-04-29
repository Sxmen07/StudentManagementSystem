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
                Response.Redirect("Login.aspx");
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

                string query = "SELECT S.*, FORMAT(S.DateofBirth, 'yyyy-MM-dd') AS FormattedDateOfBirth, P.ProgrammeName FROM Student S INNER JOIN Programme P ON S.ProgrammeCode = P.ProgrammeCode WHERE StudentEmail=@Email";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    txtStudentID.Text = dr["StudentID"].ToString();
                    txtStudentName.Text = dr["StudentName"].ToString();
                    txtStudentEmail.Text = dr["StudentEmail"].ToString();
                    txtPersonalEmail.Text = dr["PersonalEmail"].ToString();
                    txtNationality.Text = dr["Nationality"].ToString();
                    txtSex.Text = dr["Sex"].ToString();
                    txtDateOfBirth.Text = dr["FormattedDateOfBirth"].ToString();
                    txtContactNumber.Text = dr["ContactNo"].ToString();
                    txtProgrammeCode.Text = dr["ProgrammeCode"].ToString();
                    txtProgrammeName.Text = dr["ProgrammeName"].ToString();
                    txtIntakeSemester.Text = dr["IntakeSemester"].ToString();
                    txtIntakeYear.Text = dr["IntakeYear"].ToString();
                    txtCurrentSemester.Text = dr["CurrentSemester"].ToString();
                }
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            //Enable editing of profile fields
            txtPersonalEmail.Enabled = true;
            txtNationality.Enabled = true;
            txtDateOfBirth.Enabled = true;
            txtContactNumber.Enabled = true;

            // Show Save and Reset button and hide Edit button
            btnSave.Visible = true;
            btnReset.Visible = true;
            btnEdit.Visible = false;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = "UPDATE Student SET PersonalEmail=@PersonalEmail, Nationality=@Nationality, DateOfBirth=@DateOfBirth, ContactNo=@ContactNo WHERE StudentEmail=@Email";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@PersonalEmail", txtPersonalEmail.Text.Trim());
                cmd.Parameters.AddWithValue("@Nationality", txtNationality.Text.Trim());
                cmd.Parameters.AddWithValue("@DateOfBirth", txtDateOfBirth.Text.Trim());
                cmd.Parameters.AddWithValue("@ContactNo", txtContactNumber.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                int rows = cmd.ExecuteNonQuery();

                if (rows > 0)
                {
                    lblMessage.Text = "Profile updated successfully.";
                    // Register the script to run when the page loads back in the browser
                    string script = "setTimeout(function() { document.getElementById('" + lblMessage.ClientID + "').style.display = 'none'; }, 3000);";
                    ClientScript.RegisterStartupScript(this.GetType(), "hideLabel", script, true);
                    // Disable editing after saving
                    txtPersonalEmail.Enabled = false;
                    txtNationality.Enabled = false;
                    txtDateOfBirth.Enabled = false;
                    txtContactNumber.Enabled = false;
                    // Hide Save and Reset button and show Edit button
                    btnSave.Visible = false;
                    btnReset.Visible = false;
                    btnEdit.Visible = true;
                }
                else
                {
                    lblMessage.Text = "Error updating profile. Please try again.";

                    // Register the script to run when the page loads back in the browser
                    string script = "setTimeout(function() { document.getElementById('" + lblMessage.ClientID + "').style.display = 'none'; }, 3000);";
                    ClientScript.RegisterStartupScript(this.GetType(), "hideLabel", script, true);

                }
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            LoadProfile();
            // Disable editing after resetting
            txtPersonalEmail.Enabled = true;
            txtNationality.Enabled = true;
            txtDateOfBirth.Enabled = false;
            txtDateOfBirth.Enabled = true;
            txtContactNumber.Enabled = true;
            // hide Edit button and show Save and Reset button
            btnEdit.Visible = false;
            btnSave.Visible = true;
            btnReset.Visible = true;
        }
    }
}