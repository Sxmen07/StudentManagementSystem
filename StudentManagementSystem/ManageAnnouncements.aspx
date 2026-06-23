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
        
        <!-- SIDEBAR NAVIGATION SYSTEM -->
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <!-- MAIN WINDOW STREAM CONTENT CONTAINER -->
        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <!-- EXPLICIT BANNER HEADER DESIGN -->
            <div class="bg-[#F4F7FC] border-b border-[#E3E8F0] px-12 py-10 relative overflow-hidden shrink-0">
                <!-- Decorative Abstract Circles -->
                <div class="absolute -left-6 -bottom-6 w-24 h-24 rounded-full border-[12px] border-[#3B82F6]/20 pointer-events-none"></div>
                <div class="absolute right-4 -bottom-10 w-40 h-40 rounded-full border-[16px] border-[#06B6D4]/20 pointer-events-none"></div>
                <div class="absolute right-20 -bottom-4 w-28 h-28 rounded-full border-[12px] border-[#3B82F6]/10 pointer-events-none"></div>

                <div class="max-w-4xl mx-auto flex items-center justify-between relative z-10">
                    <div class="flex items-center gap-6">
                        <!-- Blue Loudspeaker Icon Container -->
                        <div class="w-14 h-14 bg-[#3B82F6] text-white rounded-xl flex items-center justify-center text-2xl shadow-md font-bold select-none">
                            📢
                        </div>
                        <div>
                            <h2 class="text-3xl font-bold tracking-tight text-[#1A1A1A]">Announcements</h2>
                            <p class="text-[#7C7B77] text-xs mt-1">View broadcast notifications or dispatch new directives out to institutional domains.</p>
                        </div>
                    </div>
                    <!-- TRIGGER MODAL POPUP BUTTON -->
                    <asp:LinkButton ID="lnkOpenModal" runat="server" OnClick="lnkOpenModal_Click" CssClass="bg-[#3B82F6] hover:bg-blue-600 text-white font-semibold text-xs px-4 py-2.5 rounded-lg shadow-sm transition-colors flex items-center gap-2 cursor-pointer">
                        <span>+ Post an Announcement</span>
                    </asp:LinkButton>
                </div>
            </div>

            <!-- CORE BULLETIN FEED FRAME (ENLARGED CARD LAYOUT) -->
            <div class="flex-1 px-12 py-8 overflow-y-auto">
                <div class="max-w-4xl mx-auto space-y-5">
                    
                    <!-- STATUS NOTIFICATIONS DISPLAY -->
                    <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3 rounded-lg shadow-sm mb-4" Visible="false"></asp:Label>

                    <!-- BULLETIN FEED REPEATER CARDS VIEW -->
                    <asp:Repeater ID="rptAnnouncements" runat="server" OnItemCommand="rptAnnouncements_ItemCommand" OnItemDataBound="rptAnnouncements_ItemDataBound">
                        <ItemTemplate>
                            <!-- Card Container with Left Border logic: All 3 (Red), Admin (Blue), Lecturer (Orange), Student (Green) -->
                            <div class="bg-white rounded-xl border border-[#EBEBE9] p-6 shadow-sm hover:shadow-md transition-shadow flex flex-col gap-4 relative overflow-hidden group">
                                
                                <div class='absolute left-0 top-0 bottom-0 w-1.5 
                                    <%# (Convert.ToBoolean(Eval("TargetAdmin")) && Convert.ToBoolean(Eval("TargetLecturer")) && Convert.ToBoolean(Eval("TargetStudent"))) ? "bg-red-500" : 
                                        Convert.ToBoolean(Eval("TargetAdmin")) ? "bg-blue-500" : 
                                        Convert.ToBoolean(Eval("TargetLecturer")) ? "bg-orange-500" : "bg-emerald-500" %>'>
                                </div>
                                
                                <!-- TOP ROW: SENDER INFORMATION TRACK -->
                                <div class="flex items-center justify-between w-full pl-2">
                                    <div class="flex items-center gap-3.5">
                                        <!-- Profile Picture Container with safe default image fallback logic -->
                                        <div class="w-11 h-11 rounded-full overflow-hidden border border-zinc-200/80 shrink-0 bg-zinc-50 flex items-center justify-center shadow-sm">
                                            <img src='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ProfilePictureUrl"))) 
                                                          ? ResolveUrl("~/profile_upload/default-avatar.jpg") 
                                                          : ResolveUrl(Convert.ToString(Eval("ProfilePictureUrl"))) %>' 
                                                 alt="Avatar" class="w-full h-full object-cover" />
                                        </div>
                                        <div>
                                            <!-- Sender Registered Full Corporate Identity Name -->
                                            <h5 class="font-bold text-sm text-[#1A1A1A] tracking-tight">
                                                <%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("HopName"))) ? Eval("HopName") : "System Administrator" %>
                                            </h5>
                                            <div class="text-[10px] text-[#9A9996] font-medium mt-0.5">
                                                <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("yyyy-MM-dd • hh:mm tt") %>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- AUDIENCE CHIP BADGES (Includes Red for All Roles) -->
                                    <div class="flex gap-1 text-[9px] uppercase tracking-wider font-bold">
                                        <%# (Convert.ToBoolean(Eval("TargetAdmin")) && Convert.ToBoolean(Eval("TargetLecturer")) && Convert.ToBoolean(Eval("TargetStudent"))) ? 
                                            "<span class='bg-red-50 text-red-600 px-2 py-0.5 rounded border border-red-100'>All Audiences</span>" : "" %>
                                        
                                        <%# !(Convert.ToBoolean(Eval("TargetAdmin")) && Convert.ToBoolean(Eval("TargetLecturer")) && Convert.ToBoolean(Eval("TargetStudent"))) && Convert.ToBoolean(Eval("TargetAdmin")) ? 
                                            "<span class='bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded border border-blue-100'>Admin</span>" : "" %>
                                        
                                        <%# !(Convert.ToBoolean(Eval("TargetAdmin")) && Convert.ToBoolean(Eval("TargetLecturer")) && Convert.ToBoolean(Eval("TargetStudent"))) && Convert.ToBoolean(Eval("TargetAdmin")) ? "" : Convert.ToBoolean(Eval("TargetLecturer")) ? 
                                            "<span class='bg-orange-50 text-orange-600 px-1.5 py-0.5 rounded border border-orange-100'>Lecturer</span>" : "" %>
                                        
                                        <%# !(Convert.ToBoolean(Eval("TargetAdmin")) && Convert.ToBoolean(Eval("TargetLecturer")) && Convert.ToBoolean(Eval("TargetStudent"))) && Convert.ToBoolean(Eval("TargetAdmin")) ? "" : Convert.ToBoolean(Eval("TargetStudent")) ? 
                                            "<span class='bg-emerald-50 text-emerald-600 px-1.5 py-0.5 rounded border border-emerald-100'>Student</span>" : "" %>
                                    </div>
                                </div>

                                <!-- MIDDLE ROW: BIGGER ANNOUNCEMENT HEADER TITLE -->
                                <div class="pl-2 space-y-1.5 border-t border-zinc-100/60 pt-3">
                                    <h4 class="font-bold text-base text-[#1A1A1A] tracking-tight leading-snug">
                                        <%# Eval("Title") %>
                                    </h4>
                                    <!-- NOTICE CONTENT DETAILS DESCRIPTION -->
                                    <p class="text-xs text-[#5F5E5B] leading-relaxed pr-6 whitespace-pre-line">
                                        <%# Eval("ContentText") %>
                                    </p>
                                </div>

                                <!-- ADMINISTRATIVE ACTION CONTROL PANEL (Author Protected) -->
                                <asp:PlaceHolder ID="phAuthorControls" runat="server">
                                    <div class="absolute right-4 bottom-4 opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1 bg-white/90 backdrop-blur-sm pl-2 py-1 rounded-md">
                                        <asp:LinkButton ID="lnkEdit" runat="server" CommandName="Edit" CommandArgument='<%# Eval("AnnouncementID") %>' CssClass="text-zinc-600 hover:text-zinc-900 bg-zinc-50 border border-zinc-200 hover:bg-zinc-100 px-2.5 py-1 text-[11px] font-medium rounded-md transition-colors shadow-sm">
                                            Edit
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="lnkDelete" runat="server" CommandName="Delete" CommandArgument='<%# Eval("AnnouncementID") %>' OnClientClick="return confirm('Retract this announcement stream permanently?');" CssClass="text-red-600 hover:text-red-700 bg-red-50 border border-red-100 hover:bg-red-100/70 px-2.5 py-1 text-[11px] font-medium rounded-md transition-colors shadow-sm">
                                            Delete
                                        </asp:LinkButton>
                                    </div>
                                </asp:PlaceHolder>

                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Panel ID="pnlEmpty" runat="server" Visible='<%# rptAnnouncements.Items.Count == 0 %>' class="text-center py-16 bg-white border border-[#EBEBE9] rounded-xl">
                                <span class="text-3xl block mb-2">📭</span>
                                <p class="text-xs font-medium text-[#9A9996]">No administrative broadcast history notices logged on current feed.</p>
                            </asp:Panel>
                        </FooterTemplate>
                    </asp:Repeater>
                    
                </div>
            </div>

            <!-- COMPOSING TRANSMISSION DIALOG COMPONENT PANEL (POP-UP MODAL WINDOW) -->
            <asp:Panel ID="pnlModalContainer" runat="server" Visible="false" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm transition-opacity">
                <div class="bg-[#F7F7F5] w-full max-w-md rounded-xl border border-[#EBEBE9] shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
                    
                    <!-- POPUP HEADER -->
                    <div class="bg-white border-b border-[#EBEBE9] px-6 py-4 flex items-center justify-between">
                        <h3 class="text-sm font-semibold text-[#1A1A1A] flex items-center gap-2">
                            <span>📝</span> <asp:Literal ID="litModalHeader" runat="server" Text="Compose Broadcast Notice"></asp:Literal>
                        </h3>
                        <asp:LinkButton ID="lnkCloseTop" runat="server" OnClick="lnkCloseModal_Click" CssClass="text-[#9A9996] hover:text-[#1A1A1A] font-bold text-lg transition-colors cursor-pointer select-none">&times;</asp:LinkButton>
                    </div>

                    <!-- MODAL BODY -->
                    <div class="p-6 space-y-4">
                        <asp:HiddenField ID="hfAnnouncementID" runat="server" />
                        
                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Bulletin Header Title</label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded-lg border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors shadow-sm" placeholder="e.g., Scheduled Core Upgrades..."></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Detailed Announcement Context</label>
                            <asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" Rows="5" CssClass="w-full bg-white p-2.5 text-sm rounded-lg border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors resize-none shadow-sm" placeholder="Draft transmission parameters here..."></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Target Audience Routing</label>
                            <div class="bg-white p-3.5 rounded-lg border border-[#EBEBE9] space-y-2.5 text-xs font-medium shadow-sm">
                                <label class="flex items-center gap-2.5 cursor-pointer text-[#2F2F2F] select-none">
                                    <asp:CheckBox ID="chkAdmin" runat="server" /> System Administrators (Admins)
                                </label>
                                <label class="flex items-center gap-2.5 cursor-pointer text-[#2F2F2F] select-none">
                                    <asp:CheckBox ID="chkLecturer" runat="server" /> Academic Faculty Members (Lecturers)
                                </label>
                                <label class="flex items-center gap-2.5 cursor-pointer text-[#2F2F2F] select-none">
                                    <asp:CheckBox ID="chkStudent" runat="server" /> Registered Student Cohorts (Students)
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- MODAL FOOTER BUTTON CONTROL ACTION BAR -->
                    <div class="bg-white border-t border-[#EBEBE9] px-6 py-4 flex items-center justify-end gap-2.5">
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Discard" OnClick="lnkCloseModal_Click" 
                            CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs font-medium px-4 py-2 rounded-lg hover:bg-[#F4F4F2] transition-colors cursor-pointer" />
                        <asp:Button ID="btnPublish" runat="server" Text="Broadcast Announcement" OnClick="btnPublish_Click"
                            CssClass="bg-[#3B82F6] text-white font-semibold text-xs px-4 py-2 rounded-lg hover:bg-blue-600 transition-colors cursor-pointer shadow-sm" />
                    </div>

                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>