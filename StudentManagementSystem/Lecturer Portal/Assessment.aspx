<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Assessment.aspx.cs" Inherits="LecturerPortal.Assessment" %>

<!DOCTYPE html>
<html>
<head>
    <title>Student Assessment</title>
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

        .filter-card, .table-card, .export-card {
            background: rgba(255,255,255,0.96);
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 22px;
            margin-bottom: 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
            transition: 0.2s ease;
        }

        .filter-card:hover, .table-card:hover, .export-card:hover {
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

        select, input[type=text], input[type=number] {
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

        select:focus, input:focus {
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

        .btn-blue, .btn-primary {
            background: linear-gradient(135deg, #00CBD4, #0ea5e9);
        }

        .btn-blue:hover, .btn-primary:hover {
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

        .btn-container {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .table-card {
            padding: 0;
            overflow-x: auto;
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

        .weight-box {
            font-size: 13px;
            color: #4b5563;
            font-weight: 800;
        }

        .status-area {
            padding: 14px 22px 4px;
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

        .mark-input {
            width: 100%;
            max-width: 90px;
            min-width: 65px;
        }

        .total-cell {
            font-weight: 800;
            color: #0284c7;
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

        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(15,23,42,.45);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            padding: 16px;
        }

        .modal-box {
            width: 100%;
            max-width: 820px;
            max-height: calc(100vh - 32px);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            background: #fff;
            border-radius: 20px;
            border: 1px solid #e5e7eb;
            box-shadow: 0 24px 70px rgba(0,0,0,.22);
        }

        .modal-header {
            padding: 18px 22px;
            border-bottom: 1px solid #eef2f7;
            font-size: 16px;
            font-weight: 800;
            color: #111827;
            flex-shrink: 0;
        }

        .modal-body {
            padding: 22px;
            overflow-y: auto;
            flex: 1;
        }

        .modal-footer {
            padding: 16px 22px;
            border-top: 1px solid #eef2f7;
            text-align: right;
            flex-shrink: 0;
            background: #fbfdff;
        }

        .grid {
            width: 100%;
            border-collapse: collapse;
            margin-top: 16px;
        }

        .grid th, .grid td {
            padding: 12px;
            border-bottom: 1px solid #f0f0f0;
            font-size: 13px;
            text-align: left;
        }

        .grid a {
            color: #0284c7;
            text-decoration: none;
            margin-right: 8px;
            font-weight: 800;
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

            .table-toolbar {
                flex-direction: column;
                align-items: flex-start;
            }

            .btn-container {
                width: 100%;
            }

            .btn {
                flex: 1;
                min-width: 120px;
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
            <a href="Attendance.aspx" class="nav-item">📝 Attendance</a>
            <a href="Assessment.aspx" class="nav-item active">📊 Assessment</a>
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
                    <asp:Label ID="lblWelcomeName" runat="server" />
                </div>
            </div>
        </div>

            <div class="page-title">Student Assessment</div>
            <div class="page-sub">Select a course, add assessment columns, then enter marks for each student.</div>

            <div class="filter-card">
                <div class="section-title">Select Course</div>

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
                        <asp:Button ID="btnLoad" runat="server" Text="Load Students"
                            Style="width: 100%" CssClass="btn btn-blue" OnClick="btnLoad_Click" />
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlExportOptions" runat="server" CssClass="export-card">
                <strong style="font-size:13px; color:#555;">Export Summary Report:</strong>

                <asp:DropDownList ID="ddlExportType" runat="server"
                    Style="width:140px; display:inline-block; margin:0 10px;">
                    <asp:ListItem Text="Excel (.xls)" Value="xls" />
                    <asp:ListItem Text="Word (.doc)" Value="doc" />
                    <asp:ListItem Text="CSV Vector (.csv)" Value="csv" />
                </asp:DropDownList>

                <asp:Button ID="btnDownloadReport" runat="server" Text="Download"
                    CssClass="btn btn-primary" OnClick="btnDownloadReport_Click" />
            </asp:Panel>

            <asp:Panel ID="pnlTable" runat="server" Visible="false">
                <asp:HiddenField ID="hfCourseOfferID" runat="server" />

                <div class="table-card">
                    <div class="table-toolbar">
                        <div class="weight-box">
                            Total Weightage:
                            <asp:Label ID="lblTotalWeightage" runat="server" Text="0%" />
                        </div>

                        <div class="btn-container">
                            <asp:Button ID="btnEditStructure" runat="server" Text="Edit Columns"
                                CssClass="btn btn-blue" OnClick="btnOpenAssessmentModal_Click" />

                            <asp:Button ID="btnSaveScores" runat="server" Text="Save Marks"
                                CssClass="btn btn-green" OnClick="btnSaveScores_Click" />
                        </div>
                    </div>

                    <div class="status-area">
                        <asp:Label ID="lblStatus" runat="server" />
                    </div>

                    <asp:Literal ID="litAssessmentTable" runat="server" />
                </div>
            </asp:Panel>
        </div>
    </div>

    <asp:Panel ID="pnlAssessmentModal" runat="server" Visible="false" CssClass="modal-overlay">
        <div class="modal-box">
            <div class="modal-header">Edit Assessment Columns</div>

            <div class="modal-body">
                <div class="filter-row" style="margin-bottom: 20px;">
                    <div class="filter-group">
                        <span class="filter-label">Assessment Name</span>
                        <asp:TextBox ID="txtAssessmentName" runat="server" placeholder="Assignment 1" />
                    </div>

                    <div class="filter-group">
                        <span class="filter-label">Max Marks</span>
                        <asp:TextBox ID="txtMaxMarks" runat="server" TextMode="Number" placeholder="100" />
                    </div>

                    <div class="filter-group">
                        <span class="filter-label">Weightage %</span>
                        <asp:TextBox ID="txtWeightage" runat="server" TextMode="Number" placeholder="20" />
                    </div>

                    <div class="filter-group">
                        <asp:Button ID="btnAddAssessment" runat="server" Text="Add Column"
                            CssClass="btn btn-blue" OnClick="btnAddAssessment_Click" />
                    </div>
                </div>

                <div style="overflow-x: auto; width: 100%;">
                    <asp:GridView ID="gvAssessments" runat="server"
                        CssClass="grid"
                        AutoGenerateColumns="false"
                        DataKeyNames="AssessmentID"
                        OnRowEditing="gvAssessments_RowEditing"
                        OnRowUpdating="gvAssessments_RowUpdating"
                        OnRowCancelingEdit="gvAssessments_RowCancelingEdit"
                        OnRowDeleting="gvAssessments_RowDeleting">

                        <Columns>
                            <asp:BoundField DataField="AssessmentName" HeaderText="Assessment Name" />
                            <asp:BoundField DataField="MaxMarks" HeaderText="Max Marks" />
                            <asp:BoundField DataField="Weightage" HeaderText="Weightage %" />
                            <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="modal-footer">
                <asp:Button ID="btnCloseAssessmentModal" runat="server" Text="Done"
                    CssClass="btn btn-green" OnClick="btnCloseAssessmentModal_Click" />
            </div>
        </div>
    </asp:Panel>
</form>

<script>
    function updateTotals() {
        document.querySelectorAll("tbody tr").forEach(function (row) {
            var total = 0;

            row.querySelectorAll(".mark-input").forEach(function (input) {
                var mark = parseFloat(input.value || "0");
                var max = parseFloat(input.getAttribute("max") || "0");
                var weight = parseFloat(input.getAttribute("data-weight") || "0");

                if (mark > max) {
                    input.value = max;
                    mark = max;
                }

                if (mark < 0) {
                    input.value = 0;
                    mark = 0;
                }

                if (max > 0) {
                    total += (mark / max) * weight;
                }
            });

            var totalCell = row.querySelector(".total-cell");
            if (totalCell) {
                totalCell.textContent = total.toFixed(2) + "%";
            }
        });
    }
</script>
</body>
</html>