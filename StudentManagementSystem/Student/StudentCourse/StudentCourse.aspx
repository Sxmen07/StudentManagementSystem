<%@ Page Title="Student Course" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourse.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourse" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Font Awesome (if not already in master) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style type="text/css">
        /* Card hover effect */
        .course-card {
            transition: all 0.25s ease-in-out;
        }
        .course-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.10);
        }
        .course-card:hover .card-arrow {
            transform: translateX(4px);
            color: #0095FD;
        }
        .card-arrow {
            transition: all 0.2s ease-in-out;
        }
        /* Active tab */
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
        .stat-card {
            transition: all 0.25s ease-in-out;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
        }
    </style>

    <!-- ============================================================ -->
    <!-- GRADIENT HEADER                                               -->
    <!-- ============================================================ -->
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">My Courses</h1>
            <p class="text-sm mt-1">View and access your course materials.</p>
        </div>
    </header>

    <!-- ============================================================ -->
    <!-- MAIN CONTENT                                                  -->
    <!-- ============================================================ -->
    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">

        <!-- ============================================================ -->
        <!-- 3x SUMMARY STATS CARDS                                       -->
        <!-- ============================================================ -->
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            
            <!-- Card 1: Total Enrolled -->
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#111827] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-book"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Enrolled</p>
                    <p class="text-2xl font-bold text-[#111827]">
                        <asp:Label ID="lblTotalCourses" runat="server" Text="0" />
                    </p>
                </div>
            </div>

            <!-- Card 2: Current Courses -->
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#0095FD] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-play-circle"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Current Courses</p>
                    <p class="text-2xl font-bold text-[#0095FD]">
                        <asp:Label ID="lblCurrentCount" runat="server" Text="0" />
                    </p>
                </div>
            </div>

            <!-- Card 3: Completed Courses -->
            <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#00CBD4] flex items-center justify-center text-white text-lg flex-shrink-0">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Completed</p>
                    <p class="text-2xl font-bold text-[#00CBD4]">
                        <asp:Label ID="lblCompletedCount" runat="server" Text="0" />
                    </p>
                </div>
            </div>
        </div>

        <!-- ============================================================ -->
        <!-- TAB NAVIGATION                                                -->
        <!-- ============================================================ -->
        <div class="flex gap-8 border-b border-[#EBEBE9] pb-3 mb-6">
            <asp:LinkButton ID="btnCurrent" runat="server" Text="Current Courses" 
                CssClass="text-base font-semibold transition duration-200 tab-active" 
                OnClick="btnCurrent_Click" />
            <asp:LinkButton ID="btnCompleted" runat="server" Text="Completed" 
                CssClass="text-base font-semibold transition duration-200 tab-inactive" 
                OnClick="btnCompleted_Click" />
        </div>

        <!-- ============================================================ -->
        <!-- CURRENT COURSES PANEL                                         -->
        <!-- ============================================================ -->
        <asp:Panel ID="pnlCurrent" runat="server" CssClass="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            <asp:Repeater ID="rptCurrentCourses" runat="server">
                <ItemTemplate>
                    <a href='<%# ResolveUrl("~/Student/StudentCourseMaterial/StudentCourseMaterial.aspx?courseOfferId=" + Eval("CourseOfferID")) %>'
                       class="course-card bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm flex flex-col h-full">
                        <div class="p-5 flex-1">
                            <div class="flex items-start justify-between">
                                <div>
                                    <h4 class="text-base font-bold text-gray-900"><%# Eval("CourseCode") %></h4>
                                    <p class="text-sm text-gray-700 mt-0.5"><%# Eval("CourseName") %></p>
                                </div>
                                <span class="text-xs font-medium text-green-600 bg-green-50 px-2.5 py-1 rounded-full flex-shrink-0 ml-2">
                                    <i class="fas fa-circle text-[6px] align-middle mr-1"></i> Active
                                </span>
                            </div>
                            <div class="mt-3 flex items-center text-xs text-gray-500 gap-4">
                                <span><i class="fas fa-user mr-1.5 text-gray-400"></i><%# Eval("Instructor") %></span>
                                <span><i class="fas fa-credit-card mr-1.5 text-gray-400"></i><%# Eval("CreditHours") %> Credits</span>
                            </div>
                            <p class="text-sm text-gray-600 mt-3 line-clamp-2"><%# Eval("Description") %></p>
                        </div>
                        <div class="px-5 py-3 border-t border-gray-100 bg-gray-50 flex justify-end">
                            <span class="text-sm font-medium text-[#0095FD] flex items-center gap-1 card-arrow">
                                View Materials <i class="fas fa-arrow-right text-xs"></i>
                            </span>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoCurrent" runat="server" CssClass="text-gray-500 italic col-span-full text-center py-12" Visible="false" Text="You are not enrolled in any current courses." />
        </asp:Panel>

        <!-- ============================================================ -->
        <!-- COMPLETED COURSES PANEL                                       -->
        <!-- ============================================================ -->
        <asp:Panel ID="pnlCompleted" runat="server" Visible="false" CssClass="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            <asp:Repeater ID="rptCompletedCourses" runat="server">
                <ItemTemplate>
                    <a href='<%# ResolveUrl("~/Student/StudentCourseMaterial/StudentCourseMaterial.aspx?courseOfferId=" + Eval("CourseOfferID")) %>'
                       class="course-card bg-white border border-gray-200 rounded-xl overflow-hidden shadow-sm flex flex-col h-full">
                        <div class="p-5 flex-1">
                            <div class="flex items-start justify-between">
                                <div>
                                    <h4 class="text-base font-bold text-gray-900"><%# Eval("CourseCode") %></h4>
                                    <p class="text-sm text-gray-700 mt-0.5"><%# Eval("CourseName") %></p>
                                </div>
                                <span class="text-xs font-medium text-gray-500 bg-gray-100 px-2.5 py-1 rounded-full flex-shrink-0 ml-2">
                                    <i class="fas fa-check text-[10px] mr-1"></i> Done
                                </span>
                            </div>
                            <div class="mt-3 flex items-center text-xs text-gray-500 gap-4">
                                <span><i class="fas fa-user mr-1.5 text-gray-400"></i><%# Eval("Instructor") %></span>
                                <span><i class="fas fa-credit-card mr-1.5 text-gray-400"></i><%# Eval("CreditHours") %> Credits</span>
                            </div>
                            <p class="text-sm text-gray-600 mt-3 line-clamp-2"><%# Eval("Description") %></p>
                        </div>
                        <div class="px-5 py-3 border-t border-gray-100 bg-gray-50 flex justify-end">
                            <span class="text-sm font-medium text-gray-500 flex items-center gap-1 card-arrow">
                                View Materials <i class="fas fa-arrow-right text-xs"></i>
                            </span>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoCompleted" runat="server" CssClass="text-gray-500 italic col-span-full text-center py-12" Visible="false" Text="No completed courses yet." />
        </asp:Panel>
    </div>

</asp:Content>