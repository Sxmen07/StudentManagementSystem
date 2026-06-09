<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="LecturerPortal.Attendance" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Attendance</title>
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

        .filter-card, .table-card { background: #fff; border: 1px solid #e8e8e8; border-radius: 12px; margin-bottom: 16px; }
        .filter-card { padding: 18px 20px; }
        .table-card { overflow-x: auto; }
        .filter-row { display: flex; gap: 14px; flex-wrap: wrap; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; gap: 5px; }
        .filter-label { font-size: 11px; font-weight: 600; color: #666; text-transform: uppercase; letter-spacing: .04em; }

        select, input[type=text], input[type=date] { padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 7px; font-size: 13px; color: #1a1a1a; background: #fff; min-width: 150px; }
        select:focus, input:focus { outline: none; border-color: #1d4ed8; }

        .table-toolbar { display: flex; justify-content: space-between; align-items: center; padding: 14px 18px; border-bottom: 1px solid #f0f0f0; gap: 12px; flex-wrap: wrap; }
        .search-input { padding: 8px 14px; border: 1px solid #d1d5db; border-radius: 7px; font-size: 13px; width: 260px; }
        .summary-pills { display: flex; gap: 10px; font-size: 12px; flex-wrap: wrap; }
        .pill { padding: 4px 12px; border-radius: 20px; font-weight: 600; }
        .pill-p { background: #dcfce7; color: #166534; }
        .pill-a { background: #fee2e2; color: #991b1b; }
        .pill-l { background: #fef9c3; color: #854d0e; }

        table { width: 100%; border-collapse: collapse; min-width: 760px; }
        thead th { background: #f8f9fa; padding: 10px 14px; font-size: 11px; font-weight: 600; color: #555; text-transform: uppercase; border-bottom: 1px solid #e8e8e8; }
        thead th.chk-col { text-align: center; width: 110px; }
        tbody td { padding: 11px 14px; border-bottom: 1px solid #f5f5f5; font-size: 13px; color: #1a1a1a; vertical-align: middle; }
        tbody tr:hover td { background: #fafcff; }
        td.center { text-align: center; }
        .student-id { font-family: Consolas, monospace; font-size: 12px; color: #555; }

        input[type=checkbox] { width: 18px; height: 18px; cursor: pointer; accent-color: #16a34a; }
        input.chk-absent { accent-color: #dc2626; }
        input.chk-late { accent-color: #d97706; }
        .tick-all-header { display: flex; flex-direction: column; align-items: center; gap: 3px; }
        .tick-all-label { font-size: 9px; color: #aaa; font-weight: 400; text-transform: none; letter-spacing: 0; }

        .btn-load { padding: 9px 20px; background: #1d4ed8; color: #fff; border: none; border-radius: 7px; font-size: 13px; cursor: pointer; }
        .btn-load:hover { background: #1e40af; }
        .btn-save { padding: 9px 20px; background: #16a34a; color: #fff; border: none; border-radius: 7px; font-size: 13px; cursor: pointer; }
        .btn-save:hover { background: #15803d; }

        .table-footer { padding: 12px 18px; font-size: 12px; color: #888; border-top: 1px solid #f0f0f0; display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .success-msg { color: #16a34a; font-size: 13px; font-weight: 500; }
        .error-msg { color: #dc2626; font-size: 13px; font-weight: 500; }
        .hidden { display: none !important; }
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
        <a href="Attendance.aspx" class="nav-item active">Attendance</a>
        <a href="Assessment.aspx" class="nav-item">Assessment</a>
        <a href="Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">Logout</a>
    </div>

    <div class="main">
        <div class="page-title">Student Attendance</div>
        <div class="page-sub">Select a course and date, then mark attendance for each student.</div>

        <div class="filter-card">
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
                    <asp:Button ID="btnHistory" runat="server" Text="History" CssClass="btn-load" OnClick="btnHistory_Click" />
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
                            <th class="chk-col"><div class="tick-all-header">Present<label><input type="checkbox" id="chkAllPresent" onchange="tickAll('present')" /><span class="tick-all-label">tick all</span></label></div></th>
                            <th class="chk-col"><div class="tick-all-header">Absent<label><input type="checkbox" id="chkAllAbsent" class="chk-absent" onchange="tickAll('absent')" /><span class="tick-all-label">tick all</span></label></div></th>
                            <th class="chk-col"><div class="tick-all-header">Late<label><input type="checkbox" id="chkAllLate" class="chk-late" onchange="tickAll('late')" /><span class="tick-all-label">tick all</span></label></div></th>
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
                                    <td class="center"><asp:CheckBox ID="chkAbsent" runat="server" CssClass="chk-absent" onclick="handleCheck(this,'absent')" /></td>
                                    <td class="center"><asp:CheckBox ID="chkLate" runat="server" CssClass="chk-late" onclick="handleCheck(this,'late')" /></td>
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
                    <strong>Attendance History</strong>
                    <asp:Label ID="lblHistoryStatus" runat="server" CssClass="success-msg" />
                </div>
                <asp:Literal ID="litAttendanceHistory" runat="server" />
                <div class="table-footer">
                    <span>Attendance rate counts Present and Late as attended.</span>
                </div>
            </div>
        </asp:Panel>
    </div>
</div>
</form>

<script>
function getStatusBox(row, type) {
    var wrapper = row.querySelector('.chk-' + type);
    if (wrapper) return wrapper.querySelector('input[type=checkbox]');
    return row.querySelector('input.chk-' + type);
}

function handleCheck(cb, type) {
    var row = cb.closest('tr');
    ['present', 'absent', 'late'].forEach(function(t) {
        var box = getStatusBox(row, t);
        if (box && box !== cb) box.checked = false;
    });
    updateSummary();
}

function tickAll(type) {
    var allP = document.getElementById('chkAllPresent');
    var allA = document.getElementById('chkAllAbsent');
    var allL = document.getElementById('chkAllLate');

    if (type === 'present') { allA.checked = false; allL.checked = false; }
    if (type === 'absent') { allP.checked = false; allL.checked = false; }
    if (type === 'late') { allP.checked = false; allA.checked = false; }

    var checked = type === 'present' ? allP.checked : type === 'absent' ? allA.checked : allL.checked;

    document.querySelectorAll('#attBody tr').forEach(function(row) {
        if (row.classList.contains('hidden')) return;

        ['present', 'absent', 'late'].forEach(function(t) {
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
    document.querySelectorAll('#attBody tr').forEach(function(row) {
        var name = (row.getAttribute('data-name') || '').toLowerCase();
        var id = (row.getAttribute('data-id') || '').toLowerCase();
        row.classList.toggle('hidden', q !== '' && !name.includes(q) && !id.includes(q));
    });
    updateSummary();
}

function updateSummary() {
    var p = 0, a = 0, l = 0, total = 0;
    document.querySelectorAll('#attBody tr:not(.hidden)').forEach(function(row) {
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

window.onload = function() { updateSummary(); };
</script>
</body>
</html>