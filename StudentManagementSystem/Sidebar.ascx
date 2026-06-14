<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Sidebar.ascx.cs" Inherits="StudentManagementSystem.Sidebar" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

<div class="group fixed lg:relative left-0 top-0 h-full w-16 hover:w-64 bg-gradient-to-b from-[#0095FD]/80 to-[#FF6B35]/60 backdrop-blur-xl text-white flex flex-col justify-between border-r border-white/10 transition-all duration-300 ease-in-out z-50 p-4 overflow-hidden shadow-[5px_0_25px_rgba(0,0,0,0.2)]">
    <div>

        <h1 class="text-xl font-bold tracking-tighter text-white mb-8 h-8 flex items-center gap-4 whitespace-nowrap overflow-hidden pl-1">
            <i class="fa-solid fa-graduation-cap text-white shrink-0 text-xl w-5 text-center drop-shadow-md"></i> 
            <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300 tracking-wide">UniTrack</span>
        </h1>
        
        <nav class="space-y-1.5">

            <a href="AdminDashboard.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-house text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Dashboard Home</span>
            </a>

            <a href="CreateAccounts.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2" id="navCreate">
                <i class="fa-solid fa-user-plus text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Create Accounts</span>
            </a>

            <a href="ManageSchoolNPrograms.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-school text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Schools & Programs</span>
            </a>

            <a href="ManageCourses.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-book-open text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Manage Courses</span>
            </a>

            <a href="AssignCourses2Lec.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-chalkboard-user text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Assign Courses</span>
            </a>
            
            <a href="TrackStudentGrade.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-chart-simple text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Grade Tracker</span>
            </a>

            <a href="ManageAnnouncements.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-bullhorn text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Announcements</span>
            </a>

            <a href="AdminInbox.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-envelope text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Support Inbox</span>
            </a>

            <a href="UserProfile.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-circle-user text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">User Profile</span>
            </a>

            <a href="ManageCalendar.aspx" class="flex items-center gap-4 hover:bg-white/15 p-2 rounded-md font-medium text-sm transition-colors text-white/90 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <i class="fa-solid fa-circle-user text-base shrink-0 w-5 text-center"></i>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Academic Calendar</span>
            </a>

        </nav>
    </div>
    
    <div class="w-full h-9 overflow-hidden relative flex items-center justify-start pl-2">
        <i class="fa-solid fa-power-off text-white/80 text-base absolute left-3 pointer-events-none group-hover:opacity-0 transition-opacity duration-200"></i>
        <div class="w-full opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            <asp:Button ID="btnLogout" runat="server" Text="Log Out" 
                CssClass="w-full bg-white/10 border border-white/10 hover:bg-white/20 text-white font-semibold text-xs py-2 rounded transition-all cursor-pointer text-center block" 
                OnClick="btnLogout_Click" UseSubmitBehavior="false" />
        </div>
    </div>

</div>