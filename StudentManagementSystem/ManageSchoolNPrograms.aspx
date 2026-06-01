<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageSchoolNPrograms.aspx.cs" Inherits="StudentManagementSystem.ManageSchoolNPrograms" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Academic Structure</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
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
                    <a href="CreateAccounts.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-base shrink-0 w-4 text-center font-bold">⍡</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Create Accounts</span>
                    </a>
                    <a href="ManageSchoolNPrograms.aspx" class="flex items-center gap-4 bg-zinc-800 p-2 rounded-md font-semibold text-sm transition-colors text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-lg shrink-0 w-4 text-center font-normal">⎔</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Schools & Programs</span>
                    </a>
                    <a href="ManageCourses.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-base shrink-0 w-4 text-center font-bold">▤</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Manage Courses</span>
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

        <div class="flex-1 pl-20 pr-10 py-10 lg:pl-10 overflow-y-auto bg-white space-y-12 h-full">
            
            <div>
                <header class="mb-6 border-b border-[#F1F1EF] pb-4">
                    <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">School Structures</h2>
                    <p class="text-[#7C7B77] text-sm">Configure and update institutional faculties.</p>
                </header>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div class="bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] h-fit">
                        <h3 class="text-sm font-semibold mb-4 text-[#1A1A1A]">Manage Faculty</h3>
                        <asp:HiddenField ID="hfSchoolID" runat="server" />
                        <div class="space-y-4">
                            <div>
                                <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">School Name</label>
                                <asp:TextBox ID="txtSchoolName" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="e.g., School of Computing"></asp:TextBox>
                            </div>
                            <asp:Button ID="btnSaveSchool" runat="server" Text="Create School" CssClass="w-full bg-[#1A1A1A] text-white font-medium text-sm py-2.5 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm" OnClick="btnSaveSchool_Click" />
                            <asp:Button ID="btnCancelSchool" runat="server" Text="Cancel Edit" CssClass="w-full bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs py-2 rounded hover:bg-[#F4F4F2] transition-colors cursor-pointer" OnClick="btnCancelSchool_Click" Visible="false" />
                        </div>
                    </div>

                    <div class="lg:col-span-2 bg-white rounded-lg border border-[#EBEBE9] p-6">
                        <asp:GridView ID="gvSchools" runat="server" AutoGenerateColumns="False" DataKeyNames="SchoolID" OnRowCommand="gvSchools_RowCommand" CssClass="w-full text-left text-sm border-collapse" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="SchoolID" HeaderText="ID" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-[#7C7B77] w-16" />
                                <asp:BoundField DataField="SchoolName" HeaderText="School Name" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] font-medium text-[#1A1A1A]" />
                                <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-right space-x-3 w-32">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditSchool" CommandArgument='<%# Eval("SchoolID") %>' CssClass="text-[#5F5E5B] hover:text-[#1A1A1A] underline text-xs transition-colors">Edit</asp:LinkButton>
                                        <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteSchool" CommandArgument='<%# Eval("SchoolID") %>' OnClientClick="return confirm('Warning: Deleting this school will automatically clear out matching programmes and course maps. Continue?');" CssClass="text-red-600 hover:text-red-800 underline text-xs transition-colors">Delete</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <div>
                <header class="mb-6 border-b border-[#F1F1EF] pb-4 flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                    <div>
                        <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Academic Programmes</h2>
                        <p class="text-[#7C7B77] text-sm">Deploy and assign qualifications under active schools.</p>
                    </div>
                    
                    <div class="flex items-center gap-2 bg-[#F7F7F5] border border-[#EBEBE9] px-3 py-1.5 rounded-md h-fit">
                        <span class="text-xs font-bold text-[#7C7B77] uppercase tracking-wider">Filter By Faculty:</span>
                        <asp:DropDownList ID="ddlFilterSchool" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFilterSchool_SelectedIndexChanged" CssClass="bg-transparent text-sm font-medium text-[#2F2F2F] outline-none cursor-pointer"></asp:DropDownList>
                    </div>
                </header>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div class="bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] h-fit">
                        <h3 class="text-sm font-semibold mb-4 text-[#1A1A1A]">Manage Programme</h3>
                        <asp:HiddenField ID="hfProgrammeID" runat="server" />
                        <div class="space-y-4">
                            <div>
                                <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Programme Title</label>
                                <asp:TextBox ID="txtProgrammeName" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="e.g., Diploma in IT"></asp:TextBox>
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Hosting Faculty / School</label>
                                <asp:DropDownList ID="ddlSchools" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors cursor-pointer"></asp:DropDownList>
                            </div>
                            <asp:Button ID="btnSaveProg" runat="server" Text="Create Programme" CssClass="w-full bg-[#1A1A1A] text-white font-medium text-sm py-2.5 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm" OnClick="btnSaveProg_Click" />
                            <asp:Button ID="btnCancelProg" runat="server" Text="Cancel Edit" CssClass="w-full bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs py-2 rounded hover:bg-[#F4F4F2] transition-colors cursor-pointer" OnClick="btnCancelProg_Click" Visible="false" />
                        </div>
                    </div>

                    <div class="lg:col-span-2 bg-white rounded-lg border border-[#EBEBE9] p-6">
                        <asp:GridView ID="gvProgrammes" runat="server" AutoGenerateColumns="False" DataKeyNames="ProgrammeID" OnRowCommand="gvProgrammes_RowCommand" CssClass="w-full text-left text-sm border-collapse" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="ProgrammeID" HeaderText="ID" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-[#7C7B77] w-16" />
                                <asp:BoundField DataField="ProgrammeName" HeaderText="Programme Title" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] font-medium text-[#1A1A1A]" />
                                <asp:BoundField DataField="SchoolName" HeaderText="Assigned School" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-[#5F5E5B]" />
                                <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-right w-44">
                                    <ItemTemplate>
                                        <div class="inline-flex gap-2 justify-end w-full">
                                            <asp:Button ID="btnEditProg" runat="server" CommandName="EditProg" CommandArgument='<%# Eval("ProgrammeID") %>' Text="Edit" CssClass="bg-zinc-100 hover:bg-zinc-200 text-zinc-800 text-xs font-medium px-2.5 py-1 rounded transition-colors cursor-pointer border border-zinc-200" />
                                            <asp:Button ID="btnDeleteProg" runat="server" CommandName="DeleteProg" CommandArgument='<%# Eval("ProgrammeID") %>' Text="Delete" OnClientClick="return confirm('Are you sure you want to permanently delete this academic programme? All assigned courses will be dropped from the curriculum.');" CssClass="bg-red-50 hover:bg-red-100 text-red-600 text-xs font-medium px-2.5 py-1 rounded transition-colors cursor-pointer border border-red-200" />
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

        </div>
    </form>
</body>
</html>