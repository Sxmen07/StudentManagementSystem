<%@ Page Title="Course Material" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseMaterial.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseMaterial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">
                Course Materials
            </h1>
        </div>
    </header>

    <!-- Full width container, reduced left padding, removed centering -->
    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">
        <!-- Back button row -->
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

        <!-- Top Bar: Course Title + Instructor -->
        <div class="flex flex-wrap justify-between items-start sm:items-center gap-4 mb-6">
            <div>
                <h1 class="text-3xl font-bold text-gray-900"><asp:Label ID="lblCourseTitle" runat="server" /></h1>
                <p class="text-gray-600"><asp:Label ID="lblInstructor" runat="server" /></p>
            </div>
        </div>

        <!-- Two-column layout: Left = Materials, Right = Notifications -->
        <div class="flex flex-col lg:flex-row lg:flex-nowrap gap-8">
            <!-- Left column: Materials -->
            <div class="flex-1 min-w-0">
                <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                    <!-- Search and filter bar -->
                    <div class="p-4 border-b border-gray-200">
                        <div class="flex flex-wrap gap-4 items-center justify-between">
                            <div class="relative flex-1 max-w-md">
                                <input type="text" id="searchMaterial" placeholder="Search course materials..." class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500" onkeyup="filterMaterials()" />
                                <svg class="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" width="20" height="20">
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

                    <!-- Material table -->
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
                                        <span class="px-2 py-1 text-xs font-semibold rounded-full 
                                            <%# GetCategoryBadgeClass(Eval("MaterialCategory").ToString()) %>">
                                            <%# Eval("MaterialCategory") %>
                                        </span>
                                    </td>
                                    <td class="px-8 py-4 text-sm text-gray-600 max-w-xs truncate"><%# Eval("Description") %></td>
                                    <td class="px-8 py-4 whitespace-nowrap text-sm text-gray-500">
                                        <%# GetFileName(Eval("FileURL").ToString()) %>
                                    </td>
                                    <td class="px-8 py-4 whitespace-nowrap text-sm text-gray-600"><%# Convert.ToDateTime(Eval("UploadDate")).ToString("MMM dd, yyyy") %></td>
                                    <td class="px-8 py-4 whitespace-nowrap text-sm text-center space-x-4">
                                        <asp:PlaceHolder ID="phView" runat="server" 
                                            Visible='<%# !string.IsNullOrEmpty(Eval("FileURL")?.ToString()) %>'>
                                            <a href='<%# ResolveUrl(Eval("FileURL").ToString()) %>' target="_blank" 
                                               class="text-gray-600 hover:text-green-600 transition-colors duration-200 inline-flex items-center gap-1" title="View">
                                                <i class="fa-solid fa-eye"></i>
                                                <span class="text-xs font-medium">View</span>
                                            </a>
                                        </asp:PlaceHolder>
                                        
                                        <asp:PlaceHolder ID="phDownload" runat="server" 
                                            Visible='<%# !string.IsNullOrEmpty(Eval("FileURL")?.ToString()) %>'>
                                            <a href='<%# ResolveUrl(Eval("FileURL").ToString()) %>' download 
                                               class="text-gray-600 hover:text-indigo-600 transition-colors duration-200 inline-flex items-center gap-1" title="Download">
                                                <i class="fa-solid fa-download"></i>
                                                <span class="text-xs font-medium">Download</span>
                                            </a>
                                        </asp:PlaceHolder>
                                        
                                        <asp:PlaceHolder ID="phNoFile" runat="server" 
                                            Visible='<%# string.IsNullOrEmpty(Eval("FileURL")?.ToString()) %>'>
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

            <!-- Right column: Notifications -->
            <div class="w-full lg:w-80 flex-shrink-0">
                <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
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
        function filterMaterials() {
            const searchTerm = document.getElementById('searchMaterial').value.toLowerCase();
            const activeFilter = document.querySelector('.filter-btn.active').getAttribute('data-filter');
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
