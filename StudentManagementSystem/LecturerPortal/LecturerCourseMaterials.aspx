<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerCourseMaterials.aspx.cs"
    Inherits="LecturerPortal.LecturerCourseMaterials" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Course Materials</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: "Segoe UI", sans-serif;
            background: linear-gradient(135deg, #eef7ff, #f8fbff);
            margin: 0;
            color: #1f2937;
        }
        .layout { display: flex; min-height: 100vh; }
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
        .avatar-circle:hover { transform: scale(1.05); }
        .avatar-circle img { width: 100%; height: 100%; object-fit: cover; }
        .sidebar-name { font-size: 14px; font-weight: 700; color: #111827; }
        .sidebar-role { font-size: 11px; color: #9ca3af; }
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
        .nav-item:hover { background: #f3f8ff; color: #1d4ed8; transform: translateX(3px); }
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
            from { opacity: 0; transform: translateY(12px); }
            to { opacity: 1; transform: translateY(0); }
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
        .welcome-small { font-size: 13px; opacity: 0.9; margin-bottom: 3px; }
        .welcome-name { font-size: 24px; font-weight: 800; }
        .welcome-pill {
            background: rgba(255,255,255,0.22);
            padding: 8px 14px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
        }
        .page-title { font-size: 26px; font-weight: 700; color: #111827; margin-bottom: 5px; }
        .page-sub { font-size: 13px; color: #6b7280; margin-bottom: 22px; }

        /* Filter card (like Assessment) */
        .filter-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 22px;
            margin-bottom: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }
        .filter-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            align-items: end;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }
        .filter-label {
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
        select:focus, input:focus, textarea:focus {
            border-color: #00CBD4;
            box-shadow: 0 0 0 3px rgba(0,203,212,0.15);
            background: white;
        }
        .btn {
            padding: 11px 20px;
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
            transition: 0.2s ease;
            text-align: center;
            box-shadow: 0 8px 18px rgba(14,165,233,0.20);
        }
        .btn-blue {
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
        }
        .btn-blue:hover {
            background: linear-gradient(135deg, #0ea5e9, #115FB3);
            transform: translateY(-1px);
        }
        .btn-green {
            background: #16a34a;
        }
        .btn-green:hover {
            background: #15803d;
            transform: translateY(-1px);
        }

        /* Two-column layout */
        .material-layout {
            display: grid;
            grid-template-columns: 1fr 1.5fr;
            gap: 20px;
            align-items: start;
        }
        .post-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }
        .post-card .section-title {
            font-size: 15px;
            font-weight: 800;
            color: #111827;
            margin-bottom: 16px;
        }
        .post-card .field-group {
            display: flex;
            flex-direction: column;
            gap: 7px;
            margin-bottom: 14px;
        }
        .post-card .field-label {
            font-size: 11px;
            font-weight: 700;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }
        .post-card textarea {
            min-height: 100px;
            resize: vertical;
        }
        .upload-area {
            border: 1px dashed #cbd5e1;
            border-radius: 16px;
            padding: 16px;
            background: linear-gradient(135deg,#f8fbff,#ecfeff);
            margin-bottom: 14px;
        }
        .upload-title {
            font-size: 13px;
            font-weight: 800;
            color: #111827;
            margin-bottom: 6px;
        }
        .upload-sub {
            font-size: 12px;
            color: #6b7280;
            margin-bottom: 10px;
        }
        .button-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 18px;
        }
        .button-row .btn {
            width: 100%;
            padding: 12px;
            font-size: 14px;
        }
        .btn-cancel {
            background: #64748b;
        }
        .btn-cancel:hover {
            background: #475569;
        }
        .status-area {
            margin-top: 14px;
            min-height: 20px;
        }

        /* Right panel: material list */
        .list-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 0;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }
        .list-header {
            padding: 18px 22px;
            border-bottom: 1px solid #eef2f7;
            font-weight: 800;
            font-size: 15px;
            color: #111827;
            background: #fbfdff;
        }
        .material-card {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 22px;
            border-bottom: 1px solid #f1f5f9;
            transition: 0.2s ease;
        }
        .material-card:last-child { border-bottom: none; }
        .material-card:hover { background: #f8fbff; }
        .file-icon {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            background: #ecfeff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }
        .material-body {
            flex: 1;
            margin-left: 14px;
        }
        .material-title {
            font-weight: 700;
            color: #111827;
            font-size: 14px;
        }
        .material-desc {
            font-size: 13px;
            color: #4b5563;
            margin: 4px 0;
        }
        .material-meta {
            font-size: 11px;
            color: #6b7280;
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
        }
        .material-meta .badge {
            background: #ecfeff;
            color: #0284c7;
            padding: 2px 10px;
            border-radius: 999px;
            font-weight: 700;
        }
        .material-actions {
            display: flex;
            gap: 8px;
            flex-shrink: 0;
        }
        .open-btn {
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            color: white;
            text-decoration: none;
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 800;
            border: none;
            cursor: pointer;
            transition: 0.2s ease;
        }
        .open-btn:hover {
            background: linear-gradient(135deg, #0ea5e9, #115FB3);
            transform: translateY(-1px);
        }
        .edit-btn { background: #111827; }
        .edit-btn:hover { background: #374151; }
        .delete-btn { background: #dc2626; }
        .delete-btn:hover { background: #b91c1c; }

        .no-data {
            padding: 30px;
            text-align: center;
            color: #9ca3af;
        }
        .success-msg { color: #16a34a; font-size: 13px; font-weight: 600; }
        .error-msg { color: #dc2626; font-size: 13px; font-weight: 600; }

        @media (max-width: 1100px) {
            .material-layout {
                grid-template-columns: 1fr;
            }
        }
        @media (max-width: 900px) {
            .main { padding: 24px 18px; }
            .sidebar { width: 200px; }
            .welcome-card { flex-direction: column; align-items: flex-start; gap: 12px; }
        }
        @media (max-width: 600px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; height: auto; position: relative; }
            .filter-row { grid-template-columns: 1fr; }
            .material-card { flex-direction: column; align-items: flex-start; gap: 12px; }
            .material-actions { width: 100%; }
            .button-row { grid-template-columns: 1fr; }
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
                <div class="sidebar-name"><asp:Label ID="lblSidebarName" runat="server" /></div>
                <div class="sidebar-role">Lecturer</div>
            </div>
        </div>
        <a href="LectDashboard.aspx" class="nav-item">🏠 Dashboard</a>
        <a href="Attendance.aspx" class="nav-item">📝 Attendance</a>
        <a href="Assessment.aspx" class="nav-item">📊 Assessment</a>
        <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item">🎓 Academic Progress</a>
        <a href="LecturerPostAnnouncement.aspx" class="nav-item">📢 Announcements</a>
        <a href="LecturerCourseMaterials.aspx" class="nav-item active">📁 Course Materials</a>
        <a href="../Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">🚪 Logout</a>
    </div>

    <div class="main">

        <div class="welcome-card">
            <div>
                <div class="welcome-small">Welcome back</div>
                <div class="welcome-name"><asp:Label ID="lblWelcomeName" runat="server" Text="Lecturer" /></div>
            </div>
            <div class="welcome-pill">📁 Course Materials</div>
        </div>

        <div class="page-title">Course Materials</div>
        <div class="page-sub">Select a course to upload, schedule, and manage learning materials.</div>

        <!-- Filter Card -->
        <div class="filter-card">
            <div class="section-title" style="font-size:15px;font-weight:800;color:#111827;margin-bottom:16px;">Select Course</div>
            <div class="filter-row">
                <div class="filter-group">
                    <span class="filter-label">Programme</span>
                    <asp:DropDownList ID="ddlProgramme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_Changed" />
                </div>
                <div class="filter-group">
                    <span class="filter-label">Course Offer</span>
                    <asp:DropDownList ID="ddlCourseOffer" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourseOffer_Changed" />
                </div>
                <div class="filter-group">
                    <asp:Button ID="btnLoad" runat="server" Text="Load Materials" CssClass="btn btn-blue" OnClick="btnLoad_Click" />
                </div>
            </div>
        </div>

        <!-- Content Panel: Hidden until a course is loaded -->
        <asp:Panel ID="pnlCourseContent" runat="server" Visible="false">
            <div class="material-layout">

                <!-- Left: Post / Edit Material -->
                <div class="post-card">
                    <div class="section-title">📝 Post / Edit Material</div>

                    <asp:HiddenField ID="hfSelectedCourseOfferID" runat="server" Value="0" />
                    <asp:HiddenField ID="hfEditingMaterialID" runat="server" Value="0" />

                    <div class="field-group">
                        <span class="field-label">Material Title</span>
                        <asp:TextBox ID="txtTitle" runat="server" placeholder="Example: Week 3 Lecture Notes" />
                    </div>

                    <div class="field-group">
                        <span class="field-label">Description</span>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" placeholder="Write a short description for students..." />
                    </div>

                    <div class="field-group">
                        <span class="field-label">Category</span>
                        <asp:DropDownList ID="ddlCategory" runat="server">
                            <asp:ListItem Text="Lecturers" Value="Lecturers" />
                            <asp:ListItem Text="Assignments" Value="Assignments" />
                            <asp:ListItem Text="Tutorials" Value="Tutorials" />
                        </asp:DropDownList>
                    </div>

                    <div class="upload-area">
                        <div class="upload-title">📎 Attach File</div>
                        <div class="upload-sub">Optional. You can post material even without uploading a file.</div>
                        <asp:FileUpload ID="fileUpload" runat="server" />
                    </div>

                    <div class="field-group">
                        <span class="field-label">Schedule Date</span>
                        <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
                    </div>

                    <div class="button-row">
                        <asp:Button ID="btnPost" runat="server" Text="Post Material" CssClass="btn" OnClick="btnPost_Click" />
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-cancel" OnClick="btnCancelEdit_Click" CausesValidation="false" />
                    </div>

                    <div class="status-area">
                        <asp:Label ID="lblStatus" runat="server" />
                    </div>
                </div>

                <!-- Right: Material List -->
                <div class="list-card">
                    <div class="list-header">📋 Materials for this Course</div>
                    <asp:Repeater ID="rptMaterials" runat="server" OnItemCommand="rptMaterials_ItemCommand">
                        <ItemTemplate>
                            <div class="material-card">
                                <div class="file-icon">📄</div>
                                <div class="material-body">
                                    <div class="material-title"><%# Eval("MaterialTitle") %></div>
                                    <div class="material-desc"><%# Eval("Description") %></div>
                                    <div class="material-meta">
                                        <span class="badge">📅 <%# Eval("ScheduleDate", "{0:yyyy-MM-dd}") %></span>
                                        <span class="badge">📂 <%# Eval("MaterialCategory") %></span>
                                        <span>Uploaded: <%# Eval("UploadDate", "{0:yyyy-MM-dd HH:mm}") %></span>
                                    </div>
                                </div>
                                <div class="material-actions">
                                    <asp:HyperLink ID="lnkOpen" runat="server" CssClass="open-btn"
                                        NavigateUrl='<%# ResolveUrl(Eval("FileURL").ToString()) %>'
                                        Visible='<%# !string.IsNullOrEmpty(Eval("FileURL").ToString()) %>'
                                        Text="Open" Target="_blank" />
                                    <asp:LinkButton ID="btnEditMaterial" runat="server" CssClass="open-btn edit-btn"
                                        CommandName="EditMaterial" CommandArgument='<%# Eval("MaterialID") %>'>Edit</asp:LinkButton>
                                    <asp:LinkButton ID="btnDeleteMaterial" runat="server" CssClass="open-btn delete-btn"
                                        CommandName="DeleteMaterial" CommandArgument='<%# Eval("MaterialID") %>'
                                        OnClientClick="return confirm('Delete this material?');">Delete</asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:PlaceHolder ID="phEmpty" runat="server" Visible='<%# ((Repeater)Container.NamingContainer).Items.Count == 0 %>'>
                                <div class="no-data">No materials for this course yet.</div>
                            </asp:PlaceHolder>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>

            </div>
        </asp:Panel>

    </div>
</div>
</form>
</body>
</html>