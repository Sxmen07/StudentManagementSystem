<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LectProfile.aspx.cs" Inherits="LecturerPortal.Dashboard" %>

<!DOCTYPE html>
<html>
<head>
    <title>My Profile</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: Segoe UI, sans-serif; background: #f0f2f5; margin: 0; }
        .layout { display: flex; min-height: 100vh; }

        /* Sidebar */
        .sidebar { width: 200px; background: #fff; border-right: 1px solid #e8e8e8; padding: 20px 14px; display: flex; flex-direction: column; gap: 4px; }
        .sidebar-avatar { display: flex; align-items: center; gap: 10px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #f0f0f0; }
        .avatar-circle { width: 40px; height: 40px; border-radius: 50%; background: #dbeafe; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; color: #1d4ed8; flex-shrink: 0; }
        .sidebar-name { font-size: 13px; font-weight: 600; color: #1a1a1a; }
        .sidebar-role { font-size: 11px; color: #888; }
        .nav-item { display: flex; align-items: center; gap: 8px; padding: 9px 10px; border-radius: 8px; font-size: 13px; color: #555; cursor: pointer; text-decoration: none; }
        .nav-item:hover { background: #f5f5f5; }
        .nav-item.active { background: #f0f7ff; color: #1d4ed8; font-weight: 600; }
        .nav-icon { font-size: 16px; }

        /* Main */
        .main { flex: 1; padding: 32px 36px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .page-title { font-size: 22px; font-weight: 600; color: #1a1a1a; }
        .btn-row { display: flex; gap: 8px; }
        .btn { padding: 8px 18px; border-radius: 8px; font-size: 13px; cursor: pointer; border: 1px solid #d1d5db; background: #fff; color: #333; }
        .btn-primary { background: #1d4ed8; color: #fff; border-color: #1d4ed8; }
        .btn-primary:hover { background: #1e40af; }
        .btn-success { background: #16a34a; color: #fff; border-color: #16a34a; }
        .btn-success:hover { background: #15803d; }
        .btn:hover { background: #f5f5f5; }

        /* Profile Card */
        .profile-card { background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; padding: 24px; margin-bottom: 16px; }
        .card-label { font-size: 11px; font-weight: 600; color: #888; text-transform: uppercase; letter-spacing: .05em; margin-bottom: 16px; }
        .field-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .field-group { display: flex; flex-direction: column; gap: 5px; }
        .field-label { font-size: 12px; color: #666; }

        .field-view { font-size: 14px; color: #1a1a1a; padding: 8px 12px; background: #f8f9fa; border-radius: 7px; border: 1px solid transparent; min-height: 36px; }

        .field-input { font-size: 14px; color: #1a1a1a; padding: 8px 12px; background: #fff; border-radius: 7px; border: 1px solid #d1d5db; outline: none; width: 100%; }
        .field-input:focus { border-color: #1d4ed8; box-shadow: 0 0 0 3px rgba(29,78,216,.1); }
        .field-input[readonly] { background: #f8f9fa; border-color: transparent; color: #888; cursor: default; }

        .success-msg { color: #16a34a; font-size: 13px; margin-top: 10px; font-weight: 500; }
        .edit-notice { font-size: 12px; color: #888; padding: 8px 12px; background: #fffbeb; border: 1px solid #fcd34d; border-radius: 7px; margin-bottom: 16px; display: none; }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="layout">
            <div class="sidebar">
                <div class="sidebar-avatar">
                    <div class="avatar-circle" id="avatarInitials">DA</div>
                    <div>
                        <div class="sidebar-name">
                            <asp:Label ID="lblSidebarName" runat="server" />
                        </div>
                        <div class="sidebar-role">Lecturer</div>
                    </div>
                </div>

                <a href="Dashboard.aspx" class="nav-item active">My Profile</a>
                <a href="Attendance.aspx" class="nav-item">Attendance</a>
                <a href="Assessment.aspx" class="nav-item">Assessment</a>
                <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item">Academic Progress</a>
                <a href="LecturerPostAnnouncement.aspx" class="nav-item">Announcements</a>
                <a href="LecturerCourseMaterials.aspx" class="nav-item">Course Materials</a>
                <a href="Login.aspx" class="nav-item" style="margin-top:auto; color:#e74c3c;">Logout</a>
            </div>

            <div class="main">
                <div class="page-header">
                    <div class="page-title">My Profile</div>

                    <div class="btn-row">
                        <asp:Button ID="btnEdit" runat="server" Text="Edit Profile"
                            CssClass="btn btn-primary" OnClick="btnEdit_Click" />

                        <asp:Button ID="btnSave" runat="server" Text="Save Changes"
                            CssClass="btn btn-success" OnClick="btnSave_Click" Visible="false" />

                        <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                            CssClass="btn" OnClick="btnCancel_Click" Visible="false" />
                    </div>
                </div>

                <div id="editNotice" class="edit-notice">
                    <asp:Label ID="lblEditNotice" runat="server" />
                </div>

                <div class="profile-card">
                    <div class="card-label">Personal Information</div>

                    <div class="field-grid">
                        <div class="field-group">
                            <span class="field-label">Full Name</span>
                            <asp:TextBox ID="txtName" runat="server" CssClass="field-input" ReadOnly="true" />
                        </div>

                        <div class="field-group">
                            <span class="field-label">Email</span>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="field-input" ReadOnly="true" />
                        </div>

                        <div class="field-group">
                            <span class="field-label">Contact No</span>
                            <asp:TextBox ID="txtContact" runat="server" CssClass="field-input" ReadOnly="true" />
                        </div>

                        <div class="field-group">
                            <span class="field-label">Department</span>
                            <asp:TextBox ID="txtDepartment" runat="server" CssClass="field-input" ReadOnly="true" />
                        </div>
                    </div>
                </div>

                <div class="profile-card">
                    <div class="card-label">Security</div>

                    <div class="field-grid">
                        <div class="field-group">
                            <span class="field-label">New Password</span>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                                CssClass="field-input" placeholder="Leave blank to keep current"
                                ReadOnly="true" />
                        </div>
                    </div>
                </div>

                <asp:Label ID="lblStatus" runat="server" CssClass="success-msg" />
            </div>
        </div>
    </form>

    <script>
        window.onload = function () {
            var name = document.getElementById('<%= lblSidebarName.ClientID %>');

            if (name) {
                var parts = name.innerText.trim().split(' ');
                var initials = parts.map(function (p) {
                    return p[0];
                }).join('').substring(0, 2).toUpperCase();

                document.getElementById('avatarInitials').innerText = initials;
            }
        };
    </script>
</body>
</html>