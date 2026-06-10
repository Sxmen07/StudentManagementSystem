using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageAnnouncements : System.Web.UI.Page
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
                BindAnnouncementsGrid();
            }
        }

        private void BindAnnouncementsGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT AnnouncementID, Title, TargetAdmin, TargetLecturer, TargetStudent, CreatedDate FROM AdminAnnouncement ORDER BY CreatedDate DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvAnnouncements.DataSource = dt;
                            gvAnnouncements.DataBind();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error connecting to announcement registry tracks: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        protected void btnPublish_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string content = txtContent.Text.Trim();
            bool tAdmin = chkAdmin.Checked;
            bool tLecturer = chkLecturer.Checked;
            bool tStudent = chkStudent.Checked;

            if (string.IsNullOrWhiteSpace(title) || string.IsNullOrWhiteSpace(content))
            {
                ShowStatus("Validation block: Title header and content text fields cannot be left empty.", false);
                return;
            }

            if (!tAdmin && !tLecturer && !tStudent)
            {
                ShowStatus("Routing constraint error: Please assign at least one target audience layer for transmission.", false);
                return;
            }

            bool isUpdate = (btnPublish.Text == "Update Announcement");

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = isUpdate
                    ? "UPDATE AdminAnnouncement SET Title = @Title, ContentText = @Content, TargetAdmin = @TAdmin, TargetLecturer = @TLecturer, TargetStudent = @TStudent WHERE AnnouncementID = @ID"
                    : "INSERT INTO AdminAnnouncement (Title, ContentText, TargetAdmin, TargetLecturer, TargetStudent) VALUES (@Title, @Content, @TAdmin, @TLecturer, @TStudent)";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Title", title);
                    cmd.Parameters.AddWithValue("@Content", content);
                    cmd.Parameters.AddWithValue("@TAdmin", tAdmin);
                    cmd.Parameters.AddWithValue("@TLecturer", tLecturer);
                    cmd.Parameters.AddWithValue("@TStudent", tStudent);

                    if (isUpdate)
                    {
                        cmd.Parameters.AddWithValue("@ID", Convert.ToInt32(hfAnnouncementID.Value));
                    }

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowStatus(isUpdate ? "Broadcast system variables modified successfully!" : "Announcement broadcasted across selected channels!", true);
                        ResetFormState();
                        BindAnnouncementsGrid();
                    }
                    catch (Exception ex)
                    {
                        ShowStatus("Database broadcast operation failure: " + ex.Message, false);
                    }
                }
            }
        }

        protected void gvAnnouncements_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int announcementId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditAnnouncement")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT Title, ContentText, TargetAdmin, TargetLecturer, TargetStudent FROM AdminAnnouncement WHERE AnnouncementID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", announcementId);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    txtTitle.Text = reader["Title"].ToString();
                                    txtContent.Text = reader["ContentText"].ToString();
                                    chkAdmin.Checked = Convert.ToBoolean(reader["TargetAdmin"]);
                                    chkLecturer.Checked = Convert.ToBoolean(reader["TargetLecturer"]);
                                    chkStudent.Checked = Convert.ToBoolean(reader["TargetStudent"]);

                                    hfAnnouncementID.Value = announcementId.ToString();
                                    btnPublish.Text = "Update Announcement";
                                    btnCancelEdit.Visible = true;
                                    ShowStatus("Active transmission profile loaded. Adjust criteria and sync.", true);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error retrieving target record variables: " + ex.Message, false);
                        }
                    }
                }
            }
            else if (e.CommandName == "DeleteAnnouncement")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM AdminAnnouncement WHERE AnnouncementID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", announcementId);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            ShowStatus("Broadcast entry purged from live history registry logs.", true);
                            BindAnnouncementsGrid();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Purge operation failure: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ResetFormState();
        }

        private void ResetFormState()
        {
            txtTitle.Text = "";
            txtContent.Text = "";
            chkAdmin.Checked = false;
            chkLecturer.Checked = false;
            chkStudent.Checked = false;
            hfAnnouncementID.Value = "";
            btnPublish.Text = "Broadcast Announcement";
            btnCancelEdit.Visible = false;
            lblStatus.Visible = false;
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