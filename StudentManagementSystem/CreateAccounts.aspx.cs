using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class CreateAccounts : System.Web.UI.Page
    {
        private string connString = @"Server=(localdb)\MSSQLLocalDB;Database=StudentManagementSystem;Trusted_Connection=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                BindUserGrid();
                BindSemesterDropdown();
            }
        }

        // =========================================================================
        // DYNAMIC SEED: RECOVER SYSTEM SEMESTER ENTRIES FOR INTAKE SELECTION
        // =========================================================================
        private void BindSemesterDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT SemesterID, Semester FROM Semester ORDER BY SemesterID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        ddlStudentSemester.DataSource = cmd.ExecuteReader();
                        ddlStudentSemester.DataValueField = "SemesterID"; // Passes primary index key automatically (e.g. 2, 3, 4)
                        ddlStudentSemester.DataTextField = "Semester";     // Displays text value gracefully (e.g. "Jan", "April")
                        ddlStudentSemester.DataBind();
                    }
                    catch (Exception ex)
                    {
                        ShowStatus("Could not query dynamic operational terms: " + ex.Message, false);
                    }
                }
            }
            ddlStudentSemester.Items.Insert(0, new ListItem("-- Select Active Semester --", ""));
        }

        protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Toggle semester options field configuration dynamically based on active selection tier
            pnlSemesterSelection.Visible = (ddlRole.SelectedValue == "Student");
        }

        private void BindUserGrid()
        {
            string selectedFilter = ddlFilterRole != null ? ddlFilterRole.SelectedValue : "All";

            string hopPart = "SELECT HopID AS UserID, HopEmail AS Username, UserRole AS Role FROM HeadofProgramme";
            string lecPart = "SELECT LecturerID AS UserID, LecturerEmail AS Username, UserRole AS Role FROM Lecturer";
            string boldPart = "SELECT StudentID AS UserID, StudentEmail AS Username, UserRole AS Role FROM Student";

            string finalQuery = "";

            if (selectedFilter == "Admin") finalQuery = hopPart + " ORDER BY Username";
            else if (selectedFilter == "Lecturer") finalQuery = lecPart + " ORDER BY Username";
            else if (selectedFilter == "Student") finalQuery = boldPart + " ORDER BY Username";
            else finalQuery = hopPart + " UNION " + lecPart + " UNION " + boldPart + " ORDER BY Role, Username";

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(finalQuery, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            conn.Open();
                            da.Fill(dt);
                            gvUsers.DataSource = dt;
                            gvUsers.DataBind();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error filtering user directory: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        protected void ddlFilterRole_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindUserGrid();
        }

        // =========================================================================
        // PRIMARY REGISTRATION / MODIFICATION INTERFACE CONTROLLER
        // =========================================================================
        protected void btnCreateAccount_Click(object sender, EventArgs e)
        {
            string email = txtNewUsername.Text.Trim();
            string password = txtNewPassword.Text.Trim();
            string role = ddlRole.SelectedValue;

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(role))
            {
                ShowStatus("Please complete all inputs before submitting.", false);
                return;
            }

            // Security Validation: If target role is Student, verify a valid semester index row has been chosen
            if (role == "Student" && string.IsNullOrEmpty(ddlStudentSemester.SelectedValue))
            {
                ShowStatus("Operational constraint warning: Please specify a valid intake semester for student registration.", false);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();
                    bool isUpdate = (btnCreateAccount.Text == "Update Account");

                    if (isUpdate)
                    {
                        string originalRole = Session["EditingRole"].ToString();
                        string targetId = hfUserID.Value;

                        // OPTION A: Admin changed the account's structural role tier
                        if (originalRole != role)
                        {
                            string dropQuery = "";
                            if (originalRole == "Admin") dropQuery = "DELETE FROM HeadofProgramme WHERE HopID = @ID";
                            else if (originalRole == "Lecturer") dropQuery = "DELETE FROM Lecturer WHERE LecturerID = @ID";
                            else if (originalRole == "Student") dropQuery = "DELETE FROM Student WHERE StudentID = @ID";

                            using (SqlCommand dropCmd = new SqlCommand(dropQuery, conn))
                            {
                                dropCmd.Parameters.AddWithValue("@ID", targetId);
                                dropCmd.ExecuteNonQuery();
                            }

                            string insertQuery = "";
                            if (role == "Admin") insertQuery = "INSERT INTO HeadofProgramme (HopName, HopEmail, Password) VALUES ('Modified Admin', @Email, @Password)";
                            else if (role == "Lecturer") insertQuery = "INSERT INTO Lecturer (LecturerName, LecturerEmail, Password) VALUES ('Modified Faculty', @Email, @Password)";
                            else if (role == "Student") insertQuery = "INSERT INTO Student (StudentName, StudentEmail, Password, SemesterID, IntakeYear) VALUES ('Modified Student', @Email, @Password, @SemesterID, 2026)";

                            using (SqlCommand insCmd = new SqlCommand(insertQuery, conn))
                            {
                                insCmd.Parameters.AddWithValue("@Email", email);
                                insCmd.Parameters.AddWithValue("@Password", password);
                                if (role == "Student")
                                {
                                    insCmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(ddlStudentSemester.SelectedValue));
                                }
                                insCmd.ExecuteNonQuery();
                            }
                        }
                        // OPTION B: Role didn't change, just update details normaly
                        else
                        {
                            string updateQuery = "";
                            if (role == "Admin") updateQuery = "UPDATE HeadofProgramme SET HopEmail = @Email, Password = @Password WHERE HopID = @ID";
                            else if (role == "Lecturer") updateQuery = "UPDATE Lecturer SET LecturerEmail = @Email, Password = @Password WHERE LecturerID = @ID";
                            else if (role == "Student") updateQuery = "UPDATE Student SET StudentEmail = @Email, Password = @Password, SemesterID = @SemesterID WHERE StudentID = @ID";

                            using (SqlCommand updCmd = new SqlCommand(updateQuery, conn))
                            {
                                updCmd.Parameters.AddWithValue("@Email", email);
                                updCmd.Parameters.AddWithValue("@Password", password);
                                updCmd.Parameters.AddWithValue("@ID", targetId);
                                if (role == "Student")
                                {
                                    updCmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(ddlStudentSemester.SelectedValue));
                                }
                                updCmd.ExecuteNonQuery();
                            }
                        }
                    }
                    else
                    {
                        string insertQuery = "";
                        if (role == "Admin") insertQuery = "INSERT INTO HeadofProgramme (HopName, HopEmail, Password) VALUES ('New Admin', @Email, @Password)";
                        else if (role == "Lecturer") insertQuery = "INSERT INTO Lecturer (LecturerName, LecturerEmail, Password) VALUES ('Faculty Member', @Email, @Password)";
                        else if (role == "Student") insertQuery = "INSERT INTO Student (StudentName, StudentEmail, Password, SemesterID, IntakeYear) VALUES ('Student Enrollee', @Email, @Password, @SemesterID, 2026)";

                        using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@Email", email);
                            cmd.Parameters.AddWithValue("@Password", password);
                            if (role == "Student")
                            {
                                cmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(ddlStudentSemester.SelectedValue));
                            }
                            cmd.ExecuteNonQuery();
                        }
                    }

                    ResetFormState();
                    ShowStatus(isUpdate ? "Account profile changes synchronized cleanly!" : "Account created successfully!", true);
                    BindUserGrid();
                }
                catch (SqlException ex)
                {
                    // Catch block to capture structural index errors
                    if (ex.Number == 547)
                    {
                        ShowStatus("Database integrity conflict: The selected semester does not exist in our active dictionary records.", false);
                    }
                    else
                    {
                        ShowStatus("Database transaction failed: " + ex.Message, false);
                    }
                }
                catch (Exception ex)
                {
                    ShowStatus("System engine failure: " + ex.Message, false);
                }
            }
        }

        // =========================================================================
        // DATA ROW INTERACTION ENGINE HUB
        // =========================================================================
        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string args = e.CommandArgument.ToString();
            if (!args.Contains(",")) return;

            string[] parsedArgs = args.Split(',');
            string targetId = parsedArgs[0];
            string targetRole = parsedArgs[1];

            if (e.CommandName == "EditUser")
            {
                string query = "";
                if (targetRole == "Admin") query = "SELECT HopEmail AS Email, Password, NULL as SemesterID FROM HeadofProgramme WHERE HopID = @ID";
                else if (targetRole == "Lecturer") query = "SELECT LecturerEmail AS Email, Password, NULL as SemesterID FROM Lecturer WHERE LecturerID = @ID";
                else if (targetRole == "Student") query = "SELECT StudentEmail AS Email, Password, SemesterID FROM Student WHERE StudentID = @ID";

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", targetId);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    txtNewUsername.Text = reader["Email"].ToString();
                                    txtNewPassword.Text = reader["Password"].ToString();
                                    ddlRole.SelectedValue = targetRole;

                                    // Display semester settings mapping options if loading a student profile record
                                    if (targetRole == "Student")
                                    {
                                        pnlSemesterSelection.Visible = true;
                                        string semId = reader["SemesterID"].ToString();
                                        if (ddlStudentSemester.Items.FindByValue(semId) != null)
                                        {
                                            ddlStudentSemester.SelectedValue = semId;
                                        }
                                    }
                                    else
                                    {
                                        pnlSemesterSelection.Visible = false;
                                    }

                                    hfUserID.Value = targetId;
                                    Session["EditingRole"] = targetRole;

                                    btnCreateAccount.Text = "Update Account";
                                    btnCancelAccount.Visible = true;
                                    ShowStatus("Profile data loaded. Modify details and save changes.", true);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error retrieving profile data: " + ex.Message, false);
                        }
                    }
                }
            }
            else if (e.CommandName == "DeleteUser")
            {
                string deleteQuery = "";
                if (targetRole == "Admin") deleteQuery = "DELETE FROM HeadofProgramme WHERE HopID = @ID AND HopID <> 1;";
                else if (targetRole == "Lecturer") deleteQuery = "DELETE FROM Lecturer WHERE LecturerID = @ID;";
                else if (targetRole == "Student") deleteQuery = "DELETE FROM Student WHERE StudentID = @ID;";

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", targetId);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowStatus("User profile data wiped successfully.", true);
                            BindUserGrid();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Deletion error: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        protected void btnCancelAccount_Click(object sender, EventArgs e)
        {
            ResetFormState();
        }

        private void ResetFormState()
        {
            txtNewUsername.Text = "";
            txtNewPassword.Text = "";
            ddlRole.SelectedIndex = 0;
            ddlStudentSemester.SelectedIndex = 0;
            pnlSemesterSelection.Visible = false;
            btnCreateAccount.Text = "Register Account";
            btnCancelAccount.Visible = false;
            Session["EditingRole"] = null;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            lblStatus.BackColor = isSuccess ? System.Drawing.Color.FromArgb(240, 253, 244) : System.Drawing.Color.FromArgb(254, 242, 242);
            lblStatus.ForeColor = isSuccess ? System.Drawing.Color.MediumSeaGreen : System.Drawing.Color.OrangeRed;
            lblStatus.Visible = true;
        }
    }
}