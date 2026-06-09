<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerPostAnnouncement.aspx.cs" Inherits="LecturerPortal.LecturerPostAnnouncement" %>

<!DOCTYPE html>
<html>
<head>
    <title>Post Announcement</title>

    <style>
        * { box-sizing: border-box; }
        body { font-family: Segoe UI, sans-serif; background: #f0f2f5; margin: 0; }
        .layout { display: flex; min-height: 100vh; }

        .sidebar { width: 200px; background: #fff; border-right: 1px solid #e8e8e8; padding: 20px 14px; display: flex; flex-direction: column; gap: 4px; }
        .sidebar-avatar { display: flex; align-items: center; gap: 10px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #f0f0f0; }
        .avatar-circle { width: 40px; height: 40px; border-radius: 50%; background: #dbeafe; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; color: #1d4ed8; }
        .sidebar-name { font-size: 13px; font-weight: 600; color: #1a1a1a; }
        .sidebar-role { font-size: 11px; color: #888; }
        .nav-item { display: flex; align-items: center; gap: 8px; padding: 9px 10px; border-radius: 8px; font-size: 13px; color: #555; text-decoration: none; cursor: pointer; }
        .nav-item:hover { background: #f5f5f5; }
        .nav-item.active { background: #f0f7ff; color: #1d4ed8; font-weight: 600; }

        .main { flex: 1; padding: 32px 36px; }
        .page-title { font-size: 22px; font-weight: 600; color: #1a1a1a; margin-bottom: 6px; }
        .page-sub { font-size: 13px; color: #888; margin-bottom: 20px; }

        .form-card, .table-card { background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; margin-bottom: 16px; }
        .form-card { padding: 20px; }
        .form-layout { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }
        .field-group { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
        .field-label { font-size: 11px; font-weight: 600; color: #666; text-transform: uppercase; letter-spacing: .04em; }

        select, input[type=text], input[type=date], textarea {
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            font-size: 13px;
            color: #1a1a1a;
            background: #fff;
            width: 100%;
        }

        textarea {
            min-height: 170px;
            resize: vertical;
            font-family: Segoe UI, sans-serif;
        }

        select:focus, input:focus, textarea:focus { outline: none; border-color: #1d4ed8; }

        .upload-box { border: 1px dashed #d1d5db; border-radius: 12px; padding: 16px; background: #f8f9fa; margin-bottom: 14px; }
        .upload-title { font-size: 13px; font-weight: 600; margin-bottom: 6px; color: #333; }
        .upload-sub { font-size: 12px; color: #888; margin-bottom: 10px; }

        .btn-post { padding: 9px 20px; background: #1d4ed8; color: #fff; border: none; border-radius: 7px; font-size: 13px; cursor: pointer; width: 100%; }
        .btn-post:hover { background: #1e40af; }

        .success-msg { color: #16a34a; font-size: 13px; font-weight: 500; }
        .error-msg { color: #dc2626; font-size: 13px; font-weight: 500; }

        table { width: 100%; border-collapse: collapse; min-width: 720px; }
        thead th { background: #f8f9fa; padding: 10px 14px; font-size: 11px; font-weight: 600; color: #555; text-transform: uppercase; border-bottom: 1px solid #e8e8e8; }
        tbody td { padding: 11px 14px; border-bottom: 1px solid #f5f5f5; font-size: 13px; color: #1a1a1a; vertical-align: middle; }
        tbody tr:hover td { background: #fafcff; }
        .table-card { overflow-x: auto; }
        .table-title { padding: 14px 18px; border-bottom: 1px solid #f0f0f0; font-weight: 600; font-size: 14px; }

        @media (max-width: 900px) {
            .form-layout { grid-template-columns: 1fr; }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">
    <div class="layout">
        <div class="sidebar">
            <div class="sidebar-avatar">
                <div class="avatar-circle">DA</div>
                <div>
                    <div class="sidebar-name"><asp:Label ID="lblSidebarName" runat="server" /></div>
                    <div class="sidebar-role">Lecturer</div>
                </div>
            </div>

            <a href="LectProfile.aspx" class="nav-item">My Profile</a>
            <a href="Attendance.aspx" class="nav-item">Attendance</a>
            <a href="Assessment.aspx" class="nav-item">Assessment</a>
            <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item">Academic Progress</a>
            <a href="LecturerPostAnnouncement.aspx" class="nav-item active">Announcements</a>
            <a href="Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">Logout</a>
        </div>

        <div class="main">
            <div class="page-title">Post Announcement</div>
            <div class="page-sub">Post announcements for the selected course.</div>

            <div class="form-card">
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
                            <div class="upload-title">Upload Attachment</div>
                            <div class="upload-sub">Not saved by current Announcement table.</div>
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
                                <asp:ListItem Text="All Students In Course" Value="CourseOfferID" />
                                <asp:ListItem Text="All Students" Value="All" />
                            </asp:DropDownList>
                        </div>

                        <asp:Panel ID="pnlStudentSelect" runat="server" Visible="false">
                            <div class="field-group">
                                <span class="field-label">Select Student</span>
                                <asp:DropDownList ID="ddlStudents" runat="server" />
                            </div>
                        </asp:Panel>

                        <asp:Button ID="btnPost" runat="server" Text="Post Announcement"
                            CssClass="btn-post" OnClick="btnPost_Click" />

                        <div style="margin-top:12px;">
                            <asp:Label ID="lblStatus" runat="server" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="table-card">
                <div class="table-title">Recent Announcements</div>

                <asp:GridView ID="gvAnnouncements" runat="server"
                    AutoGenerateColumns="false"
                    GridLines="None"
                    EmptyDataText="No announcements posted yet.">

                    <Columns>
                        <asp:BoundField DataField="Title" HeaderText="Title" />
                        <asp:BoundField DataField="Description" HeaderText="Message" />
                        <asp:BoundField DataField="TargetType" HeaderText="Target Type" />
                        <asp:BoundField DataField="CreatedDate" HeaderText="Posted At" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</form>
</body>
</html>