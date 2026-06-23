<%@ Page Title="Student Attendance" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentAttendance.aspx.cs" Inherits="StudentManagementSystems.Student.StudentAttendance" %>
<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">
                Student Attendance
            </h1>
            <p class="text-sm mt-1">Stay on track – monitor your attendance across all courses</p>
        </div>
    </header>

    <div class="w-full px-4 sm:px-6 lg:px-8 py-8">
        <!-- Toggle Headers -->
        <div class="flex gap-8 border-b border-gray-200 pb-4 mb-6">
            <asp:LinkButton ID="btnCurrent" runat="server" Text="Current Courses" CssClass="section-title text-xl sm:text-2xl font-bold" OnClick="btnCurrent_Click" />
            <asp:LinkButton ID="btnHistory" runat="server" Text="History" CssClass="section-title text-xl sm:text-2xl font-bold" OnClick="btnHistory_Click" />
        </div>

        <!-- Search & Sort Controls -->
        <div class="mb-6 flex flex-wrap gap-4 items-end justify-between">
            <div class="relative">
                <input type="text" id="searchCourse" placeholder="Search by course code or name..." class="pl-10 pr-4 py-2 border border-gray-300 rounded-lg w-64 sm:w-80 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                <svg class="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
            </div>
            <div>
                <label class="text-sm text-gray-600 mr-2">Sort by:</label>
                <select id="sortBy" class="border border-gray-300 rounded-lg px-3 py-2 text-sm">
                    <option value="code_asc">Course Code (A-Z)</option>
                    <option value="code_desc">Course Code (Z-A)</option>
                    <option value="attendance_desc">Attendance % (High to Low)</option>
                    <option value="attendance_asc">Attendance % (Low to High)</option>
                </select>
            </div>
        </div>

        <!-- Current Courses Panel -->
        <asp:Panel ID="pnlCurrent" runat="server" CssClass="flex flex-col gap-8">
            <div id="currentCoursesContainer">
                <asp:Repeater ID="rptCurrentCourses" runat="server" OnItemDataBound="rptCurrentCourses_ItemDataBound">
                    <ItemTemplate>
                        <div class="course-card bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm" 
                             data-course-code='<%# Eval("CourseCode") %>' 
                             data-course-name='<%# Eval("CourseName") %>'
                             data-attendance-percent='0'>
                            <div class="px-6 py-4 bg-[#0095FD] border-b border-gray-200">
                                <asp:Label ID="lblCourseCode" runat="server" CssClass="text-lg font-semibold text-white" />
                                <asp:Label ID="lblCourseName" runat="server" CssClass="block text-sm text-white/80" />
                            </div>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-6">
                                <!-- Attendance table -->
                                <div class="scrollable-table rounded-lg border border-gray-200">
                                    <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="False" CssClass="w-full"
                                        OnRowDataBound="gvAttendance_RowDataBound"
                                        HeaderStyle-CssClass="bg-gray-100 text-gray-700 font-semibold text-sm uppercase tracking-wider"
                                        RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                                        AlternatingRowStyle-CssClass="bg-gray-50"
                                        GridLines="None"
                                        EmptyDataText="No attendance records found.">
                                        <Columns>
                                            <asp:BoundField DataField="AttendanceDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="px-4 py-2" />
                                            <asp:BoundField DataField="AttendanceStatus" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="px-4 py-2" />
                                        </Columns>
                                    </asp:GridView>
                                </div>
                                <!-- Doughnut chart -->
                                <div class="bg-gray-50 p-4 rounded-lg flex flex-col items-center">
                                    <h4 class="font-semibold text-gray-800 mb-2">Attendance Summary</h4>
                                    <asp:Chart ID="chartAttendance" runat="server" Width="200" Height="200">
                                        <Series>
                                            <asp:Series Name="Attendance" ChartType="Doughnut"></asp:Series>
                                        </Series>
                                        <ChartAreas>
                                            <asp:ChartArea Name="ChartArea1"></asp:ChartArea>
                                        </ChartAreas>
                                        <Legends>
                                            <asp:Legend Name="Legend1" Docking="Bottom" />
                                        </Legends>
                                    </asp:Chart>
                                    <asp:Label ID="lblSummary" runat="server" CssClass="text-gray-700 mt-2 text-sm text-center" />
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <asp:Label ID="lblNoCurrent" runat="server" CssClass="text-gray-500 italic text-center py-8" Visible="false" Text="No current courses." />
        </asp:Panel>

        <!-- History Courses Panel -->
        <asp:Panel ID="pnlHistory" runat="server" Visible="false" CssClass="flex flex-col gap-8">
            <div id="historyCoursesContainer">
                <asp:Repeater ID="rptHistoryCourses" runat="server" OnItemDataBound="rptHistoryCourses_ItemDataBound">
                    <ItemTemplate>
                        <div class="course-card bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm" 
                             data-course-code='<%# Eval("CourseCode") %>' 
                             data-course-name='<%# Eval("CourseName") %>'
                             data-attendance-percent='0'>
                            <div class="px-6 py-4 bg-[#0095FD] border-b border-gray-200">
                                <asp:Label ID="lblCourseCode" runat="server" CssClass="text-lg font-semibold text-white" />
                                <asp:Label ID="lblCourseName" runat="server" CssClass="block text-sm text-white/80" />
                            </div>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 p-6">
                                <div class="scrollable-table rounded-lg border border-gray-200">
                                    <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="False" CssClass="w-full"
                                        OnRowDataBound="gvAttendance_RowDataBound"
                                        HeaderStyle-CssClass="bg-gray-100 text-gray-700 font-semibold text-sm uppercase tracking-wider"
                                        RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                                        AlternatingRowStyle-CssClass="bg-gray-50"
                                        GridLines="None"
                                        EmptyDataText="No attendance records found.">
                                        <Columns>
                                            <asp:BoundField DataField="AttendanceDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="px-4 py-2" />
                                            <asp:BoundField DataField="AttendanceStatus" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="px-4 py-2" />
                                        </Columns>
                                    </asp:GridView>
                                </div>
                                <div class="bg-white p-4 rounded-lg flex flex-col items-center">
                                    <h4 class="font-semibold text-gray-800 mb-2">Attendance Summary</h4>
                                    <asp:Chart ID="chartAttendance" runat="server" Width="200" Height="200">
                                        <Series>
                                            <asp:Series Name="Attendance" ChartType="Doughnut"></asp:Series>
                                        </Series>
                                        <ChartAreas>
                                            <asp:ChartArea Name="ChartArea1"></asp:ChartArea>
                                        </ChartAreas>
                                        <Legends>
                                            <asp:Legend Name="Legend1" Docking="Bottom" />
                                        </Legends>
                                    </asp:Chart>
                                    <asp:Label ID="lblSummary" runat="server" CssClass="text-gray-700 mt-2 text-sm text-center" />
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <asp:Label ID="lblNoHistory" runat="server" CssClass="text-gray-500 italic text-center py-8" Visible="false" Text="No past courses." />
        </asp:Panel>
    </div>

    <script type="text/javascript">
        // Helper to get the currently visible panel's container
        function getVisibleContainer() {
            var currentPanel = document.getElementById('pnlCurrent');
            var historyPanel = document.getElementById('pnlHistory');
            if (currentPanel && currentPanel.style.display !== 'none') {
                return document.getElementById('currentCoursesContainer');
            } else if (historyPanel && historyPanel.style.display !== 'none') {
                return document.getElementById('historyCoursesContainer');
            }
            return null;
        }

        // Extract attendance percentage from the summary label and store as data attribute
        function storeAttendancePercentages() {
            var container = getVisibleContainer();
            if (!container) return;
            var cards = container.querySelectorAll('.course-card');
            cards.forEach(function (card) {
                // Find the summary label inside this card
                var summaryLabel = card.querySelector('.text-gray-700.mt-2.text-sm.text-center');
                if (summaryLabel && !card.getAttribute('data-percent-stored')) {
                    var text = summaryLabel.innerText;
                    var match = text.match(/Attendance Rate:\s*([\d.]+)%/);
                    if (match) {
                        card.setAttribute('data-attendance-percent', parseFloat(match[1]));
                        card.setAttribute('data-percent-stored', 'true');
                    }
                }
            });
        }

        // Filter and sort courses
        function filterAndSort() {
            var container = getVisibleContainer();
            if (!container) return;

            var searchTerm = document.getElementById('searchCourse').value.toLowerCase();
            var sortValue = document.getElementById('sortBy').value;
            var cards = Array.from(container.querySelectorAll('.course-card'));

            // Filter by course code or name
            var filtered = cards.filter(function (card) {
                var code = (card.getAttribute('data-course-code') || '').toLowerCase();
                var name = (card.getAttribute('data-course-name') || '').toLowerCase();
                return code.includes(searchTerm) || name.includes(searchTerm);
            });

            // Sort
            filtered.sort(function (a, b) {
                var aVal, bVal;
                switch (sortValue) {
                    case 'code_asc':
                        aVal = a.getAttribute('data-course-code') || '';
                        bVal = b.getAttribute('data-course-code') || '';
                        return aVal.localeCompare(bVal);
                    case 'code_desc':
                        aVal = a.getAttribute('data-course-code') || '';
                        bVal = b.getAttribute('data-course-code') || '';
                        return bVal.localeCompare(aVal);
                    case 'attendance_desc':
                        aVal = parseFloat(a.getAttribute('data-attendance-percent')) || 0;
                        bVal = parseFloat(b.getAttribute('data-attendance-percent')) || 0;
                        return bVal - aVal;
                    case 'attendance_asc':
                        aVal = parseFloat(a.getAttribute('data-attendance-percent')) || 0;
                        bVal = parseFloat(b.getAttribute('data-attendance-percent')) || 0;
                        return aVal - bVal;
                    default: return 0;
                }
            });

            // Reorder DOM
            filtered.forEach(function (card) {
                container.appendChild(card);
            });
        }

        // Set up event listeners
        function init() {
            var searchInput = document.getElementById('searchCourse');
            var sortSelect = document.getElementById('sortBy');
            if (searchInput) searchInput.addEventListener('input', function () {
                filterAndSort();
            });
            if (sortSelect) sortSelect.addEventListener('change', function () {
                filterAndSort();
            });
        }

        // Run after page loads, and again after any postback (tab change)
        document.addEventListener('DOMContentLoaded', function () {
            init();
            // Wait for charts to render and labels to populate
            setTimeout(function () {
                storeAttendancePercentages();
                filterAndSort();
            }, 300);
        });

        // Also run after full page load (e.g., after tab postback)
        window.addEventListener('load', function () {
            setTimeout(function () {
                storeAttendancePercentages();
                filterAndSort();
            }, 300);
        });
    </script>
</asp:Content>