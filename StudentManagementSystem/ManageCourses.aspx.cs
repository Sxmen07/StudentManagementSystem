using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageCourses : System.Web.UI.Page
    {
        // Keeps the local server instance completely synchronized across the system files
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=SE_Assignment;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                PopulateProgrammeDropdowns();
                BindCoursesGrid(); // Default state binds all data
            }
        }

        private void RefreshAllData()
        {
            PopulateProgrammeDropdowns();
            BindCoursesGrid();
        }

        private void BindCoursesGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT c.CourseID, c.CourseCode, c.CourseName, c.CreditHours, p.ProgrammeName FROM Courses c " +
                               "INNER JOIN Programmes p ON c.ProgrammeID = p.ProgrammeID ";

                // If filter dropdown selection is active, add the programmatic conditional parameter mapping
                if (!string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue))
                {
                    query += "WHERE c.ProgrammeID = @FilterProgID ";
                }

                query += "ORDER BY c.CourseCode ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@FilterProgID", ddlFilterProgramme.SelectedValue);
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvCourses.DataSource = dt;
                        gvCourses.DataBind();
                    }
                }
            }
        }

        private void PopulateProgrammeDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT ProgrammeID, ProgrammeName FROM Programmes ORDER BY ProgrammeName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        // Sync Form Input Dropdown
                        ddlProgrammes.Items.Clear();
                        ddlProgrammes.Items.Add(new ListItem("-- Choose Associated Program --", ""));

                        // Sync Filter Nav Dropdown
                        string currentSelectedFilter = ddlFilterProgramme.SelectedValue;
                        ddlFilterProgramme.Items.Clear();
                        ddlFilterProgramme.Items.Add(new ListItem("All Programmes", ""));

                        while (dr.Read())
                        {
                            string id = dr["ProgrammeID"].ToString();
                            string name = dr["ProgrammeName"].ToString();

                            ddlProgrammes.Items.Add(new ListItem(name, id));
                            ddlFilterProgramme.Items.Add(new ListItem(name, id));
                        }

                        // Maintain previous view filter pointer selection state safely
                        if (ddlFilterProgramme.Items.FindByValue(currentSelectedFilter) != null)
                        {
                            ddlFilterProgramme.SelectedValue = currentSelectedFilter;
                        }
                    }
                }
            }
        }

        protected void ddlFilterProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindCoursesGrid();
        }

        protected void btnSaveCourse_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtCourseCode.Text) || string.IsNullOrWhiteSpace(txtCourseName.Text) || string.IsNullOrEmpty(ddlProgrammes.SelectedValue)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = string.IsNullOrEmpty(hfCourseID.Value)
                    ? "INSERT INTO Courses (CourseCode, CourseName, CreditHours, ProgrammeID) VALUES (@CourseCode, @CourseName, @CreditHours, @ProgrammeID)"
                    : "UPDATE Courses SET CourseCode = @CourseCode, CourseName = @CourseName, CreditHours = @CreditHours, ProgrammeID = @ProgrammeID WHERE CourseID = @CourseID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseCode", txtCourseCode.Text.Trim().ToUpper());
                    cmd.Parameters.AddWithValue("@CourseName", txtCourseName.Text.Trim());
                    cmd.Parameters.AddWithValue("@CreditHours", Convert.ToInt32(txtCreditHours.Text.Trim()));
                    cmd.Parameters.AddWithValue("@ProgrammeID", ddlProgrammes.SelectedValue);
                    if (!string.IsNullOrEmpty(hfCourseID.Value))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", hfCourseID.Value);
                    }

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            ClearCourseForm();
            BindCoursesGrid();
        }

        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;

            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditCourse")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT CourseID, CourseCode, CourseName, CreditHours, ProgrammeID FROM Courses WHERE CourseID = @CourseID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", id);
                        conn.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                hfCourseID.Value = dr["CourseID"].ToString();
                                txtCourseCode.Text = dr["CourseCode"].ToString();
                                txtCourseName.Text = dr["CourseName"].ToString();
                                txtCreditHours.Text = dr["CreditHours"].ToString();
                                ddlProgrammes.SelectedValue = dr["ProgrammeID"].ToString();
                                btnSaveCourse.Text = "Update Course";
                                btnCancelCourse.Visible = true;
                            }
                        }
                    }
                }
            }
            else if (e.CommandName == "DeleteCourse")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM Courses WHERE CourseID = @CourseID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", id);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                ClearCourseForm();
                BindCoursesGrid();
            }
        }

        protected void btnCancelCourse_Click(object sender, EventArgs e)
        {
            ClearCourseForm();
        }

        private void ClearCourseForm()
        {
            hfCourseID.Value = string.Empty;
            txtCourseCode.Text = string.Empty;
            txtCourseName.Text = string.Empty;
            txtCreditHours.Text = "3";
            ddlProgrammes.SelectedIndex = 0;
            btnSaveCourse.Text = "Register Course";
            btnCancelCourse.Visible = false;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}