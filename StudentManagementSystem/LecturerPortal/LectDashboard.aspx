<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LectDashboard.aspx.cs" Inherits="LecturerPortal.LectDashboard" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="UTF-8" />
    <title>Lecturer Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        /* existing styles */
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

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 16px;
            margin-bottom: 28px;
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
        .card:hover { transform: translateY(-4px); box-shadow: 0 18px 40px rgba(0,0,0,0.07); border-color: #bfdbfe; }
        .card-icon { font-size: 22px; margin-bottom: 10px; }
        .card-title {
            font-size: 11px;
            font-weight: 800;
            color: #6b7280;
            text-transform: uppercase;
            margin-bottom: 8px;
            display: block;
            letter-spacing: 0.4px;
        }
        .card-value { font-size: 29px; font-weight: 800; color: #0284c7; position: relative; z-index: 1; }
        .card-red .card-value { color: #dc2626; }
        .card-orange .card-value { color: #f97316; }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 28px 0 16px 0;
        }
        .section-header h2 {
            font-size: 18px;
            font-weight: 800;
            color: #111827;
            margin: 0;
        }
        .section-header a {
            font-size: 13px;
            font-weight: 700;
            color: #0284c7;
            text-decoration: none;
        }
        .section-header a:hover { text-decoration: underline; }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
        }
        .course-card {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 18px 20px;
            transition: 0.2s ease;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
        }
        .course-card:hover {
            transform: translateY(-3px);
            border-color: #00CBD4;
            box-shadow: 0 12px 28px rgba(0,203,212,0.10);
        }
        .course-card .course-name {
            font-size: 16px;
            font-weight: 700;
            color: #111827;
            margin-bottom: 4px;
        }
        .course-card .course-code {
            font-size: 12px;
            color: #6b7280;
            margin-bottom: 12px;
        }
        .course-card .course-stats {
            display: flex;
            gap: 16px;
            font-size: 13px;
            color: #4b5563;
            flex-wrap: wrap;
        }
        .course-card .course-stats span {
            background: #f8fbff;
            padding: 4px 10px;
            border-radius: 999px;
        }
        .course-card .course-stats .stat-highlight {
            background: #ecfeff;
            color: #0284c7;
            font-weight: 700;
        }

        .activity-feed {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 20px;
            margin-top: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
        }
        .activity-item {
            display: flex;
            gap: 14px;
            padding: 12px 0;
            border-bottom: 1px solid #f1f5f9;
        }
        .activity-item:last-child { border-bottom: none; }
        .activity-icon { font-size: 20px; width: 36px; text-align: center; }
        .activity-content { flex: 1; }
        .activity-title { font-weight: 600; color: #111827; }
        .activity-desc { font-size: 13px; color: #6b7280; }
        .activity-time { font-size: 11px; color: #9ca3af; }

        .chart-container {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
        }
        .chart-container canvas { max-height: 250px; width: 100% !important; }

        .hidden-framework-controls { display: none !important; }

        @media (max-width: 900px) {
            .main { padding: 24px 18px; }
            .sidebar { width: 200px; }
            .welcome-card { flex-direction: column; align-items: flex-start; gap: 12px; }
        }
        @media (max-width: 600px) {
            .layout { flex-direction: column; }
            .sidebar { width: 100%; height: auto; position: relative; }
            .metrics-grid { grid-template-columns: 1fr; }
            .course-grid { grid-template-columns: 1fr; }
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
                <div class="sidebar-name"><asp:Label ID="lblSidebarName" runat="server" /></div>
                <div class="sidebar-role">Lecturer</div>
            </div>
        </div>
        <a href="LectDashboard.aspx" class="nav-item active">🏠 Dashboard</a>
        <a href="Attendance.aspx" class="nav-item">📝 Attendance</a>
        <a href="Assessment.aspx" class="nav-item">📊 Assessment</a>
        <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item">🎓 Academic Progress</a>
        <a href="LecturerPostAnnouncement.aspx" class="nav-item">📢 Announcements</a>
        <a href="LecturerCourseMaterials.aspx" class="nav-item">📁 Course Materials</a>
        <a href="../Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">🚪 Logout</a>
    </div>

    <div class="main">

        <div class="welcome-card">
            <div>
                <div class="welcome-small">Welcome back</div>
                <div class="welcome-name"><asp:Label ID="lblWelcomeName" runat="server" Text="Lecturer" /></div>
            </div>
            <div class="welcome-pill">📚 <asp:Label ID="lblCourseCount" runat="server" Text="0" /> Courses</div>
        </div>

        <div class="page-title">Lecturer Insights Dashboard</div>
        <div class="page-sub">Overview of your courses, student performance, and recent activity.</div>

        <!-- Summary Metrics -->
        <div class="metrics-grid">
            <div class="card" onclick="location.href='Attendance.aspx'">
                <div class="card-icon">📅</div>
                <span class="card-title">Average Attendance Rate</span>
                <div class="card-value"><asp:Label ID="lblAvgAttendance" runat="server" Text="0%" /></div>
            </div>
            <div class="card card-red" onclick="location.href='Attendance.aspx'">
                <div class="card-icon">⚠️</div>
                <span class="card-title">Low Attendance (<80%)</span>
                <div class="card-value"><asp:Label ID="lblLowAttendanceCount" runat="server" Text="0" /></div>
            </div>
            <div class="card card-orange" onclick="location.href='Assessment.aspx'">
                <div class="card-icon">📉</div>
                <span class="card-title">Failing Risk (<40%)</span>
                <div class="card-value"><asp:Label ID="lblFailingCount" runat="server" Text="0" /></div>
            </div>
            <div class="card" onclick="location.href='LecturerMonitorAcademicProgress.aspx'">
                <div class="card-icon">👨‍🎓</div>
                <span class="card-title">Total Students Enrolled</span>
                <div class="card-value"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div>
            </div>
        </div>

        <!-- Chart: Attendance per Course -->
        <div class="chart-container">
            <h3 style="margin:0 0 12px 0; font-size:15px; font-weight:800; color:#111827;">Attendance Rate by Course</h3>
            <canvas id="attendanceChart"></canvas>
        </div>

        <!-- My Courses -->
        <div class="section-header">
            <h2>📚 My Courses</h2>
            <a href="Attendance.aspx">View All →</a>
        </div>
        <div class="course-grid">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <div class="course-card">
                        <div class="course-name"><%# Eval("CourseName") %></div>
                        <div class="course-code"><%# Eval("CourseCode") %></div>
                        <div class="course-stats">
                            <span>👥 <asp:Literal ID="litEnrolled" runat="server" Text='<%# Eval("EnrolledCount") %>' /></span>
                            <span class="stat-highlight">📈 <asp:Literal ID="litAttendance" runat="server" Text='<%# Eval("AttendanceRate") %>' />%</span>
                            <span>📊 <asp:Literal ID="litAvgGrade" runat="server" Text='<%# Eval("AvgGrade") %>' /></span>
                        </div>
                        <div style="margin-top:10px; font-size:12px;">
                            <a href="Attendance.aspx?coid=<%# Eval("CourseOfferID") %>" style="color:#0284c7; text-decoration:none;">Take Attendance</a> |
                            <a href="Assessment.aspx?coid=<%# Eval("CourseOfferID") %>" style="color:#0284c7; text-decoration:none;">Assessments</a>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- Recent Activity -->
        <div class="section-header">
    <h2>🕒 Recent Activity</h2>
    <a href="LecturerPostAnnouncement.aspx">Post Announcement →</a>
</div>
<div class="activity-feed">
    <asp:Repeater ID="rptActivities" runat="server">
        <ItemTemplate>
            <div class="activity-item">
                <div class="activity-icon"><%# Eval("Icon") %></div>
                <div class="activity-content">
                    <div class="activity-title"><%# Eval("Title") %></div>
                    <div class="activity-desc"><%# Eval("Description") %></div>
                    <div class="activity-time"><%# Eval("TimeAgo") %></div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
    <asp:Label ID="lblNoActivity" runat="server" 
               Text="No recent activity" 
               CssClass="no-data-message" 
               Visible="false" />
</div>

        <!-- Hidden framework controls (for compatibility) -->
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