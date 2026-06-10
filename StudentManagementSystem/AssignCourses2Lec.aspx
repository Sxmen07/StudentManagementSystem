<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AssignCourses2Lec.aspx.cs" Inherits="StudentManagementSystem.AssignCourses2Lec" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full overflow-hidden">
<head runat="server">
    <title>UniTrack | Faculty Assignments</title>
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
    <form id="form1" runat="server" class="h-full flex relative" onkeydown="if(event.keyCode==13) { return false; }">
        
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
                    <a href="AssignCourses2Lec.aspx" class="flex items-center gap-4 bg-zinc-800 p-2 rounded-md font-semibold text-sm transition-colors text-white whitespace-nowrap overflow-hidden pl-2">
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

        <div class="flex-1 pl-20 pr-10 py-8 lg:pl-24 bg-white space-y-6 flex flex-col h-screen overflow-y-auto">
            <header class="border-b border-[#F1F1EF] pb-4 shrink-0">
                <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Faculty Course Assignation</h2>
                <p class="text-[#7C7B77] text-sm">Allocate active curriculum courses to registered lecturers, set semester terms, and track status rows.</p>
            </header>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 shrink-0">
                
                <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-5 shadow-sm grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div class="sm:col-span-3">
                        <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-[#EBEBE9] pb-2">Assign Teaching Duty</h3>
                    </div>
                    
                    <asp:Label ID="lblStatus" runat="server" CssClass="sm:col-span-3 block text-xs font-medium" Visible="false"></asp:Label>
                    <asp:HiddenField ID="hfCourseOfferID" runat="server" />

                    <div class="sm:col-span-3 grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Select Lecturer</label>
                            <asp:DropDownList ID="ddlLecturers" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] outline-none text-[#2F2F2F] font-medium cursor-pointer"></asp:DropDownList>
                        </div>
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Select Course Module</label>
                            <asp:DropDownList ID="ddlCourses" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] outline-none text-[#2F2F2F] font-medium cursor-pointer"></asp:DropDownList>
                        </div>
                    </div>

                    <div class="sm:col-span-3 grid grid-cols-1 sm:grid-cols-3 gap-3">
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Semester Term</label>
                            <asp:DropDownList ID="ddlSemesters" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] outline-none text-[#2F2F2F] font-medium cursor-pointer"></asp:DropDownList>
                        </div>
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Academic Year</label>
                            <asp:TextBox ID="txtYear" runat="server" TextMode="Number" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="e.g., 2026"></asp:TextBox>
                        </div>
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Offer Availability Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] outline-none text-[#2F2F2F] font-medium cursor-pointer">
                                <asp:ListItem Value="Available">Available</asp:ListItem>
                                <asp:ListItem Value="Not Available">Not Available</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="sm:col-span-3 pt-2 flex gap-2">
                        <asp:Button ID="btnSaveAssignment" runat="server" Text="Confirm Assignment" OnClick="btnSaveAssignment_Click" CssClass="flex-1 bg-[#1A1A1A] text-white font-medium text-xs py-2 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm text-center" />
                        <asp:Button ID="btnCancelEdit" runat="server" Text="X" OnClick="btnCancelEdit_Click" Visible="false" CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs px-3 py-2 rounded hover:bg-[#F4F4F2] transition-colors cursor-pointer" />
                    </div>
                </div>

                <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-5 shadow-sm flex flex-col justify-between">
                    <div>
                        <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-[#EBEBE9] pb-2 mb-3">Live System Metrics</h3>
                        <p class="text-xs text-zinc-500 mb-4">Quick operational summary of curriculum distributions currently mapped inside the database registers.</p>
                    </div>
                    <div class="grid grid-cols-3 gap-3 bg-white p-4 rounded-lg border border-[#EBEBE9] flex-1 items-center">
                        <div class="text-center border-r border-zinc-100">
                            <span class="block text-xl font-bold text-[#1A1A1A]"><asp:Literal ID="litTotalAllocations" runat="server" Text="0"></asp:Literal></span>
                            <span class="text-[9px] uppercase tracking-wider font-bold text-zinc-400">Total Offers</span>
                        </div>
                        <div class="text-center border-r border-zinc-100">
                            <span class="block text-xl font-bold text-emerald-600"><asp:Literal ID="litActiveOffers" runat="server" Text="0"></asp:Literal></span>
                            <span class="text-[9px] uppercase tracking-wider font-bold text-zinc-400">Available</span>
                        </div>
                        <div class="text-center">
                            <span class="block text-xl font-bold text-amber-600"><asp:Literal ID="litInactiveOffers" runat="server" Text="0"></asp:Literal></span>
                            <span class="text-[9px] uppercase tracking-wider font-bold text-zinc-400">Suspended</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-5 shadow-sm flex-1 flex flex-col justify-start h-fit">
                <div class="border-b border-[#EBEBE9] pb-3 mb-4 flex justify-between items-center">
                    <h3 class="text-sm font-bold text-[#1A1A1A] uppercase tracking-wider">Active Faculty Deployments</h3>
                    <div class="flex items-center gap-2 bg-white border border-[#EBEBE9] px-2 py-1 rounded-md">
                        <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Show Lecturer:</span>
                        <asp:DropDownList ID="ddlFilterLecturer" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFilterLecturer_SelectedIndexChanged" CssClass="bg-transparent text-xs font-semibold outline-none cursor-pointer"></asp:DropDownList>
                    </div>
                </div>

                <div class="bg-white rounded-lg border border-[#EBEBE9] p-5">
                    <asp:GridView ID="gvAssignments" runat="server" AutoGenerateColumns="False" DataKeyNames="CourseOfferID" 
                        OnRowCommand="gvAssignments_RowCommand" OnPageIndexChanging="gvAssignments_PageIndexChanging"
                        AllowPaging="True" PageSize="5" PagerStyle-CssClass="grid-pager" PagerSettings-Mode="NumericFirstLast"
                        CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                        
                        <Columns>
                            <asp:BoundField DataField="CourseOfferID" HeaderText="Offer ID" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] text-zinc-400 w-20 text-center" HeaderStyle-CssClass="text-center pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" />
                            <asp:BoundField DataField="LecturerName" HeaderText="Faculty Lecturer" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] font-semibold text-[#1A1A1A]" />
                            <asp:BoundField DataField="CourseDetails" HeaderText="Assigned Course Module" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] font-medium text-zinc-800" />
                            <asp:BoundField DataField="TermDetails" HeaderText="Academic Term Cycle" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] text-zinc-600 w-36" />
                            <asp:BoundField DataField="OfferStatus" HeaderText="Status" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] font-bold w-28" />
                            
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-right" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] text-right w-36">
                                <ItemTemplate>
                                    <div class="inline-flex gap-1.5 justify-end w-full">
                                        <asp:Button ID="btnEdit" runat="server" CommandName="EditAssignment" CommandArgument='<%# Eval("CourseOfferID") %>' Text="Edit" CssClass="bg-zinc-100 hover:bg-zinc-200 text-zinc-800 text-[10px] font-medium px-2.5 py-1 rounded border border-zinc-200 cursor-pointer" />
                                        <asp:Button ID="btnDelete" runat="server" CommandName="DeleteAssignment" CommandArgument='<%# Eval("CourseOfferID") %>' Text="Delete" OnClientClick="return confirm('Wiping this teaching assignment could drop connected student enrollment metrics. Proceed?');" CssClass="bg-red-50 hover:bg-red-100 text-red-600 text-[10px] font-medium px-2.5 py-1 rounded border border-red-200 cursor-pointer" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>

                        <EmptyDataTemplate>
                            <div class="text-center py-12 px-4">
                                <span class="text-3xl text-zinc-300 block mb-2">✓</span>
                                <p class="text-sm font-semibold text-[#1A1A1A]">No courses are assigned to any faculty yet.</p>
                                <p class="text-xs text-[#7C7B77] mt-0.5">Use the staging controls row above to map your first lecturer assignment rule block.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

        </div>
    </form>
</body>
</html>