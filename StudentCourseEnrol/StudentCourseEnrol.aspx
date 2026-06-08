<%@ Page Title="Course Enrollment" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseEnrol.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseEnrol" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bg-topbar-gradient h-[150px] w-full">
        <h2 class="text-[48px] font-bold text-white px-6 py-[60px] text-shadow">Course Enrollment</h2>
    </div>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Subtitle and summary cards -->
        <div class="mb-8">
            <p class="text-gray-600 mb-4">Manage your current registration and browse upcoming semester requirements.</p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
                    <p class="text-sm text-gray-500">Current GPA</p>
                    <p class="text-3xl font-bold text-indigo-600"><asp:Label ID="lblCurrentGPA" runat="server" Text="—" /></p>
                </div>
                <div class="bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
                    <p class="text-sm text-gray-500">Credits Earned</p>
                    <p class="text-3xl font-bold text-indigo-600"><asp:Label ID="lblCreditsEarned" runat="server" Text="0" /> / <asp:Label ID="lblTotalRequiredCredits" runat="server" Text="0" /></p>
                </div>
            </div>
        </div>

        <!-- Current Semester Enrollment (with Drop action) -->
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden mb-10">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
                <h3 class="text-lg font-semibold text-gray-900">Current Semester Enrollment</h3>
                <asp:LinkButton ID="btnPrintSchedule" runat="server" CssClass="text-sm text-indigo-600 hover:text-indigo-800">Print Schedule</asp:LinkButton>
            </div>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvCurrentEnrolled" runat="server" AutoGenerateColumns="False" 
                    CssClass="min-w-full bg-white" 
                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 text-sm font-semibold uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Course" ItemStyle-CssClass="px-6 py-4 font-medium text-gray-900" />
                        <asp:BoundField DataField="CourseName" HeaderText="Name" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
                        <asp:BoundField DataField="Instructor" HeaderText="Instructor" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
                        <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-CssClass="px-6 py-4 text-gray-700 text-center" />
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:Button ID="btnDrop" runat="server" Text="Drop" CommandArgument='<%# Eval("CourseOfferID") %>'
                                    OnClick="DropCourse_Click" CssClass="bg-red-500 hover:bg-red-600 text-white text-xs px-3 py-1 rounded" />
                            </ItemTemplate>
                            <ItemStyle CssClass="px-6 py-4 text-center" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <asp:Label ID="lblNoCurrent" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="You are not enrolled in any current courses." />
        </div>

        <!-- Dropped Courses (this semester) with Re-enroll action -->
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden mb-10">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 class="text-lg font-semibold text-gray-900">Dropped Courses (This Semester)</h3>
                <p class="text-sm text-gray-500">Courses you have dropped. Re‑enroll if still within add/drop period.</p>
            </div>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvDropped" runat="server" AutoGenerateColumns="False"
                    CssClass="min-w-full bg-white"
                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 text-sm font-semibold uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ItemStyle-CssClass="px-6 py-4 font-medium text-gray-900" />
                        <asp:BoundField DataField="CourseName" HeaderText="Course Name" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
                        <asp:BoundField DataField="Instructor" HeaderText="Instructor" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
                        <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-CssClass="px-6 py-4 text-gray-700 text-center" />
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:Button ID="btnReenroll" runat="server" Text="Re‑enroll" CommandArgument='<%# Eval("CourseOfferID") %>'
                                    OnClick="ReenrollCourse_Click" CssClass="bg-green-600 hover:bg-green-700 text-white text-xs px-3 py-1 rounded" />
                            </ItemTemplate>
                            <ItemStyle CssClass="px-6 py-4 text-center" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <asp:Label ID="lblNoDropped" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="No dropped courses for this semester." />
        </div>

        <!-- Available for Enrollment -->
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden mb-10">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 class="text-lg font-semibold text-gray-900">Available for Enrollment</h3>
                <p class="text-sm text-gray-500"><asp:Label ID="lblTargetSemester" runat="server" Text="Next Semester" /></p>
            </div>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvAvailable" runat="server" AutoGenerateColumns="False"
                    CssClass="min-w-full bg-white"
                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 text-sm font-semibold uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ItemStyle-CssClass="px-6 py-4 font-medium text-gray-900" />
                        <asp:BoundField DataField="CourseName" HeaderText="Name" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
                        <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-CssClass="px-6 py-4 text-gray-700 text-center" />
                        <asp:BoundField DataField="Schedule" HeaderText="Schedule" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:Button ID="btnEnroll" runat="server" Text="Enroll" CommandArgument='<%# Eval("CourseOfferID") %>'
                                    OnClick="EnrollCourse_Click" CssClass="bg-indigo-600 hover:bg-indigo-700 text-white text-xs px-3 py-1 rounded" />
                            </ItemTemplate>
                            <ItemStyle CssClass="px-6 py-4 text-center" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <asp:Label ID="lblNoAvailable" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="No courses available for enrollment at this time." />
            <div class="px-6 py-3 bg-gray-50 text-right">
                <asp:HyperLink ID="hlViewRequirements" runat="server" NavigateUrl="~/Student/ProgrammeRequirements.aspx" CssClass="text-sm text-indigo-600 hover:text-indigo-800">View All Requirements →</asp:HyperLink>
            </div>
        </div>

        <!-- Academic History (Completed Courses with Grade) -->
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <h3 class="text-lg font-semibold text-gray-900">Academic History</h3>
            </div>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False"
                    CssClass="min-w-full bg-white"
                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 text-sm font-semibold uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="SemesterYear" HeaderText="Semester" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
                        <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ItemStyle-CssClass="px-6 py-4 font-medium text-gray-900" />
                        <asp:BoundField DataField="CourseName" HeaderText="Course Name" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
                        <asp:BoundField DataField="Grade" HeaderText="Grade" ItemStyle-CssClass="px-6 py-4 font-semibold text-gray-900 text-center" />
                        <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-CssClass="px-6 py-4 text-gray-700 text-center" />
                    </Columns>
                </asp:GridView>
            </div>
            <asp:Label ID="lblNoHistory" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="No completed courses yet." />
            <div class="px-6 py-3 bg-gray-50 text-right">
                <asp:LinkButton ID="btnShowMoreHistory" runat="server" CssClass="text-sm text-indigo-600 hover:text-indigo-800">Showing 4 of 24 completed courses</asp:LinkButton>
            </div>
        </div>
    </div>
</asp:Content>
