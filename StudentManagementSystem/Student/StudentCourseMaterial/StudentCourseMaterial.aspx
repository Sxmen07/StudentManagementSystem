<%@ Page Title="Course Material" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseMaterial.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseMaterial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">
                <asp:Label ID="lblCourseTitle" runat="server" />
            </h1>
            <p class="text-lg sm:text-xl text-white/80 mt-2 font-medium">
                <asp:Label ID="lblLecturer" runat="server" />
            </p>
        </div>
    </header>

    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">
        <div class="mb-4">
            <asp:HyperLink ID="btnBackToCourses" runat="server" 
                NavigateUrl="~/Student/StudentCourse/StudentCourse.aspx" 
                CssClass="inline-flex items-center text-indigo-600 hover:text-indigo-800 font-medium">
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
                Back to My Courses
            </asp:HyperLink>
        </div>

        <div class="flex flex-col lg:flex-row lg:flex-nowrap gap-8">
            <div class="flex-1 min-w-0">

                <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
                    <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 text-center">
                        <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Attendance</p>
                        <p class="text-2xl font-bold text-[#0095FD]"><asp:Label ID="lblAttRate" runat="server" Text="0%" /></p>
                    </div>
                    <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 text-center">
                        <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Present</p>
                        <p class="text-2xl font-bold text-green-600"><asp:Label ID="lblPresent" runat="server" Text="0" /></p>
                    </div>
                    <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 text-center">
                        <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Late / Absent</p>
                        <p class="text-2xl font-bold text-yellow-600"><asp:Label ID="lblLate" runat="server" Text="0" /> / <asp:Label ID="lblAbsent" runat="server" Text="0" /></p>
                    </div>
                    <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 text-center">
                        <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Current Grade</p>
                        <p class="text-2xl font-bold text-indigo-600"><asp:Label ID="lblCurrentGrade" runat="server" Text="—" /></p>
                    </div>
                </div>

                <div class="border-b border-gray-200 mb-4">
                    <ul class="flex flex-wrap -mb-px text-sm font-medium text-center" id="tabHeaders">
                        <li class="mr-2">
                            <a href="#tab-materials" class="inline-block p-3 border-b-2 border-indigo-600 rounded-t-lg text-indigo-600 active-tab" onclick="switchTab(event, 'tab-materials')">Materials</a>
                        </li>
                        <li class="mr-2">
                            <a href="#tab-attendance" class="inline-block p-3 border-b-2 border-transparent rounded-t-lg hover:text-gray-600 hover:border-gray-300 text-gray-500" onclick="switchTab(event, 'tab-attendance')">Attendance</a>
                        </li>
                        <li class="mr-2">
                            <a href="#tab-results" class="inline-block p-3 border-b-2 border-transparent rounded-t-lg hover:text-gray-600 hover:border-gray-300 text-gray-500" onclick="switchTab(event, 'tab-results')">Results</a>
                        </li>
                    </ul>
                </div>

                <div id="tab-materials" class="tab-content">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                        <div class="p-4 border-b border-gray-200">
                            <div class="flex flex-wrap gap-4 items-center justify-between">
                                <div class="relative flex-1 max-w-md">
                                    <input type="text" id="searchMaterial" placeholder="Search course materials..." class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" onkeyup="filterMaterials()" />
                                    <svg class="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                    </svg>
                                </div>
                                <div class="flex gap-2">
                                    <button type="button" data-filter="all" class="filter-btn active px-4 py-2 text-sm font-medium rounded-lg bg-indigo-600 text-white">All</button>
                                    <button type="button" data-filter="Lecturers" class="filter-btn px-4 py-2 text-sm font-medium rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200">Lecturers</button>
                                    <button type="button" data-filter="Assignments" class="filter-btn px-4 py-2 text-sm font-medium rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200">Assignments</button>
                                    <button type="button" data-filter="Tutorials" class="filter-btn px-4 py-2 text-sm font-medium rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200">Tutorials</button>
                                </div>
                            </div>
                        </div>

                        <div class="overflow-x-auto">
                            <asp:Repeater ID="rptMaterials" runat="server">
                                <HeaderTemplate>
                                    <table class="min-w-full divide-y divide-gray-200">
                                        <thead class="bg-gray-50">
                                            <tr>
                                                <th class="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider">Material Title</th>
                                                <th class="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider">Type</th>
                                                <th class="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider">Description</th>
                                                <th class="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider">File Name</th>
                                                <th class="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider">Upload Date</th>
                                                <th class="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody class="bg-white divide-y divide-gray-200 material-list">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr class="material-row" data-type='<%# Eval("MaterialCategory") %>'>
                                        <td class="px-8 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%# Eval("MaterialTitle") %></td>
                                        <td class="px-8 py-4 whitespace-nowrap text-sm">
                                            <span class="px-2 py-1 text-xs font-semibold rounded-full <%# GetCategoryBadgeClass(Eval("MaterialCategory").ToString()) %>">
                                                <%# Eval("MaterialCategory") %>
                                            </span>
                                        </td>
                                        <td class="px-8 py-4 text-sm text-gray-600 max-w-xs">
                                            <span class="description-text" style="display: inline-block; max-height: 4.5em; overflow: hidden; transition: max-height 0.2s ease;">
                                                <%# Eval("Description") %>
                                            </span>
                                            <asp:PlaceHolder ID="phReadMore" runat="server" Visible='<%# IsDescriptionLong(Eval("Description")) %>'>
                                                <a href="javascript:void(0)" class="text-indigo-600 text-xs font-medium read-more-link">Read more</a>
                                            </asp:PlaceHolder>
                                        </td>
                                        <td class="px-8 py-4 whitespace-nowrap text-sm text-gray-500">
                                            <%# GetFileName(Eval("FileURL").ToString()) %>
                                        </td>
                                        <td class="px-8 py-4 whitespace-nowrap text-sm text-gray-600"><%# Convert.ToDateTime(Eval("UploadDate")).ToString("MMM dd, yyyy") %></td>
                                        <td class="px-8 py-4 whitespace-nowrap text-sm text-center space-x-4">
                                            <asp:PlaceHolder ID="phView" runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("FileURL")?.ToString()) %>'>
                                                <a href='<%# ResolveUrl(Eval("FileURL").ToString()) %>' target="_blank" class="text-gray-600 hover:text-green-600 transition-colors duration-200 inline-flex items-center gap-1" title="View">
                                                    <i class="fa-solid fa-eye"></i>
                                                    <span class="text-xs font-medium">View</span>
                                                </a>
                                            </asp:PlaceHolder>
                                            <asp:PlaceHolder ID="phDownload" runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("FileURL")?.ToString()) %>'>
                                                <a href='<%# ResolveUrl(Eval("FileURL").ToString()) %>' download class="text-gray-600 hover:text-indigo-600 transition-colors duration-200 inline-flex items-center gap-1" title="Download">
                                                    <i class="fa-solid fa-download"></i>
                                                    <span class="text-xs font-medium">Download</span>
                                                </a>
                                            </asp:PlaceHolder>
                                            <asp:PlaceHolder ID="phNoFile" runat="server" Visible='<%# string.IsNullOrEmpty(Eval("FileURL")?.ToString()) %>'>
                                                <span class="text-xs text-gray-400">No file</span>
                                            </asp:PlaceHolder>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                            <asp:Label ID="lblNoMaterials" runat="server" CssClass="block text-center py-8 text-gray-500" Visible="false" Text="No materials found for this course." />
                        </div>
                    </div>
                </div>

                <div id="tab-attendance" class="tab-content hidden">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                        <div class="p-6 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-semibold text-gray-900 mb-1">Attendance Overview</h3>
                            <asp:Label ID="lblAttSummary" runat="server" CssClass="text-sm text-gray-500 font-medium" />
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" 
                                AlternatingRowStyle-CssClass="bg-gray-50"
                                GridLines="None" EmptyDataText="No attendance records for this course."
                                EmptyDataRowStyle-CssClass="block text-center py-8 text-gray-500 text-sm"
                                OnRowDataBound="gvAttendance_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="AttendanceDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm font-medium text-gray-900" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="AttendanceStatus" HeaderText="Status">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center" />
                                    </asp:BoundField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

                <div id="tab-results" class="tab-content hidden">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                        <div class="p-6 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-semibold text-gray-900">Academic Results</h3>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" 
                                AlternatingRowStyle-CssClass="bg-gray-50"
                                GridLines="None" EmptyDataText="No assessment results for this course."
                                EmptyDataRowStyle-CssClass="block text-center py-8 text-gray-500 text-sm">
                                <Columns>
                                    <asp:BoundField DataField="AssessmentName" HeaderText="Assessment">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm font-medium text-gray-900" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="MaxMarks" HeaderText="Max Marks" DataFormatString="{0:F2}">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-gray-600 text-center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="ObtainedMark" HeaderText="Obtained" DataFormatString="{0:F2}">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-gray-600 text-center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="Weightage" HeaderText="Weightage" DataFormatString="{0:F2}">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-gray-600 text-center" />
                                    </asp:BoundField>
                                    <asp:TemplateField HeaderText="Weighted Score">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemTemplate>
                                            <%# (((decimal)Eval("ObtainedMark") / (decimal)Eval("MaxMarks")) * (decimal)Eval("Weightage")).ToString("F2") %>
                                        </ItemTemplate>
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center font-semibold text-indigo-600" />
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                        <div class="bg-gray-50 px-8 py-4 text-right text-sm font-semibold border-t border-gray-200 text-gray-700">
                            Total: <span class="text-gray-900 mr-4"><asp:Label ID="lblTotalPercentage" runat="server" /></span>
                            Grade: <span class="text-indigo-600"><asp:Label ID="lblGrade" runat="server" /></span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="w-full lg:w-80 flex-shrink-0">
                <div class="bg-white rounded-xl border border-gray-200 overflow-hidden sticky top-4">
                    <div class="p-4 border-b border-gray-200 flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-gray-900">Course Notifications</h3>
                        <button id="markAllRead" class="text-sm text-indigo-600 hover:text-indigo-800">Mark all</button>
                    </div>
                    <div class="divide-y divide-gray-100" id="notificationsList">
                        <asp:Repeater ID="rptNotifications" runat="server">
                            <ItemTemplate>
                                <div class="px-4 py-3 hover:bg-gray-50 transition border-b border-gray-100 last:border-b-0 cursor-pointer" 
                                     style='<%# ((bool)Eval("IsRead") ? "background-color: #f3f4f6;" : "") %>'
                                     onclick="location.href='../StudentCourseNotification/StudentCourseNotification.aspx?id=<%# Eval("AnnouncementID") %>&courseOfferId=<%# Request.QueryString["courseOfferId"] %>';">
                                    <div class="flex justify-between items-start gap-2">
                                        <div class="flex items-center gap-2">
                                            <span class='<%# ((bool)Eval("IsRead") ? "hidden" : "inline-block w-2 h-2 bg-red-500 rounded-full") %>'></span>
                                            <p class='<%# ((bool)Eval("IsRead") ? "text-sm font-medium text-gray-700" : "text-sm font-semibold text-gray-900") %>'>
                                                <%# Eval("Title") %>
                                            </p>
                                        </div>
                                        <p class="text-xs text-gray-400 whitespace-nowrap">
                                            <%# ((DateTime)Eval("CreatedDate")).ToString("MMM dd") %>
                                        </p>
                                    </div>
                                    <p class="text-xs text-gray-400 mt-1 ml-4">
                                        <%# GetTimeAgo((DateTime)Eval("CreatedDate")) %>
                                    </p>
                                    <div class="mt-2 flex items-center gap-3 ml-4">
                                        <asp:LinkButton ID="btnMarkUnread" runat="server" 
                                            CommandArgument='<%# Eval("AnnouncementID") %>'
                                            OnClick="MarkNotificationAsUnread_Click"
                                            CssClass="text-xs text-gray-500 hover:text-red-600"
                                            Visible='<%# (bool)Eval("IsRead") %>'
                                            OnClientClick="event.stopPropagation();">
                                            Mark as unread
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Label ID="lblNoNotifications" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="No recent notifications." />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        // Tab switching
        function switchTab(e, tabId) {
            e.preventDefault();
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
            // Show selected
            document.getElementById(tabId).classList.remove('hidden');
            // Update tab header styles
            document.querySelectorAll('#tabHeaders a').forEach(a => {
                a.classList.remove('border-indigo-600', 'text-indigo-600', 'active-tab');
                a.classList.add('border-transparent', 'text-gray-500');
            });
            document.querySelector(`#tabHeaders a[href="#${tabId}"]`).classList.add('border-indigo-600', 'text-indigo-600', 'active-tab');
            // Refresh filters/search if materials tab
            if (tabId === 'tab-materials') {
                filterMaterials();
            }
        }

        // Expandable description
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.read-more-link').forEach(link => {
                link.addEventListener('click', function (e) {
                    e.preventDefault();
                    const container = this.closest('td').querySelector('.description-text');
                    if (!container) return;
                    const isExpanded = container.style.maxHeight !== '4.5em';
                    container.style.maxHeight = isExpanded ? '4.5em' : 'none';
                    this.textContent = isExpanded ? 'Read more' : 'Show less';
                });
            });
        });

        // Search and filter for materials
        function filterMaterials() {
            const searchTerm = document.getElementById('searchMaterial').value.toLowerCase();
            const activeFilter = document.querySelector('.filter-btn.active')?.getAttribute('data-filter') || 'all';
            const rows = document.querySelectorAll('.material-row');
            rows.forEach(row => {
                const title = row.cells[0].innerText.toLowerCase();
                const type = row.getAttribute('data-type');
                let matchesSearch = title.includes(searchTerm);
                let matchesFilter = (activeFilter === 'all') || (type === activeFilter);

                row.style.display = (matchesSearch && matchesFilter) ? '' : 'none';
            });
        }

        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                document.querySelectorAll('.filter-btn').forEach(b => {
                    b.classList.remove('active', 'bg-indigo-600', 'text-white');
                    b.classList.add('bg-gray-100', 'text-gray-700');
                });
                this.classList.add('active', 'bg-indigo-600', 'text-white');
                this.classList.remove('bg-gray-100', 'text-gray-700');
                filterMaterials();
            });
        });

        const markBtn = document.getElementById('markAllRead');
        if (markBtn) {
            markBtn.addEventListener('click', function () {
                alert('All notifications marked as read (demo).');
            });
        }
    </script>
</asp:Content>