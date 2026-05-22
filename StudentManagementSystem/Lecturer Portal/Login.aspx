<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="LecturerPortal.Login" %>
<!DOCTYPE html>
<html>
<head>
    <title>Lecturer Login</title>
    <style>
        body { font-family: Segoe UI, sans-serif; background: #f0f2f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-box { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); width: 380px; }
        h2 { text-align: center; color: #2c3e50; margin-bottom: 30px; }
        label { display: block; margin-bottom: 5px; color: #555; font-weight: 600; }
        input[type=text], input[type=password] { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; margin-bottom: 20px; font-size: 14px; box-sizing: border-box; }
        input[type=submit] { width: 100%; padding: 12px; background: #3498db; color: white; border: none; border-radius: 6px; font-size: 16px; cursor: pointer; }
        input[type=submit]:hover { background: #2980b9; }
        .error { color: red; font-size: 13px; margin-bottom: 15px; }
    </style>
</head>
<body>
<div class="login-box">
    <h2>Lecturer Portal</h2>
    <form id="form1" runat="server">
        <label>Email</label>
        <asp:TextBox ID="txtEmail" runat="server" placeholder="xxx@lecturer.unitrack" Width="100%" />
        
        <label>Password</label>
        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Enter password" Width="100%" />
        
        <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false" />
        
        <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" />
    </form>
</div>
</body>
</html>