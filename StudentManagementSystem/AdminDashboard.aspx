<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="StudentManagementSystem.AdminDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full overflow-hidden">
<head runat="server">
    <title>UniTrack | Admin Home</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <div class="group fixed left-0 top-0 h-screen w-16 hover:w-64 bg-zinc-950 text-white flex flex-col justify-between border-r border-zinc-900 transition-all duration-300 ease-in-out z-50 p-4 overflow-hidden shrink-0">
            <div>
                <h1 class="text-xl font-bold tracking-tighter text-white mb-8 h-8 flex items-center gap-4 whitespace-nowrap overflow-hidden pl-1">
                    <span class="w-4 h-4 rounded-sm bg-white shrink-0 block"></span> 
                    <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">UniTrack</span>
                </h1>
                
                <nav class="space-y-1.5">
                    <a href="AdminDashboard.aspx" class="flex items-center gap-4 bg-zinc-800 p-2 rounded-md font-semibold text-sm transition-colors text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-lg shrink-0 w-4 text-center font-normal">⌂</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Dashboard Home</span>
                    </a>
                    
                    <a href="CreateAccounts.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
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

                    <a href="AssignCourses2Lec.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-base shrink-0 w-4 text-center font-bold">✓</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Assign Courses</span>
                    </a>
                </nav>
            </div>
            
            <div class="w-full h-9 overflow-hidden relative flex items-center justify-start pl-2">
                <span class="text-red-500 font-bold text-lg absolute left-3 pointer-events-none group-hover:opacity-0 transition-opacity duration-200">⏻</span>
                <div class="w-full opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                    <asp:Button ID="btnLogout" runat="server" Text="Log Out" 
                        CssClass="w-full bg-red-950/40 border border-red-900/30 hover:bg-red-900/60 text-red-400 font-medium text-xs py-2 rounded transition-colors cursor-pointer text-center block" 
                        OnClick="btnLogout_Click" />
                </div>
            </div>
        </div>

        <div class="flex-1 pl-20 pr-10 py-10 lg:pl-24 overflow-y-auto bg-white h-full">
            <header class="mb-8 border-b border-[#F1F1EF] pb-5">
                <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Administrative Portal</h2>
                <p class="text-[#7C7B77] text-sm">Welcome back, Head of Programme. Select an operational subsystem module below.</p>
            </header>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                
                <a href="CreateAccounts.aspx" class="block group bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] hover:border-[#1A1A1A] transition-colors">
                    <div class="text-[#7C7B77] group-hover:text-[#1A1A1A] transition-colors text-xs font-bold uppercase tracking-wider mb-2">Access Control</div>
                    <h3 class="text-lg font-semibold text-[#1A1A1A] mb-2">Create Accounts &rarr;</h3>
                    <p class="text-[#5F5E5B] text-xs leading-relaxed">Register new institutional profiles and assign access tiers for students, lecturers, or system managers.</p>
                </a>

                <a href="ManageSchoolNPrograms.aspx" class="block group bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] hover:border-[#1A1A1A] transition-colors">
                    <div class="text-[#7C7B77] group-hover:text-[#1A1A1A] transition-colors text-xs font-bold uppercase tracking-wider mb-2">Structure Matrix</div>
                    <h3 class="text-lg font-semibold text-[#1A1A1A] mb-2">Schools & Programs &rarr;</h3>
                    <p class="text-[#5F5E5B] text-xs leading-relaxed">Configure structural organizational faculties, launch diploma qualification streams, and maintain core tracks.</p>
                </a>

                <a href="ManageCourses.aspx" class="block group bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] hover:border-[#1A1A1A] transition-colors">
                    <div class="text-[#7C7B77] group-hover:text-[#1A1A1A] transition-colors text-xs font-bold uppercase tracking-wider mb-2">Curriculum Setup</div>
                    <h3 class="text-lg font-semibold text-[#1A1A1A] mb-2">Manage Courses &rarr;</h3>
                    <p class="text-[#5F5E5B] text-xs leading-relaxed">Build core subject definitions, assign manual structural credit hour distributions, and link tracking maps.</p>
                </a>

                <a href="AssignCourses2Lec.aspx" class="block group bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] hover:border-[#1A1A1A] transition-colors">
                    <div class="text-[#7C7B77] group-hover:text-[#1A1A1A] transition-colors text-xs font-bold uppercase tracking-wider mb-2">Faculty Scheduling</div>
                    <h3 class="text-lg font-semibold text-[#1A1A1A] mb-2">Assign Courses to Lecturers &rarr;</h3>
                    <p class="text-[#5F5E5B] text-xs leading-relaxed">Allocate active curriculum courses to registered lecturers, set calendar terms, and track status indicators.</p>
                </a>

            </div>
        </div>

    </form>
</body>
</html>