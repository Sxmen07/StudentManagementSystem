using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageSchoolNPrograms : System.Web.UI.Page
    {
        // Change this line to your exact working local string setup (e.g., from localdb)
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=SE_Assignment;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                BindSchoolsGrid();
                PopulateSchoolDropdowns();
                BindProgrammesGrid(); // Default pulls all records
            }
        }

        private void RefreshAllData()
        {
            BindSchoolsGrid();
            PopulateSchoolDropdowns();
            BindProgrammesGrid();
        }

        // --- SCHOOL INFRASTRUCTURE FUNCTIONS ---
        private void BindSchoolsGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT SchoolID, SchoolName FROM Schools ORDER BY SchoolID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvSchools.DataSource = dt;
                        gvSchools.DataBind();
                    }
                }
            }
        }

        protected void btnSaveSchool_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSchoolName.Text)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = string.IsNullOrEmpty(hfSchoolID.Value)
                    ? "INSERT INTO Schools (SchoolName) VALUES (@SchoolName)"
                    : "UPDATE Schools SET SchoolName = @SchoolName WHERE SchoolID = @SchoolID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SchoolName", txtSchoolName.Text.Trim());
                    if (!string.IsNullOrEmpty(hfSchoolID.Value))
                    {
                        cmd.Parameters.AddWithValue("@SchoolID", hfSchoolID.Value);
                    }
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            ClearSchoolForm();
            RefreshAllData();
        }

        protected void gvSchools_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditSchool")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT SchoolID, SchoolName FROM Schools WHERE SchoolID = @SchoolID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@SchoolID", id);
                        conn.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                hfSchoolID.Value = dr["SchoolID"].ToString();
                                txtSchoolName.Text = dr["SchoolName"].ToString();
                                btnSaveSchool.Text = "Update School";
                                btnCancelSchool.Visible = true;
                            }
                        }
                    }
                }
            }
            else if (e.CommandName == "DeleteSchool")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // Cascading constraints handle related structural dependencies automatically 
                    string query = "DELETE FROM Schools WHERE SchoolID = @SchoolID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@SchoolID", id);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                ClearSchoolForm();
                RefreshAllData();
            }
        }

        protected void btnCancelSchool_Click(object sender, EventArgs e)
        {
            ClearSchoolForm();
        }

        private void ClearSchoolForm()
        {
            hfSchoolID.Value = string.Empty;
            txtSchoolName.Text = string.Empty;
            btnSaveSchool.Text = "Create School";
            btnCancelSchool.Visible = false;
        }

        // --- PROGRAMMES MANAGEMENT WITH DYNAMIC FILTER ROUTINES ---
        private void BindProgrammesGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Core Base Query String Joining Tables
                string query = "SELECT p.ProgrammeID, p.ProgrammeName, s.SchoolName FROM Programmes p " +
                               "INNER JOIN Schools s ON p.SchoolID = s.SchoolID ";

                // If a specific school filter is chosen in the navigation controller, inject a WHERE filter clause
                if (!string.IsNullOrEmpty(ddlFilterSchool.SelectedValue))
                {
                    query += "WHERE p.SchoolID = @FilterSchoolID ";
                }

                query += "ORDER BY p.ProgrammeID DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrEmpty(ddlFilterSchool.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@FilterSchoolID", ddlFilterSchool.SelectedValue);
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvProgrammes.DataSource = dt;
                        gvProgrammes.DataBind();
                    }
                }
            }
        }

        private void PopulateSchoolDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT SchoolID, SchoolName FROM Schools ORDER BY SchoolName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        // Sync Form Dropdown
                        ddlSchools.Items.Clear();
                        ddlSchools.Items.Add(new ListItem("-- Choose Hosting Faculty --", ""));

                        // Sync Filter Navigation Dropdown
                        string selectedFilter = ddlFilterSchool.SelectedValue; // Maintain user selection position across lifecycle
                        ddlFilterSchool.Items.Clear();
                        ddlFilterSchool.Items.Add(new ListItem("All Schools", ""));

                        while (dr.Read())
                        {
                            string id = dr["SchoolID"].ToString();
                            string name = dr["SchoolName"].ToString();

                            ddlSchools.Items.Add(new ListItem(name, id));
                            ddlFilterSchool.Items.Add(new ListItem(name, id));
                        }

                        // Restore previous filter pointer position if active
                        if (ddlFilterSchool.Items.FindByValue(selectedFilter) != null)
                        {
                            ddlFilterSchool.SelectedValue = selectedFilter;
                        }
                    }
                }
            }
        }

        // Intercept filter dropdown index changes to dynamically update data rows
        protected void ddlFilterSchool_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindProgrammesGrid();
        }

        protected void btnSaveProg_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtProgrammeName.Text) || string.IsNullOrEmpty(ddlSchools.SelectedValue)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = string.IsNullOrEmpty(hfProgrammeID.Value)
                    ? "INSERT INTO Programmes (ProgrammeName, SchoolID) VALUES (@ProgName, @SchoolID)"
                    : "UPDATE Programmes SET ProgrammeName = @ProgName, SchoolID = @SchoolID WHERE ProgrammeID = @ProgID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ProgName", txtProgrammeName.Text.Trim());
                    cmd.Parameters.AddWithValue("@SchoolID", ddlSchools.SelectedValue);
                    if (!string.IsNullOrEmpty(hfProgrammeID.Value))
                    {
                        cmd.Parameters.AddWithValue("@ProgID", hfProgrammeID.Value);
                    }
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            ClearProgrammeForm();
            BindProgrammesGrid();
        }

        protected void gvProgrammes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Prevent empty command arguments from breaking runtime actions
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;

            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditProg")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT ProgrammeID, ProgrammeName, SchoolID FROM Programmes WHERE ProgrammeID = @ProgID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ProgID", id);
                        conn.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                hfProgrammeID.Value = dr["ProgrammeID"].ToString();
                                txtProgrammeName.Text = dr["ProgrammeName"].ToString();
                                ddlSchools.SelectedValue = dr["SchoolID"].ToString();
                                btnSaveProg.Text = "Update Programme";
                                btnCancelProg.Visible = true;
                            }
                        }
                    }
                }
            }
            else if (e.CommandName == "DeleteProg")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // Pure SQL deletion script using database relational cascading foreign keys [cite: 85, 206]
                    string query = "DELETE FROM Programmes WHERE ProgrammeID = @ProgID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ProgID", id);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                ClearProgrammeForm();
                BindProgrammesGrid();
            }
        }

        protected void btnCancelProg_Click(object sender, EventArgs e)
        {
            ClearProgrammeForm();
        }

        private void ClearProgrammeForm()
        {
            hfProgrammeID.Value = string.Empty;
            txtProgrammeName.Text = string.Empty;
            ddlSchools.SelectedIndex = 0;
            btnSaveProg.Text = "Create Programme";
            btnCancelProg.Visible = false;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}