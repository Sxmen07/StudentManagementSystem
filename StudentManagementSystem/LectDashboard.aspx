<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LectDashboard.aspx.cs" Inherits="LecturerPortal.LectDashboard" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Lecturer Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif; background: #f0f2f5; margin: 0; }
        
        .layout { display: flex; min-height: 100vh; flex-direction: row; }
        
        /* Sidebar Layout matching Attendance & LectProfile styling exactly */
        .sidebar { width: 240px; background: #fff; border-right: 1px solid #e8e8e8; padding: 24px 14px; display: flex; flex-direction: column; gap: 4px; flex-shrink: 0; }
        .sidebar-profile { display: flex; flex-direction: column; align-items: center; text-align: center; padding-bottom: 20px; margin-bottom: 20px; border-bottom: 1px solid #f0f0f0; gap: 10px; }
        .avatar-container { position: relative; width: 80px; height: 80px; }
        .avatar-circle { width: 80px; height: 80px; border-radius: 50%; background: #dbeafe; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: 600; color: #1d4ed8; overflow: hidden; border: 2px solid #1d4ed8; cursor: pointer; transition: transform 0.2s; }
        .avatar-circle:hover { transform: scale(1.04); box-shadow: 0 2px 8px rgba(29, 78, 216, 0.15); }
        .avatar-circle img { width: 100%; height: 100%; object-fit: cover; }
        .sidebar-name { font-size: 14px; font-weight: 600; color: #1a1a1a; margin-top: 4px; }
        .sidebar-role { font-size: 11px; color: #888; text-transform: uppercase; letter-spacing: 0.05em; }
        
        .nav-item { display: flex; align-items: center; gap: 8px; padding: 10px 12px; border-radius: 8px; font-size: 13px; color: #555; text-decoration: none; cursor: pointer; }
        .nav-item:hover { background: #f5f5f5; }
        .nav-item.active { background: #f0f7ff; color: #1d4ed8; font-weight: 600; }

        /* Main Workspace Panel */
        .main { flex: 1; padding: 32px 36px; min-width: 0; }
        .page-title { font-size: 22px; font-weight: 600; color: #1a1a1a; margin-bottom: 6px; }
        .page-sub { font-size: 13px; color: #888; margin-bottom: 20px; }

        /* Summary Dashboard Information Cards Grid Layout */
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 24px; }
        .card { background: #fff; border-radius: 12px; padding: 20px; border: 1px solid #e8e8e8; cursor: pointer; transition: transform 0.2s, box-shadow 0.2s; position: relative; overflow: hidden; border-left: 4px solid #1d4ed8; }
        .card:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05); }
        .card-red { border-left-color: #dc2626; }
        .card-orange { border-left-color: #f97316; }
        
        .card-title { font-size: 12px; font-weight: 600; color: #666; text-transform: uppercase; margin-bottom: 8px; display: block; letter-spacing: .04em; }
        .card-value { font-size: 26px; font-weight: 700; color: #1a1a1a; }
        
        .chart-card { background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; padding: 24px; max-width: 750px; }
        .chart-header { font-size: 14px; font-weight: 600; color: #1a1a1a; margin-bottom: 16px; text-transform: uppercase; letter-spacing: 0.02em; }
        .hidden-framework-controls { display: none !important; }

        @media (max-width: 768px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; border-right: none; border-bottom: 1px solid #e8e8e8; padding: 16px; flex-direction: row; flex-wrap: wrap; }
            .sidebar-profile { width: 100%; border-bottom: 1px solid #f0f0f0; padding-bottom: 12px; }
            .main { padding: 20px 16px; }
            .metrics-grid { grid-template-columns: 1fr; }
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
                        <asp:Image ID="imgSidebar" runat="server" />
                        <asp:Literal ID="litSideInitials" runat="server" />
                    </div>
                </div>
            </a>
            <div>
                <div class="sidebar-name"><asp:Label ID="lblSidebarName" runat="server" /></div>
                <div class="sidebar-role">Lecturer</div>
            </div>
        </div>
        
        <a href="LectDashboard.aspx" class="nav-item active">Dashboard</a>
        <a href="Attendance.aspx" class="nav-item">Attendance</a>
        <a href="Assessment.aspx" class="nav-item">Assessment</a>
        <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item">Academic Progress</a>
        <a href="LecturerPostAnnouncement.aspx" class="nav-item">Announcements</a>
        <a href="LecturerCourseMaterials.aspx" class="nav-item">Course Materials</a>
        <a href="Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">Logout</a>
    </div>

    <div class="main">
        <div class="page-title">Lecturer Insights Dashboard</div>
        <div class="page-sub">Overview tracking modules for cohort tracks, critical performance status, and attendance parameters.</div>

        <div class="metrics-grid">
            <div class="card" onclick="location.href='Attendance.aspx'">
                <span class="card-title">Average Attendance Rate</span>
                <div class="card-value"><asp:Label ID="lblAvgAttendance" runat="server" Text="0%" /></div>
            </div>
            <div class="card card-red" onclick="location.href='Attendance.aspx'">
                <span class="card-title">Low Attendance Track (&lt;80%)</span>
                <div class="card-value"><asp:Label ID="lblLowAttendanceCount" runat="server" Text="0" /></div>
            </div>
            <div class="card card-orange" onclick="location.href='Assessment.aspx'">
                <span class="card-title">Failing Status Risk Marks (&lt;40%)</span>
                <div class="card-value"><asp:Label ID="lblFailingCount" runat="server" Text="0" /></div>
            </div>
        </div>

        <div class="chart-card">
            <div class="chart-header">Weekly Student Cohort Tracking Curve</div>
            <div style="position: relative; width:100%; height:auto;">
                <canvas id="dashboardChart" height="260"></canvas>
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