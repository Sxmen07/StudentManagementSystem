<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Inherits="StudentManagementSystem.Student.StudentProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <header class="bg-topbar-gradient w-full">
    <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
        <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">
            My Profile
        </h1>
        <!-- subtitle -->
        <p class="text-sm mt-1">Take a look of my study journey</p>
    </div>
</header>

    <!-- Full width container, reduced left padding -->
    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 mt-[40px]">
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div class="p-6 sm:p-8">
                <div class="flex flex-col sm:flex-row items-center sm:items-start gap-6">
                    <div class="w-32 h-32 rounded-full border-4 border-white shadow-md overflow-hidden bg-gray-200 flex-shrink-0">
                        <asp:Image ID="ProfilePicture" runat="server" CssClass="w-full h-full object-cover" />
                    </div>

                    <div class="flex-1 text-center sm:text-left space-y-2 mt-2">
                        <div class="flex flex-col sm:flex-row items-center gap-3">
                            <asp:Label ID="StudentName" runat="server" CssClass="text-3xl font-bold text-gray-900"></asp:Label>

                            <a href="/Student/StudentSetting/StudentSetting.aspx" class="text-gray-400 hover:text-indigo-600 transition-colors duration-200" title="Edit Profile">
                                <i class="fa-solid fa-pen-to-square text-xl"></i>
                            </a>
                        </div>

                        <asp:Label ID="ProgramName" runat="server" CssClass="text-lg text-indigo-600 font-medium block"></asp:Label>

                        <div class="flex items-center justify-center sm:justify-start gap-2 text-gray-500 pt-1 text-sm">
                            <i class="fa-solid fa-envelope"></i>
                            <asp:Label ID="StudentEmail" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-xl border border-gray-200 mt-8 overflow-hidden mb-16">
            <div class="p-6 border-b border-gray-100">
                <h2 class="text-xl font-semibold text-gray-800">My Enrolled Courses</h2>
                <p class="text-sm text-gray-500">Courses you are currently enrolled in</p>
            </div>

            <div class="divide-y divide-gray-200">
                <asp:Repeater ID="CourseRepeater" runat="server">
                    <ItemTemplate>
                        <div class="p-4 hover:bg-gray-50 transition">
                            <div class="flex items-center justify-between">
                                <div>
                                    <p class="font-medium text-gray-900"><%# Eval("CourseName") %></p>
                                    <p class="text-sm text-gray-500">Course Code: <%# Eval("CourseCode") %></p>
                                </div>
                                <div class="text-sm text-gray-400 font-medium">
                                    <%# Eval("Semester") %> <%# Eval("Year") %>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" CssClass="p-8 text-center text-gray-500">
                    <i class="fa-solid fa-book-open block text-3xl text-gray-300 mb-2"></i>
                    You are not enrolled in any courses yet.
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>