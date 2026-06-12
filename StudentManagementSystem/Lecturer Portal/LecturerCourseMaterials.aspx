<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerCourseMaterials.aspx.cs"
    Inherits="LecturerPortal.LecturerCourseMaterials" %>

<!DOCTYPE html>
<html>
<head>
    <title>Course Materials</title>

    <style>
        * { box-sizing: border-box; }
        body { font-family: Segoe UI, sans-serif; background: #f0f2f5; margin: 0; }

        .layout { display: flex; min-height: 100vh; }

        .sidebar {
            width: 200px;
            background: #fff;
            border-right: 1px solid #e8e8e8;
            padding: 20px 14px;
            display: flex;
            flex-direction: column;
        }

        .sidebar-avatar {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 1px solid #f0f0f0;
        }

        .sidebar-name {
            font-size: 13px;
            font-weight: 600;
            color: #1a1a1a;
        }

        .sidebar-role {
            font-size: 11px;
            color: #888;
        }

        .avatar-circle { 
            width: 40px;
            height: 40px; 
            border-radius: 50%; 
            background: #dbeafe; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 13px; 
            font-weight: 600; 
            color: #1d4ed8; 

        }

        .nav-item {
            padding: 9px 10px;
            border-radius: 8px;
            font-size: 13px;
            color: #555;
            text-decoration: none;
            margin-top: 4px;
        }

        .nav-item:hover { background: #f5f5f5; }
        .nav-item.active { background: #f0f7ff; color: #1d4ed8; font-weight: 600; }

        .main { flex: 1; padding: 32px 36px; }

        .page-title { font-size: 22px; font-weight: 600; }
        .page-sub { font-size: 13px; color: #888; margin-bottom: 18px; }

        .form-card, .table-card {
            background: #fff;
            border: 1px solid #e8e8e8;
            border-radius: 12px;
            padding: 18px;
            margin-bottom: 16px;
        }

        .field-group { margin-bottom: 12px; display: flex; flex-direction: column; gap: 6px; }

        .field-label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            color: #666;
        }

        select, input, textarea {
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            font-size: 13px;
        }

        textarea { min-height: 100px; }

        .btn {
            width: 100%;
            padding: 10px;
            background: #1d4ed8;
            color: white;
            border: none;
            border-radius: 7px;
            cursor: pointer;
        }

        .btn:hover { background: #1e40af; }


        .material-card {
            display: flex;
            align-items: center;
            justify-content: space-between;

            padding: 14px 16px;
            margin-bottom: 10px;

            border: 1px solid #e8e8e8;
            border-radius: 12px;
            background: #fff;

            transition: 0.2s ease;
        }

        .material-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(0,0,0,0.06);
            border-color: #dbeafe;
        }

        .file-icon {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            background: #eef2ff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }

        .material-body { flex: 1; margin-left: 12px; }

        .material-title {
            font-size: 14px;
            font-weight: 600;
            color: #111;
        }

        .material-desc {
            font-size: 12px;
            color: #666;
            margin-top: 3px;
        }

        .material-meta {
            margin-top: 6px;
            font-size: 11px;
            color: #888;
            display: flex;
            gap: 10px;
        }

        .badge {
            background: #eef2ff;
            color: #3730a3;
            padding: 3px 8px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
        }

        .open-btn {
            background: #1d4ed8;
            color: white;
            text-decoration: none;
            padding: 7px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
        }

        .open-btn:hover { background: #1e40af; }

        .table-title {
            font-weight: 600;
            margin-bottom: 12px;
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

        <a class="nav-item" href="LectProfile.aspx">My Profile</a>
        <a class="nav-item" href="Attendance.aspx">Attendance</a>
        <a class="nav-item" href="Assessment.aspx">Assessment</a>
        <a class="nav-item" href="LecturerMonitorAcademicProgress.aspx">Academic Progress</a>
        <a class="nav-item" href="LecturerPostAnnouncement.aspx">Announcements</a>
        <a class="nav-item active" href="LecturerCourseMaterials.aspx">Course Materialsss</a>
        <a class="nav-item" style="margin-top:auto; color:red;" href="Login.aspx">Logout</a>
    </div>

    <div class="main">

        <div class="page-title">Course Materials</div>
        <div class="page-sub">Select a course to manage materials</div>

        <!-- COURSE SELECT -->
        <div class="form-card">
            <div class="field-group">
                <div class="field-label">Select Course</div>
                <asp:DropDownList ID="ddlCourseFilter" runat="server"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlCourseFilter_SelectedIndexChanged" />
            </div>
        </div>

        <!-- CONTENT -->
        <asp:Panel ID="pnlCourseContent" runat="server" Visible="false">

            <!-- POST -->
            <div class="form-card">
                <div class="table-title">Post Material</div>

                <div class="field-group">
                    <div class="field-label">Title</div>
                    <asp:TextBox ID="txtTitle" runat="server" />
                </div>

                <div class="field-group">
                    <div class="field-label">Description</div>
                    <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" />
                </div>

                <div class="field-group">
                    <div class="field-label">Upload File</div>
                    <asp:FileUpload ID="fileUpload" runat="server" />
                </div>

                <div class="field-group">
                    <div class="field-label">Schedule Date</div>
                    <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
                </div>

                <asp:Button ID="btnPost" runat="server" Text="Post Material"
                    CssClass="btn" OnClick="btnPost_Click" />

                <div style="margin-top:10px;">
                    <asp:Label ID="lblStatus" runat="server" />
                </div>
            </div>

            <!-- HISTORY (MODERN CARDS) -->
            <div class="table-card">
                <div class="table-title">Material History</div>

                <asp:Repeater ID="rptMaterials" runat="server">

                    <ItemTemplate>

                        <div class="material-card">

                            <div class="file-icon">📄</div>

                            <div class="material-body">

                                <div class="material-title">
                                    <%# Eval("MaterialTitle") %>
                                </div>

                                <div class="material-desc">
                                    <%# Eval("Description") %>
                                </div>

                                <div class="material-meta">
                                    <span class="badge">
                                        📅 <%# Eval("ScheduleDate", "{0:yyyy-MM-dd}") %>
                                    </span>

                                    <span>
                                        Uploaded: <%# Eval("UploadDate", "{0:yyyy-MM-dd HH:mm}") %>
                                    </span>
                                </div>

                            </div>

                            <a class="open-btn"
                               href='<%# ResolveUrl(Eval("FileURL").ToString()) %>'
                               target="_blank">
                               Open
                            </a>

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