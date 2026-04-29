<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Inherits="StudentManagementSystem.Student.StudentProfile" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Student Information</h2>

        <asp:Label ID="lblMessage" runat="server"
    CssClass=""></asp:Label>

        <div class="">
            <asp:Button ID="btnEdit" runat="server"
                Text="Edit"
                CssClass=""
                OnClick="btnEdit_Click" />
            <asp:Button ID="btnSave" runat="server"
                Text="Save"
                CssClass=""
                OnClick="btnSave_Click"
                Visible="false" />
            <asp:Button ID="btnReset" runat="server"
                Text="Reset"
                CssClass=""
                OnClick="btnReset_Click"
                Visible="false" />
        </div>
        <div class="">
            <label>Student ID</label>
            <asp:TextBox ID="txtStudentID" runat="server"
                CssClass=""
                Placeholder="Student ID"
                ReadOnly="true"></asp:TextBox>
            <label>Student Name</label>
            <asp:TextBox ID="txtStudentName" runat="server"
                CssClass=""
                Placeholder="Student Name"
                ReadOnly="true"></asp:TextBox>
            <label>Student Email</label>
            <asp:TextBox ID="txtStudentEmail" runat="server"
                CssClass=""
                Placeholder="Student Email"
                ReadOnly="true"></asp:TextBox>
            <label>Personal Email</label>
            <asp:TextBox ID="txtPersonalEmail" runat="server"
                CssClass=""
                Placeholder="Personal Email"
                Enabled="false"></asp:TextBox>
            <label>Nationality</label>
            <asp:TextBox ID="txtNationality" runat="server"
                CssClass=""
                Placeholder="Nationality"
                Enabled="false"></asp:TextBox>
            <label>Sex</label>
            <asp:TextBox ID="txtSex" runat="server"
                CssClass=""
                Placeholder="Sex"
                Enabled="false"></asp:TextBox>
            <label>Date of Birth</label>
            <asp:TextBox ID="txtDateOfBirth" runat="server"
                CssClass=""
                Placeholder="Date of Birth"
                TextMode="Date"
                Enabled="false"></asp:TextBox>
            <label>Contact Number</label>
            <asp:TextBox ID="txtContactNumber" runat="server"
                CssClass=""
                Placeholder="Contact Number"
                Enabled="false"></asp:TextBox>
            <h4>Programme Information</h4>
            <label>Programme Code</label>
            <asp:TextBox ID="txtProgrammeCode" runat="server"
                CssClass=""
                Placeholder="Programme Code"
                Enabled="false"></asp:TextBox>
            <label>Programme Name</label>
            <asp:TextBox ID="txtProgrammeName" runat="server"
                CssClass=""
                Placeholder="Programme Name"
                Enabled="false"></asp:TextBox>
            <label>Intake Semester</label>
            <asp:TextBox ID="txtIntakeSemester" runat="server"
                CssClass=""
                Placeholder="Intake Semester"
                Enabled="false"></asp:TextBox>
            <label>Intake Year</label>
            <asp:TextBox ID="txtIntakeYear" runat="server"
                CssClass=""
                Placeholder="Intake Year"
                Enabled="false"></asp:TextBox>
            <label>Current Semester</label>
            <asp:TextBox ID="txtCurrentSemester" runat="server"
                CssClass=""
                Placeholder="Current Semester"
                Enabled="false"></asp:TextBox>
        </div>

        <div class="">
        </div>

    </form>
</body>
</html>
