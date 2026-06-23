using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    [Serializable]
    public class CalendarEventItem
    {
        public int EventID { get; set; }
        public string EventName { get; set; }
        public string HexColor { get; set; }
        public string TargetRole { get; set; }
    }

    public partial class ManageCalendar : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["StudentManagementSystemDB"].ConnectionString;

        private DateTime BrowsingMonthYear
        {
            get { return ViewState["BrowsingMonthYear"] != null ? (DateTime)ViewState["BrowsingMonthYear"] : new DateTime(2026, 4, 1); }
            set { ViewState["BrowsingMonthYear"] = value; }
        }

        // FIXED: Restored 'object sender' types to fix compilation faults
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindSemesterDropdown();
                if (ddlSemesterFilter.Items.Count > 1)
                {
                    ddlSemesterFilter.SelectedIndex = 1;
                    AutoAlignCalendarToSemesterStart();
                }
                RenderCalendarGridStructure();
            }
        }

        private void BindSemesterDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT SemesterID, (Semester + ' - ' + StartMonthDay) AS SemesterName FROM Semester ORDER BY SemesterID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        ddlSemesterFilter.DataSource = cmd.ExecuteReader();
                        ddlSemesterFilter.DataValueField = "SemesterID";
                        ddlSemesterFilter.DataTextField = "SemesterName";
                        ddlSemesterFilter.DataBind();
                    }
                    catch (Exception ex) { ShowStatus("Database communication error: " + ex.Message, false); }
                }
            }
            ddlSemesterFilter.Items.Insert(0, new ListItem("-- Filter Global Term Framework --", ""));
        }

        private void AutoAlignCalendarToSemesterStart()
        {
            if (ddlSemesterFilter.SelectedIndex == 0) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT StartMonthDay FROM Semester WHERE SemesterID = @SemID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SemID", ddlSemesterFilter.SelectedValue);
                    try
                    {
                        conn.Open();
                        string startMD = Convert.ToString(cmd.ExecuteScalar());
                        if (!string.IsNullOrEmpty(startMD) && startMD.Contains("-"))
                        {
                            string[] elements = startMD.Split('-');
                            int month = Convert.ToInt32(elements[0]);
                            BrowsingMonthYear = new DateTime(2026, month, 1);
                        }
                    }
                    catch { }
                }
            }
        }

        private void RenderCalendarGridStructure()
        {
            DateTime currentFocus = BrowsingMonthYear;
            litCurrentMonthYear.Text = currentFocus.ToString("MMMM yyyy");

            DateTime firstDayOfMonth = new DateTime(currentFocus.Year, currentFocus.Month, 1);
            int leadingPaddingOffset = (int)firstDayOfMonth.DayOfWeek;
            int daysInCurrentMonth = DateTime.DaysInMonth(currentFocus.Year, currentFocus.Month);

            DataTable dtEventsCache = PullTermCalendarCacheDataset();
            DataTable dtCalendarCells = new DataTable();

            dtCalendarCells.Columns.Add("DayNumber", typeof(string));
            dtCalendarCells.Columns.Add("FullDateString", typeof(string));
            dtCalendarCells.Columns.Add("IsCurrentMonth", typeof(bool));
            dtCalendarCells.Columns.Add("IsToday", typeof(bool));
            dtCalendarCells.Columns.Add("CellEventsList", typeof(List<CalendarEventItem>));

            DateTime precedingMonthFocus = firstDayOfMonth.AddMonths(-1);
            int totalDaysInPrecedingMonth = DateTime.DaysInMonth(precedingMonthFocus.Year, precedingMonthFocus.Month);
            for (int i = leadingPaddingOffset - 1; i >= 0; i--)
            {
                DataRow padRow = dtCalendarCells.NewRow();
                padRow["DayNumber"] = (totalDaysInPrecedingMonth - i).ToString();
                padRow["FullDateString"] = "";
                padRow["IsCurrentMonth"] = false;
                padRow["IsToday"] = false;
                padRow["CellEventsList"] = new List<CalendarEventItem>();
                dtCalendarCells.Rows.Add(padRow);
            }

            DateTime todayStamp = DateTime.Today;
            for (int day = 1; day <= daysInCurrentMonth; day++)
            {
                DateTime iteratedDate = new DateTime(currentFocus.Year, currentFocus.Month, day);
                DataRow cellRow = dtCalendarCells.NewRow();

                string formattedDateString = iteratedDate.ToString("yyyy-MM-dd");
                cellRow["DayNumber"] = day.ToString();
                cellRow["FullDateString"] = formattedDateString;
                cellRow["IsCurrentMonth"] = true;
                cellRow["IsToday"] = (iteratedDate == todayStamp);

                List<CalendarEventItem> matchEvents = new List<CalendarEventItem>();
                DataRow[] cacheRows = dtEventsCache.Select($"EventDate = '{formattedDateString}'");
                foreach (DataRow r in cacheRows)
                {
                    matchEvents.Add(new CalendarEventItem
                    {
                        EventID = Convert.ToInt32(r["EventID"]),
                        EventName = r["EventName"].ToString(),
                        HexColor = r["HexColor"].ToString(),
                        TargetRole = r["TargetRole"].ToString()
                    });
                }
                cellRow["CellEventsList"] = matchEvents;
                dtCalendarCells.Rows.Add(cellRow);
            }

            rptCalendarCells.DataSource = dtCalendarCells;
            rptCalendarCells.DataBind();
        }

        private DataTable PullTermCalendarCacheDataset()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT EventID, EventName, HexColor, TargetRole, CONVERT(VARCHAR(10), EventDate, 120) AS EventDate FROM AcademicCalendar";
                if (ddlSemesterFilter.SelectedIndex > 0) query += " WHERE SemesterID = @SemID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (ddlSemesterFilter.SelectedIndex > 0) cmd.Parameters.AddWithValue("@SemID", ddlSemesterFilter.SelectedValue);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) { da.Fill(dt); }
                }
            }
            return dt;
        }

        // FIXED: Restored 'object sender' signatures
        protected void btnPrevMonth_Click(object sender, EventArgs e) { BrowsingMonthYear = BrowsingMonthYear.AddMonths(-1); RenderCalendarGridStructure(); }
        protected void btnNextMonth_Click(object sender, EventArgs e) { BrowsingMonthYear = BrowsingMonthYear.AddMonths(1); RenderCalendarGridStructure(); }

        protected void ddlSemesterFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            AutoAlignCalendarToSemesterStart();
            RenderCalendarGridStructure();
            ResetPlanningFormState();
        }

        protected void rptCalendarCells_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectDay")
            {
                string targetDate = e.CommandArgument.ToString();
                if (string.IsNullOrEmpty(targetDate)) return;

                txtStartDate.Text = targetDate;
                txtEndDate.Text = "";

                hfActiveEventID.Value = "";
                txtEventName.Text = "";
                txtDescription.Text = "";
                ddlColorType.SelectedIndex = 0;
                ddlTargetRole.SelectedIndex = 0;

                btnSaveEvent.Text = "Commit Schedule";
                btnDeleteEvent.Text = "Delete Day Event";
                btnDeleteEvent.Visible = true;
                litFormActionTitle.Text = "Schedule Planning Console";

                BindDayAgendaFeed(targetDate);
            }
        }

        private void BindDayAgendaFeed(string dateString)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT EventID, EventName, HexColor, TargetRole FROM AcademicCalendar WHERE EventDate = @EvDate ORDER BY EventID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@EvDate", dateString);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) { da.Fill(dt); }
                }
            }
            rptDayAgenda.DataSource = dt;
            rptDayAgenda.DataBind();
        }

        protected void rptDayAgenda_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectEvent")
            {
                int eventId = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT EventID, EventName, EventDescription, HexColor, TargetRole, CONVERT(VARCHAR(10), EventDate, 120) AS EventDate FROM AcademicCalendar WHERE EventID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", eventId);
                        try
                        {
                            conn.Open();
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    hfActiveEventID.Value = reader["EventID"].ToString();
                                    txtEventName.Text = reader["EventName"].ToString();
                                    txtDescription.Text = reader["EventDescription"].ToString();
                                    ddlColorType.SelectedValue = reader["HexColor"].ToString();

                                    string tRole = reader["TargetRole"].ToString();
                                    if (ddlTargetRole.Items.FindByValue(tRole) != null) ddlTargetRole.SelectedValue = tRole;

                                    string dateString = reader["EventDate"].ToString();
                                    txtStartDate.Text = dateString;
                                    txtEndDate.Text = "";

                                    btnSaveEvent.Text = "Update Event Entries";
                                    btnDeleteEvent.Text = "Delete Day Event";
                                    btnDeleteEvent.Visible = true;
                                    litFormActionTitle.Text = "Modify Calendar Target Row";
                                }
                            }
                        }
                        catch (Exception ex) { ShowStatus("Query error: " + ex.Message, false); }
                    }
                }
            }
        }

        protected void btnSaveEvent_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtStartDate.Text))
            {
                ShowStatus("Validation error: Choose a start date first.", false);
                return;
            }

            string name = txtEventName.Text.Trim();
            if (string.IsNullOrWhiteSpace(name))
            {
                ShowStatus("Validation error: Title cannot be blank.", false);
                return;
            }

            if (ddlSemesterFilter.SelectedIndex == 0)
            {
                ShowStatus("Selection error: Please filter by active semester term first.", false);
                return;
            }

            int targetSemesterID = Convert.ToInt32(ddlSemesterFilter.SelectedValue);
            DateTime startDate = DateTime.Parse(txtStartDate.Text);
            DateTime endDate = string.IsNullOrEmpty(txtEndDate.Text) ? startDate : DateTime.Parse(txtEndDate.Text);

            if (endDate < startDate)
            {
                ShowStatus("Validation error: End date cannot be before start date.", false);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string boundsQuery = "SELECT StartMonthDay, EndMonthDay FROM Semester WHERE SemesterID = @SemID";
                using (SqlCommand cmd = new SqlCommand(boundsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@SemID", targetSemesterID);
                    try
                    {
                        conn.Open();
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                string startMD = r["StartMonthDay"].ToString();
                                string endMD = r["EndMonthDay"].ToString();

                                DateTime permittedStart = new DateTime(2026, Convert.ToInt32(startMD.Split('-')[0]), Convert.ToInt32(startMD.Split('-')[1]));
                                DateTime permittedEnd = new DateTime(2026, Convert.ToInt32(endMD.Split('-')[0]), Convert.ToInt32(endMD.Split('-')[1]));

                                if (startDate < permittedStart || endDate > permittedEnd)
                                {
                                    ShowStatus($"Scheduling Restriction Violation: Selected dates fall outside active term boundaries ({permittedStart:yyyy-MM-dd} to {permittedEnd:yyyy-MM-dd}).", false);
                                    return;
                                }
                            }
                        }
                    }
                    catch (Exception ex) { ShowStatus("Boundary check exception: " + ex.Message, false); return; }
                }
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    conn.Open();
                    bool isUpdate = !string.IsNullOrEmpty(hfActiveEventID.Value);

                    if (isUpdate)
                    {
                        string query = "UPDATE AcademicCalendar SET EventName = @Name, EventDescription = @Desc, HexColor = @Color, TargetRole = @TRole WHERE EventID = @ID";
                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@Name", name);
                            cmd.Parameters.AddWithValue("@Desc", txtDescription.Text.Trim());
                            cmd.Parameters.AddWithValue("@Color", ddlColorType.SelectedValue);
                            cmd.Parameters.AddWithValue("@TRole", ddlTargetRole.SelectedValue);
                            cmd.Parameters.AddWithValue("@ID", Convert.ToInt32(hfActiveEventID.Value));
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        string query = "INSERT INTO AcademicCalendar (EventName, EventDescription, EventDate, SemesterID, HexColor, TargetRole) VALUES (@Name, @Desc, @EvDate, @SemID, @Color, @TRole)";
                        for (DateTime date = startDate; date <= endDate; date = date.AddDays(1))
                        {
                            using (SqlCommand cmd = new SqlCommand(query, conn))
                            {
                                cmd.Parameters.AddWithValue("@Name", name);
                                cmd.Parameters.AddWithValue("@Desc", txtDescription.Text.Trim());
                                cmd.Parameters.AddWithValue("@EvDate", date.ToString("yyyy-MM-dd"));
                                cmd.Parameters.AddWithValue("@SemID", targetSemesterID);
                                cmd.Parameters.AddWithValue("@Color", ddlColorType.SelectedValue);
                                cmd.Parameters.AddWithValue("@TRole", ddlTargetRole.SelectedValue);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }

                    ShowStatus("Schedule parameters committed successfully!", true);
                    ResetPlanningFormState();
                    RenderCalendarGridStructure();
                }
                catch (Exception ex) { ShowStatus("Save failure: " + ex.Message, false); }
            }
        }

        // FIXED: Restored 'object sender' signatures
        protected void btnDeleteEvent_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtStartDate.Text)) return;

            DateTime startDate = DateTime.Parse(txtStartDate.Text);
            DateTime endDate = string.IsNullOrEmpty(txtEndDate.Text) ? startDate : DateTime.Parse(txtEndDate.Text);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = !string.IsNullOrEmpty(hfActiveEventID.Value)
                    ? "DELETE FROM AcademicCalendar WHERE EventID = @ID"
                    : "DELETE FROM AcademicCalendar WHERE EventDate BETWEEN @Start AND @End";

                if (ddlSemesterFilter.SelectedIndex > 0 && string.IsNullOrEmpty(hfActiveEventID.Value))
                    query += " AND SemesterID = @SemID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrEmpty(hfActiveEventID.Value))
                    {
                        cmd.Parameters.AddWithValue("@ID", Convert.ToInt32(hfActiveEventID.Value));
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Start", startDate.ToString("yyyy-MM-dd"));
                        cmd.Parameters.AddWithValue("@End", endDate.ToString("yyyy-MM-dd"));
                        if (ddlSemesterFilter.SelectedIndex > 0) cmd.Parameters.AddWithValue("@SemID", ddlSemesterFilter.SelectedValue);
                    }

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        ShowStatus("Scheduled event parameters wiped successfully!", true);
                        ResetPlanningFormState();
                        RenderCalendarGridStructure();
                    }
                    catch (Exception ex) { ShowStatus("Deletion error: " + ex.Message, false); }
                }
            }
        }

        private void ResetPlanningFormState()
        {
            hfActiveEventID.Value = "";
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            txtEventName.Text = "";
            txtDescription.Text = "";
            ddlColorType.SelectedIndex = 0;
            ddlTargetRole.SelectedIndex = 0;
            btnSaveEvent.Text = "Commit Schedule";
            btnDeleteEvent.Visible = false;
            rptDayAgenda.DataSource = null;
            rptDayAgenda.DataBind();
        }

        private void ShowStatus(string message, bool isSuccess)
        {
            lblStatus.Text = message;
            lblStatus.BackColor = isSuccess ? Color.FromArgb(240, 253, 244) : Color.FromArgb(254, 242, 242);
            lblStatus.ForeColor = isSuccess ? Color.MediumSeaGreen : Color.OrangeRed;
            lblStatus.Visible = true;
        }

        // FIXED: Restored 'object sender' signatures
        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            DataTable dt = PullExportData();
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Event Date,Target Level,Event Title,Description");

            foreach (DataRow row in dt.Rows)
            {
                sb.AppendLine($"{Convert.ToDateTime(row["Event Date"]):yyyy-MM-dd},[{row["Target Level"]}],\"{row["Event Title"]}\",\"{row["Description"]}\"");
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Academic_Calendar.csv");
            Response.ContentType = "text/csv";
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = PullExportData();
            GridView gv = new GridView { DataSource = dt };
            gv.DataBind();

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Academic_Calendar.xls");
            Response.ContentType = "application/ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter htw = new HtmlTextWriter(sw))
                {
                    gv.RenderControl(htw);
                    Response.Output.Write(sw.ToString());
                    Response.Flush();
                    Response.End();
                }
            }
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = PullExportData();
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Academic_Calendar_Report.html");
            Response.ContentType = "text/html";

            string activeTermLabel = ddlSemesterFilter.SelectedIndex > 0 ? ddlSemesterFilter.SelectedItem.Text : "All Semesters Framework";

            StringBuilder sb = new StringBuilder();
            sb.Append("<html><head><style>");
            sb.Append("body { font-family: Arial, sans-serif; padding: 30px; color: #333; max-width: 800px; margin: 0 auto; } ");
            sb.Append("h2 { font-size: 18px; font-weight: bold; margin-bottom: 4px; color: #111; text-transform: uppercase; letter-spacing: 0.5px; } ");
            sb.Append("p { font-size: 11px; color: #666; margin-top: 0; margin-bottom: 25px; } ");
            sb.Append("table { width: 100%; border-collapse: collapse; margin-top: 10px; } ");
            sb.Append("th { border-bottom: 2px solid #111; padding: 8px 10px; text-align: left; font-size: 11px; font-weight: bold; } ");
            sb.Append("td { border-bottom: 1px solid #e5e5e5; padding: 8px 10px; font-size: 11px; vertical-align: top; color: #222; } ");
            sb.Append(".date-col { width: 95px; font-weight: bold; color: #555; } ");
            sb.Append(".level-col { width: 100px; font-weight: bold; color: #3B82F6; } ");
            sb.Append(".title-col { width: 180px; font-weight: bold; } ");
            sb.Append("</style></head><body>");

            sb.Append("<h2>Academic Calendar Schedule Run</h2>");
            sb.Append($"<p>Institutional Schedule Records &bull; Scope Term: <b>{activeTermLabel}</b></p>");

            sb.Append("<table><thead><tr>");
            sb.Append("<th class='date-col'>Date</th>");
            sb.Append("<th class='level-col'>Target Level</th>");
            sb.Append("<th class='title-col'>Event Title</th>");
            sb.Append("<th>Description Guidelines</th>");
            sb.Append("</tr></thead><tbody>");

            foreach (DataRow row in dt.Rows)
            {
                sb.Append("<tr>");
                sb.Append($"<td class='date-col'>{Convert.ToDateTime(row["Event Date"]):yyyy-MM-dd}</td>");
                sb.Append($"<td class='level-col'>{row["Target Level"]}</td>");
                sb.Append($"<td class='title-col'>{row["Event Title"]}</td>");
                sb.Append($"<td>{row["Description"]}</td>");
                sb.Append("</tr>");
            }

            sb.Append("</tbody></table></body></html>");

            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        private DataTable PullExportData()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT EventDate, TargetRole, EventName, EventDescription FROM AcademicCalendar";
                if (ddlSemesterFilter.SelectedIndex > 0)
                {
                    query += " WHERE SemesterID = @SemID";
                }
                query += " ORDER BY EventDate ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (ddlSemesterFilter.SelectedIndex > 0)
                    {
                        cmd.Parameters.AddWithValue("@SemID", ddlSemesterFilter.SelectedValue);
                    }
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) { da.Fill(dt); }
                }
            }

            dt.Columns["EventDate"].ColumnName = "Event Date";
            dt.Columns["TargetRole"].ColumnName = "Target Level";
            dt.Columns["EventName"].ColumnName = "Event Title";
            dt.Columns["EventDescription"].ColumnName = "Description";

            return dt;
        }
    }
}