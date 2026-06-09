<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Assessment.aspx.cs" Inherits="LecturerPortal.Assessment" %>

<!DOCTYPE html>
<html>
<head>
    <title>Student Assessment</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: Segoe UI, sans-serif; background: #f0f2f5; margin: 0; }
        .layout { display: flex; min-height: 100vh; }

        .sidebar { width: 200px; background: #fff; border-right: 1px solid #e8e8e8; padding: 20px 14px; display: flex; flex-direction: column; gap: 4px; }
        .sidebar-avatar { display: flex; align-items: center; gap: 10px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #f0f0f0; }
        .avatar-circle { width: 40px; height: 40px; border-radius: 50%; background: #dbeafe; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; color: #1d4ed8; }
        .sidebar-name { font-size: 13px; font-weight: 600; color: #1a1a1a; }
        .sidebar-role { font-size: 11px; color: #888; }
        .nav-item { display: flex; align-items: center; gap: 8px; padding: 9px 10px; border-radius: 8px; font-size: 13px; color: #555; text-decoration: none; }
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

        select, input[type=text], input[type=number] {
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            font-size: 13px;
            color: #1a1a1a;
            background: #fff;
            min-width: 150px;
        }

        select:focus, input:focus { outline: none; border-color: #1d4ed8; }

        .btn { padding: 9px 18px; color: #fff; border: none; border-radius: 7px; font-size: 13px; cursor: pointer; margin-left: 6px; }
        .btn-blue { background: #1d4ed8; }
        .btn-blue:hover { background: #1e40af; }
        .btn-green { background: #16a34a; }
        .btn-green:hover { background: #15803d; }

        .table-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px 18px;
            border-bottom: 1px solid #f0f0f0;
            gap: 12px;
            flex-wrap: wrap;
            background: #fff;
        }

        .weight-box { font-size: 13px; color: #555; font-weight: 600; }

        table { width: 100%; border-collapse: collapse; min-width: 760px; }
        thead th {
            background: #f8f9fa;
            padding: 10px 14px;
            font-size: 11px;
            font-weight: 600;
            color: #555;
            text-transform: uppercase;
            border-bottom: 1px solid #e8e8e8;
            vertical-align: top;
        }

        tbody td {
            padding: 11px 14px;
            border-bottom: 1px solid #f5f5f5;
            font-size: 13px;
            color: #1a1a1a;
            vertical-align: middle;
        }

        tbody tr:hover td { background: #fafcff; }
        .student-id { font-family: Consolas, monospace; font-size: 12px; color: #555; }
        .mark-input { width: 90px; min-width: 90px; }
        .total-cell { font-weight: 700; color: #166534; }

        .success-msg { color: #16a34a; font-size: 13px; font-weight: 500; }
        .error-msg { color: #dc2626; font-size: 13px; font-weight: 500; }

        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.35);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }

        .modal-box {
            width: 820px;
            max-width: calc(100vw - 32px);
            max-height: calc(100vh - 32px);
            overflow: auto;
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e8e8e8;
            box-shadow: 0 20px 60px rgba(0,0,0,.2);
        }

        .modal-header { padding: 16px 18px; border-bottom: 1px solid #f0f0f0; font-size: 16px; font-weight: 600; }
        .modal-body { padding: 18px; }
        .modal-footer { padding: 14px 18px; border-top: 1px solid #f0f0f0; text-align: right; }

        .grid { width: 100%; border-collapse: collapse; margin-top: 16px; min-width: 0; }
        .grid th, .grid td { padding: 10px 12px; border-bottom: 1px solid #f0f0f0; font-size: 13px; }
        .grid a { color: #1d4ed8; text-decoration: none; margin-right: 8px; font-weight: 600; }
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
            <a href="Assessment.aspx" class="nav-item active">Assessment</a>
            <a href="Login.aspx" class="nav-item" style="margin-top:auto;color:#e74c3c;">Logout</a>
        </div>

        <div class="main">
            <div class="page-title">Student Assessment</div>
            <div class="page-sub">Select a course, add assessment columns, then enter marks for each student.</div>

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
                        <asp:Button ID="btnLoad" runat="server" Text="Load Students"
                            CssClass="btn btn-blue" OnClick="btnLoad_Click" />
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlTable" runat="server" Visible="false">
                <asp:HiddenField ID="hfCourseOfferID" runat="server" />

                <div class="table-card">
                    <div class="table-toolbar">
                        <div class="weight-box">
                            Total Weightage:
                            <asp:Label ID="lblTotalWeightage" runat="server" Text="0%" />
                        </div>

                        <div>
                            <asp:Button ID="btnEditStructure" runat="server" Text="Edit Columns"
                                CssClass="btn btn-blue" OnClick="btnOpenAssessmentModal_Click" />

                            <asp:Button ID="btnSaveScores" runat="server" Text="Save Marks"
                                CssClass="btn btn-green" OnClick="btnSaveScores_Click" />
                        </div>
                    </div>

                    <div style="padding:12px 18px;">
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
                <div class="filter-row">
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