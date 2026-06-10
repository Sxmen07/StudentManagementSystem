<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageAnnouncements.aspx.cs" Inherits="StudentManagementSystem.ManageAnnouncements" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Announcement Hub</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 pl-20 pr-10 py-10 lg:pl-10 overflow-y-auto bg-white h-full">
            <header class="mb-8 border-b border-[#F1F1EF] pb-5">
                <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Broadcast Communications Control</h2>
                <p class="text-[#7C7B77] text-sm">Draft, target, and dispatch systemic bulletins or priority notices out to role-specific target domains.</p>
            </header>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                
                <div class="bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] h-fit">
                    <h3 class="text-sm font-semibold mb-6 text-[#1A1A1A]">Publish Bulletin Notice</h3>
                    
                    <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium mb-4 p-2.5 rounded-md" Visible="false"></asp:Label>
                    <asp:HiddenField ID="hfAnnouncementID" runat="server" />

                    <div class="space-y-4">
                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Bulletin Header Title</label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="e.g., Campus Maintenance Update"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Detailed Announcement Context</label>
                            <asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" Rows="5" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors resize-none" placeholder="Draft notice details here..."></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Target Audience Routing</label>
                            <div class="bg-white p-3 rounded border border-[#EBEBE9] space-y-2 text-xs font-medium">
                                <label class="flex items-center gap-2.5 cursor-pointer text-[#2F2F2F]">
                                    <asp:CheckBox ID="chkAdmin" runat="server" /> System Administrators (Admins)
                                </label>
                                <label class="flex items-center gap-2.5 cursor-pointer text-[#2F2F2F]">
                                    <asp:CheckBox ID="chkLecturer" runat="server" /> Academic Faculty Members (Lecturers)
                                </label>
                                <label class="flex items-center gap-2.5 cursor-pointer text-[#2F2F2F]">
                                    <asp:CheckBox ID="chkStudent" runat="server" /> Registered Student Cohorts (Students)
                                </label>
                            </div>
                        </div>

                        <div class="pt-2 space-y-2">
                            <asp:Button ID="btnPublish" runat="server" Text="Broadcast Announcement" 
                                CssClass="w-full bg-[#1A1A1A] text-white font-medium text-sm py-2.5 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm" 
                                OnClick="btnPublish_Click" />
                            <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel Modification" 
                                CssClass="w-full bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs py-2 rounded hover:bg-[#F4F4F2] transition-colors cursor-pointer" 
                                OnClick="btnCancelEdit_Click" Visible="false" />
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-2 bg-white rounded-lg border border-[#EBEBE9] p-6">
                    <h4 class="text-sm font-semibold text-[#1A1A1A] mb-4 border-b border-[#F1F1EF] pb-4">Active Broadcast Streams Directory</h4>

                    <asp:GridView ID="gvAnnouncements" runat="server" AutoGenerateColumns="False" DataKeyNames="AnnouncementID" OnRowCommand="gvAnnouncements_RowCommand" CssClass="w-full text-left text-sm border-collapse" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="Title" HeaderText="Announcement Header" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase w-1/4" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] font-bold text-[#1A1A1A]" />
                            
                            <asp:TemplateField HeaderText="Broadcast Distribution Tiers" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase w-1/4">
                                <ItemTemplate>
                                    <div class="flex flex-wrap gap-1 text-[10px] font-bold">
                                        <%# Convert.ToBoolean(Eval("TargetAdmin")) ? "<span class='bg-zinc-100 text-zinc-800 px-1.5 py-0.5 rounded'>Admin</span>" : "" %>
                                        <%# Convert.ToBoolean(Eval("TargetLecturer")) ? "<span class='bg-blue-50 text-blue-700 px-1.5 py-0.5 rounded'>Lecturer</span>" : "" %>
                                        <%# Convert.ToBoolean(Eval("TargetStudent")) ? "<span class='bg-emerald-50 text-emerald-700 px-1.5 py-0.5 rounded'>Student</span>" : "" %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="CreatedDate" HeaderText="Dispatched Date" DataFormatString="{0:yyyy-MM-dd HH:mm}" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase w-32 text-center" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-[#7C7B77] text-xs text-center" />
                            
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase text-right" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-right w-40">
                                <ItemTemplate>
                                    <div class="inline-flex gap-2 justify-end w-full">
                                        <asp:Button ID="btnEdit" runat="server" CommandName="EditAnnouncement" CommandArgument='<%# Eval("AnnouncementID") %>' Text="Edit" 
                                            CssClass="bg-zinc-100 hover:bg-zinc-200 text-zinc-800 text-xs font-medium px-2.5 py-1 rounded transition-colors cursor-pointer border border-zinc-200" />
                                        <asp:Button ID="btnDelete" runat="server" CommandName="DeleteAnnouncement" CommandArgument='<%# Eval("AnnouncementID") %>' Text="Delete" 
                                            OnClientClick="return confirm('Are you sure you want to permanently delete this broadcast announcement stream? This will retract visibility from all target routing lines immediately.');" 
                                            CssClass="bg-red-50 hover:bg-red-100 text-red-600 text-xs font-medium px-2.5 py-1 rounded transition-colors cursor-pointer border border-red-200" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="text-center py-12 text-zinc-400 text-xs font-medium">
                                No system-wide announcements currently found in the active history cache.
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>
    </form>
</body>
</html>