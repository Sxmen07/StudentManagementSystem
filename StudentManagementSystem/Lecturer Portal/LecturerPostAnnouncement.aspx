<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerPostAnnouncement.aspx.cs" Inherits="LecturerPortal.LecturerPostAnnouncement" %>

<!DOCTYPE html>
<html>
<head>
    <title>Announcements</title>

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

        .nav-item.active {
            background: linear-gradient(135deg, #eaf8ff, #f0fbff);
            color: #0284c7;
            font-weight: 700;
            box-shadow: inset 3px 0 0 #00CBD4;
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

        .welcome-card {
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            color: white;
            padding: 22px 24px;
            border-radius: 22px;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
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

        .welcome-pill {
            background: rgba(255,255,255,0.22);
            padding: 8px 14px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
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
            margin-bottom: 22px;
        }

        .menu-card, .form-card, .table-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            margin-bottom: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }

        .menu-card {
            padding: 46px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .menu-card::after {
            content: "";
            position: absolute;
            right: -45px;
            top: -45px;
            width: 140px;
            height: 140px;
            background: rgba(0,203,212,0.12);
            border-radius: 50%;
        }

        .menu-card h2 {
            margin: 0;
            font-size: 23px;
            color: #111827;
        }

        .menu-card p {
            color: #6b7280 !important;
            font-size: 13px;
        }

        .menu-buttons {
            display: flex;
            justify-content: center;
            gap: 18px;
            margin-top: 24px;
            flex-wrap: wrap;
        }

        .menu-btn {
            width: 235px;
            padding: 18px;
            border-radius: 16px;
            border: none;
            cursor: pointer;
            font-size: 15px;
            font-weight: 800;
            color: #fff;
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            transition: 0.2s ease;
            box-shadow: 0 8px 18px rgba(14,165,233,0.20);
        }

        .menu-btn:hover {
            background: linear-gradient(135deg, #0ea5e9, #115FB3);
            transform: translateY(-2px);
        }

        .back-btn {
            padding: 9px 15px;
            background: #64748b;
            color: #fff;
            border: none;
            border-radius: 11px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            margin-bottom: 14px;
            transition: 0.2s ease;
        }

        .back-btn:hover {
            background: #475569;
            transform: translateY(-1px);
        }

        .form-card {
            padding: 24px;
        }

        .form-layout {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }

        .section-title {
            font-size: 15px;
            font-weight: 800;
            color: #111827;
            margin-bottom: 16px;
        }

        .field-group {
            display: flex;
            flex-direction: column;
            gap: 7px;
            margin-bottom: 14px;
        }

        .field-label {
            font-size: 11px;
            font-weight: 700;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }

        select, input[type=text], input[type=date], textarea {
            padding: 10px 13px;
            border: 1px solid #dbe1ea;
            border-radius: 11px;
            font-size: 13px;
            color: #111827;
            background: #fbfdff;
            width: 100%;
            outline: none;
            transition: 0.2s ease;
        }

        textarea {
            min-height: 170px;
            resize: vertical;
            font-family: "Segoe UI", sans-serif;
        }

        select:focus, input:focus, textarea:focus {
            border-color: #00CBD4;
            box-shadow: 0 0 0 3px rgba(0,203,212,0.15);
            background: white;
        }

        .upload-box {
            border: 1px dashed #cbd5e1;
            border-radius: 16px;
            padding: 16px;
            background: #f8fbff;
            margin-bottom: 14px;
        }

        .upload-title {
            font-size: 13px;
            font-weight: 800;
            margin-bottom: 6px;
            color: #111827;
        }

        .upload-sub {
            font-size: 12px;
            color: #6b7280;
            margin-bottom: 10px;
        }

        .student-box {
            max-height: 190px;
            overflow-y: auto;
            border: 1px solid #dbe1ea;
            border-radius: 12px;
            padding: 10px;
            background: #fbfdff;
        }

        .student-box label {
            font-size: 13px;
            margin-left: 6px;
        }

        .select-all {
            font-size: 13px;
            margin-bottom: 8px;
            display: block;
        }

        .btn-post {
            padding: 12px 20px;
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
            width: 100%;
            transition: 0.2s ease;
            box-shadow: 0 8px 18px rgba(14,165,233,0.20);
        }

        .btn-post:hover {
            background: linear-gradient(135deg, #0ea5e9, #115FB3);
            transform: translateY(-1px);
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

        .table-card {
            overflow: hidden;
            width: 100%;
        }

        .table-title {
            padding: 16px 20px;
            border-bottom: 1px solid #eef2f7;
            font-weight: 800;
            font-size: 15px;
            color: #111827;
            background: #fbfdff;
        }

        .table-card table {
            width: 100%;
            table-layout: fixed;
            border-collapse: collapse;
        }

        .table-card th {
            background: #f8fbff;
            padding: 14px;
            font-size: 11px;
            font-weight: 800;
            color: #6b7280;
            text-transform: uppercase;
            border-bottom: 1px solid #e5e7eb;
            text-align: left;
        }

        .table-card td {
            padding: 14px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13px;
            color: #111827;
            vertical-align: top;
            text-align: left;
            word-wrap: break-word;
        }

        .table-card tr:hover td {
            background: #f8fbff;
        }

        @media (max-width: 900px) {
            .form-layout {
                grid-template-columns: 1fr;
            }

            .main {
                padding: 24px 18px;
            }

            .sidebar {
                width: 200px;
            }

            .welcome-card {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
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
        }

        .announcement-card {
            display: flex;
            gap: 14px;
            padding: 18px;
            margin: 16px;
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 18px;
            transition: 0.2s ease;
            position: relative;
            overflow: hidden;
        }

        .announcement-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 14px 32px rgba(0,0,0,0.07);
            border-color: #bfdbfe;
        }

        .announcement-icon {
            width: 48px;
            height: 48px;
            border-radius: 16px;
            background: #ecfeff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }

        .announcement-content {
            flex: 1;
        }

        .announcement-top {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: center;
            margin-bottom: 6px;
        }

        .announcement-title {
            font-size: 15px;
            font-weight: 800;
            color: #111827;
        }

        .announcement-message {
            font-size: 13px;
            color: #4b5563;
            line-height: 1.5;
            margin-bottom: 10px;
        }

        .announcement-meta {
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            font-size: 11px;
            color: #6b7280;
        }

        .announcement-badge {
            background: #eaf8ff;
            color: #0284c7;
            padding: 5px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 800;
        }

        .announcement-right {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 8px;
            flex-shrink: 0;
        }

        .sent-box {
            margin-top: 12px;
            background: #f8fbff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 10px 12px;
        }

        .sent-label {
            display: block;
            font-size: 10px;
            font-weight: 800;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            margin-bottom: 5px;
        }

        .sent-emails {
            font-size: 12px;
            color: #0284c7;
            font-weight: 700;
            word-break: break-word;
        }

        .open-file-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-top: 0;
            padding: 6px 10px;
            background: #ecfeff;
            color: #0284c7;
            border: 1px solid #bae6fd;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 800;
            text-decoration: none;
        }

        .open-file-btn:hover {
            background: #cffafe;
        }
    </style>
</head>

<body>
<form id="form1" runat="server" enctype="multipart/form-data">
    <div class="layout">

        <div class="sidebar">
             <div class="sidebar-avatar">
                 <a href="LectProfile.aspx" style="text-decoration:none;">
                     <div class="avatar-circle">
                         <asp:Image ID="imgSidebar" runat="server" />
                         <asp:Literal ID="litSideInitials" runat="server" />
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
            <a href="LecturerPostAnnouncement.aspx" class="nav-item active">📢 Announcements</a>
            <a href="LecturerCourseMaterials.aspx" class="nav-item">📁 Course Materials</a>
            <a href="Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">🚪 Logout</a>
        </div>

        <div class="main">

            <div class="welcome-card">
                <div>
                    <div class="welcome-small">Welcome back</div>
                    <div class="welcome-name">
                        <asp:Label ID="lblWelcomeName" runat="server" Text="Lecturer" />
                    </div>
                </div>
            </div>

            <div class="page-title">Announcements</div>
            <div class="page-sub">Create announcements for students or view recent posted updates.</div>

            <asp:Panel ID="pnlMenu" runat="server">
                <div class="menu-card">
                    <h2>📢 Announcement Page</h2>
                    <p>Choose whether you want to post a new announcement or view existing announcements.</p>

                    <div class="menu-buttons">
                        <asp:Button ID="btnShowPost" runat="server"
                            Text="Post Announcement"
                            CssClass="menu-btn"
                            OnClick="btnShowPost_Click" />

                        <asp:Button ID="btnShowView" runat="server"
                            Text="View Announcement"
                            CssClass="menu-btn"
                            OnClick="btnShowView_Click" />
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlPostAnnouncement" runat="server" Visible="false">
                <asp:Button ID="btnBackFromPost" runat="server"
                    Text="← Back"
                    CssClass="back-btn"
                    OnClick="btnBack_Click" />

                <div class="form-card">
                    <div class="section-title">Post New Announcement</div>

                    <div class="form-layout">
                        <div>
                            <div class="field-group">
                                <span class="field-label">Announcement Title</span>
                                <asp:TextBox ID="txtTitle" runat="server" placeholder="Enter announcement title" />
                            </div>

                            <div class="field-group">
                                <span class="field-label">Course Offer</span>
                                <asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" />
                            </div>

                            <div class="field-group">
                                <span class="field-label">Announcement Message</span>
                                <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine"
                                    placeholder="Write announcement here..." />
                            </div>

                            <div class="field-group">
                                <span class="field-label">Schedule Date</span>
                                <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
                            </div>
                        </div>

                        <div>
                            <div class="upload-box">
                                <div class="upload-title">📎 Upload Attachment</div>
                                <div class="upload-sub">Optional file attachment for this announcement.</div>
                                <asp:FileUpload ID="fileUpload" runat="server" />
                            </div>

                            <div class="field-group">
                                <span class="field-label">Announcement Type</span>
                                <asp:DropDownList ID="ddlType" runat="server">
                                    <asp:ListItem Text="General" Value="General" />
                                    <asp:ListItem Text="Attendance Alert" Value="Attendance Alert" />
                                    <asp:ListItem Text="Assignment Reminder" Value="Assignment Reminder" />
                                    <asp:ListItem Text="Exam Result" Value="Exam Result" />
                                </asp:DropDownList>
                            </div>

                            <div class="field-group">
                                <span class="field-label">Send To</span>
                                <asp:DropDownList ID="ddlSendOption" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlSendOption_SelectedIndexChanged">
                                    <asp:ListItem Text="All Students In Course" Value="CourseCode"/>
                                    <asp:ListItem Text="Selected Students In Course" Value="SelectedStudents" />
                                    <asp:ListItem Text="All Students" Value="ProgrammeCode" />
                                </asp:DropDownList>
                            </div>

                            <asp:Panel ID="pnlStudentSelect" runat="server" Visible="false">
                                <div class="field-group">
                                    <span class="field-label">Select Students</span>

                                    <asp:CheckBox ID="chkSelectAllStudents" runat="server"
                                        Text=" Select All"
                                        CssClass="select-all"
                                        AutoPostBack="true"
                                        OnCheckedChanged="chkSelectAllStudents_CheckedChanged" />

                                    <div class="student-box">
                                        <asp:CheckBoxList ID="cblStudents" runat="server" />
                                    </div>
                                </div>
                            </asp:Panel>

                            <asp:Button ID="btnPost" runat="server"
                                Text="Post Announcement"
                                CssClass="btn-post"
                                OnClick="btnPost_Click" />

                            <div style="margin-top:12px;">
                                <asp:Label ID="lblStatus" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlViewAnnouncement" runat="server" Visible="false">
                <asp:Button ID="btnBackFromView" runat="server"
                    Text="← Back"
                    CssClass="back-btn"
                    OnClick="btnBack_Click" />

                <div class="table-card">
                    <div class="table-title">Recent Announcements</div>

                    <asp:Repeater ID="rptAnnouncements" runat="server">
                        <ItemTemplate>
                            <div class="announcement-card">
                                <div class="announcement-icon">📢</div>

                                <div class="announcement-content">
                                    <div class="announcement-top">
                                        <div class="announcement-title">
                                            <%# Eval("Title") %>
                                        </div>

                                        <div class="announcement-right">
                                            <span class="announcement-badge">
                                                <%# Eval("TargetType") %>
                                            </span>

                                            <asp:PlaceHolder ID="phAttachment" runat="server"
                                                Visible='<%# !string.IsNullOrEmpty(Convert.ToString(Eval("AttachmentPath"))) %>'>

                                                <a href='<%# ResolveUrl(Convert.ToString(Eval("AttachmentPath"))) %>'
                                                   target="_blank"
                                                   class="open-file-btn">
                                                    📂 Open File
                                                </a>

                                            </asp:PlaceHolder>
                                        </div>
                                    </div>

                                    <div class="announcement-message">
                                        <%# Eval("Description") %>
                                    </div>
                                        <div class="announcement-meta">
                                            <span>🎯 Target: <%# Eval("TargetValue") %></span>
                                            <span>🕒 Posted: <%# Eval("CreatedDate", "{0:yyyy-MM-dd HH:mm}") %></span>
                                        </div>
                                            <asp:PlaceHolder ID="phSentTo" runat="server"
                                                Visible='<%# !string.IsNullOrWhiteSpace(Eval("SentTo").ToString()) %>'>

                                        <div class="sent-box">
                                            <span class="sent-label">Sent To</span>
                                            <div class="sent-emails">
                                                <%# Eval("SentTo") %>
                                            </div>
                                        </div>
                                    </asp:PlaceHolder>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

        </div>
    </div>
</form>
</body>
</html>