<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="LecturerPortal.Attendance" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Attendance</title>
    <style>
        body { font-family: Segoe UI, sans-serif; background: #f0f2f5; margin: 0; }
        .navbar { background: #2c3e50; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; }
        .navbar a { color: #3498db; text-decoration: none; margin-left: 20px; }
        .container { max-width: 950px; margin: 40px auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 15px rgba(0,0,0,0.08); }
        h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .filter-row { display: flex; gap: 15px; flex-wrap: wrap; margin-bottom: 25px; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; }
        label { font-weight: 600; color: #555; font-size: 13px; margin-bottom: 4px; }
        select, input[type=text] { padding: 9px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; min-width: 160px; }
        .btn { padding: 9px 20px; background: #3498db; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; }
        .btn-green { background: #27ae60; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #2c3e50; color: white; padding: 10px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #eee; }
        tr:hover td { background: #f9f9f9; }
        .success { color: green; font-weight: bold; margin-top: 15px; display: block; }
    </style>
</head>
<body>
<div class="navbar">
    <span>Lecturer Portal — <asp:Label ID="lblWelcome" runat="server" /></span>
    <div>
        <a href="LectProfile.aspx">LectProfile</a>
        <a href="Assessment.aspx">Assessment</a>
        <a href="Login.aspx">Logout</a>
    </div>
</div>
<div class="container">
    <h2>Student Attendance</h2>
    <form id="form1" runat="server">
    <div class="filter-row">
        <div class="filter-group">
            <label>Programme</label>
            <asp:DropDownList ID="ddlProgramme" runat="server" AutoPostBack="true"
                OnSelectedIndexChanged="ddlProgramme_Changed" />
        </div>
        <div class="filter-group">
            <label>Course Offer</label>
            <asp:DropDownList ID="ddlCourseOffer" runat="server" />
        </div>
        <div class="filter-group">
            <label>Date</label>
            <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
        </div>
        <div>
            <asp:Button ID="btnLoad" runat="server" Text="Load Students"
                CssClass="btn" OnClick="btnLoad_Click" style="margin-top:18px" />
        </div>
    </div>

    <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="false"
        DataKeyNames="StudentID" OnRowDataBound="gvAttendance_RowDataBound"
        EmptyDataText="No students enrolled in this course offer.">
        <Columns>
            <asp:BoundField DataField="StudentID"   HeaderText="Student ID" />
            <asp:BoundField DataField="StudentName" HeaderText="Name" />
            <asp:BoundField DataField="StudentEmail" HeaderText="Email" />
            <asp:TemplateField HeaderText="Status">
                <ItemTemplate>
                    <asp:DropDownList ID="ddlStatus" runat="server">
                        <asp:ListItem Value="Present">Present</asp:ListItem>
                        <asp:ListItem Value="Late">Late</asp:ListItem>
                        <asp:ListItem Value="Absent">Absent</asp:ListItem>
                    </asp:DropDownList>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <asp:Button ID="btnSave" runat="server" Text="Save Attendance" CssClass="btn btn-green"
        OnClick="btnSave_Click" Style="margin-top:20px" Visible="false" />
    <asp:Label ID="lblStatus" runat="server" CssClass="success" />

    <%-- Hidden field to persist CourseOfferID across postbacks --%>
    <asp:HiddenField ID="hfCourseOfferID" runat="server" />
    </form>
</div>
</body>
</html>