<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="StudentManagementSystem.ForgotPassword" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full">
<head runat="server">
    <title>UniTrack | Recover Password</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
</head>
<body class="h-full w-full m-0 p-0 flex items-center justify-center p-6 bg-[linear-gradient(rgba(0,0,0,0.5),rgba(0,0,0,0.5)),url('images/login_bg.jpg')] bg-cover bg-center bg-no-repeat bg-fixed font-['Poppins']">
    
    <form id="form1" runat="server" class="w-full max-w-md bg-white/95 backdrop-blur-md p-8 rounded-xl border border-zinc-200 shadow-xl space-y-6" onkeydown="if(event.keyCode==13) { return false; }">
        
        <header class="border-b border-[#F1F1EF] pb-4">
            <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Account Recovery</h2>
            <p class="text-[#7C7B77] text-sm mt-1">Lost your security credentials? Enter your system email and identity number to provision a temporary access key.</p>
        </header>

        <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3 rounded-md" Visible="false"></asp:Label>
        
        <asp:Panel ID="pnlSuccessDetails" runat="server" CssClass="bg-emerald-50 border border-emerald-200 p-4 rounded-lg text-xs space-y-2 text-emerald-800" Visible="false">
            <p class="font-bold text-sm">✓ Reset Token Generated</p>
            <p>Your password has been securely updated. Please use the temporary key below to regain entry:</p>
            <div class="bg-white p-2.5 rounded border border-emerald-300 font-mono text-center text-sm font-bold tracking-wider select-all my-2 text-zinc-900">
                <asp:Literal ID="litTempPassword" runat="server"></asp:Literal>
            </div>
            <p class="text-[10px] text-emerald-600 font-medium">Important: Once you log back into your dashboard, update your profile settings immediately to change this password.</p>
        </asp:Panel>

        <asp:Panel ID="pnlFormFields" runat="server" class="space-y-4">
            <div>
                <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Registered Email Address</label>
                <asp:TextBox ID="txtRecoveryEmail" runat="server" TextMode="Email" CssClass="w-full bg-[#F7F7F5]/50 p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="e.g., student@inti.edu.my"></asp:TextBox>
            </div>

            <div>
                <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">IC / Passport Number</label>
                <asp:TextBox ID="txtIdentityNumber" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="e.g., 001122145566 or Passport No."></asp:TextBox>
            </div>

            <div class="pt-2 space-y-3">
                <asp:Button ID="btnResetRequest" runat="server" Text="Generate Access Key" 
                    CssClass="w-full bg-[#1A1A1A] text-white font-medium text-sm py-2.5 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm text-center font-semibold" 
                    OnClick="btnResetRequest_Click" />
            </div>
        </asp:Panel>

        <div class="text-center">
            <a href="Login.aspx" class="text-xs text-[#7C7B77] hover:text-[#1A1A1A] font-medium transition-colors inline-block pt-1">&larr; Return to Sign In</a>
        </div>

    </form>
</body>
</html>