using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
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
                return;
            }

            if (!IsPostBack)
            {
                ViewState["ActiveFilterRole"] = "All";
                ViewState["SelectedProgFilter"] = "All";
                ViewState["SearchKeyword"] = "";
                PopulateSemesterDropdown();
                PopulateProgrammeDropdowns();
                BindUserGrid();
            }
        }

        private void PopulateSemesterDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT SemesterID, Semester + ' (' + CAST(AcademicYear AS VARCHAR) + ')' AS Name FROM Semester ORDER BY AcademicYear DESC, SemesterID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        ddlStudentSemester.DataSource = cmd.ExecuteReader();
                        ddlStudentSemester.DataValueField = "SemesterID";
                        ddlStudentSemester.DataTextField = "Name";
                        ddlStudentSemester.DataBind();
                    }
                    catch { }
                }
            }
            ddlStudentSemester.Items.Insert(0, new ListItem("-- Select Semester --", ""));
        }

        private void PopulateProgrammeDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT ProgrammeCode, ProgrammeName FROM Programme ORDER BY ProgrammeName ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) { da.Fill(dt); }

                        ddlStudentProgramme.DataSource = dt;
                        ddlStudentProgramme.DataValueField = "ProgrammeCode";
                        ddlStudentProgramme.DataTextField = "ProgrammeName";
                        ddlStudentProgramme.DataBind();
                        ddlStudentProgramme.Items.Insert(0, new ListItem("-- Choose Programme Track --", ""));

                        ddlFilterProgramme.DataSource = dt;
                        ddlFilterProgramme.DataValueField = "ProgrammeCode";
                        ddlFilterProgramme.DataTextField = "ProgrammeName";
                        ddlFilterProgramme.DataBind();
                        ddlFilterProgramme.Items.Insert(0, new ListItem("All Programmes Track", "All"));
                    }
                    catch { }
                }
            }
        }

        protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e)
        {
            pnlStudentFields.Visible = (ddlRole.SelectedValue == "Student");
            pnlModalContainer.Visible = true;
        }

        protected void btnTriggerRegistrationModal_Click(object sender, EventArgs e)
        {
            ResetFormState();
            litModalHeader.Text = "Register New Profile Instance";
            btnCreateAccount.Text = "Register Account";
            pnlModalContainer.Visible = true;
        }

        protected void FilterButton_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            ViewState["ActiveFilterRole"] = btn.CommandArgument;
            BindUserGrid();
        }

        protected void ddlFilterProgramme_SelectedIndexChanged(object sender, EventArgs e)
        {
            ViewState["SelectedProgFilter"] = ddlFilterProgramme.SelectedValue;
            BindUserGrid();
        }

        // ADDED: Handles text inputs dynamically inside the new Search bar component box
        protected void txtSearchUID_TextChanged(object sender, EventArgs e)
        {
            ViewState["SearchKeyword"] = txtSearchUID.Text.Trim();
            lnkClearSearch.Visible = !string.IsNullOrEmpty(txtSearchUID.Text.Trim());
            BindUserGrid();
        }

        protected void lnkClearSearch_Click(object sender, EventArgs e)
        {
            txtSearchUID.Text = "";
            ViewState["SearchKeyword"] = "";
            lnkClearSearch.Visible = false;
            BindUserGrid();
        }

        private void BindUserGrid()
        {
            string currentFilter = ViewState["ActiveFilterRole"].ToString();
            string progFilter = ViewState["SelectedProgFilter"].ToString();
            string searchWord = ViewState["SearchKeyword"].ToString().ToUpper();
            UpdateFilterTabStyles(currentFilter);

            divProgSortWrapper.Visible = (currentFilter == "All" || currentFilter == "Student");

            string hopPart = "SELECT HopID AS UserID, DisplayID, HopEmail AS Username, UserRole AS Role, ProfilePictureUrl, '' AS ProgrammeName, '' AS ProgrammeCode FROM HeadofProgramme";
            string lecPart = "SELECT LecturerID AS UserID, DisplayID, LecturerEmail AS Username, UserRole AS Role, ProfilePictureUrl, '' AS ProgrammeName, '' AS ProgrammeCode FROM Lecturer";
            string studentPart = "SELECT s.StudentID AS UserID, s.DisplayID, s.StudentEmail AS Username, s.UserRole AS Role, s.ProfilePictureUrl, ISNULL(p.ProgrammeName, '') AS ProgrammeName, ISNULL(s.ProgrammeCode, '') AS ProgrammeCode FROM Student s LEFT JOIN Programme p ON s.ProgrammeCode = p.ProgrammeCode";

            // If a program filter is selected, append the constraint clause block
            if (progFilter != "All")
            {
                studentPart += " WHERE s.ProgrammeCode = @ProgFilterCode";
            }

            string finalQuery = "";
            if (currentFilter == "Admin") finalQuery = hopPart;
            else if (currentFilter == "Lecturer") finalQuery = lecPart;
            else if (currentFilter == "Student") finalQuery = studentPart;
            else
            {
                if (progFilter != "All") finalQuery = studentPart;
                else finalQuery = $"SELECT * FROM ({hopPart} UNION {lecPart} UNION {studentPart}) AS MergedUsers";
            }

            // ADDED: Real-time SQL filter injector logic handling live keywords strings securely
            if (!string.IsNullOrEmpty(searchWord))
            {
                if (finalQuery.Contains("WHERE")) finalQuery += " AND DisplayID LIKE @SearchParam";
                else finalQuery += " WHERE DisplayID LIKE @SearchParam";
            }

            // Append consistent ordering arrays parameters matrix
            if (currentFilter == "Student" || (currentFilter == "All" && progFilter != "All"))
            {
                finalQuery += " ORDER BY ProgrammeName ASC, Username ASC";
            }
            else
            {
                finalQuery += " ORDER BY Role ASC, Username ASC";
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(finalQuery, conn))
                {
                    if (progFilter != "All" && (currentFilter == "All" || currentFilter == "Student"))
                    {
                        cmd.Parameters.AddWithValue("@ProgFilterCode", progFilter);
                    }
                    if (!string.IsNullOrEmpty(searchWord))
                    {
                        cmd.Parameters.AddWithValue("@SearchParam", "%" + searchWord + "%");
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvUsers.DataSource = dt;
                            gvUsers.DataBind();
                        }
                        catch { }
                    }
                }
            }
        }

        private void UpdateFilterTabStyles(string activeRole)
        {
            // Normal buttons style matching export controls perfectly
            string normalStyle = "px-4 py-2 text-xs font-bold rounded-xl border bg-white text-zinc-700 border-zinc-200 hover:bg-zinc-50 shadow-sm transition-all cursor-pointer select-none";

            // FIXED: Accent states update perfectly to mirror row-level pills badge color distribution palettes
            btnFilterAll.CssClass = (activeRole == "All") ? "px-4 py-2 text-xs font-bold rounded-xl border bg-zinc-900 text-white border-zinc-900 shadow-sm cursor-pointer transition-all" : normalStyle;
            btnFilterAdmin.CssClass = (activeRole == "Admin") ? "px-4 py-2 text-xs font-bold rounded-xl border bg-blue-50 text-blue-600 border-blue-200 shadow-sm cursor-pointer transition-all" : normalStyle;
            btnFilterLecturer.CssClass = (activeRole == "Lecturer") ? "px-4 py-2 text-xs font-bold rounded-xl border bg-orange-50 text-orange-600 border-orange-200 shadow-sm cursor-pointer transition-all" : normalStyle;
            btnFilterStudent.CssClass = (activeRole == "Student") ? "px-4 py-2 text-xs font-bold rounded-xl border bg-emerald-50 text-emerald-600 border-emerald-200 shadow-sm cursor-pointer transition-all" : normalStyle;
        }

        private string ComputeCorporateAutoCredential(string fullName, string idNumber, string role)
        {
            StringBuilder initials = new StringBuilder();
            string[] words = fullName.Trim().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string word in words)
            {
                if (word.Length > 0) initials.Append(char.ToLower(word[0]));
            }

            string cleanId = idNumber.Trim();
            string last4 = cleanId.Length >= 4 ? cleanId.Substring(cleanId.Length - 4) : "1234";

            string roleDomain = "student";
            if (role == "Admin") roleDomain = "admin";
            else if (role == "Lecturer") roleDomain = "lect";

            return $"{initials}{last4}@{roleDomain}.unitrack.com";
        }

        protected void btnCreateAccount_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string identityNumber = txtIdentityNumber.Text.Trim();
            string role = ddlRole.SelectedValue;

            if (string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(identityNumber) || string.IsNullOrWhiteSpace(role))
            {
                ShowStatus("Please complete all inputs, including Name and IC/Passport, before submitting.", false);
                pnlModalContainer.Visible = true;
                return;
            }

            if (role == "Student" && (string.IsNullOrEmpty(ddlStudentSemester.SelectedValue) || string.IsNullOrEmpty(ddlStudentProgramme.SelectedValue)))
            {
                ShowStatus("Operational warning: Please choose an intake semester and programme for students.", false);
                pnlModalContainer.Visible = true;
                return;
            }

            string autoGeneratedCredentialStr = ComputeCorporateAutoCredential(fullName, identityNumber, role);

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
                            string dropQuery = originalRole == "Admin" ? "DELETE FROM HeadofProgramme WHERE HopID = @ID" : originalRole == "Lecturer" ? "DELETE FROM Lecturer WHERE LecturerID = @ID" : "DELETE FROM Student WHERE StudentID = @ID";
                            using (SqlCommand dropCmd = new SqlCommand(dropQuery, conn))
                            {
                                dropCmd.Parameters.AddWithValue("@ID", targetId);
                                dropCmd.ExecuteNonQuery();
                            }

                            string insertQuery = role == "Admin" ? "INSERT INTO HeadofProgramme (HopName, HopEmail, Password, IdentityNumber) VALUES (@Name, @Email, @Password, @IDNum)" : role == "Lecturer" ? "INSERT INTO Lecturer (LecturerName, LecturerEmail, Password, IdentityNumber) VALUES (@Name, @Email, @Password, @IDNum)" : "INSERT INTO Student (StudentName, StudentEmail, Password, IdentityNumber, SemesterID, ProgrammeCode, IntakeYear) VALUES (@Name, @Email, @Password, @IDNum, @SemesterID, @ProgCode, 2026)";
                            using (SqlCommand insCmd = new SqlCommand(insertQuery, conn))
                            {
                                insCmd.Parameters.AddWithValue("@Name", fullName);
                                insCmd.Parameters.AddWithValue("@Email", autoGeneratedCredentialStr);
                                insCmd.Parameters.AddWithValue("@Password", autoGeneratedCredentialStr);
                                insCmd.Parameters.AddWithValue("@IDNum", identityNumber);
                                if (role == "Student")
                                {
                                    insCmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(ddlStudentSemester.SelectedValue));
                                    insCmd.Parameters.AddWithValue("@ProgCode", ddlStudentProgramme.SelectedValue);
                                }
                                insCmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            string updateQuery = role == "Admin" ? "UPDATE HeadofProgramme SET HopName = @Name, HopEmail = @Email, Password = @Password, IdentityNumber = @IDNum WHERE HopID = @ID" : role == "Lecturer" ? "UPDATE Lecturer SET LecturerName = @Name, LecturerEmail = @Email, Password = @Password, IdentityNumber = @IDNum WHERE LecturerID = @ID" : "UPDATE Student SET StudentName = @Name, StudentEmail = @Email, Password = @Password, IdentityNumber = @IDNum, SemesterID = @SemesterID, ProgrammeCode = @ProgCode WHERE StudentID = @ID";
                            using (SqlCommand updCmd = new SqlCommand(updateQuery, conn))
                            {
                                updCmd.Parameters.AddWithValue("@Name", fullName);
                                updCmd.Parameters.AddWithValue("@Email", autoGeneratedCredentialStr);
                                updCmd.Parameters.AddWithValue("@Password", autoGeneratedCredentialStr);
                                updCmd.Parameters.AddWithValue("@IDNum", identityNumber);
                                updCmd.Parameters.AddWithValue("@ID", targetId);
                                if (role == "Student")
                                {
                                    updCmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(ddlStudentSemester.SelectedValue));
                                    updCmd.Parameters.AddWithValue("@ProgCode", ddlStudentProgramme.SelectedValue);
                                }
                                updCmd.ExecuteNonQuery();
                            }
                        }
                    }
                    else
                    {
                        string insertQuery = role == "Admin" ? "INSERT INTO HeadofProgramme (HopName, HopEmail, Password, IdentityNumber) VALUES (@Name, @Email, @Password, @IDNum)" : role == "Lecturer" ? "INSERT INTO Lecturer (LecturerName, LecturerEmail, Password, IdentityNumber) VALUES (@Name, @Email, @Password, @IDNum)" : "INSERT INTO Student (StudentName, StudentEmail, Password, IdentityNumber, SemesterID, ProgrammeCode, IntakeYear) VALUES (@Name, @Email, @Password, @IDNum, @SemesterID, @ProgCode, 2026)";
                        using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@Name", fullName);
                            cmd.Parameters.AddWithValue("@Email", autoGeneratedCredentialStr);
                            cmd.Parameters.AddWithValue("@Password", autoGeneratedCredentialStr);
                            cmd.Parameters.AddWithValue("@IDNum", identityNumber);
                            if (role == "Student")
                            {
                                cmd.Parameters.AddWithValue("@SemesterID", Convert.ToInt32(ddlStudentSemester.SelectedValue));
                                cmd.Parameters.AddWithValue("@ProgCode", ddlStudentProgramme.SelectedValue);
                            }
                            cmd.ExecuteNonQuery();
                        }
                    }

                    ResetFormState();
                    ShowStatus(isUpdate ? "Account changes synchronized cleanly!" : "Profile credential keys provisioned successfully!", true);
                    BindUserGrid();
                }
                catch { }
            }
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string args = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(args) || !args.Contains(",")) return;

            string[] parsedArgs = args.Split(',');
            string targetId = parsedArgs[0];
            string targetRole = parsedArgs[1];

            if (e.CommandName == "EditUser")
            {
                string query = targetRole == "Admin" ? "SELECT HopName AS Name, HopEmail AS Email, Password, IdentityNumber, NULL as SemesterID, NULL as ProgrammeCode FROM HeadofProgramme WHERE HopID = @ID" : targetRole == "Lecturer" ? "SELECT LecturerName AS Name, LecturerEmail AS Email, Password, IdentityNumber, NULL as SemesterID, NULL as ProgrammeCode FROM Lecturer WHERE LecturerID = @ID" : "SELECT StudentName AS Name, StudentEmail AS Email, Password, IdentityNumber, SemesterID, ProgrammeCode FROM Student WHERE StudentID = @ID";

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
                                    ddlRole.SelectedValue = targetRole;

                                    if (targetRole == "Student")
                                    {
                                        pnlStudentFields.Visible = true;
                                        string semId = reader["SemesterID"].ToString();
                                        if (ddlStudentSemester.Items.FindByValue(semId) != null) ddlStudentSemester.SelectedValue = semId;

                                        string progCode = reader["ProgrammeCode"].ToString();
                                        if (ddlStudentProgramme.Items.FindByValue(progCode) != null) ddlStudentProgramme.SelectedValue = progCode;
                                    }
                                    else { pnlStudentFields.Visible = false; }

                                    hfUserID.Value = targetId;
                                    Session["EditingRole"] = targetRole;
                                    litModalHeader.Text = "Modify Identity Access Parameters";
                                    btnCreateAccount.Text = "Update Account";
                                    pnlModalContainer.Visible = true;
                                    lblStatus.Visible = false;
                                }
                            }
                        }
                        catch { }
                    }
                }
            }
            else if (e.CommandName == "DeleteUser")
            {
                string deleteQuery = targetRole == "Admin" ? "DELETE FROM HeadofProgramme WHERE HopID = @ID AND HopID <> 1;" : targetRole == "Lecturer" ? "DELETE FROM Lecturer WHERE LecturerID = @ID;" : "DELETE FROM Student WHERE StudentID = @ID;";
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", targetId);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowStatus("User account profile removed from directory registries.", true);
                            BindUserGrid();
                        }
                        catch { }
                    }
                }
            }
        }

        protected void btnCancelAccount_Click(object sender, EventArgs e) { ResetFormState(); }
        private void ResetFormState()
        {
            txtFullName.Text = ""; txtIdentityNumber.Text = ""; ddlRole.SelectedIndex = 0;
            ddlStudentSemester.SelectedIndex = 0; ddlStudentProgramme.SelectedIndex = 0;
            pnlStudentFields.Visible = false; btnCreateAccount.Text = "Register Account";
            pnlModalContainer.Visible = false; Session["EditingRole"] = null;
        }

        private DataTable GetExportDataPayload()
        {
            string currentFilter = ViewState["ActiveFilterRole"].ToString();
            string progFilter = ViewState["SelectedProgFilter"].ToString();
            string searchWord = ViewState["SearchKeyword"].ToString().ToUpper();

            string hop = "SELECT DisplayID, HopEmail AS Email, UserRole AS Role, '-' AS Programme FROM HeadofProgramme";
            string lec = "SELECT DisplayID, LecturerEmail AS Email, UserRole AS Role, '-' AS Programme FROM Lecturer";
            string stu = "SELECT s.DisplayID, s.StudentEmail AS Email, s.UserRole AS Role, ISNULL(p.ProgrammeName, '-') AS Programme FROM Student s LEFT JOIN Programme p ON s.ProgrammeCode = p.ProgrammeCode";

            if (progFilter != "All") { stu += " WHERE s.ProgrammeCode = @PFilter"; }

            string query = "";
            if (currentFilter == "Admin") query = hop;
            else if (currentFilter == "Lecturer") query = lec;
            else if (currentFilter == "Student") query = stu;
            else
            {
                if (progFilter != "All") query = stu;
                else query = $"SELECT * FROM ({hop} UNION {lec} UNION {stu}) AS Users";
            }

            if (!string.IsNullOrEmpty(searchWord))
            {
                if (query.Contains("WHERE")) query += " AND DisplayID LIKE @SearchParam";
                else query += " WHERE DisplayID LIKE @SearchParam";
            }

            if (currentFilter == "Student" || (currentFilter == "All" && progFilter != "All"))
            {
                query += " ORDER BY Programme ASC, Email ASC";
            }
            else
            {
                query += " ORDER BY Role ASC, Email ASC";
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (progFilter != "All" && (currentFilter == "All" || currentFilter == "Student"))
                    {
                        cmd.Parameters.AddWithValue("@PFilter", progFilter);
                    }
                    if (!string.IsNullOrEmpty(searchWord))
                    {
                        cmd.Parameters.AddWithValue("@SearchParam", "%" + searchWord + "%");
                    }
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
            }
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            DataTable dt = GetExportDataPayload();
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Institutional Name list");
            sb.AppendLine();
            sb.AppendLine("No,User ID,Email Address,Role,Assigned Programme");

            int idx = 1;
            foreach (DataRow r in dt.Rows)
            {
                sb.AppendLine($"{idx},{r["DisplayID"]},{r["Email"]},{r["Role"]},\"{r["Programme"]}\"");
                idx++;
            }

            Response.Clear();
            Response.AddHeader("content-disposition", "attachment;filename=Institutional_Namelist.csv");
            Response.ContentType = "text/csv";
            Response.Output.Write(sb.ToString());
            Response.End();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = GetExportDataPayload();
            Response.Clear();
            Response.AddHeader("content-disposition", "attachment;filename=Institutional_Namelist.xls");
            Response.ContentType = "application/vnd.ms-excel";

            StringWriter sw = new StringWriter();
            HtmlTextWriter hw = new HtmlTextWriter(sw);

            hw.Write("<h2>Institutional Name list</h2>");
            hw.Write("<table border='1' style='font-family:Arial; font-size:12px;'>");
            hw.Write("<tr style='background-color:#F7F7F5; font-weight:bold;'><th>No</th><th>User ID</th><th>Email Address</th><th>Role System Tier</th><th>Assigned Programme</th></tr>");

            int idx = 1;
            foreach (DataRow r in dt.Rows)
            {
                hw.Write($"<tr><td style='text-align:center;'>{idx}</td><td style='text-align:center; font-weight:bold;'>{r["DisplayID"]}</td><td>{r["Email"]}</td><td style='text-align:center;'>{r["Role"]}</td><td>{HttpUtility.HtmlEncode(r["Programme"])}</td></tr>");
                idx++;
            }
            hw.Write("</table>");
            Response.Output.Write(sw.ToString());
            Response.End();
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetExportDataPayload();
            StringBuilder sb = new StringBuilder();

            sb.Append("<html><head><style>body{font-family:Segoe UI,Arial,sans-serif; padding:40px;} table{width:100%; border-collapse:collapse; margin-top:20px;} th,td{border:1px solid #ccc; padding:12px; font-size:12px;} th{background-color:#f4f4f5; text-align:left; font-weight:700; text-transform:uppercase; font-size:10px; color:#555;}</style></head><body>");
            sb.Append("<h2>Institutional Name list</h2>");
            sb.Append("<table><tr><th style='text-align:center; width:7%;'>No</th><th>User ID</th><th>Email Address</th><th>Role Access</th><th>Assigned Programme Title</th></tr>");

            int idx = 1;
            foreach (DataRow r in dt.Rows)
            {
                sb.Append($"<tr><td style='text-align:center; color:#888;'>{idx}</td><td style='font-weight:bold;'>{r["DisplayID"]}</td><td style='font-weight:600;'>{r["Email"]}</td><td>{r["Role"]}</td><td>{HttpUtility.HtmlEncode(r["Programme"])}</td></tr>");
                idx++;
            }
            sb.Append("</table><script>window.onload = function() { window.print(); }</script></body></html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(sb.ToString());
            Response.End();
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