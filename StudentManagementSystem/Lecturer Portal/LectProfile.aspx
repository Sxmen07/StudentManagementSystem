<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LectProfile.aspx.cs" Inherits="LecturerPortal.Dashboard" %>

<!DOCTYPE html>
<html>
<head>
    <title>My Profile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; margin: 0; }
        
        .layout { display: flex; flex-direction: row; min-height: 100vh; }

        .sidebar { width: 240px; background: #fff; border-right: 1px solid #e8e8e8; padding: 24px 14px; display: flex; flex-direction: column; gap: 4px; flex-shrink: 0; }
        .sidebar-profile { display: flex; flex-direction: column; align-items: center; text-align: center; padding-bottom: 20px; margin-bottom: 20px; border-bottom: 1px solid #f0f0f0; gap: 10px; }
        .avatar-container { position: relative; width: 80px; height: 80px; }
        .avatar-circle { width: 80px; height: 80px; border-radius: 50%; background: #dbeafe; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: 600; color: #1d4ed8; overflow: hidden; border: 2px solid #1d4ed8; cursor: pointer; transition: transform 0.2s; }
        .avatar-circle:hover { transform: scale(1.04); box-shadow: 0 2px 8px rgba(29, 78, 216, 0.15); }
        .avatar-circle img { width: 100%; height: 100%; object-fit: cover; }
        .sidebar-name { font-size: 14px; font-weight: 600; color: #1a1a1a; margin-top: 4px; }
        .sidebar-role { font-size: 11px; color: #888; text-transform: uppercase; letter-spacing: 0.05em; }

        .nav-item { display: flex; align-items: center; gap: 8px; padding: 10px 12px; border-radius: 8px; font-size: 13px; color: #555; text-decoration: none; }
        .nav-item:hover { background: #f5f5f5; }
        .nav-item.active { background: #f0f7ff; color: #1d4ed8; font-weight: 600; }

        .main { flex: 1; padding: 32px 36px; min-width: 0; }
        .profile-container { max-width: 800px; margin: 0 auto; display: flex; flex-direction: column; gap: 24px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; }
        .page-title { font-size: 22px; font-weight: 600; color: #1a1a1a; margin: 0; }
        
        .btn-action { padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 500; cursor: pointer; border: none; }
        .btn-edit { background: #1d4ed8; color: #fff; }
        .btn-edit:hover { background: #1e40af; }
        .btn-save { background: #16a34a; color: #fff; margin-right: 8px; }
        .btn-save:hover { background: #15803d; }
        .btn-cancel { background: #e5e7eb; color: #4b5563; }
        .btn-cancel:hover { background: #d1d5db; }
        .btn-delete { background: #dc2626; color: #fff; margin-left: 12px; padding: 6px 12px; font-size: 12px; }
        .btn-delete:hover { background: #b91c1c; }

        .profile-card { background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; padding: 24px; }
        .card-label { font-size: 14px; font-weight: 600; color: #1a1a1a; margin-bottom: 16px; text-transform: uppercase; letter-spacing: 0.02em; border-bottom: 1px solid #f0f0f0; padding-bottom: 8px; }
        
        .profile-hero { display: flex; gap: 24px; align-items: center; }
        
        /* Updated large avatar layout styling to match sidebar look */
        .large-avatar { width: 80px; height: 80px; border-radius: 50%; background: #dbeafe; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: 600; color: #1d4ed8; overflow: hidden; border: 2px solid #1d4ed8; }
        .large-avatar img { width: 100%; height: 100%; object-fit: cover; }
        
        .hero-details { display: flex; flex-direction: column; gap: 4px; }
        .hero-name { font-size: 20px; font-weight: 600; color: #1a1a1a; }
        .hero-dept { font-size: 13px; color: #666; }

        .field-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
        .field-group { display: flex; flex-direction: column; gap: 6px; }
        .field-label { font-size: 11px; font-weight: 600; color: #666; text-transform: uppercase; letter-spacing: .04em; }
        .field-input { padding: 9px 12px; border: 1px solid #d1d5db; border-radius: 7px; font-size: 13px; color: #1a1a1a; background: #fff; width: 100%; }
        .field-input[readonly] { background: #f9fafb; color: #4b5563; border-color: #e5e7eb; }
        .field-input:focus:not([readonly]) { outline: none; border-color: #1d4ed8; }

        .success-msg { color: #16a34a; font-size: 13px; font-weight: 500; margin-top: 10px; display: block; }
        .error-msg { color: #dc2626; font-size: 13px; font-weight: 500; margin-top: 10px; display: block; }

        @media (max-width: 768px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; border-right: none; border-bottom: 1px solid #e8e8e8; padding: 16px; flex-direction: row; flex-wrap: wrap; }
            .sidebar-profile { width: 100%; border-bottom: 1px solid #f0f0f0; padding-bottom: 12px; }
            .main { padding: 20px 16px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="layout">
            <div class="sidebar">
                <div class="sidebar-profile">
                    <a href="LectProfile.aspx" style="text-decoration: none;">
                        <div class="avatar-container">
                            <div class="avatar-circle">
                                <asp:Image ID="imgProfile" runat="server" />
                                <asp:Literal ID="litInitials" runat="server" />
                            </div>
                        </div>
                    </a>
                    <div>
                        <div class="sidebar-name"><asp:Label ID="lblSidebarName" runat="server" /></div>
                        <div class="sidebar-role">Lecturer</div>
                    </div>
                </div>

                <a href="LectDashboard.aspx" class="nav-item">Dashboard</a>
                <a href="Attendance.aspx" class="nav-item">Attendance</a>
                <a href="Assessment.aspx" class="nav-item">Assessment</a>
                <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item">Academic Progress</a>
                <a href="LecturerPostAnnouncement.aspx" class="nav-item">Announcements</a>
                <a href="LecturerCourseMaterials.aspx" class="nav-item">Course Materials</a>
                <a href="Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">Logout</a>
            </div>

            <div class="main">
                <div class="profile-container">
                    <div class="page-header">
                        <h1 class="page-title">My Account Profile</h1>
                        <div>
                            <asp:Button ID="btnEdit" runat="server" Text="Edit Profile" CssClass="btn-action btn-edit" OnClick="btnEdit_Click" />
                            <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn-action btn-save" Visible="false" OnClick="btnSave_Click" />
                            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn-action btn-cancel" Visible="false" OnClick="btnCancel_Click" />
                        </div>
                    </div>

                    <div class="profile-card">
                        <div class="profile-hero">
                            <div class="large-avatar">
                                <asp:Image ID="imgMainProfile" runat="server" />
                                <asp:Literal ID="lblMainInitials" runat="server" />
                            </div>
                            <div class="hero-details">
                                <span class="hero-name"><%= txtName.Text %></span>
                                <span class="hero-dept"><%= txtDepartment.Text %> Department</span>
                                <div>
                                    <asp:Button ID="btnDeletePhoto" runat="server" Text="Delete Photo" CssClass="btn-action btn-delete" OnClick="btnDeletePhoto_Click" OnClientClick="return confirm('Are you sure you want to delete your profile picture?');" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="profile-card">
                        <div class="card-label">Personal Information</div>
                        <div class="field-grid">
                            <div class="field-group">
                                <span class="field-label">Full Name</span>
                                <asp:TextBox ID="txtName" runat="server" CssClass="field-input" ReadOnly="true" />
                            </div>
                            <div class="field-group">
                                <span class="field-label">Email Address</span>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="field-input" ReadOnly="true" />
                            </div>
                            <div class="field-group">
                                <span class="field-label">Contact Number</span>
                                <asp:TextBox ID="txtContact" runat="server" CssClass="field-input" ReadOnly="true" />
                            </div>
                            <div class="field-group">
                                <span class="field-label">Department</span>
                                <asp:TextBox ID="txtDepartment" runat="server" CssClass="field-input" ReadOnly="true" />
                            </div>
                        </div>

                        <asp:Panel ID="pnlPhotoUpload" runat="server" Visible="false">
                            <div class="field-group" style="margin-top:15px;">
                                <span class="field-label">Upload Profile Photo</span>
                                <asp:FileUpload ID="fuProfilePic" runat="server" />
                            </div>
                        </asp:Panel>
                    </div>

                    <div class="profile-card">
                        <div class="card-label">Security</div>
                        <div class="field-grid">
                            <div class="field-group">
                                <span class="field-label">New Password</span>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="field-input" placeholder="Leave blank to retain current" ReadOnly="true" />
                            </div>
                        </div>
                    </div>
                    <asp:Label ID="lblStatus" runat="server" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>