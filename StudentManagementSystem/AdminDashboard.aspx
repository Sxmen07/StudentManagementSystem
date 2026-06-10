<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="StudentManagementSystem.AdminDashboard" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>
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
        <uc:Navbar runat="server" ID="AdminSidebar" />
            
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

                <a href="TrackStudentGrade.aspx" class="block group bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] hover:border-[#1A1A1A] transition-colors">
                    <div class="text-[#7C7B77] group-hover:text-[#1A1A1A] transition-colors text-xs font-bold uppercase tracking-wider mb-2">Performance Oversight</div>
                    <h3 class="text-lg font-semibold text-[#1A1A1A] mb-2">Track Student Standing &rarr;</h3>
                    <p class="text-[#5F5E5B] text-xs leading-relaxed">Analyze student grade outcomes, trace risk parameters, and evaluate active alert thresholds.</p>
                </a>
                    
                <a href="AdminInbox.aspx" class="block group bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] hover:border-[#1A1A1A] transition-colors shadow-sm">
                        <div class="text-[#7C7B77] group-hover:text-[#1A1A1A] transition-colors text-xs font-bold uppercase tracking-wider mb-2"> System Communications</div>
                        <h3 class="text-lg font-semibold text-[#1A1A1A] mb-1 flex items-center gap-2">Support Ticket Inbox <span class="inline-block transition-transform group-hover:translate-x-1 duration-200">&rarr;</span>
                        </h3>
                        <p class="text-[#5F5F5B] text-xs leading-relaxed">
                            Review incoming help requests, account inquiries, and system messages dispatched by unregistered or locked-out users.
                        </p>
                    </a>
                
            </div>
        </div>

    </form>
</body>
</html>