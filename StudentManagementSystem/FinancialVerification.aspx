<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FinanceVerification.aspx.cs" Inherits="StudentManagementSystem.FinanceVerification" %>

<!DOCTYPE html>
<html>
<head>
    <title>Finance Verification Panel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f7f8fc;
            margin: 0;
            padding: 20px;
            color: #1f2937;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.06);
            padding: 24px;
        }
        h1 {
            font-size: 28px;
            font-weight: 700;
            margin: 0 0 4px 0;
            color: #111827;
        }
        .subtitle {
            font-size: 14px;
            color: #6b7280;
            margin-bottom: 24px;
        }
        .badge {
            display: inline-block;
            padding: 2px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-pending { background: #fef3c7; color: #92400e; }
        .badge-success { background: #d1fae5; color: #065f46; }
        .badge-failed { background: #fee2e2; color: #991b1b; }
        .badge-verified { background: #d1fae5; color: #065f46; }
        .badge-rejected { background: #fee2e2; color: #991b1b; }
        .badge-pending-blue { background: #dbeafe; color: #1e40af; }

        .grid-container {
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }
        th {
            background: #f3f4f6;
            color: #374151;
            font-weight: 700;
            padding: 12px 16px;
            text-align: left;
            border-bottom: 2px solid #e5e7eb;
            white-space: nowrap;
        }
        td {
            padding: 12px 16px;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
        }
        tr:hover td {
            background: #fafbfc;
        }
        .proof-link {
            color: #0095FD;
            text-decoration: none;
            font-weight: 600;
        }
        .proof-link:hover {
            text-decoration: underline;
        }
        .comment-box {
            width: 100%;
            max-width: 200px;
            padding: 6px 10px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 13px;
        }
        .btn {
            padding: 6px 16px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: background 0.15s;
            margin: 2px;
        }
        .btn-verify {
            background: #10b981;
            color: white;
        }
        .btn-verify:hover {
            background: #059669;
        }
        .btn-reject {
            background: #ef4444;
            color: white;
        }
        .btn-reject:hover {
            background: #dc2626;
        }
        .btn-refresh {
            background: #6b7280;
            color: white;
            padding: 8px 20px;
            margin-bottom: 16px;
        }
        .btn-refresh:hover {
            background: #4b5563;
        }
        .status-area {
            margin: 16px 0;
            padding: 12px 16px;
            border-radius: 8px;
            font-weight: 600;
        }
        .status-success { background: #d1fae5; color: #065f46; }
        .status-error { background: #fee2e2; color: #991b1b; }
        .empty-row td {
            padding: 40px;
            text-align: center;
            color: #9ca3af;
            font-style: italic;
        }
        .flex-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }
        .actions-cell {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 6px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="flex-row">
                <div>
                    <h1>💳 Finance Verification Panel</h1>
                    <p class="subtitle">Review and approve/reject student payment submissions</p>
                </div>
                <asp:Button ID="btnRefresh" runat="server" Text="↻ Refresh List" CssClass="btn btn-refresh" OnClick="btnRefresh_Click" />
            </div>

            <asp:Label ID="lblStatus" runat="server" CssClass="status-area" Visible="false" />

            <div class="grid-container">
                <asp:GridView ID="gvPayments" runat="server" AutoGenerateColumns="False" GridLines="None"
                    CssClass="min-w-full" OnRowDataBound="gvPayments_RowDataBound"
                    EmptyDataText="No pending payment submissions at this time.">
                    <Columns>
                        <asp:BoundField DataField="ReferenceID" HeaderText="Reference" ItemStyle-Font-Bold="true" />
                        <asp:BoundField DataField="StudentName" HeaderText="Student" />
                        <asp:BoundField DataField="SemesterDisplay" HeaderText="Semester" />
                        <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="RM {0:N2}" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField DataField="PaymentDate" HeaderText="Payment Date" DataFormatString="{0:yyyy-MM-dd}" />
                        <asp:BoundField DataField="UploadDate" HeaderText="Submitted" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                        <asp:TemplateField HeaderText="Proof">
                            <ItemTemplate>
                                <asp:HyperLink ID="lnkProof" runat="server" 
                                    NavigateUrl='<%# ResolveUrl(Eval("PaymentProof").ToString()) %>' 
                                    Target="_blank" CssClass="proof-link"
                                    Text="View Receipt" 
                                    Visible='<%# !string.IsNullOrEmpty(Eval("PaymentProof")?.ToString()) %>' />
                                <span style="color:#aaa;" runat="server" Visible='<%# string.IsNullOrEmpty(Eval("PaymentProof")?.ToString()) %>'>No file</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Student Status">
                            <ItemTemplate>
                                <span class='<%# GetStudentBadge(Eval("StudentStatus").ToString()) %>'><%# Eval("StudentStatus") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Verification">
                            <ItemTemplate>
                                <span class='<%# GetVerifiedBadge(Eval("VerifiedStatus").ToString()) %>'><%# Eval("VerifiedStatus") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <div class="actions-cell">
                                    <asp:TextBox ID="txtComment" runat="server" CssClass="comment-box" placeholder="Optional comment" />
                                    <asp:Button ID="btnVerify" runat="server" Text="Verify" CommandName="Verify" 
                                        CommandArgument='<%# Eval("PaymentID") %>' CssClass="btn btn-verify" OnClick="btnAction_Click" />
                                    <asp:Button ID="btnReject" runat="server" Text="Reject" CommandName="Reject" 
                                        CommandArgument='<%# Eval("PaymentID") %>' CssClass="btn btn-reject" OnClick="btnAction_Click" />
                                </div>
                            </ItemTemplate>
                            <ItemStyle CssClass="actions-cell" />
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataRowStyle CssClass="empty-row" />
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>