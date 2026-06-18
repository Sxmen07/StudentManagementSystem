<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LectProfile.aspx.cs" Inherits="LecturerPortal.LectProfile" %>

<!DOCTYPE html>
<html>
<head>
    <title>My Profile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        * { box-sizing: border-box; }

        body {
            font-family: "Segoe UI", sans-serif;
            background: linear-gradient(135deg, #eef7ff, #f8fbff);
            margin: 0;
            color: #1f2937;
        }

        .layout {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 220px;
            background: rgba(255,255,255,0.92);
            border-right: 1px solid #e5e7eb;
            padding: 22px 16px;
            display: flex;
            flex-direction: column;
            gap: 4px;
            box-shadow: 4px 0 18px rgba(0,0,0,0.03);
            position: sticky;
            top: 0;
            height: 100vh;
        }

        .sidebar-avatar {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
            padding-bottom: 18px;
            border-bottom: 1px solid #eef2f7;
        }

        .avatar-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: linear-gradient(135deg, #00CBD4, #1d4ed8);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 800;
            color: white;
            box-shadow: 0 8px 18px rgba(14,165,233,0.28);
            overflow: hidden;
            cursor: pointer;
            transition: 0.2s ease;
        }

        .avatar-circle:hover {
            transform: scale(1.05);
        }

        .avatar-circle img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .sidebar-name {
            font-size: 14px;
            font-weight: 700;
            color: #111827;
        }

        .sidebar-role {
            font-size: 11px;
            color: #9ca3af;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 9px;
            padding: 11px 12px;
            border-radius: 12px;
            font-size: 13px;
            color: #4b5563;
            text-decoration: none;
            cursor: pointer;
            margin-top: 6px;
            transition: 0.2s ease;
        }

        .nav-item:hover {
            background: #f3f8ff;
            color: #1d4ed8;
            transform: translateX(3px);
        }

        .main {
            flex: 1;
            padding: 36px 44px;
            animation: fadeUp 0.35s ease;
        }

        @keyframes fadeUp {
            from {
                opacity: 0;
                transform: translateY(12px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .profile-container {
            max-width: 850px;
            margin: 0 auto;
        }

        .welcome-card {
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            color: white;
            padding: 22px 24px;
            border-radius: 22px;
            margin-bottom: 24px;
            box-shadow: 0 14px 35px rgba(14,165,233,0.25);
        }

        .welcome-small {
            font-size: 13px;
            opacity: 0.9;
            margin-bottom: 3px;
        }

        .welcome-name {
            font-size: 24px;
            font-weight: 800;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 22px;
            gap: 12px;
            flex-wrap: wrap;
        }

        .page-title {
            font-size: 26px;
            font-weight: 700;
            color: #111827;
            margin-bottom: 5px;
        }

        .page-sub {
            font-size: 13px;
            color: #6b7280;
        }

        .profile-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
            transition: 0.2s ease;
        }

        .profile-card:hover {
            box-shadow: 0 18px 40px rgba(0,0,0,0.07);
        }

        .profile-hero {
            display: flex;
            gap: 20px;
            align-items: center;
        }

        .large-avatar {
            width: 86px;
            height: 86px;
            border-radius: 50%;
            background: linear-gradient(135deg, #00CBD4, #1d4ed8);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: 800;
            color: white;
            overflow: hidden;
            box-shadow: 0 12px 28px rgba(14,165,233,0.25);
            flex-shrink: 0;
        }

        .large-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .hero-details {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .hero-name {
            font-size: 22px;
            font-weight: 800;
            color: #111827;
        }

        .hero-dept {
            font-size: 13px;
            color: #6b7280;
        }

        .card-label {
            font-size: 15px;
            font-weight: 800;
            color: #111827;
            margin-bottom: 16px;
        }

        .field-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 16px;
        }

        .field-group {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .field-label {
            font-size: 11px;
            font-weight: 700;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }

        .field-input {
            padding: 10px 13px;
            border: 1px solid #dbe1ea;
            border-radius: 11px;
            font-size: 13px;
            background: #fbfdff;
            outline: none;
            transition: 0.2s ease;
            width: 100%;
        }

        .field-input[readonly] {
            background: #f8fbff;
            color: #4b5563;
        }

        .field-input:focus:not([readonly]) {
            border-color: #00CBD4;
            box-shadow: 0 0 0 3px rgba(0,203,212,0.15);
            background: white;
        }

        .btn-action {
            padding: 10px 16px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
            border: none;
            transition: 0.2s ease;
        }

        .btn-edit,
        .btn-save {
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            color: white;
            box-shadow: 0 8px 18px rgba(14,165,233,0.20);
        }

        .btn-edit:hover,
        .btn-save:hover {
            background: linear-gradient(135deg, #0ea5e9, #115FB3);
            transform: translateY(-1px);
        }

        .btn-cancel {
            background: #e5e7eb;
            color: #4b5563;
        }

        .btn-cancel:hover {
            background: #d1d5db;
        }

        .btn-delete {
            background: #dc2626;
            color: white;
            margin-top: 8px;
            padding: 8px 13px;
            font-size: 12px;
        }

        .btn-delete:hover {
            background: #b91c1c;
        }

        .success-msg {
            color: #16a34a;
            font-size: 13px;
            font-weight: 600;
        }

        .error-msg {
            color: #dc2626;
            font-size: 13px;
            font-weight: 600;
        }

        @media (max-width: 900px) {
            .main {
                padding: 24px 18px;
            }

            .sidebar {
                width: 200px;
            }
        }

        @media (max-width: 600px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }

            .profile-hero {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">
    <div class="layout">

        <div class="sidebar">
            <div class="sidebar-avatar">
                <a href="LectProfile.aspx" style="text-decoration:none;">
                    <div class="avatar-circle">
                        <asp:Image ID="imgProfile" runat="server" />
                        <asp:Literal ID="litInitials" runat="server" />
                    </div>
                </a>

                <div>
                    <div class="sidebar-name">
                        <asp:Label ID="lblSidebarName" runat="server" />
                    </div>
                    <div class="sidebar-role">Lecturer</div>
                </div>
            </div>

            <a href="LectDashboard.aspx" class="nav-item">🏠 Dashboard</a>
            <a href="Attendance.aspx" class="nav-item">📝 Attendance</a>
            <a href="Assessment.aspx" class="nav-item">📊 Assessment</a>
            <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item">🎓 Academic Progress</a>
            <a href="LecturerPostAnnouncement.aspx" class="nav-item">📢 Announcements</a>
            <a href="LecturerCourseMaterials.aspx" class="nav-item">📁 Course Materials</a>
            <a href="Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">🚪 Logout</a>
        </div>

        <div class="main">
            <div class="profile-container">

                <div class="welcome-card">
                    <div class="welcome-small">Welcome back</div>
                    <div class="welcome-name">
                        <asp:Label ID="lblWelcomeName" runat="server" />
                    </div>
                </div>

                <div class="page-header">
                    <div>
                        <div class="page-title">My Account Profile</div>
                        <div class="page-sub">View and update your lecturer account information.</div>
                    </div>

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

                            <asp:Button ID="btnDeletePhoto" runat="server"
                                Text="Delete Photo"
                                CssClass="btn-action btn-delete"
                                OnClick="btnDeletePhoto_Click"
                                OnClientClick="return confirm('Are you sure you want to delete your profile picture?');" />
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
                            <asp:TextBox ID="txtPassword" runat="server"
                                TextMode="Password"
                                CssClass="field-input"
                                placeholder="Leave blank to retain current"
                                ReadOnly="true" />
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