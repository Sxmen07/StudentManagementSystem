<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LectDashboard.aspx.cs" Inherits="LecturerPortal.LectDashboard" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Lecturer Dashboard</title>
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

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 20px;
            cursor: pointer;
            transition: 0.2s ease;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }

        .card::after {
            content: "";
            position: absolute;
            right: -25px;
            top: -25px;
            width: 75px;
            height: 75px;
            background: rgba(0,203,212,0.12);
            border-radius: 50%;
        }

        .card:hover {
            transform: translateY(-4px);
            box-shadow: 0 18px 40px rgba(0,0,0,0.07);
            border-color: #bfdbfe;
        }

        .card-icon {
            font-size: 22px;
            margin-bottom: 10px;
        }

        .card-title {
            font-size: 11px;
            font-weight: 800;
            color: #6b7280;
            text-transform: uppercase;
            margin-bottom: 8px;
            display: block;
            letter-spacing: 0.4px;
        }

        .card-value {
            font-size: 29px;
            font-weight: 800;
            color: #0284c7;
            position: relative;
            z-index: 1;
        }

        .card-red .card-value {
            color: #dc2626;
        }

        .card-orange .card-value {
            color: #f97316;
        }

        .chart-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 24px;
            max-width: 820px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
            transition: 0.2s ease;
        }

        .chart-card:hover {
            box-shadow: 0 18px 40px rgba(0,0,0,0.07);
        }

        .chart-header {
            font-size: 15px;
            font-weight: 800;
            color: #111827;
            margin-bottom: 16px;
        }

        .hidden-framework-controls {
            display: none !important;
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

        @media (max-width: 600px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }

            .metrics-grid {
                grid-template-columns: 1fr;
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

        <a href="LectDashboard.aspx" class="nav-item active">🏠 Dashboard</a>
        <a href="Attendance.aspx" class="nav-item">📝 Attendance</a>
        <a href="Assessment.aspx" class="nav-item">📊 Assessment</a>
        <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item">🎓 Academic Progress</a>
        <a href="LecturerPostAnnouncement.aspx" class="nav-item">📢 Announcements</a>
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

        <div class="page-title">Lecturer Insights Dashboard</div>
        <div class="page-sub">Overview tracking modules for critical performance status, and attendance parameters.</div>

        <div class="metrics-grid">
            <div class="card" onclick="location.href='Attendance.aspx'">
                <div class="card-icon">📅</div>
                <span class="card-title">Average Attendance Rate</span>
                <div class="card-value">
                    <asp:Label ID="lblAvgAttendance" runat="server" Text="0%" />
                </div>
            </div>

            <div class="card card-red" onclick="location.href='Attendance.aspx'">
                <div class="card-icon">⚠️</div>
                <span class="card-title">Low Attendance Track (&lt;80%)</span>
                <div class="card-value">
                    <asp:Label ID="lblLowAttendanceCount" runat="server" Text="0" />
                </div>
            </div>

            <div class="card card-orange" onclick="location.href='Assessment.aspx'">
                <div class="card-icon">📉</div>
                <span class="card-title">Failing Status Risk Marks (&lt;40%)</span>
                <div class="card-value">
                    <asp:Label ID="lblFailingCount" runat="server" Text="0" />
                </div>
            </div>
        </div>

        <div class="hidden-framework-controls">
            <asp:DropDownList ID="ddlCourseOffer" runat="server" />
            <asp:DropDownList ID="ddlExportType" runat="server" />
            <asp:Label ID="lblStatus" runat="server" />
        </div>

    </div>
</div>

<asp:Literal ID="litChartScript" runat="server" />

</form>
</body>
</html>