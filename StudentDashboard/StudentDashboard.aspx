<%@ Page Title="Student Dashboard" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="StudentManagementSystem.Student.StudentDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bg-topbar-gradient h-[189px] w-full">
        <h2 class="text-[48px] font-bold text-white px-6 py-[90px] text-shadow">Welcome back to UniTrack!</h2>
    </div>

    <!-- Full width container, reduced left padding -->
    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">
        <!-- 2‑column layout -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Left column (2/3 width) -->
            <div class="lg:col-span-2 space-y-8">
                <!-- Current Courses -->
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
                                        CssClass="text-sm bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-1 rounded-lg">
                                        Go to Course
                                    </asp:HyperLink>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <asp:Label ID="lblNoCurrentCourses" runat="server" CssClass="p-6 text-center text-gray-500 block" Visible="false" Text="You are not enrolled in any current courses." />
                </div>

                <!-- Academic Snapshot -->
<div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
    <div class="p-4 border-b border-gray-200 flex justify-between items-center">
        <h3 class="text-lg font-semibold text-gray-900">Academic Snapshot</h3>
        <asp:HyperLink ID="hlAcademicResults" runat="server" NavigateUrl="~/Student/StudentAcademicResult/StudentAcademicResult.aspx" CssClass="text-sm text-indigo-600 hover:text-indigo-800">View Full Results →</asp:HyperLink>
    </div>
    <div class="p-4">
        <div class="grid grid-cols-2 gap-4">
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

<!-- Attendance Summary -->
<div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
    <div class="p-4 border-b border-gray-200 flex justify-between items-center">
        <h3 class="text-lg font-semibold text-gray-900">Attendance Summary</h3>
        <asp:HyperLink ID="hlViewAttendance" runat="server" NavigateUrl="~/Student/StudentAttendance/StudentAttendance.aspx" CssClass="text-sm text-indigo-600 hover:text-indigo-800">View Full →</asp:HyperLink>
    </div>
    <div class="p-4">
        <!-- Overall attendance bar -->
        <div class="mb-4">
            <div class="flex justify-between text-sm text-gray-600 mb-1">
                <span>Overall Attendance (Current Semester)</span>
                <span><asp:Label ID="lblOverallAttendance" runat="server" Text="0%" /></span>
            </div>
            <asp:HiddenField ID="hfAttendanceWidth" runat="server" Value="0" />
            <div class="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                <div class="bg-green-600 h-2 rounded-full" style='width: <%= hfAttendanceWidth.Value %>%'></div>
            </div>
        </div>

        <!-- Individual course attendance bars with text inside -->
        <div class="space-y-3">
            <asp:Repeater ID="rptAttendanceByCourse" runat="server">
    <ItemTemplate>
        <div class="flex items-center gap-3">
            <!-- Course Code -->
            <span class="w-20 text-sm font-medium text-gray-700 truncate" title="<%# Eval("CourseCode") %>">
                <%# Eval("CourseCode") %>
            </span>
            
            <!-- Progress Bar Container - taller -->
            <div class="flex-1 bg-gray-200 rounded-full h-5 overflow-hidden">
                <div class="bg-indigo-600 h-5 rounded-full" 
                     style='width: <%# String.Format("{0:F1}", Eval("AttendancePercentage")) %>%'>
                </div>
            </div>
            
            <!-- Percentage -->
            <span class="text-sm font-semibold text-gray-900 w-12 text-right">
                <%# String.Format("{0:F1}", Eval("AttendancePercentage")) %>%
            </span>
        </div>
    </ItemTemplate>
</asp:Repeater>
        </div>
    </div>
</div>
            </div>

            <!-- Right column (1/3 width) -->
            <div class="space-y-8">
                <!-- Notifications (grey background for read, white for unread) -->
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

                <!-- Quick Actions -->
                <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                    <div class="p-4 border-b border-gray-200">
                        <h3 class="text-lg font-semibold text-gray-900">Quick Actions</h3>
                    </div>
                    <div class="p-4 space-y-2">
                        <asp:HyperLink ID="hlQuickCourses" runat="server" NavigateUrl="~/Student/StudentCourse/StudentCourse.aspx" CssClass="block text-sm text-gray-700 hover:text-indigo-600">📚 My Courses</asp:HyperLink>
                        <asp:HyperLink ID="hlQuickResults" runat="server" NavigateUrl="~/Student/StudentAcademicResult/StudentAcademicResult.aspx" CssClass="block text-sm text-gray-700 hover:text-indigo-600">📊 Academic Results</asp:HyperLink>
                        <asp:HyperLink ID="hlQuickAttendance" runat="server" NavigateUrl="~/Student/StudentAttendance/StudentAttendance.aspx" CssClass="block text-sm text-gray-700 hover:text-indigo-600">📅 Attendance Records</asp:HyperLink>
                        <asp:HyperLink ID="hlQuickSettings" runat="server" NavigateUrl="~/Student/StudentSetting/StudentSetting.aspx" CssClass="block text-sm text-gray-700 hover:text-indigo-600">⚙️ Profile Settings</asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
