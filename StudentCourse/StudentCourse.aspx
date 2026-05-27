<%@ Page Title="Student Course" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourse.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourse" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        
    </style>

    <div class="bg-topbar-gradient h-[189px] w-full">
        <h2 class="text-[48px] font-bold text-white px-6 py-[90px] text-shadow">My Courses</h2>
    </div>

    <div class="m-[64px]">
        <!-- Toggle Headers as Server Buttons -->
        <div class="flex gap-8 border-b pb-4 mb-6">
            <asp:LinkButton ID="btnCurrent" runat="server" Text="Current Courses" CssClass="section-title text-2xl font-bold" OnClick="btnCurrent_Click" />
            <asp:LinkButton ID="btnCompleted" runat="server" Text="Completed" CssClass="section-title text-2xl font-bold" OnClick="btnCompleted_Click" />
        </div>

        <asp:Panel ID="pnlCurrent" runat="server" CssClass="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
            <asp:Repeater ID="rptCurrentCourses" runat="server">
                <ItemTemplate>
                    <div class="course-card bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm">
                        <div class="p-5">
                            <div class="flex justify-between items-start">
                                <div>
                                    <h4 class="text-xl font-bold text-gray-800"><%# Eval("CourseCode") %> - <%# Eval("CourseName") %></h4>
                                    <p class="text-sm text-gray-500 mt-1"><%# Eval("CreditHours") %> Credits</p>
                                </div>
                                <span class="bg-green-100 text-green-700 text-xs font-semibold px-3 py-1 rounded-full">In Progress</span>
                            </div>
                            <p class="text-gray-600 mt-3"><%# Eval("Description") %></p>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoCurrent" runat="server" CssClass="text-gray-500 italic col-span-full" Visible="false" Text="You are not enrolled in any current courses." />
        </asp:Panel>

        <!-- Completed Courses Panel -->
        <asp:Panel ID="pnlCompleted" runat="server" Visible="false" CssClass="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
            <asp:Repeater ID="rptCompletedCourses" runat="server">
                <ItemTemplate>
                    <div class="course-card bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm">
                        <div class="p-5">
                            <div class="flex justify-between items-start">
                                <div>
                                    <h4 class="text-xl font-bold text-gray-800"><%# Eval("CourseCode") %> - <%# Eval("CourseName") %></h4>
                                    <p class="text-sm text-gray-500 mt-1"><%# Eval("CreditHours") %> Credits</p>
                                </div>
                                <span class="bg-gray-100 text-gray-600 text-xs font-semibold px-3 py-1 rounded-full">Completed</span>
                            </div>
                            <p class="text-gray-600 mt-3"><%# Eval("Description") %></p>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoCompleted" runat="server" CssClass="text-gray-500 italic" Visible="false" Text="No completed courses yet." />
        </asp:Panel>
    </div>
</asp:Content>
