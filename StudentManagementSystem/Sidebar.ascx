<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Sidebar.ascx.cs" Inherits="StudentManagementSystem.Sidebar" %>

<div class="group fixed lg:relative left-0 top-0 h-full w-16 hover:w-64 bg-zinc-950 text-white flex flex-col justify-between border-r border-zinc-900 transition-all duration-300 ease-in-out z-50 p-4 overflow-hidden">
    <div>
        <h1 class="text-xl font-bold tracking-tighter text-white mb-8 h-8 flex items-center gap-4 whitespace-nowrap overflow-hidden pl-1">
            <span class="w-4 h-4 rounded-sm bg-white shrink-0 block"></span> 
            <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">UniTrack</span>
        </h1>
        
        <nav class="space-y-1.5">
            <a href="AdminDashboard.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <span class="text-lg shrink-0 w-4 text-center font-normal">⌂</span>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Dashboard Home</span>
            </a>
            <a href="CreateAccounts.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2" id="navCreate">
                <span class="text-base shrink-0 w-4 text-center font-bold">⍡</span>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Create Accounts</span>
            </a>
            <a href="ManageSchoolNPrograms.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <span class="text-lg shrink-0 w-4 text-center font-normal">⎔</span>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Schools & Programs</span>
            </a>
            <a href="ManageCourses.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <span class="text-base shrink-0 w-4 text-center font-bold">▤</span>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Manage Courses</span>
            </a>

            <a href="AdminInbox.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <span class="text-base shrink-0 w-4 text-center font-bold">✉</span>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Support Inbox</span>
            </a>

            <a href="ManageAnnouncements.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <span class="text-base shrink-0 w-4 text-center font-bold">📢</span>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Announcements</span>
            </a>

            <a href="UserProfile.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                <span class="text-base shrink-0 w-4 text-center font-bold">👤</span>
                <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">User Profile</span>
            </a>
        </nav>
    </div>
    
    <div class="w-full h-9 overflow-hidden relative flex items-center justify-start pl-2">
        <span class="text-red-500 font-bold text-lg absolute left-3 pointer-events-none group-hover:opacity-0 transition-opacity duration-200">⏻</span>
        <div class="w-full opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            <asp:Button ID="btnLogout" runat="server" Text="Log Out" 
                CssClass="w-full bg-red-950/40 border border-red-900/30 hover:bg-red-900/60 text-red-400 font-medium text-xs py-2 rounded transition-colors cursor-pointer text-center block" 
                OnClick="btnLogout_Click" UseSubmitBehavior="false" />
        </div>
    </div>
</div>