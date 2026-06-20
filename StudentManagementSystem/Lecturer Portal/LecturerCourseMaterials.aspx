<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerCourseMaterials.aspx.cs"
    Inherits="LecturerPortal.LecturerCourseMaterials" %>

<!DOCTYPE html>
<html>
<head>
    <title>Course Materials</title>

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

        .form-card, .table-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }

        .form-card:hover, .table-card:hover {
            box-shadow: 0 18px 40px rgba(0,0,0,0.07);
        }

        .section-title {
            font-size: 15px;
            font-weight: 800;
            margin-bottom: 16px;
            color: #111827;
        }

        .field-group {
            margin-bottom: 14px;
            display: flex;
            flex-direction: column;
            gap: 7px;
        }

        .field-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: #6b7280;
            letter-spacing: 0.4px;
        }

        select, input, textarea {
            padding: 10px 13px;
            border: 1px solid #dbe1ea;
            border-radius: 11px;
            font-size: 13px;
            background: #fbfdff;
            outline: none;
            transition: 0.2s ease;
            width: 100%;
        }

        select:focus, input:focus, textarea:focus {
            border-color: #00CBD4;
            box-shadow: 0 0 0 3px rgba(0,203,212,0.15);
            background: white;
        }

        textarea {
            min-height: 110px;
            resize: vertical;
            font-family: "Segoe UI", sans-serif;
        }

        .upload-area {
            border: 1px dashed #cbd5e1;
            border-radius: 16px;
            padding: 16px;
            background: #f8fbff;
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

        .btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            color: white;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 800;
            transition: 0.2s ease;
            box-shadow: 0 8px 18px rgba(14,165,233,0.20);
        }

        .btn:hover {
            background: linear-gradient(135deg, #0ea5e9, #115FB3);
            transform: translateY(-1px);
        }

        .material-card {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px;
            margin-bottom: 12px;
            border: 1px solid #e5e7eb;
            border-radius: 18px;
            background: #ffffff;
            transition: 0.2s ease;
            position: relative;
            overflow: hidden;
        }

        .material-card::after {
            content: "";
            position: absolute;
            right: -30px;
            top: -30px;
            width: 85px;
            height: 85px;
            background: rgba(0,203,212,0.08);
            border-radius: 50%;
        }

        .material-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 14px 32px rgba(0,0,0,0.07);
            border-color: #bfdbfe;
        }

        .file-icon {
            width: 48px;
            height: 48px;
            border-radius: 16px;
            background: #ecfeff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            z-index: 1;
        }

        .material-body {
            flex: 1;
            margin-left: 14px;
            z-index: 1;
        }

        .material-title {
            font-size: 14px;
            font-weight: 800;
            color: #111827;
        }

        .material-desc {
            font-size: 12px;
            color: #6b7280;
            margin-top: 4px;
        }

        .material-meta {
            margin-top: 8px;
            font-size: 11px;
            color: #8a94a6;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .badge {
            background: #eaf8ff;
            color: #0284c7;
            padding: 5px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 800;
        }

        .open-btn {
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            color: white;
            text-decoration: none;
            padding: 9px 15px;
            border-radius: 11px;
            font-size: 12px;
            font-weight: 800;
            transition: 0.2s ease;
            z-index: 1;
        }

        .open-btn:hover {
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

        @media (max-width: 900px) {
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
        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 15px;
        }

        .course-card,
        .course-card:link,
        .course-card:visited {
            display: block;
            text-decoration: none !important;
            color: #111827 !important;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 18px;
            padding: 20px;
            transition: 0.25s ease;
            box-shadow: 0 8px 20px rgba(0,0,0,0.05);
        }

        .course-card:hover {
            transform: translateY(-4px);
            border-color: #00CBD4;
            box-shadow: 0 14px 30px rgba(0,203,212,0.15);
        }

        .course-icon {
            font-size: 32px;
            margin-bottom: 12px;
        }

        .course-name {
            font-size: 16px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .course-sub {
            font-size: 13px;
            color: #6b7280;
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

            .material-card {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
            }

            .material-body {
                margin-left: 0;
            }

            .open-btn {
                width: 100%;
                text-align: center;
            }
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
                    <div class="sidebar-name">
                        <asp:Label ID="lblSidebarName" runat="server" />
                    </div>
                    <div class="sidebar-role">Lecturer</div>
                </div>
            </div>

            <a href="LectDashboard.aspx" class="nav-item">🏠 Dashboard</a>
            <a class="nav-item" href="Attendance.aspx">📝 Attendance</a>
            <a class="nav-item" href="Assessment.aspx">📊 Assessment</a>
            <a class="nav-item" href="LecturerMonitorAcademicProgress.aspx">🎓 Academic Progress</a>
            <a class="nav-item" href="LecturerPostAnnouncement.aspx">📢 Announcements</a>
            <a class="nav-item active" href="LecturerCourseMaterials.aspx">📁 Course Materials</a>
            <a class="nav-item" style="margin-top:auto; color:#e74c3c;" href="Login.aspx">🚪 Logout</a>
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

            <div class="page-title">Course Materials</div>
            <div class="page-sub">Select a course to upload, schedule, and manage learning materials.</div>

            <div class="form-card">
                <div class="section-title">Select Course</div>

                <div class="field-group">
                    <div class="field-label">Course</div>
                    <asp:HiddenField ID="hfSelectedCourseOfferID" runat="server" Value="0" />

                <div class="course-grid">

                    <asp:Repeater ID="rptCourseCards" runat="server"
                        OnItemCommand="rptCourseCards_ItemCommand">

                        <ItemTemplate>

                            <asp:LinkButton ID="btnCourseCard"
                                runat="server"
                                CssClass="course-card"
                                CommandName="SelectCourse"
                                CommandArgument='<%# Eval("CourseOfferID") %>'>

                                <div class="course-icon">📚</div>

                                <div class="course-name">
                                    <%# Eval("DisplayName") %>
                                </div>

                                <div class="course-sub">
                                    Click to manage materials
                                </div>

                            </asp:LinkButton>

                        </ItemTemplate>

                        </asp:Repeater>
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlCourseContent" runat="server" Visible="false">

                <div class="form-card">
                    <div class="section-title">Post New Material</div>

                    <div class="field-group">
                        <div class="field-label">Title</div>
                        <asp:TextBox ID="txtTitle" runat="server" placeholder="Enter material title" />
                    </div>

                    <div class="field-group">
                        <div class="field-label">Description</div>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine"
                            placeholder="Write a short description..." />
                    </div>

                    <div class="upload-area">
                        <div class="upload-title">📎 Upload File</div>
                        <div class="upload-sub">Upload lecture notes, slides, documents, or learning materials.</div>
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

                <div class="table-card">
                    <div class="section-title">Material History</div>

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