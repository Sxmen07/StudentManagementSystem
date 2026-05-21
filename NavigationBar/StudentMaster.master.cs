using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentManagementSystem
{
    public partial class StudentMaster : MasterPage
    {
        string cs = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null)
            {
                Response.Redirect("/Login.aspx");
            }

            if (!IsPostBack)
            {
                LoadStudentInfo();
            }
        }

        void LoadStudentInfo()
        {
            string email = Session["UserEmail"].ToString();

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = "SELECT StudentName, StudentID FROM Student WHERE StudentEmail = @Email";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Email", email);
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    lblStudentName.Text = dr["StudentName"].ToString();
                    lblStudentID.Text = dr["StudentID"].ToString();
                }
            }
        }
    }
}
