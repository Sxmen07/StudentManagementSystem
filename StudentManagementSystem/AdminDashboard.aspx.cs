using System;

namespace StudentManagementSystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Prevent browser back-button caching for absolute security
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();

            // Session Verification Gate
            if (Session["UserRole"] == null)
            {
                Response.Redirect("Login.aspx");
            }
            else
            {
                string currentRole = Session["UserRole"].ToString();
                if (currentRole != "Admin")
                {
                    Response.Redirect("Login.aspx");
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        protected void btnCreateAccount_Click(object sender, EventArgs e)
        {
            // Ready for database insertion codes next session
        }
    }
}