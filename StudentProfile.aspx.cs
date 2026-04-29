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

        
    }
}