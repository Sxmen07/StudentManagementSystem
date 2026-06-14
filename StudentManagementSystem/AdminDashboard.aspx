<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="StudentManagementSystem.AdminDashboard" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Operational Control Terminal</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #EBEBE9; border-radius: 10px; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <!-- GLOBAL APP SIDEBAR CONTAINER -->
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <!-- MAIN WINDOW TERMINAL VIEWPORT -->
        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <!-- MINIMALIST HEADER BAR (Aligned with the layout grid) -->
            <div class="bg-white border-b border-[#EBEBE9] px-12 py-5 flex items-center justify-between shrink-0">
                <h2 class="text-xl font-bold text-[#111625] tracking-tight">Dashboard</h2>
                
                <div class="flex items-center gap-3">
                    <div class="text-right hidden sm:block">
                        <!-- Changed to User's dynamic name placeholder -->
                        <div class="text-xs font-bold text-zinc-800 tracking-tight"><asp:Literal ID="litAdminName" runat="server">Admin Account</asp:Literal></div>
                        <div class="flex items-center gap-1 justify-end mt-0.5">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                            <span class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider">Live</span>
                        </div>
                    </div>
                    <div class="w-9 h-9 rounded-full overflow-hidden border border-zinc-200/80 bg-zinc-50 shrink-0 shadow-sm">
                        <asp:Image ID="imgNavAvatar" runat="server" CssClass="w-full h-full object-cover" ImageUrl="~/profile_upload/default-avatar.jpg" />
                    </div>
                </div>
            </div>

            <!-- CORE CONTAINER CONTENT (Now safely padded at px-12 to perfectly align every element top-to-bottom) -->
            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar space-y-8">
                
                <!-- PREMIUM GRADIENT HERO CARD -->
                <div class="w-full bg-gradient-to-r from-[#E0E9FE] via-[#EAF1FF] to-[#FFFBE6] rounded-2xl p-8 border border-blue-100/60 shadow-sm relative overflow-hidden shrink-0">
                    <div class="absolute right-12 top-1/2 -translate-y-1/2 w-80 h-80 rounded-full bg-gradient-to-tr from-blue-400/20 to-indigo-300/10 mix-blend-multiply filter blur-xl pointer-events-none"></div>
                    
                    <div class="relative z-10 space-y-5">
                        <div>
                            <h3 class="text-lg font-bold text-[#111625] tracking-tight">Institutional Analytics Distribution</h3>
                            <p class="text-zinc-500 text-xs mt-0.5">Comprehensive real-time matrix summary generated across connected database models.</p>
                        </div>

                        <!-- Floating analytics counters -->
                        <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
                            <div class="bg-white/90 backdrop-blur-sm p-4 rounded-xl border border-white/60 shadow-sm">
                                <h5 class="text-2xl font-bold text-[#111625]"><asp:Literal ID="litTotalSchools" runat="server">0</asp:Literal></h5>
                                <span class="text-[11px] font-medium text-zinc-400 block mt-1">Total Schools 🏫</span>
                            </div>
                            <div class="bg-white/90 backdrop-blur-sm p-4 rounded-xl border border-white/60 shadow-sm">
                                <h5 class="text-2xl font-bold text-[#111625]"><asp:Literal ID="litTotalProgrammes" runat="server">0</asp:Literal></h5>
                                <span class="text-[11px] font-medium text-zinc-400 block mt-1">Programmes 🎓</span>
                            </div>
                            <div class="bg-white/90 backdrop-blur-sm p-4 rounded-xl border border-white/60 shadow-sm">
                                <h5 class="text-2xl font-bold text-[#111625]"><asp:Literal ID="litTotalCourses" runat="server">0</asp:Literal></h5>
                                <span class="text-[11px] font-medium text-zinc-400 block mt-1">Active Courses 📚</span>
                            </div>
                            <div class="bg-white/90 backdrop-blur-sm p-4 rounded-xl border border-white/60 shadow-sm">
                                <h5 class="text-2xl font-bold text-[#111625]"><asp:Literal ID="litTotalLecturers" runat="server">0</asp:Literal></h5>
                                <span class="text-[11px] font-medium text-zinc-400 block mt-1">Active Faculty 👨‍🏫</span>
                            </div>
                            <div class="bg-white/90 backdrop-blur-sm p-4 rounded-xl border border-white/60 shadow-sm col-span-2 md:col-span-1">
                                <h5 class="text-2xl font-bold text-[#111625]"><asp:Literal ID="litTotalStudents" runat="server">0</asp:Literal></h5>
                                <span class="text-[11px] font-medium text-zinc-400 block mt-1">Total Students 🧑‍🎓</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SECONDARY LOWER FRAMES (Perfectly grid-aligned to match the hero card block) -->
                <div class="space-y-8">
                    
                    <!-- EXTENDED INFRASTRUCTURE METRICS SECTION -->
                    <div>
                        <h4 class="text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-3">Extended Infrastructure Metrics</h4>
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div class="bg-white p-4 rounded-xl border border-[#EBEBE9] shadow-sm flex items-center justify-between">
                                <div>
                                    <span class="text-[11px] font-medium text-[#7C7B77]">Active Course Offers</span>
                                    <h4 class="text-lg font-bold text-[#1A1A1A] mt-0.5"><asp:Literal ID="litTotalOffers" runat="server">0</asp:Literal></h4>
                                </div>
                                <span class="text-lg">📋</span>
                            </div>
                            <div class="bg-white p-4 rounded-xl border border-[#EBEBE9] shadow-sm flex items-center justify-between">
                                <div>
                                    <span class="text-[11px] font-medium text-[#7C7B77]">Course Syllabus Materials</span>
                                    <h4 class="text-lg font-bold text-[#1A1A1A] mt-0.5"><asp:Literal ID="litTotalMaterials" runat="server">0</asp:Literal></h4>
                                </div>
                                <span class="text-lg">📁</span>
                            </div>
                            <div class="bg-white p-4 rounded-xl border border-[#EBEBE9] shadow-sm flex items-center justify-between">
                                <div>
                                    <span class="text-[11px] font-medium text-[#7C7B77]">Dispatched Bulletin Alerts</span>
                                    <h4 class="text-lg font-bold text-[#1A1A1A] mt-0.5"><asp:Literal ID="litTotalAnnouncements" runat="server">0</asp:Literal></h4>
                                </div>
                                <span class="text-lg">📢</span>
                            </div>
                        </div>
                    </div>

                    <!-- FEEDS GRID SECTIONS -->
                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                        
                        <div class="lg:col-span-2 space-y-6">
                            <!-- BROADCAST ANNOUNCEMENTS HISTORY FEED -->
                            <div class="bg-white rounded-xl border border-[#EBEBE9] p-5 shadow-sm">
                                <div class="flex items-center justify-between border-b border-zinc-100 pb-3 mb-4">
                                    <h4 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider flex items-center gap-2">
                                        <span>📢</span> Recent Administrative Broadcast Log History
                                    </h4>
                                    <a href="ManageAnnouncements.aspx" class="text-[11px] font-medium text-blue-600 hover:underline">Manage Desk &rarr;</a>
                                </div>
                                <div class="space-y-3">
                                    <asp:Repeater ID="rptRecentAnnouncements" runat="server">
                                        <ItemTemplate>
                                            <div class="p-3 bg-zinc-50 border border-zinc-100 rounded-lg flex flex-col gap-1 text-xs">
                                                <div class="flex items-center justify-between">
                                                    <span class="font-bold text-zinc-800"><%# Eval("Title") %></span>
                                                    <span class="text-[10px] text-zinc-400 font-medium"><%# Convert.ToDateTime(Eval("CreatedDate")).ToString("yyyy-MM-dd • hh:mm tt") %></span>
                                                </div>
                                                <p class="text-zinc-500 line-clamp-2 leading-relaxed"><%# Eval("ContentText") %></p>
                                            </div>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            <asp:Panel runat="server" Visible='<%# rptRecentAnnouncements.Items.Count == 0 %>' class="text-center py-4 text-zinc-400 text-xs">
                                                No announcements logged in history cache tracks.
                                            </asp:Panel>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>

                            <!-- LIVE ENROLMENT ACCOUNT DENSITIES -->
                            <div class="bg-white rounded-xl border border-[#EBEBE9] p-5 shadow-sm">
                                <div class="flex items-center justify-between border-b border-zinc-100 pb-3 mb-4">
                                    <h4 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider flex items-center gap-2">
                                        <span>📊</span> System-Wide Account Enrolment Densities
                                    </h4>
                                    <a href="CreateAccounts.aspx" class="text-[11px] font-medium text-blue-600 hover:underline">Provision Identity &rarr;</a>
                                </div>
                                <div class="grid grid-cols-3 gap-4 text-center">
                                    <div class="bg-blue-50/40 p-4 border border-blue-100 rounded-lg">
                                        <span class="text-[10px] font-bold text-blue-700 uppercase tracking-wider">Admins</span>
                                        <h5 class="text-xl font-bold text-blue-900 mt-1"><asp:Literal ID="litCountAdmins" runat="server">0</asp:Literal></h5>
                                    </div>
                                    <div class="bg-orange-50/40 p-4 border border-orange-100 rounded-lg">
                                        <span class="text-[10px] font-bold text-orange-700 uppercase tracking-wider">Lecturers</span>
                                        <h5 class="text-xl font-bold text-orange-900 mt-1"><asp:Literal ID="litCountLecturers" runat="server">0</asp:Literal></h5>
                                    </div>
                                    <div class="bg-emerald-50/40 p-4 border border-emerald-100 rounded-lg">
                                        <span class="text-[10px] font-bold text-emerald-700 uppercase tracking-wider">Students</span>
                                        <h5 class="text-xl font-bold text-emerald-900 mt-1"><asp:Literal ID="litCountStudents" runat="server">0</asp:Literal></h5>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- RIGHT SHELF INFO PANELS -->
                        <div class="space-y-6">
                            
                            <!-- ADMIN INBOX -->
                            <div class="bg-white rounded-xl border border-[#EBEBE9] p-5 shadow-sm">
                                <div class="flex items-center justify-between border-b border-zinc-100 pb-3 mb-3">
                                    <h4 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider flex items-center gap-2">
                                        <span>📥</span> Admin Inbox Messages
                                    </h4>
                                    <span class="bg-zinc-100 text-zinc-600 text-[10px] font-bold px-2 py-0.5 rounded border border-zinc-200">
                                        <asp:Literal ID="litInboxCount" runat="server">0</asp:Literal> Pending
                                    </span>
                                </div>
                                <div class="space-y-2.5 max-h-[190px] overflow-y-auto custom-scrollbar">
                                    <asp:Repeater ID="rptRecentMessages" runat="server">
                                        <ItemTemplate>
                                            <div class="p-2.5 bg-zinc-50 border border-zinc-100 rounded-lg text-xs space-y-0.5">
                                                <div class="flex items-center justify-between font-bold text-zinc-800">
                                                    <span class="truncate pr-2"><%# Eval("Subject") %></span>
                                                    <span class="text-[9px] text-zinc-400 font-medium shrink-0"><%# Convert.ToDateTime(Eval("SubmissionDate")).ToString("MM-dd HH:mm") %></span>
                                                </div>
                                                <div class="text-[10px] text-zinc-500 font-medium truncate"><%# Eval("SenderEmail") %></div>
                                            </div>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            <asp:Panel runat="server" Visible='<%# rptRecentMessages.Items.Count == 0 %>' class="text-center py-8 text-zinc-400 text-xs font-medium px-4">
                                                No inbox if there is no support issue.
                                            </asp:Panel>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>

                            <!-- RUNNING LINKS SHORTCUT PANELS -->
                            <div class="bg-white rounded-xl border border-[#EBEBE9] p-5 shadow-sm space-y-3">
                                <h4 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-zinc-100 pb-2">
                                    ⚙️ Operational Shortcuts Speedway
                                </h4>
                                <div class="grid grid-cols-1 gap-2 text-xs font-semibold text-zinc-700">
                                    <a href="ManageSchoolNPrograms.aspx" class="p-2.5 bg-zinc-50 border border-zinc-100 hover:border-zinc-300 rounded-lg flex items-center justify-between group transition-colors">
                                        <span>🏫 Manage Schools & Programmes</span>
                                        <span class="text-zinc-400 group-hover:text-zinc-700 transition-colors">&rarr;</span>
                                    </a>
                                    <a href="ManageCourses.aspx" class="p-2.5 bg-zinc-50 border border-zinc-100 hover:border-zinc-300 rounded-lg flex items-center justify-between group transition-colors">
                                        <span>📚 Course Offering Matrix Desk</span>
                                        <span class="text-zinc-400 group-hover:text-zinc-700 transition-colors">&rarr;</span>
                                    </a>
                                    <a href="TrackStudentGrade.aspx" class="p-2.5 bg-zinc-50 border border-zinc-100 hover:border-zinc-300 rounded-lg flex items-center justify-between group transition-colors">
                                        <span>📈 Student Grade Evaluation Tracker</span>
                                        <span class="text-zinc-400 group-hover:text-zinc-700 transition-colors">&rarr;</span>
                                    </a>
                                    <a href="UserProfile.aspx" class="p-2.5 bg-zinc-50 border border-zinc-100 hover:border-zinc-300 rounded-lg flex items-center justify-between group transition-colors">
                                        <span>👤 Account Configuration Workspace</span>
                                        <span class="text-zinc-400 group-hover:text-zinc-700 transition-colors">&rarr;</span>
                                    </a>
                                </div>
                            </div>

                        </div>
                    </div>

                </div>
            </div>

        </div>
    </form>
</body>
</html>