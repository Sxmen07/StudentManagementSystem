<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="LecturerPortal.Attendance" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Attendance</title>
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
            min-width: 0;
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

        .filter-card,
        .table-card,
        .export-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            margin-bottom: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
            transition: 0.2s ease;
        }

        .filter-card,
        .export-card {
            padding: 22px;
        }

        .filter-card:hover,
        .table-card:hover,
        .export-card:hover {
            box-shadow: 0 18px 40px rgba(0,0,0,0.07);
        }

        .section-title {
            font-size: 15px;
            font-weight: 800;
            color: #111827;
            margin-bottom: 16px;
        }

        .filter-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
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

        select,
        input[type=text],
        input[type=date] {
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

        select:focus,
        input:focus {
            border-color: #00CBD4;
            box-shadow: 0 0 0 3px rgba(0,203,212,0.15);
            background: white;
        }

        .table-card {
            overflow-x: auto;
            width: 100%;
            -webkit-overflow-scrolling: touch;
            padding: 0;
        }

        .table-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 18px 22px;
            border-bottom: 1px solid #eef2f7;
            gap: 16px;
            flex-wrap: wrap;
            background: #fbfdff;
        }

        .search-input {
            padding: 10px 14px;
            border: 1px solid #dbe1ea;
            border-radius: 11px;
            font-size: 13px;
            width: 100%;
            max-width: 280px;
            background: #fff;
        }

        .summary-pills {
            display: flex;
            gap: 10px;
            font-size: 12px;
            flex-wrap: wrap;
        }

        .pill {
            padding: 6px 13px;
            border-radius: 999px;
            font-weight: 800;
            white-space: nowrap;
        }

        .pill-p {
            background: #dcfce7;
            color: #166534;
        }

        .pill-a {
            background: #fee2e2;
            color: #991b1b;
        }

        .pill-l {
            background: #fef9c3;
            color: #854d0e;
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
            vertical-align: top;
        }

        thead th.chk-col {
            text-align: center;
            width: 100px;
            min-width: 90px;
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

        td.center {
            text-align: center;
        }

        .student-id {
            font-family: Consolas, monospace;
            font-size: 12px;
            color: #64748b;
            font-weight: 600;
        }

        input[type=checkbox] {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: #16a34a;
        }

        input.chk-absent {
            accent-color: #dc2626;
        }

        input.chk-late {
            accent-color: #d97706;
        }

        .tick-all-header {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 3px;
        }

        .tick-all-label {
            font-size: 9px;
            color: #9ca3af;
            font-weight: 400;
            text-transform: none;
            letter-spacing: 0;
        }

        .btn-load,
        .btn-save,
        .btn-primary {
            padding: 11px 20px;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
            transition: 0.2s ease;
            text-align: center;
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
            box-shadow: 0 8px 18px rgba(14,165,233,0.20);
        }

        .btn-load,
        .btn-save {
            width: 100%;
        }

        .btn-save {
            max-width: 190px;
            background: #16a34a;
            box-shadow: none;
        }

        .btn-load:hover,
        .btn-primary:hover {
            background: linear-gradient(135deg, #0ea5e9, #115FB3);
            transform: translateY(-1px);
        }

        .btn-save:hover {
            background: #15803d;
            transform: translateY(-1px);
        }

        .table-footer {
            padding: 15px 22px;
            font-size: 12px;
            color: #6b7280;
            border-top: 1px solid #eef2f7;
            display: flex;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
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

        .hidden {
            display: none !important;
        }

        .export-card strong {
            font-size: 13px;
            color: #555;
        }

        .export-card select {
            width: 140px;
            display: inline-block;
            margin: 0 10px;
        }

        .history-title {
            font-size: 15px;
            font-weight: 800;
            color: #111827;
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

            .main {
                padding: 24px 18px;
            }

            .table-toolbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .search-input {
                max-width: 100%;
            }

            .btn-save {
                max-width: 100%;
            }

            .export-card select,
            .export-card .btn-primary {
                width: 100%;
                margin: 10px 0 0 0;
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

        <a href="LectDashboard.aspx" class="nav-item">🏠 Dashboard</a>
        <a href="Attendance.aspx" class="nav-item active">📝 Attendance</a>
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
                <div class="welcome-name">
                    <asp:Label ID="lblWelcomeName" runat="server" />
                </div>
            </div>
        </div>

        <div class="page-title">Student Attendance</div>
        <div class="page-sub">Select a course and date, then mark attendance for each student.</div>

        <div class="filter-card">
            <div class="section-title">Select Course and Date</div>

            <div class="filter-row">
                <div class="filter-group">
                    <span class="filter-label">Programme</span>
                    <asp:DropDownList ID="ddlProgramme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramme_Changed" />
                </div>

                <div class="filter-group">
                    <span class="filter-label">Course Offer</span>
                    <asp:DropDownList ID="ddlCourseOffer" runat="server" />
                </div>

                <div class="filter-group">
                    <span class="filter-label">Date</span>
                    <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
                </div>

                <div class="filter-group">
                    <asp:Button ID="btnLoad" runat="server" Text="Load Students" CssClass="btn-load" OnClick="btnLoad_Click" />
                </div>

                <div class="filter-group">
                    <asp:Button ID="btnHistory" runat="server" Text="History" CssClass="btn-load" OnClick="btnViewHistory_Click" />
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlTable" runat="server" Visible="false">
            <asp:HiddenField ID="hfCourseOfferID" runat="server" />

            <div class="table-card">
                <div class="table-toolbar">
                    <input type="text" class="search-input" id="searchBox" placeholder="Search by name or student ID..." onkeyup="filterTable()" />

                    <div class="summary-pills">
                        <span class="pill pill-p">Present: <span id="countP">0</span></span>
                        <span class="pill pill-a">Absent: <span id="countA">0</span></span>
                        <span class="pill pill-l">Late: <span id="countL">0</span></span>
                    </div>

                    <asp:Button ID="btnSave" runat="server" Text="Save Attendance" CssClass="btn-save" OnClick="btnSave_Click" />
                </div>

                <table id="attTable">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>Student ID</th>
                            <th>Student Name</th>

                            <th class="chk-col">
                                <div class="tick-all-header">
                                    Present
                                    <label>
                                        <input type="checkbox" id="chkAllPresent" onchange="tickAll('present')" />
                                        <span class="tick-all-label">tick all</span>
                                    </label>
                                </div>
                            </th>

                            <th class="chk-col">
                                <div class="tick-all-header">
                                    Absent
                                    <label>
                                        <input type="checkbox" id="chkAllAbsent" class="chk-absent" onchange="tickAll('absent')" />
                                        <span class="tick-all-label">tick all</span>
                                    </label>
                                </div>
                            </th>

                            <th class="chk-col">
                                <div class="tick-all-header">
                                    Late
                                    <label>
                                        <input type="checkbox" id="chkAllLate" class="chk-late" onchange="tickAll('late')" />
                                        <span class="tick-all-label">tick all</span>
                                    </label>
                                </div>
                            </th>
                        </tr>
                    </thead>

                    <tbody id="attBody">
                        <asp:Repeater ID="rptStudents" runat="server" OnItemDataBound="rptStudents_ItemDataBound">
                            <ItemTemplate>
                                <tr data-name='<%# Eval("StudentName") %>' data-id='<%# Eval("StudentID") %>'>
                                    <td style="color:#aaa"><%# Container.ItemIndex + 1 %></td>
                                    <td class="student-id"><%# Eval("StudentID") %></td>
                                    <td><%# Eval("StudentName") %></td>

                                    <td class="center">
                                        <asp:HiddenField ID="hfStudentID" runat="server" Value='<%# Eval("StudentID") %>' />
                                        <asp:CheckBox ID="chkPresent" runat="server" CssClass="chk-present" onclick="handleCheck(this,'present')" />
                                    </td>

                                    <td class="center">
                                        <asp:CheckBox ID="chkAbsent" runat="server" CssClass="chk-absent" onclick="handleCheck(this,'absent')" />
                                    </td>

                                    <td class="center">
                                        <asp:CheckBox ID="chkLate" runat="server" CssClass="chk-late" onclick="handleCheck(this,'late')" />
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>

                <div class="table-footer">
                    <span id="footCount"></span>
                    <asp:Label ID="lblStatus" runat="server" CssClass="success-msg" />
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlHistory" runat="server" Visible="false">
            <div class="table-card">
                <div class="table-toolbar">
                    <span class="history-title">Attendance History</span>
                    <asp:Label ID="lblHistoryStatus" runat="server" CssClass="success-msg" />
                </div>

                <asp:Literal ID="litAttendanceHistory" runat="server" />

                <div class="table-footer">
                    <span>Attendance rate counts Present and Late as attended.</span>
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlExportOptions" runat="server" CssClass="export-card" Visible="false">
            <strong>Export Summary Report:</strong>

            <asp:DropDownList ID="ddlExportType" runat="server" CssClass="score-input">
                <asp:ListItem Text="Excel (.xls)" Value="xls" />
                <asp:ListItem Text="Word (.doc)" Value="doc" />
                <asp:ListItem Text="CSV (.csv)" Value="csv" />
            </asp:DropDownList>

            <asp:Button ID="btnDownloadReport" runat="server" Text="Download" CssClass="btn-primary" OnClick="btnDownloadReport_Click" />

            <div>
                <asp:Label ID="lblExportStatus" runat="server" CssClass="error-msg" />
            </div>
        </asp:Panel>

    </div>
</div>
</form>

<script>
    function getStatusBox(row, type) {
        var wrapper = row.querySelector('.chk-' + type);
        if (wrapper) {
            var innerBox = wrapper.querySelector('input[type=checkbox]');
            if (innerBox) return innerBox;
        }
        return row.querySelector('input.chk-' + type) || row.querySelector('.chk-' + type + ' input');
    }

    function handleCheck(cb, type) {
        var row = cb.closest('tr');

        ['present', 'absent', 'late'].forEach(function (t) {
            var box = getStatusBox(row, t);
            if (box && box !== cb) box.checked = false;
        });

        updateSummary();
    }

    function tickAll(type) {
        var allP = document.getElementById('chkAllPresent');
        var allA = document.getElementById('chkAllAbsent');
        var allL = document.getElementById('chkAllLate');

        if (type === 'present') {
            allA.checked = false;
            allL.checked = false;
        }

        if (type === 'absent') {
            allP.checked = false;
            allL.checked = false;
        }

        if (type === 'late') {
            allP.checked = false;
            allA.checked = false;
        }

        var checked = type === 'present' ? allP.checked : type === 'absent' ? allA.checked : allL.checked;

        document.querySelectorAll('#attBody tr').forEach(function (row) {
            if (row.classList.contains('hidden')) return;

            ['present', 'absent', 'late'].forEach(function (t) {
                var box = getStatusBox(row, t);
                if (box) box.checked = false;
            });

            if (checked) {
                var target = getStatusBox(row, type);
                if (target) target.checked = true;
            }
        });

        updateSummary();
    }

    function filterTable() {
        var q = document.getElementById('searchBox').value.toLowerCase();

        document.querySelectorAll('#attBody tr').forEach(function (row) {
            var name = (row.getAttribute('data-name') || '').toLowerCase();
            var id = (row.getAttribute('data-id') || '').toLowerCase();

            row.classList.toggle('hidden', q !== '' && !name.includes(q) && !id.includes(q));
        });

        updateSummary();
    }

    function updateSummary() {
        var p = 0;
        var a = 0;
        var l = 0;
        var total = 0;

        document.querySelectorAll('#attBody tr:not(.hidden)').forEach(function (row) {
            total++;

            var present = getStatusBox(row, 'present');
            var absent = getStatusBox(row, 'absent');
            var late = getStatusBox(row, 'late');

            if (present && present.checked) p++;
            if (absent && absent.checked) a++;
            if (late && late.checked) l++;
        });

        if (document.getElementById('countP')) document.getElementById('countP').textContent = p;
        if (document.getElementById('countA')) document.getElementById('countA').textContent = a;
        if (document.getElementById('countL')) document.getElementById('countL').textContent = l;
        if (document.getElementById('footCount')) document.getElementById('footCount').textContent = 'Showing ' + total + ' students';
    }

    document.addEventListener("DOMContentLoaded", function () {
        updateSummary();
    });
</script>
</body>
</html>