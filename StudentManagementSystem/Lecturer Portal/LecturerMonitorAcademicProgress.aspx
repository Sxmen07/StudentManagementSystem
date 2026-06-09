<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerMonitorAcademicProgress.aspx.cs" Inherits="LecturerPortal.LecturerMonitorAcademicProgress" %>

<!DOCTYPE html>
<html>
<head>
    <title>Monitor Academic Progress</title>

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

        .card-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 16px; }
        .stat-card { background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; padding: 18px; }
        .stat-value { font-size: 24px; font-weight: 700; color: #1a1a1a; margin-bottom: 4px; }
        .stat-label { font-size: 12px; color: #777; text-transform: uppercase; letter-spacing: .04em; }

        .filter-card, .table-card { background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; margin-bottom: 16px; }
        .filter-card { padding: 18px 20px; }
        .table-card { overflow-x: auto; }

        .filter-row { display: flex; gap: 14px; flex-wrap: wrap; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; gap: 5px; }
        .filter-label { font-size: 11px; font-weight: 600; color: #666; text-transform: uppercase; letter-spacing: .04em; }

        select, input[type=text] {
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            font-size: 13px;
            color: #1a1a1a;
            background: #fff;
            min-width: 160px;
        }

        select:focus, input:focus { outline: none; border-color: #1d4ed8; }

        .search-input { min-width: 240px; }
        .btn-load { padding: 9px 20px; background: #1d4ed8; color: #fff; border: none; border-radius: 7px; font-size: 13px; cursor: pointer; }
        .btn-load:hover { background: #1e40af; }

        table { width: 100%; border-collapse: collapse; min-width: 850px; }
        thead th { background: #f8f9fa; padding: 10px 14px; font-size: 11px; font-weight: 600; color: #555; text-transform: uppercase; border-bottom: 1px solid #e8e8e8; }
        tbody td { padding: 11px 14px; border-bottom: 1px solid #f5f5f5; font-size: 13px; color: #1a1a1a; vertical-align: middle; }
        tbody tr:hover td { background: #fafcff; }

        .student-id { font-family: Consolas, monospace; font-size: 12px; color: #555; }
        .status-good { background: #dcfce7; color: #166534; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }
        .status-risk { background: #fee2e2; color: #991b1b; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }

        .table-footer { padding: 12px 18px; font-size: 12px; color: #888; border-top: 1px solid #f0f0f0; display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .success-msg { color: #16a34a; font-size: 13px; font-weight: 500; }
        .error-msg { color: #dc2626; font-size: 13px; font-weight: 500; }

        @media (max-width: 900px) {
            .card-row { grid-template-columns: repeat(2, 1fr); }
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
            <a href="LecturerMonitorAcademicProgress.aspx" class="nav-item active">Academic Progress</a>
            <a href="LecturerPostAnnouncement.aspx" class="nav-item">Announcements</a>
            <a href="Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">Logout</a>
        </div>

        <div class="main">
            <div class="page-title">Monitor Academic Progress</div>
            <div class="page-sub">View student attendance, assessment percentage, grade, and risk status.</div>

            <div class="card-row">
                <div class="stat-card">
                    <div class="stat-value"><asp:Label ID="lblTotalStudents" runat="server" Text="0" /></div>
                    <div class="stat-label">Total Students</div>
                </div>

                <div class="stat-card">
                    <div class="stat-value"><asp:Label ID="lblAverageAttendance" runat="server" Text="0%" /></div>
                    <div class="stat-label">Average Attendance</div>
                </div>

                <div class="stat-card">
                    <div class="stat-value"><asp:Label ID="lblAverageGrade" runat="server" Text="-" /></div>
                    <div class="stat-label">Average Grade</div>
                </div>

                <div class="stat-card">
                    <div class="stat-value"><asp:Label ID="lblRiskStudents" runat="server" Text="0" /></div>
                    <div class="stat-label">At Risk Students</div>
                </div>
            </div>

            <div class="filter-card">
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
                <div style="padding:12px 18px;">
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