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
                        ddlStudentSemester.DataValueField = "SemesterID";
                        ddlStudentSemester.DataTextField = "Semester";
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

        protected void btnCreateAccount_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string identityNumber = txtIdentityNumber.Text.Trim();
            string email = txtNewUsername.Text.Trim();
            string password = txtNewPassword.Text.Trim();
            string role = ddlRole.SelectedValue;

            if (string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(identityNumber) ||
                string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(role))
            {
                ShowStatus("Please complete all inputs, including Name and IC/Passport, before submitting.", false);
                return;
            }

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

                        if (originalRole != role)
                        {
                            // Drop old structural record tier
                            string dropQuery = "";
                            if (originalRole == "Admin") dropQuery = "DELETE FROM HeadofProgramme WHERE HopID = @ID";
                            else if (originalRole == "Lecturer") dropQuery = "DELETE FROM Lecturer WHERE LecturerID = @ID";
                            else if (originalRole == "Student") dropQuery = "DELETE FROM Student WHERE StudentID = @ID";

                            using (SqlCommand dropCmd = new SqlCommand(dropQuery, conn))
                            {
                                dropCmd.Parameters.AddWithValue("@ID", targetId);
                                dropCmd.ExecuteNonQuery();
                            }

                            // Write new structural details completely
                            string insertQuery = "";
                            if (role == "Admin") insertQuery = "INSERT INTO HeadofProgramme (HopName, HopEmail, Password, IdentityNumber) VALUES (@Name, @Email, @Password, @IDNum)";
                            else if (role == "Lecturer") insertQuery = "INSERT INTO Lecturer (LecturerName, LecturerEmail, Password, IdentityNumber) VALUES (@Name, @Email, @Password, @IDNum)";
                            else if (role == "Student") insertQuery = "INSERT INTO Student (StudentName, StudentEmail, Password, IdentityNumber, SemesterID, IntakeYear) VALUES (@Name, @Email, @Password, @IDNum, @SemesterID, 2026)";

                            using (SqlCommand insCmd = new SqlCommand(insertQuery, conn))
                            {
                                insCmd.Parameters.AddWithValue("@Name", fullName);
                                insCmd.Parameters.AddWithValue("@Email", email);
                                insCmd.Parameters.AddWithValue("@Password", password);
                                insCmd.Parameters.AddWithValue("@IDNum", identityNumber);
                                if (role == "Student")
                                {
                                    insCmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(ddlStudentSemester.SelectedValue));
                                }
                                insCmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            // Updating information rows inside the same role profile tier
                            string updateQuery = "";
                            if (role == "Admin") updateQuery = "UPDATE HeadofProgramme SET HopName = @Name, HopEmail = @Email, Password = @Password, IdentityNumber = @IDNum WHERE HopID = @ID";
                            else if (role == "Lecturer") updateQuery = "UPDATE Lecturer SET LecturerName = @Name, LecturerEmail = @Email, Password = @Password, IdentityNumber = @IDNum WHERE LecturerID = @ID";
                            else if (role == "Student") updateQuery = "UPDATE Student SET StudentName = @Name, StudentEmail = @Email, Password = @Password, IdentityNumber = @IDNum, SemesterID = @SemesterID WHERE StudentID = @ID";

                            using (SqlCommand updCmd = new SqlCommand(updateQuery, conn))
                            {
                                updCmd.Parameters.AddWithValue("@Name", fullName);
                                updCmd.Parameters.AddWithValue("@Email", email);
                                updCmd.Parameters.AddWithValue("@Password", password);
                                updCmd.Parameters.AddWithValue("@IDNum", identityNumber);
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
                        // Clean insertion processing logic loop
                        string insertQuery = "";
                        if (role == "Admin") insertQuery = "INSERT INTO HeadofProgramme (HopName, HopEmail, Password, IdentityNumber) VALUES (@Name, @Email, @Password, @IDNum)";
                        else if (role == "Lecturer") insertQuery = "INSERT INTO Lecturer (LecturerName, LecturerEmail, Password, IdentityNumber) VALUES (@Name, @Email, @Password, @IDNum)";
                        else if (role == "Student") insertQuery = "INSERT INTO Student (StudentName, StudentEmail, Password, IdentityNumber, SemesterID, IntakeYear) VALUES (@Name, @Email, @Password, @IDNum, @SemesterID, 2026)";

                        using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@Name", fullName);
                            cmd.Parameters.AddWithValue("@Email", email);
                            cmd.Parameters.AddWithValue("@Password", password);
                            cmd.Parameters.AddWithValue("@IDNum", identityNumber);
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
                if (targetRole == "Admin") query = "SELECT HopName AS Name, HopEmail AS Email, Password, IdentityNumber, NULL as SemesterID FROM HeadofProgramme WHERE HopID = @ID";
                else if (targetRole == "Lecturer") query = "SELECT LecturerName AS Name, LecturerEmail AS Email, Password, IdentityNumber, NULL as SemesterID FROM Lecturer WHERE LecturerID = @ID";
                else if (targetRole == "Student") query = "SELECT StudentName AS Name, StudentEmail AS Email, Password, IdentityNumber, SemesterID FROM Student WHERE StudentID = @ID";

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
                                    txtFullName.Text = reader["Name"].ToString();
                                    txtIdentityNumber.Text = reader["IdentityNumber"].ToString();
                                    txtNewUsername.Text = reader["Email"].ToString();
                                    txtNewPassword.Text = reader["Password"].ToString();
                                    ddlRole.SelectedValue = targetRole;

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
            txtFullName.Text = "";
            txtIdentityNumber.Text = "";
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