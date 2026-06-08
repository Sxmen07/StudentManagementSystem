<%@ Page Title="Academic Results" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentAcademicResult.aspx.cs" Inherits="StudentManagementSystem.Student.StudentAcademicResult" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bg-topbar-gradient h-[189px] w-full">
        <h2 class="text-[48px] font-bold text-white px-6 py-[90px] text-shadow">Academic Results</h2>
    </div>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <asp:Repeater ID="rptSemesters" runat="server" OnItemDataBound="rptSemesters_ItemDataBound">
            <ItemTemplate>
                <div class="mb-8 bg-white rounded-xl border border-gray-200 overflow-hidden">
                    <!-- Semester header -->
                    <div class="bg-gray-800 text-white px-6 py-3">
                        <h3 class="text-xl font-semibold">
                            <%# Eval("SemesterName") %> <%# Eval("Year") %>
                        </h3>
                    </div>
                    
                    <!-- Courses table for this semester -->
                    <div class="overflow-x-auto">
                        <asp:Repeater ID="rptCourses" runat="server">
                            <HeaderTemplate>
                                <table class="min-w-full divide-y divide-gray-200">
                                    <thead class="bg-gray-50">
                                        <tr>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Course Code</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Course Name</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Credits</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Assessments (Obtained / Max)</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total Marks</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Grade</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Grade Points</th>
                                        </tr>
                                    </thead>
                                    <tbody class="bg-white divide-y divide-gray-200">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr class="hover:bg-gray-50">
                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%# Eval("CourseCode") %></td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600"><%# Eval("CourseName") %></td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600"><%# Eval("DisplayCreditHours") %></td>
                                    <td class="px-6 py-4 text-sm text-gray-600">
                                        <div class="space-y-1">
                                            <asp:Repeater ID="rptAssessments" runat="server" DataSource='<%# Eval("Assessments") %>'>
                                                <ItemTemplate>
                                                    <div><%# Eval("AssessmentName") %>: <%# Eval("ObtainedMark") %> / <%# Eval("MaxMarks") %> (Weight: <%# Eval("Weightage") %>%)</div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600"><%# Eval("DisplayTotalPercentage") %></td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold <%# GetGradeColor(Eval("Grade").ToString()) %>"><%# Eval("Grade") %></td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600"><%# Eval("DisplayGradePoint") %></td>
                                 </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                    
                    <!-- Semester GPA -->
                    <div class="bg-gray-100 px-6 py-3 flex justify-end">
                        <span class="font-semibold">Semester GPA:</span>
                        <span class="ml-2 text-lg font-bold text-indigo-600"><%# Eval("GPA") %></span>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <!-- No results message -->
        <asp:Label ID="lblNoResults" runat="server" CssClass="text-gray-500 italic" Visible="false" Text="No academic results available." />

        <!-- Total CGPA -->
        <div class="mt-8 bg-topbar-gradient rounded-xl shadow-lg p-6 text-white">
            <div class="text-right">
                <p class="text-sm uppercase tracking-wide">Cumulative GPA (CGPA)</p>
                <p class="text-4xl font-bold"><asp:Label ID="lblCGPA" runat="server" Text="0.00" /></p>
            </div>
        </div>
    </div>
</asp:Content>
