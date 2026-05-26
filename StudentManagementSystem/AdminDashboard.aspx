<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="StudentManagementSystem.AdminDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-black">
<head runat="server">
    <title>UniTrack | Admin Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-white bg-black">
    <form id="form1" runat="server" class="h-full flex">
        
        <div class="w-64 bg-zinc-950 h-full p-6 text-white flex flex-col justify-between border-r border-zinc-800">
            <div>
                <h1 class="text-2xl font-bold tracking-tighter mb-8">UniTrack</h1>
                <nav class="space-y-2">
                    <a href="#" class="block bg-zinc-800 px-4 py-3 rounded-md font-medium text-sm transition-colors">Create Accounts</a>
                    <a href="#" class="block hover:bg-zinc-900 px-4 py-3 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white">Manage Users</a>
                </nav>
            </div>
            <div>
                <asp:Button ID="btnLogout" runat="server" Text="Log Out" 
                    CssClass="w-full bg-zinc-900 border border-zinc-800 hover:bg-red-950 hover:text-red-400 hover:border-red-900 text-white font-medium text-xs py-2 rounded transition-colors cursor-pointer" 
                    OnClick="btnLogout_Click" />
            </div>
        </div>

        <div class="flex-1 p-10 overflow-y-auto bg-black">
            <header class="mb-8 border-b border-zinc-800 pb-5">
                <h2 class="text-3xl font-bold tracking-tight text-white">Admin System Management</h2>
                <p class="text-zinc-500 text-sm">Register new institutional system profiles below.</p>
            </header>

            <div class="bg-zinc-950 p-8 rounded-xl max-w-xl border border-zinc-800 shadow-none">
                <h3 class="text-lg font-semibold mb-6 text-white">Create New User Profile</h3>
                
                <asp:Label ID="lblStatus" runat="server" CssClass="block text-sm font-medium mb-4" Visible="false"></asp:Label>

                <div class="space-y-5">
                    <div>
                        <label class="block text-xs font-semibold text-zinc-500 uppercase tracking-wider mb-2">Username / Corporate Email</label>
                        <asp:TextBox ID="txtNewUsername" runat="server" CssClass="w-full bg-zinc-900 p-3 text-sm rounded outline-none border-b-2 border-transparent focus:border-white text-white placeholder-zinc-600 transition-colors" placeholder="e.g., staff@inti.edu.my"></asp:TextBox>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-zinc-500 uppercase tracking-wider mb-2">Temporary Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="w-full bg-zinc-900 p-3 text-sm rounded outline-none border-b-2 border-transparent focus:border-white text-white placeholder-zinc-600 transition-colors" placeholder="••••••••"></asp:TextBox>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-zinc-500 uppercase tracking-wider mb-2">Assigned Institutional Role</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="w-full bg-zinc-900 p-3 text-sm rounded outline-none border-b-2 border-transparent focus:border-white text-white transition-colors cursor-pointer">
                            <asp:ListItem Value="">-- Select Access Tier --</asp:ListItem>
                            <asp:ListItem Value="Student">Student</asp:ListItem>
                            <asp:ListItem Value="Lecturer">Lecturer</asp:ListItem>
                            <asp:ListItem Value="Admin">Admin</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="pt-2">
                        <asp:Button ID="btnCreateAccount" runat="server" Text="Register Account" 
                            CssClass="w-full bg-white text-black font-bold text-sm py-4 rounded-md shadow-none hover:bg-zinc-200 transition-colors cursor-pointer" 
                            OnClick="btnCreateAccount_Click" />
                    </div>
                </div>
            </div>
        </div>

    </form>
</body>
</html>