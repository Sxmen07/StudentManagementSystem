using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageAnnouncements : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

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
                string query = @"
                    SELECT a.AnnouncementID, a.Title, a.ContentText, a.TargetAdmin, a.TargetLecturer, a.TargetStudent, a.CreatedDate, a.SenderAdminID, h.HopName, h.ProfilePictureUrl 
                    FROM AdminAnnouncement a
                    LEFT JOIN HeadofProgramme h ON a.SenderAdminID = h.HopID
                    ORDER BY a.CreatedDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            rptAnnouncements.DataSource = dt;
                            rptAnnouncements.DataBind();
                        }
                        catch (Exception ex)
                        {
                            ShowStatus("Error connecting to announcement registry tracks: " + ex.Message, false);
                        }
                    }
                }
            }
        }

        protected void lnkOpenModal_Click(object sender, EventArgs e)
        {
            ResetFormState();
            litModalHeader.Text = "Compose Broadcast Notice";
            btnPublish.Text = "Broadcast Announcement";
            pnlModalContainer.Visible = true;
        }

        protected void lnkCloseModal_Click(object sender, EventArgs e)
        {
            ResetFormState();
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
                pnlModalContainer.Visible = true;
                return;
            }

            if (!tAdmin && !tLecturer && !tStudent)
            {
                ShowStatus("Routing constraint error: Please assign at least one target audience layer for transmission.", false);
                pnlModalContainer.Visible = true;
                return;
            }

            bool isUpdate = (btnPublish.Text == "Update Announcement");
            int activeAdminID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = isUpdate
                    ? "UPDATE AdminAnnouncement SET Title = @Title, ContentText = @Content, TargetAdmin = @TAdmin, TargetLecturer = @TLecturer, TargetStudent = @TStudent WHERE AnnouncementID = @ID"
                    : "INSERT INTO AdminAnnouncement (Title, ContentText, TargetAdmin, TargetLecturer, TargetStudent, SenderAdminID) VALUES (@Title, @Content, @TAdmin, @TLecturer, @TStudent, @SenderID)";

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
                    else
                    {
                        cmd.Parameters.AddWithValue("@SenderID", activeAdminID);
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
                        pnlModalContainer.Visible = true;
                    }
                }
            }
        }

        protected void rptAnnouncements_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int announcementId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Edit")
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
                                    litModalHeader.Text = "Modify Announcement Broadcast Options";
                                    btnPublish.Text = "Update Announcement";

                                    pnlModalContainer.Visible = true;
                                    lblStatus.Visible = false;
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
            else if (e.CommandName == "Delete")
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
                            ResetFormState();
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

        protected void rptAnnouncements_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                if (row != null && row["SenderAdminID"] != DBNull.Value)
                {
                    int recordSenderID = Convert.ToInt32(row["SenderAdminID"]);
                    int loggedInUserID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;

                    PlaceHolder phControls = (PlaceHolder)e.Item.FindControl("phAuthorControls");
                    if (phControls != null)
                    {
                        phControls.Visible = (loggedInUserID == recordSenderID);
                    }
                }
                else
                {
                    PlaceHolder phControls = (PlaceHolder)e.Item.FindControl("phAuthorControls");
                    if (phControls != null) phControls.Visible = false;
                }
            }
        }

        private void ResetFormState()
        {
            txtTitle.Text = "";
            txtContent.Text = "";
            chkAdmin.Checked = false;
            chkLecturer.Checked = false;
            chkStudent.Checked = false;
            hfAnnouncementID.Value = "";
            pnlModalContainer.Visible = false;
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