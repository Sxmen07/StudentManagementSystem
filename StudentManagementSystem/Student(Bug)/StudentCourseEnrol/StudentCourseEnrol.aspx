<%@ Page Title="Course Enrollment" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseEnrol.aspx.cs" Inherits="StudentManagementSystems.Student.StudentCourseEnrol" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">
                Course Enrollment
            </h1>
            <p class="text-sm mt-1">Plan your semester and register for courses</p>
        </div>
    </header>

    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">
        <!-- Message placeholder for enrollment period status (server-side) -->
        <asp:Label ID="lblEnrollmentStatus" runat="server" CssClass="block mb-4"></asp:Label>

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

        <!-- Current Semester Enrollment -->
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden mb-10">
            <div class="px-6 py-4 border-b border-gray-200 bg-[#0095FD] flex justify-between items-center">
                <h3 class="text-lg font-semibold text-white">Current Semester Enrollment</h3>
            </div>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvCurrentEnrolled" runat="server" AutoGenerateColumns="False" 
                    CssClass="min-w-full bg-white" 
                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 text-sm font-semibold uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="px-6 py-4 font-medium text-gray-900" />
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

        <!-- Dropped Courses -->
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden mb-10">
            <div class="px-6 py-4 border-b border-gray-200 bg-[#0095FD]">
                <h3 class="text-lg font-semibold text-white">Dropped Courses (This Semester)</h3>
                <p class="text-sm text-white/80">Courses you have dropped. Re‑enroll if still within add/drop period.</p>
            </div>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvDropped" runat="server" AutoGenerateColumns="False"
                    CssClass="min-w-full bg-white"
                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 text-sm font-semibold uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="px-6 py-4 font-medium text-gray-900" />
                        <asp:BoundField DataField="CourseName" HeaderText="Name" ItemStyle-CssClass="px-6 py-4 text-gray-700" />
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
            <div class="px-6 py-4 border-b border-gray-200 bg-[#0095FD]">
                <h3 class="text-lg font-semibold text-white">Available for Enrollment</h3>
                <p class="text-sm text-white/80"><asp:Label ID="lblTargetSemester" runat="server" Text="Next Semester" /></p>
            </div>
            <div class="overflow-x-auto">
                <asp:GridView ID="gvAvailable" runat="server" AutoGenerateColumns="False"
                    CssClass="min-w-full bg-white"
                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 text-sm font-semibold uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="px-6 py-4 font-medium text-gray-900" />
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
        </div>

        <!-- Academic History -->
        <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200 bg-[#0095FD]">
                <h3 class="text-lg font-semibold text-white">Academic History</h3>
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
        </div>
    </div>
</asp:Content>