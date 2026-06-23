<%@ Page Title="Academic Results" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentAcademicResult.aspx.cs" Inherits="StudentManagementSystems.Student.StudentAcademicResult" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">Academic Results</h1>
            <p class="text-sm mt-1">Marks isn't everything but marks provide a better future in career.</p>
        </div>
    </header>

    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">
        <!-- Filter & Sort Panel -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 mb-6 flex flex-wrap gap-4 items-end justify-end">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Semester</label>
                <asp:DropDownList ID="ddlSemesterFilter" runat="server" CssClass="border border-gray-300 rounded-md px-3 py-2 text-sm">
                    <asp:ListItem Text="All Semesters" Value="all" />
                </asp:DropDownList>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Sort Courses By</label>
                <asp:DropDownList ID="ddlSortBy" runat="server" CssClass="border border-gray-300 rounded-md px-3 py-2 text-sm">
                    <asp:ListItem Text="Course Code (A-Z)" Value="code_asc" />
                    <asp:ListItem Text="Course Code (Z-A)" Value="code_desc" />
                    <asp:ListItem Text="Total % (High to Low)" Value="total_desc" />
                    <asp:ListItem Text="Total % (Low to High)" Value="total_asc" />
                    <asp:ListItem Text="Grade Points (High to Low)" Value="gpa_desc" />
                    <asp:ListItem Text="Grade Points (Low to High)" Value="gpa_asc" />
                </asp:DropDownList>
            </div>
            <div>
                <asp:Button ID="btnApplyFilter" runat="server" Text="Apply" OnClick="btnApplyFilter_Click" CssClass="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm" />
                <asp:Button ID="btnResetFilter" runat="server" Text="Reset" OnClick="btnResetFilter_Click" CssClass="ml-2 bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-md text-sm" />
            </div>
        </div>

        <!-- Single Table with Assessment Details -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <asp:GridView ID="gvAcademicResults" runat="server" AutoGenerateColumns="False" 
                    CssClass="min-w-full divide-y divide-gray-200" 
                    HeaderStyle-CssClass="bg-gray-50" 
                    RowStyle-CssClass="hover:bg-gray-50 transition"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    EmptyDataText="No academic results available."
                    OnRowDataBound="gvAcademicResults_RowDataBound">
                    <Columns>
                        <asp:TemplateField HeaderText="Course">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 align-top" />
                            <ItemTemplate>
                                <div class="text-sm font-medium text-gray-900"><%# Eval("CourseCode") %></div>
                                <div class="text-xs text-gray-500"><%# Eval("CourseName") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="CreditHours" HeaderText="Credits" SortExpression="CreditHours">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 text-center align-top" />
                        </asp:BoundField>

                        <asp:BoundField DataField="SemesterDisplay" HeaderText="Semester" SortExpression="SemesterDisplay">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 text-center align-top" />
                        </asp:BoundField>

                        <asp:BoundField DataField="Year" HeaderText="Year" SortExpression="Year">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 text-center align-top" />
                        </asp:BoundField>

                        <asp:TemplateField HeaderText="Assessment">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 align-top" />
                            <ItemTemplate>
                                <asp:Repeater ID="rptAssessmentNames" runat="server">
                                    <ItemTemplate>
                                        <div class="min-h-[42px] flex items-center">
                                            <div class="text-sm font-semibold text-gray-800"><%# Eval("AssessmentName") %></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Score">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 align-top" />
                            <ItemTemplate>
                                <asp:Repeater ID="rptScores" runat="server">
                                    <ItemTemplate>
                                        <div class="min-h-[42px] flex items-center">
                                            <div class="text-sm font-semibold text-gray-900 whitespace-nowrap">
                                                <%# String.Format("{0:F2}", Eval("ObtainedMark")) %> / <%# String.Format("{0:F2}", Eval("MaxMarks")) %>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Weighted Score">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 align-top" />
                            <ItemTemplate>
                                <asp:Repeater ID="rptWeightedScores" runat="server">
                                    <ItemTemplate>
                                        <div class="min-h-[42px] flex items-center">
                                            <div class="text-sm font-medium text-indigo-600 whitespace-nowrap">
                                                <%# (((decimal)Eval("ObtainedMark") / (decimal)Eval("MaxMarks")) * (decimal)Eval("Weightage")).ToString("F2") %> / <%# Eval("Weightage") %>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="TotalPercentage" HeaderText="Total %" SortExpression="TotalPercentage" DataFormatString="{0:F2}%">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 text-center align-top" />
                        </asp:BoundField>

                        <asp:BoundField DataField="Grade" HeaderText="Grade" SortExpression="Grade">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 text-center align-top font-semibold" />
                        </asp:BoundField>

                        <asp:BoundField DataField="GradePoint" HeaderText="Grade Pts" SortExpression="GradePoint" DataFormatString="{0:F2}">
                            <HeaderStyle CssClass="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" />
                            <ItemStyle CssClass="px-4 py-3 text-center align-top" />
                        </asp:BoundField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- CGPA Display -->
        <div class="mt-8 bg-gradient-to-r from-indigo-600 to-indigo-800 rounded-xl shadow-lg p-6 text-white">
            <div class="flex justify-end items-center">
                <div class="text-right">
                    <p class="text-sm uppercase tracking-wide opacity-80">Cumulative GPA</p>
                    <p class="text-4xl font-bold">
                        <asp:Label ID="lblCGPA" runat="server" Text="0.00" />
                    </p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>