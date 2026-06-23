<%@ Page Title="Student Dashboard" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="StudentManagementSystem.Student.StudentDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Font Awesome (if not already in master) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style type="text/css">
        /* Card hover effects */
        .stat-card {
            transition: all 0.25s ease-in-out;
        }
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.10);
        }
        .dashboard-card {
            transition: all 0.2s ease-in-out;
        }
        .dashboard-card:hover {
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
        }
        /* Custom dropdown animation */
        .dropdown-enter {
            opacity: 0;
            transform: scale(0.95) translateY(-8px);
        }
        .dropdown-enter-active {
            opacity: 1;
            transform: scale(1) translateY(0);
            transition: all 0.2s ease-out;
        }
        .dropdown-exit {
            opacity: 1;
            transform: scale(1) translateY(0);
        }
        .dropdown-exit-active {
            opacity: 0;
            transform: scale(0.95) translateY(-8px);
            transition: all 0.2s ease-in;
        }
    </style>

    <!-- ============================================================ -->
    <!-- GRADIENT HEADER                                               -->
    <!-- ============================================================ -->
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">
                Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="" />!
            </h1>
            <p class="text-sm mt-1">Your learning journey continues. Here's what's new.</p>
        </div>
    </header>

    <!-- ============================================================ -->
    <!-- MAIN CONTENT                                                  -->
    <!-- ============================================================ -->
    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">

        <!-- ============================================================ -->
        <!-- 4x SUMMARY STATS CARDS (like Academic Results)               -->
        <!-- ============================================================ -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            
            <!-- Card 1: Current GPA -->
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#111827] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Current GPA</p>
                    <p class="text-2xl font-bold text-[#111827]">
                        <asp:Label ID="lblSemesterGPA" runat="server" Text="—" />
                    </p>
                </div>
            </div>

            <!-- Card 2: CGPA -->
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#0095FD] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-star"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">CGPA</p>
                    <p class="text-2xl font-bold text-[#0095FD]">
                        <asp:Label ID="lblCGPA" runat="server" Text="—" />
                    </p>
                </div>
            </div>

            <!-- Card 3: Credits Completed -->
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#00CBD4] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-graduation-cap"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Credits Completed</p>
                    <p class="text-2xl font-bold text-[#00CBD4]">
                        <asp:Label ID="lblCredits" runat="server" Text="0" /> / <asp:Label ID="lblTotalCredits" runat="server" Text="0" />
                    </p>
                </div>
            </div>

            <!-- Card 4: Overall Attendance -->
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#6FE8DD] flex items-center justify-center text-gray-800 text-lg flex-shrink-0">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Attendance</p>
                    <p class="text-2xl font-bold text-[#115FB3]">
                        <asp:Label ID="lblOverallAttendance" runat="server" Text="0%" />
                    </p>
                </div>
            </div>
        </div>

        <!-- ============================================================ -->
        <!-- CUSTOMIZE DROPDOWN BUTTON                                     -->
        <!-- ============================================================ -->
        <div class="flex justify-end mb-6 relative">
            <button id="btnCustomize" type="button" 
                class="bg-[#F7F7F5] hover:bg-[#0095FD] hover:text-white border border-[#EBEBE9] text-gray-700 px-4 py-2 rounded-lg text-sm font-medium transition-all duration-300 flex items-center gap-2">
                <i class="fas fa-sliders-h"></i> Customize Dashboard
            </button>

            <!-- Dropdown card -->
            <div id="settingsDropdown" 
                class="absolute right-0 mt-12 w-80 bg-white rounded-xl shadow-xl border border-gray-200 hidden z-50"
                style="opacity:0; transform:scale(0.95) translateY(-8px); transition: all 0.2s ease-out;">
                <div class="p-5">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-base font-semibold text-gray-800">Customize Dashboard</h3>
                        <button id="closeDropdown" type="button" class="text-gray-400 hover:text-gray-600 text-xl leading-none">&times;</button>
                    </div>
                    <div class="space-y-2.5">
                        <asp:CheckBox ID="chkShowCurrentCourses" runat="server" Text=" Show Current Courses" CssClass="block text-sm" />
                        <asp:CheckBox ID="chkShowAcademicSnapshot" runat="server" Text=" Show Academic Snapshot" CssClass="block text-sm" />
                        <asp:CheckBox ID="chkShowAttendance" runat="server" Text=" Show Attendance Summary" CssClass="block text-sm" />
                        <asp:CheckBox ID="chkShowNotifications" runat="server" Text=" Show Notifications" CssClass="block text-sm" />
                        <asp:CheckBox ID="chkShowQuickActions" runat="server" Text=" Show Quick Actions" CssClass="block text-sm" />
                    </div>
                    <div class="mt-5 flex justify-end gap-2">
                        <asp:Button ID="btnSavePreferences" runat="server" Text="Save" CssClass="bg-[#111827] hover:bg-[#1f2937] text-white px-4 py-1.5 rounded-md text-sm transition" OnClick="btnSavePreferences_Click" />
                        <button id="cancelDropdown" type="button" class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-1.5 rounded-md text-sm transition">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- ============================================================ -->
        <!-- MAIN GRID: 2 columns (left 2/3, right 1/3)                   -->
        <!-- ============================================================ -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

            <!-- ========================================================= -->
            <!-- LEFT COLUMN (2/3)                                          -->
            <!-- ========================================================= -->
            <div class="lg:col-span-2 space-y-6">

                <!-- ===================================================== -->
                <!-- CURRENT COURSES                                       -->
                <!-- ===================================================== -->
                <asp:Panel ID="pnlCurrentCourses" runat="server" Visible="true">
                    <div class="dashboard-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                        <div class="px-5 py-4 border-b border-gray-100 flex justify-between items-center">
                            <h3 class="text-base font-semibold text-gray-900">
                                <i class="fas fa-book-open text-[#111827] mr-2"></i>Current Courses
                            </h3>
                            <asp:HyperLink ID="hlViewAllCourses" runat="server" NavigateUrl="~/Student/StudentCourse/StudentCourse.aspx" 
                                CssClass="text-sm text-[#0095FD] hover:text-[#0070c0] font-medium">View All →</asp:HyperLink>
                        </div>
                        <div class="divide-y divide-gray-100">
                            <asp:Repeater ID="rptCurrentCourses" runat="server">
                                <ItemTemplate>
                                    <div class="px-5 py-4 flex justify-between items-center hover:bg-gray-50 transition">
                                        <div>
                                            <p class="font-medium text-gray-900"><%# Eval("CourseCode") %> - <%# Eval("CourseName") %></p>
                                            <p class="text-sm text-gray-500"><%# Eval("Instructor") %></p>
                                        </div>
                                        <asp:HyperLink ID="hlGoToCourse" runat="server" 
                                            NavigateUrl='<%# "~/Student/StudentCourseMaterial/StudentCourseMaterial.aspx?courseOfferId=" + Eval("CourseOfferID") %>'
                                            CssClass="bg-[#F7F7F5] hover:bg-[#111827] hover:text-white border border-[#EBEBE9] text-gray-700 px-4 py-1.5 rounded-lg text-sm font-medium transition-all duration-300">
                                            Go to Course
                                        </asp:HyperLink>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:Label ID="lblNoCurrentCourses" runat="server" CssClass="p-6 text-center text-gray-500 block" Visible="false" Text="You are not enrolled in any current courses." />
                    </div>
                </asp:Panel>

                <!-- ===================================================== -->
                <!-- ATTENDANCE SUMMARY                                     -->
                <!-- ===================================================== -->
                <asp:Panel ID="pnlAttendance" runat="server" Visible="true">
                    <div class="dashboard-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                        <div class="px-5 py-4 border-b border-gray-100 flex justify-between items-center">
                            <h3 class="text-base font-semibold text-gray-900">
                                <i class="fas fa-calendar-check text-[#00CBD4] mr-2"></i>Attendance Summary
                            </h3>
                            <asp:HyperLink ID="hlViewAttendance" runat="server" NavigateUrl="~/Student/StudentAttendance/StudentAttendance.aspx" 
                                CssClass="text-sm text-[#0095FD] hover:text-[#0070c0] font-medium">View Full →</asp:HyperLink>
                        </div>
                        <div class="p-5">
                            <!-- Overall Attendance Bar -->
                            <div class="mb-4">
                                <div class="flex justify-between text-sm text-gray-600 mb-1.5">
                                    <span class="font-medium">Overall Attendance</span>
                                    <span class="font-bold"><asp:Label ID="lblOverallAttendanceBar" runat="server" Text="0%" /></span>
                                </div>
                                <asp:HiddenField ID="hfAttendanceWidth" runat="server" Value="0" />
                                <asp:HiddenField ID="hfAttendanceColor" runat="server" Value="bg-green-600" />
                                <div class="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
                                    <div class="<%= hfAttendanceColor.Value %> h-3 rounded-full transition-all duration-500" style='width: <%= hfAttendanceWidth.Value %>%'></div>
                                </div>
                            </div>

                            <!-- Per-Course Attendance -->
                            <div class="space-y-3">
                                <asp:Repeater ID="rptAttendanceByCourse" runat="server">
                                    <ItemTemplate>
                                        <div class="flex items-center gap-3">
                                            <span class="w-20 text-sm font-medium text-gray-700 truncate"><%# Eval("CourseCode") %></span>
                                            <div class="flex-1 bg-gray-200 rounded-full h-2.5 overflow-hidden">
                                                <div class="bg-indigo-600 h-2.5 rounded-full transition-all duration-500" style='width: <%# String.Format("{0:F1}", Eval("AttendancePercentage")) %>%'></div>
                                            </div>
                                            <span class="text-sm font-semibold text-gray-900 w-12 text-right"><%# String.Format("{0:F1}", Eval("AttendancePercentage")) %>%</span>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </div>

            <!-- ========================================================= -->
            <!-- RIGHT COLUMN (1/3)                                         -->
            <!-- ========================================================= -->
            <div class="space-y-6">

                <!-- ===================================================== -->
                <!-- NOTIFICATIONS                                          -->
                <!-- ===================================================== -->
                <asp:Panel ID="pnlNotifications" runat="server" Visible="true">
                    <div class="dashboard-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                        <div class="px-5 py-4 border-b border-gray-100 flex justify-between items-center">
                            <h3 class="text-base font-semibold text-gray-900">
                                <i class="fas fa-bell text-[#0095FD] mr-2"></i>Notifications
                            </h3>
                            <asp:HyperLink ID="hlViewAllNotifications" runat="server" NavigateUrl="~/Student/StudentNotification/StudentNotification.aspx" 
                                CssClass="text-sm text-[#0095FD] hover:text-[#0070c0] font-medium">View All →</asp:HyperLink>
                        </div>
                        <div class="divide-y divide-gray-100 max-h-[320px] overflow-y-auto">
                            <asp:Repeater ID="rptNotifications" runat="server">
                                <ItemTemplate>
                                    <a href='/Student/StudentCourseNotification/StudentCourseNotification.aspx?id=<%# Eval("AnnouncementID") %>' 
                                       class="block hover:bg-gray-50 transition px-5 py-3.5"
                                       style='<%# ((bool)Eval("IsRead") ? "" : "border-l-4 border-[#0095FD]") %>'>
                                        <div class="flex items-start gap-3">
                                            <span class='<%# ((bool)Eval("IsRead") ? "hidden" : "inline-block w-2 h-2 bg-[#0095FD] rounded-full mt-1.5 flex-shrink-0") %>'></span>
                                            <div class="flex-1 min-w-0">
                                                <p class="text-sm font-medium text-gray-900 truncate"><%# Eval("Title") %></p>
                                                <p class="text-xs text-gray-500 mt-0.5"><%# ((DateTime)Eval("CreatedDate")).ToString("MMM dd, yyyy 'at' h:mm tt") %></p>
                                            </div>
                                        </div>
                                    </a>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:Label ID="lblNoNotifications" runat="server" CssClass="p-6 text-center text-gray-500 block" Visible="false" Text="No notifications yet." />
                    </div>
                </asp:Panel>

                <!-- ===================================================== -->
                <!-- QUICK ACTIONS                                          -->
                <!-- ===================================================== -->
                <asp:Panel ID="pnlQuickActions" runat="server" Visible="true">
                    <div class="dashboard-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                        <div class="px-5 py-4 border-b border-gray-100">
                            <h3 class="text-base font-semibold text-gray-900">
                                <i class="fas fa-bolt text-[#6FE8DD] mr-2"></i>Quick Actions
                            </h3>
                        </div>
                        <div class="p-4 space-y-1.5">
                            <asp:HyperLink ID="hlQuickCourses" runat="server" NavigateUrl="~/Student/StudentCourse/StudentCourse.aspx" 
                                CssClass="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-gray-700 hover:bg-[#F7F7F5] hover:text-[#111827] transition-all duration-200">
                                <i class="fas fa-graduation-cap w-5 text-[#111827]"></i> My Courses
                            </asp:HyperLink>
                            <asp:HyperLink ID="hlQuickResults" runat="server" NavigateUrl="~/Student/StudentAcademicResult/StudentAcademicResult.aspx" 
                                CssClass="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-gray-700 hover:bg-[#F7F7F5] hover:text-[#111827] transition-all duration-200">
                                <i class="fas fa-chart-line w-5 text-[#0095FD]"></i> Academic Results
                            </asp:HyperLink>
                            <asp:HyperLink ID="hlQuickAttendance" runat="server" NavigateUrl="~/Student/StudentAttendance/StudentAttendance.aspx" 
                                CssClass="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-gray-700 hover:bg-[#F7F7F5] hover:text-[#111827] transition-all duration-200">
                                <i class="fas fa-calendar-check w-5 text-[#00CBD4]"></i> Attendance Records
                            </asp:HyperLink>
                            <asp:HyperLink ID="hlQuickSettings" runat="server" NavigateUrl="~/Student/StudentSetting/StudentSetting.aspx" 
                                CssClass="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-gray-700 hover:bg-[#F7F7F5] hover:text-[#111827] transition-all duration-200">
                                <i class="fas fa-user-gear w-5 text-[#6FE8DD]"></i> Profile Settings
                            </asp:HyperLink>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

    <!-- ============================================================ -->
    <!-- DROPDOWN SCRIPT                                              -->
    <!-- ============================================================ -->
    <script type="text/javascript">
        var btn = document.getElementById('btnCustomize');
        var dropdown = document.getElementById('settingsDropdown');
        var closeBtn = document.getElementById('closeDropdown');
        var cancelBtn = document.getElementById('cancelDropdown');

        function openDropdown() {
            dropdown.classList.remove('hidden');
            setTimeout(function () {
                dropdown.style.opacity = '1';
                dropdown.style.transform = 'scale(1) translateY(0)';
            }, 10);
        }

        function closeDropdown() {
            dropdown.style.opacity = '0';
            dropdown.style.transform = 'scale(0.95) translateY(-8px)';
            setTimeout(function () {
                dropdown.classList.add('hidden');
            }, 200);
        }

        if (btn) {
            btn.addEventListener('click', function (e) {
                e.stopPropagation();
                openDropdown();
            });
        }
        if (closeBtn) closeBtn.addEventListener('click', closeDropdown);
        if (cancelBtn) cancelBtn.addEventListener('click', closeDropdown);

        document.addEventListener('click', function (e) {
            if (dropdown && !dropdown.contains(e.target) && e.target !== btn) {
                closeDropdown();
            }
        });
    </script>

</asp:Content>