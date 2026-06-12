<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminInbox.aspx.cs" Inherits="StudentManagementSystem.AdminInbox" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

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
        
        <!-- SIDEBAR HEREE -->
        <uc:Navbar runat="server" ID="AdminSidebar" />

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