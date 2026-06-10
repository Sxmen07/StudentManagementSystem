<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContactAdmin.aspx.cs" Inherits="StudentManagementSystem.ContactAdmin" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full">
<head runat="server">
    <title>UniTrack | Contact Support</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
</head>
<body class="h-full w-full m-0 p-0 flex items-center justify-center p-6 bg-[linear-gradient(rgba(0,0,0,0.5),rgba(0,0,0,0.5)),url('images/login_bg.jpg')] bg-cover bg-center bg-no-repeat bg-fixed font-['Poppins']">
    
    <form id="form1" runat="server" class="w-full max-w-xl bg-white/95 backdrop-blur-md p-8 rounded-xl border border-zinc-200 shadow-xl space-y-6" onkeydown="if(event.keyCode==13) { return false; }">
        
        <header class="border-b border-[#F1F1EF] pb-4">
            <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Contact System Administrator</h2>
            <p class="text-[#7C7B77] text-sm mt-1">No account? Submit a help request or account creation inquiry directly to the Head of Programme.</p>
        </header>

        <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3 rounded-md" Visible="false"></asp:Label>
        
        <div class="space-y-4">
            <div>
                <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Your Email Address</label>
                <asp:TextBox ID="txtSenderEmail" runat="server" TextMode="Email" CssClass="w-full bg-[#F7F7F5]/50 p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="name@example.com"></asp:TextBox>
            </div>

            <div>
                <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Subject / Ticket Topic</label>
                <asp:TextBox ID="txtSubject" runat="server" CssClass="w-full bg-[#F7F7F5]/50 p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="e.g., Requesting Student Account Creation"></asp:TextBox>
            </div>

            <div>
                <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Detailed Message Body</label>
                <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="6" CssClass="w-full bg-[#F7F7F5]/50 p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] resize-none" placeholder="Please provide your Full Name, Student ID (if applicable), and your course details..."></asp:TextBox>
            </div>

            <div class="pt-2 space-y-3">
                <asp:Button ID="btnSendMessage" runat="server" Text="Submit Support Ticket" 
                    CssClass="w-full bg-[#1A1A1A] text-white font-medium text-sm py-2.5 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm text-center font-semibold" 
                    OnClick="btnSendMessage_Click" />
                
                <div class="text-center">
                    <a href="Login.aspx" class="text-xs text-[#7C7B77] hover:text-[#1A1A1A] font-medium transition-colors inline-block pt-1">&larr; Return to Login Screen</a>
                </div>
            </div>
        </div>

    </form>
</body>
</html>