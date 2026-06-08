<%@ Page Title="Student Course" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourse.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourse" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bg-topbar-gradient h-[189px] w-full">
        <h2 class="text-[48px] font-bold text-white px-6 py-[90px] text-shadow">My Courses</h2>
    </div>

    <div class="m-[64px]">
        <!-- Toggle Headers -->
        <div class="flex gap-8 border-b pb-4 mb-6">
            <asp:LinkButton ID="btnCurrent" runat="server" Text="Current Courses" CssClass="section-title text-2xl font-bold" OnClick="btnCurrent_Click" />
            <asp:LinkButton ID="btnCompleted" runat="server" Text="Completed" CssClass="section-title text-2xl font-bold" OnClick="btnCompleted_Click" />
        </div>

        <!-- Current Courses Panel -->
        <asp:Panel ID="pnlCurrent" runat="server" CssClass="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
            <asp:Repeater ID="rptCurrentCourses" runat="server">
                <ItemTemplate>
                    <a href='<%# ResolveUrl("~/Student/StudentCourseMaterial/StudentCourseMaterial.aspx?courseOfferId=" + Eval("CourseOfferID")) %>'
                        class="block course-card bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm flex flex-col h-full hover:shadow-lg transition">
                        <div class="p-5 flex-1">
                            <div>
                                <h4 class="text-xl font-bold text-gray-800"><%# Eval("CourseCode") %> - <%# Eval("CourseName") %></h4>
                                <p class="text-sm text-gray-500 mt-1"><%# Eval("CreditHours") %> Credits</p>
                            </div>
                            <p class="text-gray-600 mt-3"><%# Eval("Description") %></p>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoCurrent" runat="server" CssClass="text-gray-500 italic col-span-full" Visible="false" Text="You are not enrolled in any current courses." />
        </asp:Panel>

        <!-- Completed Courses Panel -->
        <asp:Panel ID="pnlCompleted" runat="server" Visible="false" CssClass="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
            <asp:Repeater ID="rptCompletedCourses" runat="server">
                <ItemTemplate>
                    <a href='<%# ResolveUrl("~/Student/StudentCourseMaterial/StudentCourseMaterial.aspx?courseOfferId=" + Eval("CourseOfferID")) %>'
                       class="block course-card bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm flex flex-col h-full hover:shadow-lg transition">
                        <div class="p-5 flex-1">
                            <div>
                                <h4 class="text-xl font-bold text-gray-800"><%# Eval("CourseCode") %> - <%# Eval("CourseName") %></h4>
                                <p class="text-sm text-gray-500 mt-1"><%# Eval("CreditHours") %> Credits</p>
                            </div>
                            <p class="text-gray-600 mt-3"><%# Eval("Description") %></p>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoCompleted" runat="server" CssClass="text-gray-500 italic col-span-full" Visible="false" Text="No completed courses yet." />
        </asp:Panel>
    </div>
</asp:Content>
