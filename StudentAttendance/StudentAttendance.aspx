<%@ Page Title="Student Attendance" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentAttendance.aspx.cs" Inherits="StudentManagementSystem.Student.StudentAttendance" %>
<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style type="text/css">
        .stat-card {
            transition: all 0.25s ease-in-out;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
        }
        .course-card {
            transition: all 0.25s ease-in-out;
        }
        .course-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.10);
        }
        .tab-active {
            color: #111827 !important;
            border-bottom: 3px solid #111827;
            padding-bottom: 8px;
        }
        .tab-inactive {
            color: #7C7B77 !important;
            border-bottom: 3px solid transparent;
            padding-bottom: 8px;
        }
        .tab-inactive:hover {
            color: #111827 !important;
            border-bottom-color: #D1D5DB;
        }
        .gv-header-dark th {
            color: #ffffff !important;
            background-color: #111827 !important;
        }
        .badge-present {
            background: #d1fae5;
            color: #065f46;
            padding: 2px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-late {
            background: #fef3c7;
            color: #92400e;
            padding: 2px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-absent {
            background: #fee2e2;
            color: #991b1b;
            padding: 2px 10px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
        }
        .scrollable-table {
            max-height: 280px;
            overflow-y: auto;
        }
        .scrollable-table table {
            width: 100%;
        }
        .scrollable-table thead th {
            position: sticky;
            top: 0;
            z-index: 2;
        }
        
        /* Interactive Week Grid Layout */
        .week-grid-container {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            align-items: center;
            justify-content: center;
        }
        .btn-week-badge {
            display: inline-block;
            min-width: 32px;
            height: 32px;
            line-height: 30px;
            text-align: center;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            border: 1px solid #E5E7EB;
            background-color: #F3F4F6;
            color: #4B5563;
            text-decoration: none !important;
            transition: all 0.15s ease;
        }
        .btn-week-badge:hover {
            background-color: #E5E7EB;
            color: #111827;
        }
        .btn-week-badge-active {
            background-color: #111827 !important;
            color: #FFFFFF !important;
            border-color: #111827 !important;
        }
    </style>

    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">Student Attendance</h1>
            <p class="text-sm mt-1">Stay on track – monitor your attendance across all courses</p>
        </div>
    </header>

    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#111827] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-chart-simple"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Overall Attendance</p>
                    <p class="text-2xl font-bold text-[#111827]">
                        <asp:Label ID="lblOverallAttendance" runat="server" Text="0%" />
                    </p>
                </div>
            </div>
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#0095FD] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Present</p>
                    <p class="text-2xl font-bold text-[#0095FD]">
                        <asp:Label ID="lblTotalPresent" runat="server" Text="0" />
                    </p>
                </div>
            </div>
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#00CBD4] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-clock"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Late</p>
                    <p class="text-2xl font-bold text-[#00CBD4]">
                        <asp:Label ID="lblTotalLate" runat="server" Text="0" />
                    </p>
                </div>
            </div>
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#6FE8DD] flex items-center justify-center text-gray-800 text-lg flex-shrink-0">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Absent</p>
                    <p class="text-2xl font-bold text-[#115FB3]">
                        <asp:Label ID="lblTotalAbsent" runat="server" Text="0" />
                    </p>
                </div>
            </div>
        </div>

        <div class="flex gap-8 border-b border-[#EBEBE9] pb-3 mb-6">
            <asp:LinkButton ID="btnCurrent" runat="server" Text="Current Courses" 
                CssClass="text-base font-semibold transition duration-200 tab-active" 
                OnClick="btnCurrent_Click" />
            <asp:LinkButton ID="btnHistory" runat="server" Text="History" 
                CssClass="text-base font-semibold transition duration-200 tab-inactive" 
                OnClick="btnHistory_Click" />
        </div>

        <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-3 shadow-sm mb-6 flex flex-wrap items-center gap-3">
            <div class="relative flex-1 max-w-xs">
                <input type="text" id="searchCourse" placeholder="Search by course code or name..." 
                       class="w-full pl-8 pr-4 py-1.5 border border-[#EBEBE9] rounded-md text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#0095FD] placeholder:text-gray-400" />
                <i class="fas fa-search absolute left-2.5 top-2 text-gray-400 text-sm"></i>
            </div>
            <div class="flex items-center gap-2">
                <label class="text-xs font-bold text-[#7C7B77] uppercase tracking-wider">Sort by:</label>
                <select id="sortBy" class="border border-[#EBEBE9] rounded-md px-3 py-1.5 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#0095FD]">
                    <option value="code_asc">Course Code (A-Z)</option>
                    <option value="code_desc">Course Code (Z-A)</option>
                    <option value="attendance_desc">Attendance % (High to Low)</option>
                    <option value="attendance_asc">Attendance % (Low to High)</option>
                </select>
            </div>
        </div>

        <asp:Panel ID="pnlCurrent" runat="server" CssClass="flex flex-col gap-6">
            <div id="currentCoursesContainer" class="grid grid-cols-1 gap-6">
                <asp:Repeater ID="rptCurrentCourses" runat="server" OnItemDataBound="rptCurrentCourses_ItemDataBound" OnItemCommand="rptCourses_ItemCommand">
                    <ItemTemplate>
                        <div class="course-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden"
                             data-course-code='<%# Eval("CourseCode") %>'
                             data-course-name='<%# Eval("CourseName") %>'
                             data-attendance-percent='0'>
                            <div class="px-6 py-4 bg-[#111827] border-b border-gray-200 flex justify-between items-center">
                                <div>
                                    <asp:HiddenField ID="hfCourseOfferID" runat="server" Value='<%# Eval("CourseOfferID") %>' />
                                    <asp:Label ID="lblCourseCode" runat="server" CssClass="text-lg font-semibold text-white" />
                                    <asp:Label ID="lblCourseName" runat="server" CssClass="block text-sm text-white/80" />
                                </div>
                                <span class="text-white/60 text-sm">
                                    <i class="fas fa-calendar-alt mr-1"></i>
                                    <asp:Label ID="lblRecordCount" runat="server" CssClass="font-medium" />
                                </span>
                            </div>
                            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 p-6">
                                
                                <div class="lg:col-span-2">
                                    <div class="flex flex-col gap-2 mb-4 bg-gray-50 p-3 rounded-lg border border-gray-100">
                                        <div class="flex justify-between items-center px-1 mb-1">
                                            <span class="text-sm font-bold text-gray-700">Jump to Week:</span>
                                            <span class="text-xs text-gray-500 font-medium">
                                                <asp:Label ID="lblWeekRange" runat="server" Text="No data" />
                                            </span>
                                        </div>
                                        <div class="week-grid-container">
                                            <asp:ListView ID="lvWeekButtons" runat="server" OnItemDataBound="lvWeekButtons_ItemDataBound">
                                                <LayoutTemplate>
                                                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                                                </LayoutTemplate>
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnWeekSelect" runat="server" 
                                                        Text='<%# Container.DataItem %>' 
                                                        CommandName="SelectWeek" 
                                                        CommandArgument='<%# Container.DataItem %>'
                                                        CssClass="btn-week-badge" />
                                                </ItemTemplate>
                                            </asp:ListView>
                                        </div>
                                    </div>
                                    
                                    <div class="scrollable-table rounded-lg border border-gray-200">
                                        <asp:GridView ID="gvDailyAttendance" runat="server" AutoGenerateColumns="False" CssClass="w-full text-sm"
                                            HeaderStyle-CssClass="gv-header-dark"
                                            RowStyle-CssClass="border-b border-gray-100 hover:bg-gray-50 transition"
                                            AlternatingRowStyle-CssClass="bg-gray-50"
                                            GridLines="None"
                                            EmptyDataText="No attendance records for this week."
                                            ShowHeaderWhenEmpty="true"
                                            OnRowDataBound="gvDailyAttendance_RowDataBound">
                                            <Columns>
                                                <asp:BoundField DataField="AttendanceDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="px-4 py-2" />
                                                <asp:BoundField DataField="AttendanceStatus" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="px-4 py-2" />
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                    
                                    <div class="mt-3 text-sm text-gray-600 text-center bg-gray-50 p-2 rounded-lg">
                                        <asp:Label ID="lblWeekSummary" runat="server" Text="" />
                                    </div>
                                </div>
                                
                                <div class="bg-gray-50 p-4 rounded-lg flex flex-col items-center justify-center">
                                    <h4 class="font-semibold text-gray-800 mb-2">Overall Summary</h4>
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

        <asp:Panel ID="pnlHistory" runat="server" Visible="false" CssClass="flex flex-col gap-6">
            <div id="historyCoursesContainer" class="grid grid-cols-1 gap-6">
                <asp:Repeater ID="rptHistoryCourses" runat="server" OnItemDataBound="rptHistoryCourses_ItemDataBound" OnItemCommand="rptCourses_ItemCommand">
                    <ItemTemplate>
                        <div class="course-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden"
                             data-course-code='<%# Eval("CourseCode") %>'
                             data-course-name='<%# Eval("CourseName") %>'
                             data-attendance-percent='0'>
                            <div class="px-6 py-4 bg-[#111827] border-b border-gray-200 flex justify-between items-center">
                                <div>
                                    <asp:HiddenField ID="hfCourseOfferID" runat="server" Value='<%# Eval("CourseOfferID") %>' />
                                    <asp:Label ID="lblCourseCode" runat="server" CssClass="text-lg font-semibold text-white" />
                                    <asp:Label ID="lblCourseName" runat="server" CssClass="block text-sm text-white/80" />
                                </div>
                                <span class="text-white/60 text-sm">
                                    <i class="fas fa-calendar-alt mr-1"></i>
                                    <asp:Label ID="lblRecordCount" runat="server" CssClass="font-medium" />
                                </span>
                            </div>
                            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 p-6">
                                <div class="lg:col-span-2">
                                    <div class="flex flex-col gap-2 mb-4 bg-gray-50 p-3 rounded-lg border border-gray-100">
                                        <div class="flex justify-between items-center px-1 mb-1">
                                            <span class="text-sm font-bold text-gray-700">Jump to Week:</span>
                                            <span class="text-xs text-gray-500 font-medium">
                                                <asp:Label ID="lblWeekRange" runat="server" Text="No data" />
                                            </span>
                                        </div>
                                        <div class="week-grid-container">
                                            <asp:ListView ID="lvWeekButtons" runat="server" OnItemDataBound="lvWeekButtons_ItemDataBound">
                                                <LayoutTemplate>
                                                    <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                                                </LayoutTemplate>
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnWeekSelect" runat="server" 
                                                        Text='<%# Container.DataItem %>' 
                                                        CommandName="SelectWeek" 
                                                        CommandArgument='<%# Container.DataItem %>'
                                                        CssClass="btn-week-badge" />
                                                </ItemTemplate>
                                            </asp:ListView>
                                        </div>
                                    </div>
                                    
                                    <div class="scrollable-table rounded-lg border border-gray-200">
                                        <asp:GridView ID="gvDailyAttendance" runat="server" AutoGenerateColumns="False" CssClass="w-full text-sm"
                                            HeaderStyle-CssClass="gv-header-dark"
                                            RowStyle-CssClass="border-b border-gray-100 hover:bg-gray-50 transition"
                                            AlternatingRowStyle-CssClass="bg-gray-50"
                                            GridLines="None"
                                            EmptyDataText="No attendance records for this week."
                                            ShowHeaderWhenEmpty="true"
                                            OnRowDataBound="gvDailyAttendance_RowDataBound">
                                            <Columns>
                                                <asp:BoundField DataField="AttendanceDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="px-4 py-2" />
                                                <asp:BoundField DataField="AttendanceStatus" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="px-4 py-2" />
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                    
                                    <div class="mt-3 text-sm text-gray-600 text-center bg-gray-50 p-2 rounded-lg">
                                        <asp:Label ID="lblWeekSummary" runat="server" Text="" />
                                    </div>
                                </div>
                                
                                <div class="bg-gray-50 p-4 rounded-lg flex flex-col items-center justify-center">
                                    <h4 class="font-semibold text-gray-800 mb-2">Overall Summary</h4>
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

        function storeAttendancePercentages() {
            var container = getVisibleContainer();
            if (!container) return;
            var cards = container.querySelectorAll('.course-card');
            cards.forEach(function (card) {
                if (!card.getAttribute('data-percent-stored')) {
                    var summaryLabel = card.querySelector('.text-gray-700.mt-2.text-sm.text-center');
                    if (summaryLabel) {
                        var text = summaryLabel.innerText;
                        var match = text.match(/Attendance Rate:\s*([\d.]+)%/);
                        if (match) {
                            card.setAttribute('data-attendance-percent', parseFloat(match[1]));
                            card.setAttribute('data-percent-stored', 'true');
                        }
                    }
                }
            });
        }

        function filterAndSort() {
            var container = getVisibleContainer();
            if (!container) return;
            var searchTerm = document.getElementById('searchCourse').value.toLowerCase();
            var sortValue = document.getElementById('sortBy').value;
            var cards = Array.from(container.querySelectorAll('.course-card'));

            var filtered = cards.filter(function (card) {
                var code = (card.getAttribute('data-course-code') || '').toLowerCase();
                var name = (card.getAttribute('data-course-name') || '').toLowerCase();
                return code.includes(searchTerm) || name.includes(searchTerm);
            });

            filtered.sort(function (a, b) {
                var aVal, bVal;
                switch (sortValue) {
                    case 'code_asc':
                        aVal = a.getAttribute('data-course-code') || '';
                        bVal = b.getAttribute('data-course-code') || '';
                        return aVal.localeCompare(bVal);
                    case 'code_desc':
                        aVal = a.getAttribute('data-course-code'] || '';
                        bVal = b.getAttribute('data-course-code'] || '';
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

            filtered.forEach(function (card) {
                container.appendChild(card);
            });
        }

        function init() {
            var searchInput = document.getElementById('searchCourse');
            var sortSelect = document.getElementById('sortBy');
            if (searchInput) searchInput.addEventListener('input', filterAndSort);
            if (sortSelect) sortSelect.addEventListener('change', filterAndSort);
        }

        document.addEventListener('DOMContentLoaded', function () {
            init();
            setTimeout(function () {
                storeAttendancePercentages();
                filterAndSort();
            }, 400);
        });
    </script>
</asp:Content>
