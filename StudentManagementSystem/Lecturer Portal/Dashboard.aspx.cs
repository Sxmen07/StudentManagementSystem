using System;
using System.Data;
using System.Data.SqlClient;

namespace LecturerPortal
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LecturerID"] == null) Response.Redirect("Login.aspx");

            lblWelcome.Text = Session["Username"]?.ToString();

            if (!IsPostBack) LoadProfile();
        }

        private void LoadProfile()
        {
            string query = "SELECT * FROM Lecturers WHERE LecturerID = @ID";
            SqlParameter[] p = { new SqlParameter("@ID", Session["LecturerID"]) };
            DataTable dt = DBHelper.ExecuteQuery(query, p);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                txtUsername.Text = row["Username"].ToString();
                txtEmail.Text = row["Email"].ToString();
                txtStaffID.Text = row["StaffID"].ToString();
                txtDepartment.Text = row["Department"].ToString();
                txtSchool.Text = row["School"].ToString();
                txtBio.Text = row["Bio"].ToString();
                txtOfficeLocation.Text = row["OfficeLocation"].ToString();
                txtOfficeRoom.Text = row["OfficeRoom"].ToString();
                txtConsultHours.Text = row["ConsultationHours"].ToString();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string query;
            SqlParameter[] parameters;

            if (!string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                query = @"UPDATE Lecturers SET 
                    Username=@Username, Email=@Email,
                    PasswordHash=CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', @Password), 2),
                    StaffID=@StaffID, Department=@Dept, School=@School,
                    Bio=@Bio, OfficeLocation=@OfficeLoc, OfficeRoom=@OfficeRoom,
                    ConsultationHours=@ConsultHours
                    WHERE LecturerID=@ID";

                parameters = new SqlParameter[] {
                    new SqlParameter("@Username", txtUsername.Text),
                    new SqlParameter("@Email", txtEmail.Text),
                    new SqlParameter("@Password", txtPassword.Text),
                    new SqlParameter("@StaffID", txtStaffID.Text),
                    new SqlParameter("@Dept", txtDepartment.Text),
                    new SqlParameter("@School", txtSchool.Text),
                    new SqlParameter("@Bio", txtBio.Text),
                    new SqlParameter("@OfficeLoc", txtOfficeLocation.Text),
                    new SqlParameter("@OfficeRoom", txtOfficeRoom.Text),
                    new SqlParameter("@ConsultHours", txtConsultHours.Text),
                    new SqlParameter("@ID", Session["LecturerID"])
                };
            }
            else
            {
                query = @"UPDATE Lecturers SET 
                    Username=@Username, Email=@Email,
                    StaffID=@StaffID, Department=@Dept, School=@School,
                    Bio=@Bio, OfficeLocation=@OfficeLoc, OfficeRoom=@OfficeRoom,
                    ConsultationHours=@ConsultHours
                    WHERE LecturerID=@ID";

                parameters = new SqlParameter[] {
                    new SqlParameter("@Username", txtUsername.Text),
                    new SqlParameter("@Email", txtEmail.Text),
                    new SqlParameter("@StaffID", txtStaffID.Text),
                    new SqlParameter("@Dept", txtDepartment.Text),
                    new SqlParameter("@School", txtSchool.Text),
                    new SqlParameter("@Bio", txtBio.Text),
                    new SqlParameter("@OfficeLoc", txtOfficeLocation.Text),
                    new SqlParameter("@OfficeRoom", txtOfficeRoom.Text),
                    new SqlParameter("@ConsultHours", txtConsultHours.Text),
                    new SqlParameter("@ID", Session["LecturerID"])
                };
            }

            DBHelper.ExecuteNonQuery(query, parameters);
            Session["Username"] = txtUsername.Text;
            lblStatus.Text = "✔ Profile updated successfully!";
        }
    }
}