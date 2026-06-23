<%@ Page Title="Academic Results" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentAcademicResult.aspx.cs" Inherits="StudentManagementSystem.Student.StudentAcademicResult" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Font Awesome CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style type="text/css">
        .grid-pager table { margin: 0 auto; }
        .grid-pager td { padding: 0 6px; }
        .grid-pager a { color: #7C7B77; font-size: 11px; text-decoration: none; font-weight: 500; }
        .grid-pager a:hover { color: #1A1A1A; text-decoration: underline; }
        .grid-pager span { color: #1A1A1A; font-size: 11px; font-weight: 700; border-bottom: 2px solid #1A1A1A; padding-bottom: 2px; }

        .gv-header-dark th {
            color: #ffffff !important;
            background-color: #111827 !important;
        }

        .gv-row-hover:hover {
            background-color: #f9fafb !important;
        }
    </style>

    <!-- HEADER (no export buttons) -->
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">Academic Results</h1>
            <p class="text-sm mt-1">Marks isn't everything but marks provide a better future in career.</p>
        </div>
    </header>

    <!-- DOWNLOAD BAR -->
    <div class="w-full px-4 sm:px-6 lg:px-8 py-3 bg-white flex flex-wrap items-center justify-end gap-3 mt-2">
        <span class="text-xs font-semibold text-gray-600 tracking-wider">Download:</span>
        <asp:LinkButton ID="btnExportCSV" runat="server" OnClick="btnExportCSV_Click" CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 px-3 py-1.5 rounded-lg shadow-sm text-xs font-semibold transition-all">
            <i class="fa-solid fa-file-csv text-zinc-500"></i> CSV
        </asp:LinkButton>
        <asp:LinkButton ID="btnExportExcel" runat="server" OnClick="btnExportExcel_Click" CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 px-3 py-1.5 rounded-lg shadow-sm text-xs font-semibold transition-all">
            <i class="fa-solid fa-file-excel text-emerald-600"></i> Excel
        </asp:LinkButton>
        <asp:LinkButton ID="btnExportPDF" runat="server" OnClick="btnExportPDF_Click" CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 px-3 py-1.5 rounded-lg shadow-sm text-xs font-semibold transition-all">
            <i class="fa-solid fa-file-pdf text-red-600"></i> PDF
        </asp:LinkButton>
    </div>

    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">

        <!-- 4x SUMMARY CARDS (unchanged) -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4 hover:shadow-md transition">
                <div class="w-10 h-10 rounded-lg bg-[#111827] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-book-open"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Credits</p>
                    <p class="text-2xl font-bold text-[#111827]">
                        <asp:Label ID="lblTotalCredits" runat="server" Text="0" />
                    </p>
                </div>
            </div>
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4 hover:shadow-md transition">
                <div class="w-10 h-10 rounded-lg bg-[#0095FD] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-graduation-cap"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Current Credits</p>
                    <p class="text-2xl font-bold text-[#0095FD]">
                        <asp:Label ID="lblCurrentCredits" runat="server" Text="0" />
                    </p>
                </div>
            </div>
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4 hover:shadow-md transition">
                <div class="w-10 h-10 rounded-lg bg-[#00CBD4] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Current GPA</p>
                    <p class="text-2xl font-bold text-[#00CBD4]">
                        <asp:Label ID="lblCurrentGPA" runat="server" Text="0.00" />
                    </p>
                </div>
            </div>
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4 hover:shadow-md transition">
                <div class="w-10 h-10 rounded-lg bg-[#6FE8DD] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-star"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">CGPA</p>
                    <p class="text-2xl font-bold text-[#115FB3]">
                        <asp:Label ID="lblCGPA" runat="server" Text="0.00" />
                    </p>
                </div>
            </div>
        </div>

        <!-- FILTER PANEL (unchanged) -->
        <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-3 shadow-sm mb-6 flex flex-wrap items-center gap-3">
            <div class="flex items-center mr-auto">
                <div class="relative">
                    <input type="text" id="searchInput" placeholder="Search by course code or name..." 
                           class="border border-[#EBEBE9] rounded-md px-3 py-1.5 text-sm bg-white w-72 placeholder:text-gray-400 pl-8"
                           onkeyup="filterAcademicResults()" />
                    <i class="fas fa-search absolute left-2.5 top-2 text-gray-400 text-sm"></i>
                </div>
            </div>
            <div>
                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Semester</label>
                <asp:DropDownList ID="ddlSemesterFilter" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSemesterFilter_SelectedIndexChanged" CssClass="border border-[#EBEBE9] rounded-md px-3 py-1.5 text-sm bg-white">
                </asp:DropDownList>
            </div>
            <div>
                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Sort Courses By</label>
                <asp:DropDownList ID="ddlSortBy" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged" CssClass="border border-[#EBEBE9] rounded-md px-3 py-1.5 text-sm bg-white">
                    <asp:ListItem Text="Course Code (A-Z)" Value="code_asc" />
                    <asp:ListItem Text="Course Code (Z-A)" Value="code_desc" />
                    <asp:ListItem Text="Total % (High to Low)" Value="total_desc" />
                    <asp:ListItem Text="Total % (Low to High)" Value="total_asc" />
                    <asp:ListItem Text="Grade Points (High to Low)" Value="gpa_desc" />
                    <asp:ListItem Text="Grade Points (Low to High)" Value="gpa_asc" />
                </asp:DropDownList>
            </div>
        </div>

        <!-- GRID (unchanged) -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
            <asp:GridView ID="gvAcademicResults" runat="server" AutoGenerateColumns="False"
                AllowPaging="True" PageSize="6" PagerStyle-CssClass="grid-pager" PagerSettings-Mode="NumericFirstLast"
                OnPageIndexChanging="gvAcademicResults_PageIndexChanging" OnRowDataBound="gvAcademicResults_RowDataBound"
                CssClass="min-w-full divide-y divide-gray-200"
                HeaderStyle-CssClass="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider gv-header-dark"
                RowStyle-CssClass="hover:bg-gray-50 transition gv-row-hover"
                AlternatingRowStyle-CssClass="bg-gray-50"
                GridLines="None"
                ClientIDMode="Static">

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

                <EmptyDataTemplate>
                    <div class="text-center py-12 px-4">
                        <span class="text-3xl text-zinc-300 block mb-2">⍠</span>
                        <p class="text-sm font-semibold text-[#1A1A1A]">No academic records found for the selected criteria.</p>
                        <p class="text-xs text-[#7C7B77] mt-0.5">Ensure you are enrolled in courses with completed assessments.</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>

    </div>

    <script type="text/javascript">
        function filterAcademicResults() {
            var input = document.getElementById('searchInput');
            var filter = input.value.toLowerCase();
            var grid = document.getElementById('gvAcademicResults');

            if (!grid) return;

            var rows = grid.getElementsByTagName('tbody')[0];
            if (!rows) return;

            var rowCollection = rows.getElementsByTagName('tr');

            for (var i = 0; i < rowCollection.length; i++) {
                var row = rowCollection[i];
                if (row.className && row.className.indexOf('grid-pager') !== -1) continue;

                var cells = row.getElementsByTagName('td');
                if (cells.length === 0) continue;

                var courseCell = cells[0];
                var courseText = courseCell ? courseCell.innerText.toLowerCase() : '';

                var found = courseText.indexOf(filter) > -1;

                if (found) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            }
        }
    </script>
</asp:Content>