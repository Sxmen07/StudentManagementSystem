<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TrackStudentGrades.aspx.cs" Inherits="StudentManagementSystem.TrackStudentGrades" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full overflow-hidden">
<head runat="server">
    <title>UniTrack | Academic Performance Tracker</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        .grid-pager table { margin: 0 auto; }
        .grid-pager td { padding: 0 6px; }
        .grid-pager a { color: #7C7B77; font-size: 11px; text-decoration: none; font-weight: 500; }
        .grid-pager a:hover { color: #1A1A1A; text-decoration: underline; }
        .grid-pager span { color: #1A1A1A; font-size: 11px; font-weight: 700; border-bottom: 2px solid #1A1A1A; padding-bottom: 2px; }
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
                    <a href="AdminDashboard.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
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
                    <a href="TrackStudentGrades.aspx" class="flex items-center gap-4 bg-zinc-800 p-2 rounded-md font-semibold text-sm transition-colors text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-base shrink-0 w-4 text-center font-bold">⍠</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Grade Tracker</span>
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

        <div class="flex-1 pl-20 pr-10 py-8 lg:pl-24 bg-white space-y-6 flex flex-col h-screen overflow-y-auto">
            <header class="border-b border-[#F1F1EF] pb-4 shrink-0 flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                <div>
                    <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Student Performance & Standing Tracker</h2>
                    <p class="text-[#7C7B77] text-sm">Monitor student grade averages, analyze risk thresholds, and manage scholastic status categories.</p>
                </div>
                
                <div class="flex flex-wrap items-center gap-3 bg-[#F7F7F5] border border-[#EBEBE9] p-2 rounded-lg h-fit">
                    <div class="flex items-center gap-1">
                        <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Status:</span>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged" CssClass="bg-white border border-[#EBEBE9] p-1 text-xs rounded font-medium outline-none cursor-pointer">
                            <asp:ListItem Value="All">All Standings</asp:ListItem>
                            <asp:ListItem Value="Normal">Normal Only</asp:ListItem>
                            <asp:ListItem Value="In Risk">In Risk Only</asp:ListItem>
                            <asp:ListItem Value="Warning">Warning Only</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="flex items-center gap-1">
                        <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Sort By:</span>
                        <asp:DropDownList ID="ddlSortExpression" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSortExpression_SelectedIndexChanged" CssClass="bg-white border border-[#EBEBE9] p-1 text-xs rounded font-medium outline-none cursor-pointer">
                            <asp:ListItem Value="StudentName ASC">Name (A-Z)</asp:ListItem>
                            <asp:ListItem Value="StudentName DESC">Name (Z-A)</asp:ListItem>
                            <asp:ListItem Value="EstimatedCGPA DESC">CGPA (Highest)</asp:ListItem>
                            <asp:ListItem Value="EstimatedCGPA ASC">CGPA (Lowest)</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </header>

            <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium" Visible="false"></asp:Label>

            <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-5 shadow-sm flex-1 overflow-visible">
                <div class="bg-white rounded-lg border border-[#EBEBE9] p-4">
                    <asp:GridView ID="gvStudentGrades" runat="server" AutoGenerateColumns="False" 
                        AllowPaging="True" PageSize="6" PagerStyle-CssClass="grid-pager" PagerSettings-Mode="NumericFirstLast"
                        OnPageIndexChanging="gvStudentGrades_PageIndexChanging" OnRowDataBound="gvStudentGrades_RowDataBound"
                        CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                        
                        <Columns>
                            <asp:BoundField DataField="StudentID" HeaderText="Student ID" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-zinc-400 w-24 text-center" HeaderStyle-CssClass="text-center pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" />                            <asp:BoundField DataField="StudentName" HeaderText="Student Name" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] font-semibold text-[#1A1A1A]" />
                            <asp:BoundField DataField="StudentEmail" HeaderText="Institutional Email" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-[#5F5E5B]" />
                            <asp:BoundField DataField="ProgrammeCode" HeaderText="Prog" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] font-bold text-zinc-500 text-center w-20" HeaderStyle-CssClass="text-center pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" />                            
                            <%-- CGPA Column --%>
                            <asp:TemplateField HeaderText="Estimated CGPA" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-center" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-center font-bold text-[#1A1A1A] w-28">
                                <ItemTemplate>
                                    <%# Eval("EstimatedCGPA", "{0:F2}") %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Status Badge Column with Container for Color Injections --%>
                            <asp:TemplateField HeaderText="Scholastic Standing" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-center" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-center w-36">
                                <ItemTemplate>
                                    <asp:Label ID="lblStandingBadge" runat="server" Text='<%# Eval("StandingStatus") %>' 
                                        CssClass="inline-block px-3 py-1 rounded-full text-[10px] font-bold tracking-wide uppercase shadow-sm"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>

                        <EmptyDataTemplate>
                            <div class="text-center py-12 px-4">
                                <span class="text-3xl text-zinc-300 block mb-2">⍠</span>
                                <p class="text-sm font-semibold text-[#1A1A1A]">No student profile matching the current criteria was found.</p>
                                <p class="text-xs text-[#7C7B77] mt-0.5">Confirm student database synchronization states exist inside your tables.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

    </form>
</body>
</html>