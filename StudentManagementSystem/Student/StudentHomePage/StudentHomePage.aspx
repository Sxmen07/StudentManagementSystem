<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentHomePage.aspx.cs" Inherits="StudentManagementSystem.StudentHomePage" %>

<%@ Register Src="~/TopBar.ascx" TagName="TopBar" TagPrefix="uc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Student Home Page</title>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body>
    <form id="form1" runat="server">
        <uc1:TopBar ID="TopBar1" runat="server" />
        <div>
            <h2 class="text-2xl font-bold mb-4">Welcome</h2>
        </div>
    </form>
</body>
</html>
