<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminInbox.aspx.cs" Inherits="StudentManagementSystem.AdminInbox" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full overflow-hidden">
<head runat="server">
    <title>UniTrack Admin | Support Inbox</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
    </style>
    <script type="text/javascript">
        // Master toggle checkbox function to select/deselect all rows instantly
        function ToggleSelectAll(masterCheckbox) {
            var grid = document.getElementById('<%= gvAdminInbox.ClientID %>');
            var inputs = grid.getElementsByTagName("input");
            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].type == "checkbox" && inputs[i] != masterCheckbox) {
                    inputs[i].checked = masterCheckbox.checked;
                }
            }
        }
    </script>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <div class="group fixed left-0 top-0 h-screen w-16 hover:w-64 bg-zinc-950 text-white flex flex-col justify-between border-r border-zinc-900 transition-all duration-300 ease-in-out z-50 p-4 overflow-hidden shrink-0">
            <div>
                <h1 class="text-xl font-bold tracking-tighter text-white mb-8 h-8 flex items-center gap-4 whitespace-nowrap overflow-hidden pl-1">
                    <span class="w-4 h-4 rounded-sm bg-white shrink-0 block"></span> 
                    <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">UniTrack</span>
                </h1>
                <nav class="space-y-1.5">
                    <a href="AdminDashboard.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-lg shrink-0 w-4 text-center font-normal">⌂</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Dashboard Home</span>
                    </a>
                    <a href="AdminInbox.aspx" class="flex items-center gap-4 bg-zinc-800 p-2 rounded-md font-semibold text-sm transition-colors text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-base shrink-0 w-4 text-center font-bold">✉</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Support Inbox</span>
                    </a>
                </nav>
            </div>
            <div class="w-full h-9 overflow-hidden relative flex items-center justify-start pl-2">
                <span class="text-red-500 font-bold text-lg absolute left-3 pointer-events-none group-hover:opacity-0 transition-opacity duration-200">⏻</span>
                <div class="w-full opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                    <asp:Button ID="btnLogout" runat="server" Text="Log Out" CssClass="w-full bg-red-950/40 border border-red-900/30 hover:bg-red-900/60 text-red-400 font-medium text-xs py-2 rounded transition-colors cursor-pointer text-center block" OnClick="btnLogout_Click" />
                </div>
            </div>
        </div>

        <div class="flex-1 pl-20 pr-10 py-8 lg:pl-24 bg-white space-y-6 flex flex-col h-screen overflow-y-auto">
            <header class="border-b border-[#F1F1EF] pb-4 shrink-0 flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                <div>
                    <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Incoming Support Tickets</h2>
                    <p class="text-[#7C7B77] text-sm mt-0.5">Review and clear resolved system messages or student inquiries.</p>
                </div>
                
                <div class="shrink-0">
                    <asp:Button ID="btnMarkSolved" runat="server" Text="✓ Mark Selected as Solved" 
    CssClass="border border-zinc-200 text-zinc-700 bg-white hover:bg-zinc-50 hover:text-zinc-900 hover:border-zinc-300 font-medium text-xs px-4 py-2 rounded-md transition-all duration-150 cursor-pointer shadow-sm tracking-wide" 
    OnClick="btnMarkSolved_Click" />
                </div>
            </header>

            <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3 rounded-md" Visible="false"></asp:Label>

            <div class="bg-white rounded-lg border border-[#EBEBE9] p-6 shadow-sm">
                <asp:GridView ID="gvAdminInbox" runat="server" AutoGenerateColumns="False" DataKeyNames="MessageID" CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                    <Columns>
                        
                        <asp:TemplateField HeaderStyle-CssClass="pb-3 border-b border-[#EBEBE9] w-12 text-center" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-center">
                            <HeaderTemplate>
                                <input type="checkbox" onclick="ToggleSelectAll(this);" class="rounded text-zinc-900 focus:ring-zinc-950 cursor-pointer" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="chkSelect" runat="server" CssClass="rounded text-zinc-900 focus:ring-zinc-950 cursor-pointer" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="SenderEmail" HeaderText="Sender Email" 
                            HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] w-1/4" 
                            ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] font-semibold text-[#1A1A1A]" />
                        
                        <asp:BoundField DataField="Subject" HeaderText="Subject / Issue Topic" 
                            HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] w-1/4" 
                            ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] font-bold text-zinc-800" />
                        
                        <asp:BoundField DataField="MessageText" HeaderText="Detailed Message" 
                            HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] w-1/3" 
                            ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-zinc-600 leading-relaxed pr-4 whitespace-normal" />
                        
                        <asp:BoundField DataField="SubmissionDate" HeaderText="Received Time" DataFormatString="{0:yyyy-MM-dd HH:mm}" 
                            HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-center w-32" 
                            ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-[#7C7B77] text-center" />
                    </Columns>
                    
                    <EmptyDataTemplate>
                        <div class="text-center py-16 px-4">
                            <span class="text-4xl text-zinc-200 block mb-3">📥</span>
                            <p class="text-base font-semibold text-[#1A1A1A]">Your support inbox is totally clear</p>
                            <p class="text-xs text-[#7C7B77] mt-1">When guest users submit tickets via the Contact Admin page, they will show up here instantly.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

    </form>
</body>
</html>