<%@ Page Title="Student Dashboard" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="StudentManagementSystems.Student.StudentDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-xl sm:text-2xl md:text-3xl lg:text-4xl font-bold animate-welcome">
                Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="" />!
            </h1>
            <p class="text-xs sm:text-sm mt-1">Your learning journey continues. Here's what's new.</p>
        </div>
    </header>

    <!-- Customize Dashboard Button with dropdown -->
    <div class="w-full px-4 sm:px-6 lg:px-8 py-4 flex justify-end relative">
        <button id="btnCustomize" type="button" class="bg-indigo-50 hover:bg-indigo-600 hover:text-white hover:shadow-md transition-all duration-300 px-4 py-2 rounded-lg text-sm font-medium hover:scale-105">
            <i class="fa-solid fa-sliders-h mr-1"></i> Customize Dashboard
        </button>

        <!-- Dropdown card -->
        <div id="settingsDropdown" class="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-xl border border-gray-200 z-50 hidden transition-all duration-200 origin-top-right scale-95 opacity-0">
            <div class="p-4">
                <div class="flex justify-between items-center mb-3">
                    <h3 class="text-lg font-semibold text-gray-800">Customize Dashboard</h3>
                    <button id="closeDropdown" type="button" class="text-gray-400 hover:text-gray-600 text-xl leading-none">&times;</button>
                </div>
                <div class="space-y-2">
                    <asp:CheckBox ID="chkShowCurrentCourses" runat="server" Text=" Show Current Courses" CssClass="block" />
                    <asp:CheckBox ID="chkShowAcademicSnapshot" runat="server" Text=" Show Academic Snapshot" CssClass="block" />
                    <asp:CheckBox ID="chkShowAttendance" runat="server" Text=" Show Attendance Summary" CssClass="block" />
                    <asp:CheckBox ID="chkShowNotifications" runat="server" Text=" Show Notifications" CssClass="block" />
                    <asp:CheckBox ID="chkShowQuickActions" runat="server" Text=" Show Quick Actions" CssClass="block" />
                </div>
                <div class="mt-4 flex justify-end gap-2">
                    <asp:Button ID="btnSavePreferences" runat="server" Text="Save" CssClass="bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-1 rounded-md text-sm transition" OnClick="btnSavePreferences_Click" />
                    <button id="cancelDropdown" type="button" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-3 py-1 rounded-md text-sm transition duration-200">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Full width container -->
    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Left column (2/3 width) -->
            <div class="lg:col-span-2 space-y-8">
                <!-- Current Courses -->
                <asp:Panel ID="pnlCurrentCourses" runat="server" Visible="true">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                        <div class="p-4 border-b border-gray-200 flex justify-between items-center">
                            <h3 class="text-lg font-semibold text-gray-900">Current Courses</h3>
                            <asp:HyperLink ID="hlViewAllCourses" runat="server" NavigateUrl="~/Student/StudentCourse/StudentCourse.aspx" CssClass="text-sm text-indigo-600 hover:text-indigo-800">View All →</asp:HyperLink>
                        </div>
                        <div class="divide-y divide-gray-100">
                            <asp:Repeater ID="rptCurrentCourses" runat="server">
                                <ItemTemplate>
                                    <div class="p-4 flex justify-between items-center">
                                        <div>
                                            <p class="font-medium text-gray-900"><%# Eval("CourseCode") %> - <%# Eval("CourseName") %></p>
                                            <p class="text-sm text-gray-500"><%# Eval("Instructor") %></p>
                                        </div>
                                        <asp:HyperLink ID="hlGoToCourse" runat="server" 
                                            NavigateUrl='<%# "~/Student/StudentCourseMaterial/StudentCourseMaterial.aspx?courseOfferId=" + Eval("CourseOfferID") %>'
                                            CssClass="bg-indigo-50 hover:bg-indigo-600 hover:text-white hover:shadow-md transition-all duration-300 px-4 py-2 rounded-lg text-sm font-medium hover:scale-105">
                                            Go to Course
                                        </asp:HyperLink>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:Label ID="lblNoCurrentCourses" runat="server" CssClass="p-6 text-center text-gray-500 block" Visible="false" Text="You are not enrolled in any current courses." />
                    </div>
                </asp:Panel>

                <!-- Academic Snapshot -->
                <asp:Panel ID="pnlAcademicSnapshot" runat="server" Visible="true">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                        <div class="p-4 border-b border-gray-200 flex justify-between items-center">
                            <h3 class="text-lg font-semibold text-gray-900">Academic</h3>
                            <asp:HyperLink ID="hlAcademicResults" runat="server" NavigateUrl="~/Student/StudentAcademicResult/StudentAcademicResult.aspx" CssClass="text-sm text-indigo-600 hover:text-indigo-800">View Full Results →</asp:HyperLink>
                        </div>
                        <div class="p-4">
                            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                                <div class="text-center bg-gray-50 rounded-lg p-3">
                                    <p class="text-sm text-gray-500">Current GPA</p>
                                    <p class="text-2xl font-bold text-indigo-600"><asp:Label ID="lblSemesterGPA" runat="server" Text="—" /></p>
                                </div>
                                <div class="text-center bg-gray-50 rounded-lg p-3">
                                    <p class="text-sm text-gray-500">CGPA</p>
                                    <p class="text-2xl font-bold text-indigo-600"><asp:Label ID="lblCGPA" runat="server" Text="—" /></p>
                                </div>
                                <div class="text-center bg-gray-50 rounded-lg p-3">
                                    <p class="text-sm text-gray-500">Credits Completed</p>
                                    <p class="text-2xl font-bold text-indigo-600"><asp:Label ID="lblCredits" runat="server" Text="0" /> / <asp:Label ID="lblTotalCredits" runat="server" Text="0" /></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <!-- Attendance Summary -->
                <asp:Panel ID="pnlAttendance" runat="server" Visible="true">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                        <div class="p-4 border-b border-gray-200 flex justify-between items-center">
                            <h3 class="text-lg font-semibold text-gray-900">Attendance Summary</h3>
                            <asp:HyperLink ID="hlViewAttendance" runat="server" NavigateUrl="~/Student/StudentAttendance/StudentAttendance.aspx" CssClass="text-sm text-indigo-600 hover:text-indigo-800">View Full →</asp:HyperLink>
                        </div>
                        <div class="p-4">
                            <div class="mb-4">
                                <div class="flex justify-between text-sm text-gray-600 mb-1">
                                    <span>Overall Attendance (Current Semester)</span>
                                    <span><asp:Label ID="lblOverallAttendance" runat="server" Text="0%" /></span>
                                </div>
                                <asp:HiddenField ID="hfAttendanceWidth" runat="server" Value="0" />
                                <asp:HiddenField ID="hfAttendanceColor" runat="server" Value="bg-green-600" />
                                <div class="w-full bg-gray-200 rounded-full h-5 overflow-hidden">
                                    <div class="<%= hfAttendanceColor.Value %> h-5 rounded-full" style='width: <%= hfAttendanceWidth.Value %>%'></div>
                                </div>
                            </div>
                            <div class="space-y-3">
                                <asp:Repeater ID="rptAttendanceByCourse" runat="server">
                                    <ItemTemplate>
                                        <div class="flex items-center gap-3">
                                            <span class="w-20 text-sm font-medium text-gray-700 truncate"><%# Eval("CourseCode") %></span>
                                            <div class="flex-1 bg-gray-200 rounded-full h-5 overflow-hidden">
                                                <div class="bg-indigo-600 h-5 rounded-full" style='width: <%# String.Format("{0:F1}", Eval("AttendancePercentage")) %>%'></div>
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

            <!-- Right column (1/3 width) -->
            <div class="space-y-8">
                <!-- Notifications -->
                <asp:Panel ID="pnlNotifications" runat="server" Visible="true">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                        <div class="p-4 border-b border-gray-200 flex justify-between items-center">
                            <h3 class="text-lg font-semibold text-gray-900">Recent Notifications</h3>
                            <asp:HyperLink ID="hlViewAllNotifications" runat="server" NavigateUrl="~/Student/StudentNotification/StudentNotification.aspx" CssClass="text-sm text-indigo-600 hover:text-indigo-800">View All →</asp:HyperLink>
                        </div>
                        <div class="divide-y divide-gray-100">
                            <asp:Repeater ID="rptNotifications" runat="server">
                                <ItemTemplate>
                                    <a href='/Student/StudentCourseNotification/StudentCourseNotification.aspx?id=<%# Eval("AnnouncementID") %>' 
                                       class="block hover:bg-gray-100 transition"
                                       style='<%# ((bool)Eval("IsRead") ? "background-color: #f3f4f6;" : "background-color: white;") %>'>
                                        <div class="p-4">
                                            <div class="flex items-start gap-2">
                                                <span class='<%# ((bool)Eval("IsRead") ? "hidden" : "inline-block w-2 h-2 bg-red-500 rounded-full mt-1.5") %>'></span>
                                                <div class="flex-1">
                                                    <p class="text-sm font-medium text-gray-900"><%# Eval("Title") %></p>
                                                    <p class="text-xs text-gray-500 mt-1"><%# ((DateTime)Eval("CreatedDate")).ToString("MMM dd, yyyy 'at' h:mm tt") %></p>
                                                </div>
                                            </div>
                                        </div>
                                    </a>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:Label ID="lblNoNotifications" runat="server" CssClass="p-6 text-center text-gray-500 block" Visible="false" Text="No notifications yet." />
                    </div>
                </asp:Panel>

                <!-- Quick Actions -->
                <asp:Panel ID="pnlQuickActions" runat="server" Visible="true">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                        <div class="p-4 border-b border-gray-200">
                            <h3 class="text-lg font-semibold text-gray-900">Quick Actions</h3>
                        </div>
                        <div class="p-4 space-y-2">
                            <asp:HyperLink ID="hlQuickCourses" runat="server" NavigateUrl="~/Student/StudentCourse/StudentCourse.aspx" 
                                CssClass="block text-sm text-gray-700 hover:text-indigo-600 transition-colors duration-200">
                                <i class="fa-solid fa-graduation-cap w-5 mr-2 text-gray-500"></i> My Courses
                            </asp:HyperLink>
                            <asp:HyperLink ID="hlQuickResults" runat="server" NavigateUrl="~/Student/StudentAcademicResult/StudentAcademicResult.aspx" 
                                CssClass="block text-sm text-gray-700 hover:text-indigo-600 transition-colors duration-200">
                                <i class="fa-solid fa-chart-line w-5 mr-2 text-gray-500"></i> Academic Results
                            </asp:HyperLink>
                            <asp:HyperLink ID="hlQuickAttendance" runat="server" NavigateUrl="~/Student/StudentAttendance/StudentAttendance.aspx" 
                                CssClass="block text-sm text-gray-700 hover:text-indigo-600 transition-colors duration-200">
                                <i class="fa-solid fa-calendar-check w-5 mr-2 text-gray-500"></i> Attendance Records
                            </asp:HyperLink>
                            <asp:HyperLink ID="hlQuickSettings" runat="server" NavigateUrl="~/Student/StudentSetting/StudentSetting.aspx" 
                                CssClass="block text-sm text-gray-700 hover:text-indigo-600 transition-colors duration-200">
                                <i class="fa-solid fa-user-gear w-5 mr-2 text-gray-500"></i> Profile Settings
                            </asp:HyperLink>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var btn = document.getElementById('btnCustomize');
        var dropdown = document.getElementById('settingsDropdown');
        var closeBtn = document.getElementById('closeDropdown');
        var cancelBtn = document.getElementById('cancelDropdown');

        function openDropdown() {
            dropdown.classList.remove('hidden');
            setTimeout(function () {
                dropdown.classList.remove('scale-95', 'opacity-0');
                dropdown.classList.add('scale-100', 'opacity-100');
            }, 10);
        }

        function closeDropdown() {
            dropdown.classList.add('scale-95', 'opacity-0');
            dropdown.classList.remove('scale-100', 'opacity-100');
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