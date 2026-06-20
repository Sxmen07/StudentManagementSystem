﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerMonitorAcademicProgress.aspx.cs" Inherits="LecturerPortal.LecturerMonitorAcademicProgress" %>

<!DOCTYPE html>
<html>
<head>
    <title>Monitor Academic Progress</title>

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

        .card-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 18px;
        }

        .stat-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
            transition: 0.2s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::after {
            content: "";
            position: absolute;
            right: -25px;
            top: -25px;
            width: 75px;
            height: 75px;
            background: rgba(0,203,212,0.12);
            border-radius: 50%;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 18px 40px rgba(0,0,0,0.07);
        }

        .stat-icon {
            font-size: 20px;
            margin-bottom: 8px;
        }

        .stat-value {
            font-size: 27px;
            font-weight: 800;
            color: #0284c7;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 11px;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            font-weight: 700;
        }

        .filter-card, .table-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            margin-bottom: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }

        .filter-card {
            padding: 22px;
        }

        .table-card {
            overflow-x: auto;
        }

        .section-title {
            font-size: 15px;
            font-weight: 800;
            color: #111827;
            margin-bottom: 16px;
        }

        .filter-row {
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            align-items: flex-end;
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

        select, input[type=text] {
            padding: 10px 13px;
            border: 1px solid #dbe1ea;
            border-radius: 11px;
            font-size: 13px;
            color: #111827;
            background: #fbfdff;
            min-width: 160px;
            outline: none;
            transition: 0.2s ease;
        }

        select:focus, input:focus {
            border-color: #00CBD4;
            box-shadow: 0 0 0 3px rgba(0,203,212,0.15);
            background: white;
        }

        .search-input {
            min-width: 240px;
        }

        .btn-load {
            padding: 11px 24px;
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
            transition: 0.2s ease;
            box-shadow: 0 8px 18px rgba(14,165,233,0.20);
        }

        .btn-load:hover {
            background: linear-gradient(135deg, #0ea5e9, #115FB3);
            transform: translateY(-1px);
        }

        .status-area {
            padding: 14px 18px 4px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 850px;
        }

        thead th {
            background: #f8fbff;
            padding: 14px;
            font-size: 11px;
            font-weight: 800;
            color: #6b7280;
            text-transform: uppercase;
            border-bottom: 1px solid #e5e7eb;
            text-align: left;
        }

        tbody td {
            padding: 14px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13px;
            color: #111827;
            vertical-align: middle;
        }

        tbody tr:hover td {
            background: #f8fbff;
        }

        .student-id {
            font-family: Consolas, monospace;
            font-size: 12px;
            color: #64748b;
            font-weight: 600;
        }

        .status-good {
            background: #dcfce7;
            color: #166534;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 800;
            display: inline-block;
        }

        .status-risk {
            background: #fee2e2;
            color: #991b1b;
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 800;
            display: inline-block;
        }

        .table-footer {
            padding: 15px 18px;
            font-size: 12px;
            color: #6b7280;
            border-top: 1px solid #eef2f7;
            display: flex;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            background: #fbfdff;
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
            .card-row {
                grid-template-columns: repeat(2, 1fr);
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

            .card-row {
                grid-template-columns: 1fr;
            }

            .filter-row {
                flex-direction: column;
                align-items: stretch;
            }

            select, input[type=text], .search-input, .btn-load {
                width: 100%;
                min-width: 100%;
            }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">
    <div class="layout">

        <div class="sidebar">
            <div class="sidebar-avatar">
                <div class="avatar-circle">
                    <asp:Image ID="imgSidebar" runat="server" Visible="false" />
                    <asp:Literal ID="litSideInitials" runat="server" Text="LE" />
                </div>
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
            <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item active">🎓 Academic Progress</a>
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

            <div class="page-title">Monitor Academic Progress</div>
            <div class="page-sub">View student attendance, assessment percentage, grade, and risk status.</div>

            <div class="card-row">
                <div class="stat-card">
                    <div class="stat-icon">👨‍🎓</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalStudents" runat="server" Text="-" />
                    </div>
                    <div class="stat-label">Total Students</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">📅</div>
                    <div class="stat-value">
                        <asp:Label ID="lblAverageAttendance" runat="server" Text="-" />
                    </div>
                    <div class="stat-label">Average Attendance</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">🏆</div>
                    <div class="stat-value">
                        <asp:Label ID="lblAverageGrade" runat="server" Text="-" />
                    </div>
                    <div class="stat-label">Average Grade</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">⚠️</div>
                    <div class="stat-value">
                        <asp:Label ID="lblRiskStudents" runat="server" Text="-" />
                    </div>
                    <div class="stat-label">At Risk Students</div>
                </div>
            </div>

            <div class="filter-card">
                <div class="section-title">Filter Student Progress</div>

                <div class="filter-row">
                    <div class="filter-group">
                        <span class="filter-label">Programme</span>
                        <asp:DropDownList ID="ddlProgramme" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlProgramme_Changed" />
                    </div>

                    <div class="filter-group">
                        <span class="filter-label">Course Offer</span>
                        <asp:DropDownList ID="ddlCourseOffer" runat="server" />
                    </div>

                    <div class="filter-group">
                        <span class="filter-label">Search</span>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input"
                            placeholder="Search student name or ID" />
                    </div>

                    <div class="filter-group">
                        <span class="filter-label">Filter</span>
                        <asp:DropDownList ID="ddlFilter" runat="server">
                            <asp:ListItem Text="All Students" Value="All" />
                            <asp:ListItem Text="At Risk" Value="At Risk" />
                            <asp:ListItem Text="Good Performance" Value="Good" />
                        </asp:DropDownList>
                    </div>

                    <div class="filter-group">
                        <span class="filter-label">Sort</span>
                        <asp:DropDownList ID="ddlSort" runat="server">
                            <asp:ListItem Text="Student Name" Value="Name" />
                            <asp:ListItem Text="Attendance" Value="Attendance" />
                            <asp:ListItem Text="Assessment" Value="Assessment" />
                            <asp:ListItem Text="Grade" Value="Grade" />
                        </asp:DropDownList>
                    </div>

                    <div class="filter-group">
                        <asp:Button ID="btnFilter" runat="server" Text="Apply"
                            CssClass="btn-load" OnClick="btnFilter_Click" />
                    </div>
                </div>
            </div>

            <div class="table-card">
                <div class="status-area">
                    <asp:Label ID="lblStatus" runat="server" />
                </div>

                <asp:GridView ID="gvProgress" runat="server"
                    AutoGenerateColumns="false"
                    GridLines="None"
                    EmptyDataText="No student progress found for this course.">

                    <Columns>
                        <asp:BoundField DataField="StudentID" HeaderText="Student ID">
                            <ItemStyle CssClass="student-id" />
                        </asp:BoundField>

                        <asp:BoundField DataField="StudentName" HeaderText="Student Name" />

                        <asp:BoundField DataField="Attendance" HeaderText="Attendance %" DataFormatString="{0:0.##}%" />

                        <asp:BoundField DataField="AssessmentPercentage" HeaderText="Assessment %" DataFormatString="{0:0.##}%" />

                        <asp:BoundField DataField="CurrentGrade" HeaderText="Current Grade" />

                        <asp:TemplateField HeaderText="Risk Status">
                            <ItemTemplate>
                                <asp:Label ID="lblRiskStatus" runat="server"
                                    Text='<%# Eval("Status") %>'
                                    CssClass='<%# Eval("Status").ToString() == "At Risk" ? "status-risk" : "status-good" %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <div class="table-footer">
                    <span>At risk means attendance below 70% or assessment below 50%.</span>
                    <span>Late attendance is counted as attended.</span>
                </div>
            </div>
        </div>
    </div>
</form>
</body>
</html>