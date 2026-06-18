<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="StudentManagementSystem.AdminDashboard" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Operational Control Terminal</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #EBEBE9; border-radius: 10px; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <!-- HEADER BAR WITH REAL-TIME CLOCK -->
            <div class="bg-white border-b border-[#EBEBE9] px-12 py-5 flex items-center justify-between shrink-0">
                <div class="flex items-center gap-6">
                    <h2 class="text-xl font-bold text-[#111625] tracking-tight">Dashboard</h2>
                    <div class="hidden md:flex items-center gap-2 bg-[#F7F7F5] border border-[#EBEBE9] px-3 py-1 rounded-xl shadow-sm text-zinc-600 font-mono text-xs font-semibold">
                        <i class="fa-regular fa-clock text-blue-500 text-[11px]"></i>
                        <span id="txtRealTimeClock">--:--:-- --</span>
                    </div>
                </div>
                
                <div class="flex items-center gap-3">
                    <div class="text-right hidden sm:block">
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

            <!-- CORE CONTAINER CONTENT -->
            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar space-y-6">
                
                <!-- GRADIENT HERO CARD -->
                <div class="w-full bg-gradient-to-r from-[#E0E9FE] via-[#EAF1FF] to-[#FFFBE6] rounded-2xl p-8 border border-blue-100/60 shadow-sm relative overflow-hidden shrink-0">
                    <div class="absolute right-12 top-1/2 -translate-y-1/2 w-80 h-80 rounded-full bg-gradient-to-tr from-blue-400/20 to-indigo-300/10 mix-blend-multiply filter blur-xl pointer-events-none"></div>
                    
                    <div class="relative z-10 space-y-5">
                        <div>
                            <h3 class="text-lg font-bold text-[#111625] tracking-tight">Institutional Analytics Distribution</h3>
                            <p class="text-zinc-500 text-xs mt-0.5">Comprehensive real-time matrix summary generated across connected database models.</p>
                        </div>

                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
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
                                <h5 class="text-2xl font-bold text-[#111625]"><asp:Literal ID="litActiveSemester" runat="server">Intake Term</asp:Literal></h5>
                                <span class="text-[11px] font-medium text-zinc-400 block mt-1">Current Active Semester 🗓️</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Hidden data transmission fields -->
                <div class="hidden">
                    <asp:HiddenField ID="hfAdmins" runat="server" ClientIDMode="Static" Value="0" />
                    <asp:HiddenField ID="hfLecturers" runat="server" ClientIDMode="Static" Value="0" />
                    <asp:HiddenField ID="hfStudents" runat="server" ClientIDMode="Static" Value="0" />
                    <asp:HiddenField ID="hfCourseNames" runat="server" ClientIDMode="Static" Value="" />
                    <asp:HiddenField ID="hfCourseEnrollment" runat="server" ClientIDMode="Static" Value="" />
                    <asp:HiddenField ID="hfFacultyNames" runat="server" ClientIDMode="Static" Value="" />
                    <asp:HiddenField ID="hfFacultyStudents" runat="server" ClientIDMode="Static" Value="" />
                </div>

                <!-- ROW 1 GRID MATRICES (50-50 Balanced Split View) -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    
                    <!-- LEFT CONTAINER: Unified Demographics Percentage Pie Chart + Inner Stacked Cards -->
                    <div class="bg-white rounded-2xl border border-[#EBEBE9] p-6 shadow-sm flex flex-col justify-between h-[380px]">
                        <div>
                            <h4 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider mb-1 flex items-center gap-2">
                                <span>📊</span> Demographics Share
                            </h4>
                            <p class="text-[11px] text-zinc-400">Proportional system usage share shown exclusively by percentage parameters.</p>
                        </div>
                        
                        <!-- RE-CONFIGURED VIEW: Side-by-side flexbox holding the pie chart on the left, and numerical layout cards on the right -->
                        <div class="flex-1 flex flex-row items-center justify-between gap-4 mt-2 overflow-hidden">
                            <div class="w-1/2 h-full relative flex items-center justify-center max-h-[240px]">
                                <canvas id="chartDemographicsPercentages"></canvas>
                            </div>
                            
                            <!-- FIXED: The 3 colored metrics cards relocated cleanly right beside the pie chart framework -->
                            <div class="w-1/2 flex flex-col gap-2">
                                <div class="bg-blue-50/50 px-4 py-2.5 border border-blue-100 rounded-xl shadow-sm text-center">
                                    <span class="text-[9px] font-bold text-blue-700 uppercase tracking-wider block">Admins</span>
                                    <h5 class="text-base font-bold text-blue-900 mt-0.5"><asp:Literal ID="litCountAdmins" runat="server">0</asp:Literal></h5>
                                </div>
                                <div class="bg-orange-50/50 px-4 py-2.5 border border-orange-100 rounded-xl shadow-sm text-center">
                                    <span class="text-[9px] font-bold text-orange-700 uppercase tracking-wider block">Lecturers</span>
                                    <h5 class="text-base font-bold text-orange-900 mt-0.5"><asp:Literal ID="litCountLecturers" runat="server">0</asp:Literal></h5>
                                </div>
                                <div class="bg-emerald-50/50 px-4 py-2.5 border border-emerald-100 rounded-xl shadow-sm text-center">
                                    <span class="text-[9px] font-bold text-emerald-700 uppercase tracking-wider block">Students</span>
                                    <h5 class="text-base font-bold text-emerald-900 mt-0.5"><asp:Literal ID="litCountStudents" runat="server">0</asp:Literal></h5>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- RIGHT CONTAINER: Popular Course Enrollment Analytics Chart -->
                    <div class="bg-white rounded-2xl border border-[#EBEBE9] p-6 shadow-sm flex flex-col justify-between h-[380px]">
                        <div>
                            <h4 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider mb-0.5">🔥 Popular Courses Enrollment</h4>
                            <p class="text-[11px] text-zinc-400">Total aggregate registration spikes pulled live per syllabus program code identity.</p>
                        </div>
                        <div class="flex-1 relative mt-3 max-h-[260px]">
                            <canvas id="chartPopularTrends"></canvas>
                        </div>
                    </div>

                </div>

                <!-- ROW 2 CONTAINER: Full Width Student Volume by School Tracker Framework -->
                <!-- FIXED: Extended to full width to sit beautifully flush and square with the cards above! -->
                <div class="bg-white rounded-2xl border border-[#EBEBE9] p-6 shadow-sm flex flex-col justify-between w-full h-[340px]">
                    <div>
                        <h4 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider mb-0.5">🏛️ Student Volume by School (Faculty)</h4>
                        <p class="text-[10px] text-zinc-400">Total verified student rosters grouped by primary parent department registers.</p>
                    </div>
                    <div class="flex-1 relative mt-3 max-h-[250px]">
                        <canvas id="chartFacultyDensities"></canvas>
                    </div>
                </div>

                <!-- RECENT MESSAGE FEEDS PANELS -->
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <div class="lg:col-span-2 space-y-6">
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
                    </div>

                    <div class="space-y-6">
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
                    </div>
                </div>

            </div>
        </div>
    </form>

    <!-- REAL-TIME CLOCK COMPONENT SCRIPT -->
    <script type="text/javascript">
        function startRealTimeClock() {
            const clockTextElement = document.getElementById('txtRealTimeClock');
            if (!clockTextElement) return;
            setInterval(() => {
                const now = new Date();
                let hours = now.getHours();
                const minutes = String(now.getMinutes()).padStart(2, '0');
                const seconds = String(now.getSeconds()).padStart(2, '0');
                const ampm = hours >= 12 ? 'PM' : 'AM';
                hours = hours % 12;
                hours = hours ? hours : 12;
                clockTextElement.textContent = `${String(hours).padStart(2, '0')}:${minutes}:${seconds} ${ampm}`;
            }, 1000);
        }
        document.addEventListener("DOMContentLoaded", startRealTimeClock);
    </script>

    <!-- CHART.JS MULTI-GRAPH INITIALIZATION LOGIC -->
    <script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function () {
            const countAdmins = parseInt(document.getElementById("hfAdmins").value) || 0;
            const countLecturers = parseInt(document.getElementById("hfLecturers").value) || 0;
            const countStudents = parseInt(document.getElementById("hfStudents").value) || 0;
            const totalDemographics = countAdmins + countLecturers + countStudents;

            const ctxPie = document.getElementById('chartDemographicsPercentages').getContext('2d');
            new Chart(ctxPie, {
                type: 'pie',
                data: {
                    labels: ['Administrators', 'Lecturers', 'Students'],
                    datasets: [{
                        data: [countAdmins, countLecturers, countStudents],
                        backgroundColor: ['#3B82F6', '#F97316', '#10B981'],
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom', labels: { boxWidth: 10, font: { family: 'Poppins', size: 9 } } },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    const val = context.raw;
                                    const pct = totalDemographics > 0 ? ((val / totalDemographics) * 100).toFixed(1) : 0;
                                    return ` ${context.label}: ${pct}%`;
                                }
                            }
                        }
                    }
                }
            });

            const rawCourseNames = document.getElementById("hfCourseNames").value;
            const rawEnrollments = document.getElementById("hfCourseEnrollment").value;
            const rawFacultyNames = document.getElementById("hfFacultyNames").value;
            const rawFacultyStudents = document.getElementById("hfFacultyStudents").value;

            const coursesLabels = rawCourseNames ? rawCourseNames.split(',') : [];
            const enrollmentData = rawEnrollments ? rawEnrollments.split(',').map(Number) : [];
            const facultyLabels = rawFacultyNames ? rawFacultyNames.split(',') : [];
            const facultyStudentData = rawFacultyStudents ? rawFacultyStudents.split(',').map(Number) : [];

            // 1. Popular Courses Layout Graph
            const ctxTrends = document.getElementById('chartPopularTrends').getContext('2d');
            new Chart(ctxTrends, {
                type: 'bar',
                data: {
                    labels: coursesLabels,
                    datasets: [{ data: enrollmentData, backgroundColor: '#6366F1', borderRadius: 6, maxBarThickness: 14 }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { beginAtZero: true, grid: { color: '#F1F1EF' }, ticks: { precision: 0 } },
                        y: { grid: { display: false } }
                    }
                }
            });

            // 2. Full Width School Student Densities Layout Graph
            const ctxFaculty = document.getElementById('chartFacultyDensities').getContext('2d');
            new Chart(ctxFaculty, {
                type: 'bar',
                data: {
                    labels: facultyLabels,
                    datasets: [{ data: facultyStudentData, backgroundColor: '#14B8A6', borderRadius: 6, maxBarThickness: 24 }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, grid: { color: '#F1F1EF' }, ticks: { precision: 0 } },
                        x: { grid: { display: false } }
                    }
                }
            });
        });
    </script>
</body>
</html>