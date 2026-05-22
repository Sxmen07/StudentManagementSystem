<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LectProfile.aspx.cs" Inherits="LecturerPortal.Dashboard" %>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <style>
        body { font-family: Segoe UI, sans-serif; background: #f0f2f5; margin: 0; }
        .navbar { background: #2c3e50; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; }
        .navbar a { color: #3498db; text-decoration: none; margin-left: 20px; }
        .container { max-width: 800px; margin: 40px auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 15px rgba(0,0,0,0.08); }
        h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-group { display: flex; flex-direction: column; }
        label { font-weight: 600; color: #555; margin-bottom: 5px; font-size: 13px; }
        input[type=text] { padding: 9px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; }
        .full-width { grid-column: span 2; }
        .btn { padding: 11px 28px; background: #3498db; color: white; border: none; border-radius: 6px; font-size: 15px; cursor: pointer; margin-top: 20px; }
        .btn:hover { background: #2980b9; }
        .success { color: green; font-weight: bold; margin-top: 10px; display: block; }
    </style>
</head>
<body>
<div class="navbar">
    <span>Lecturer Portal — <asp:Label ID="lblWelcome" runat="server" /></span>
    <div>
        <a href="Attendance.aspx">Attendance</a>
        <a href="Assessment.aspx">Assessment</a>
        <a href="Login.aspx">Logout</a>
    </div>
</div>
<div class="container">
    <h2>Manage Personal Information</h2>
    <form id="form1" runat="server">
    <div class="form-grid">
        <div class="form-group">
            <label>Full Name</label>
            <asp:TextBox ID="txtName" runat="server" />
        </div>
        <div class="form-group">
            <label>Email</label>
            <asp:TextBox ID="txtEmail" runat="server" />
        </div>
        <div class="form-group">
            <label>New Password (leave blank to keep)</label>
            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" />
        </div>
        <div class="form-group">
            <label>Contact No</label>
            <asp:TextBox ID="txtContact" runat="server" />
        </div>
        <div class="form-group full-width">
            <label>Department</label>
            <asp:TextBox ID="txtDepartment" runat="server" />
        </div>
    </div>
    <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn" OnClick="btnSave_Click" />
    <asp:Label ID="lblStatus" runat="server" CssClass="success" />
    </form>
</div>
</body>
</html>