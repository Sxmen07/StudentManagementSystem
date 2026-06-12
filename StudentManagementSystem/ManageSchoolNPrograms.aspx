<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageSchoolNPrograms.aspx.cs" Inherits="StudentManagementSystem.ManageSchoolNPrograms" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %> <!-- REGISTER SIDEBARR -->

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full overflow-hidden">
<head runat="server">
    <title>UniTrack | Academic Structure</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        /* Style rules to keep pagination numbers elegant and minimal */
        .grid-pager table { margin: 0 auto; }
        .grid-pager td { padding: 0 6px; }
        .grid-pager a { color: #7C7B77; font-size: 11px; text-decoration: none; font-weight: 500; }
        .grid-pager a:hover { color: #1A1A1A; text-decoration: underline; }
        .grid-pager span { color: #1A1A1A; font-size: 11px; font-weight: 700; border-bottom: 2px solid #1A1A1A; padding-bottom: 2px; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative" onkeydown="if(event.keyCode==13) { return false; }">
        
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 pl-20 pr-10 py-8 lg:pl-24 bg-white space-y-6 flex flex-col h-screen overflow-y-auto">
            <header class="border-b border-[#F1F1EF] pb-4 shrink-0">
                <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Curriculum & Structural Dashboard</h2>
                <p class="text-[#7C7B77] text-sm">Configure operational terms, academic management faculties, and complete graduation programs.</p>
            </header>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 shrink-0">
                
                <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-5 shadow-sm grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div class="sm:col-span-1 space-y-3">
                        <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-[#EBEBE9] pb-2">1. Semesters</h3>
                        <asp:Label ID="lblSemesterStatus" runat="server" CssClass="block text-[10px] font-medium" Visible="false"></asp:Label>
                        <asp:HiddenField ID="hfSemesterID" runat="server" />
                        
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Intake Block</label>
                            <asp:TextBox ID="txtSemesterTerm" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="e.g., Jan Term"></asp:TextBox>
                        </div>
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Start (MM-DD)</label>
                            <asp:TextBox ID="txtStartDay" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="01-01"></asp:TextBox>
                        </div>
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">End (MM-DD)</label>
                            <asp:TextBox ID="txtEndDay" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="03-31"></asp:TextBox>
                        </div>
                        <div class="pt-1 flex gap-1.5">
                            <asp:Button ID="btnSaveSemester" runat="server" Text="Save" OnClick="btnSaveSemester_Click" CssClass="flex-1 bg-[#1A1A1A] text-white font-medium text-xs py-2 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm" />
                            <asp:Button ID="btnCancelSemester" runat="server" Text="X" OnClick="btnCancelSemester_Click" Visible="false" CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs px-2.5 py-2 rounded hover:bg-[#F4F4F2] transition-colors cursor-pointer" />
                        </div>
                    </div>
                    
                    <div class="sm:col-span-2 bg-white rounded-lg border border-[#EBEBE9] p-3 max-h-[250px] overflow-y-auto">
                        <asp:GridView ID="gvSemesters" runat="server" AutoGenerateColumns="False" DataKeyNames="SemesterID" OnRowCommand="gvSemesters_RowCommand" CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="Semester" HeaderText="Term" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-2 border-b border-[#F1F1EF] font-semibold text-[#1A1A1A]" />
                                <asp:BoundField DataField="StartMonthDay" HeaderText="Start" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-2 border-b border-[#F1F1EF] text-[#5F5E5B]" />
                                <asp:BoundField DataField="EndMonthDay" HeaderText="End" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-2 border-b border-[#F1F1EF] text-[#5F5E5B]" />
                                <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-right" ItemStyle-CssClass="py-2 border-b border-[#F1F1EF] text-right w-24">
                                    <ItemTemplate>
                                        <div class="inline-flex gap-1">
                                            <asp:Button ID="btnEditSem" runat="server" CommandName="EditSemester" CommandArgument='<%# Eval("SemesterID") %>' Text="Edit" CssClass="bg-zinc-100 hover:bg-zinc-200 text-zinc-800 text-[10px] font-medium px-1.5 py-0.5 rounded border border-zinc-200 cursor-pointer" />
                                            <asp:Button ID="btnDeleteSem" runat="server" CommandName="DeleteSemester" CommandArgument='<%# Eval("SemesterID") %>' Text="Del" OnClientClick="return confirm('Delete term record?');" CssClass="bg-red-50 hover:bg-red-100 text-red-600 text-[10px] font-medium px-1.5 py-0.5 rounded border border-red-200 cursor-pointer" />
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-5 shadow-sm grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div class="sm:col-span-1 space-y-3">
                        <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-[#EBEBE9] pb-2">2. Faculties</h3>
                        <asp:Label ID="lblSchoolStatus" runat="server" CssClass="block text-[10px] font-medium" Visible="false"></asp:Label>
                        <asp:HiddenField ID="hfSchoolID" runat="server" />
                        
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Faculty Name</label>
                            <asp:TextBox ID="txtSchoolName" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="e.g., School of Computing"></asp:TextBox>
                        </div>
                        <div class="pt-1 flex gap-1.5">
                            <asp:Button ID="btnSaveSchool" runat="server" Text="Save Faculty" OnClick="btnSaveSchool_Click" CssClass="w-full bg-[#1A1A1A] text-white font-medium text-xs py-2 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm" />
                            <asp:Button ID="btnCancelSchool" runat="server" Text="X" OnClick="btnCancelSchool_Click" Visible="false" CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs px-2.5 py-2 rounded hover:bg-[#F4F4F2] transition-colors cursor-pointer" />
                        </div>
                    </div>
                    
                    <div class="sm:col-span-2 bg-white rounded-lg border border-[#EBEBE9] p-3 max-h-[250px] overflow-y-auto">
                        <asp:GridView ID="gvSchools" runat="server" AutoGenerateColumns="False" DataKeyNames="FacultyID" OnRowCommand="gvSchools_RowCommand" CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="FacultyName" HeaderText="Faculty Designation Title" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-2.5 border-b border-[#F1F1EF] font-medium text-[#1A1A1A]" />
                                <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-right" ItemStyle-CssClass="py-2 border-b border-[#F1F1EF] text-right w-24">
                                    <ItemTemplate>
                                        <div class="inline-flex gap-1">
                                            <asp:Button ID="btnEditSchool" runat="server" CommandName="EditSchool" CommandArgument='<%# Eval("FacultyID") %>' Text="Edit" CssClass="bg-zinc-100 hover:bg-zinc-200 text-zinc-800 text-[10px] font-medium px-1.5 py-0.5 rounded border border-zinc-200 cursor-pointer" />
                                            <asp:Button ID="btnDeleteSchool" runat="server" CommandName="DeleteSchool" CommandArgument='<%# Eval("FacultyID") %>' Text="Del" OnClientClick="return confirm('Wiping this faculty might cause database constraints conflict if connected to existing programs. Proceed?');" CssClass="bg-red-50 hover:bg-red-100 text-red-600 text-[10px] font-medium px-1.5 py-0.5 rounded border border-red-200 cursor-pointer" />
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-5 shadow-sm h-fit flex flex-col justify-start shrink-0">
                <div class="border-b border-[#EBEBE9] pb-3 mb-4 flex justify-between items-center shrink-0">
                    <h3 class="text-sm font-bold text-[#1A1A1A] uppercase tracking-wider">3. Academic Qualification Programmes</h3>
                    <div class="flex items-center gap-2 bg-white border border-[#EBEBE9] px-2 py-1 rounded-md">
                        <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Filter Level:</span>
                        <asp:DropDownList ID="ddlFilterLevel" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFilterLevel_SelectedIndexChanged" CssClass="bg-transparent text-xs font-semibold outline-none cursor-pointer">
                            <asp:ListItem Value="All">All Qualification Tiers</asp:ListItem>
                            <asp:ListItem Value="Foundation">Foundation</asp:ListItem>
                            <asp:ListItem Value="Certificate">Certificate</asp:ListItem>
                            <asp:ListItem Value="Diploma">Diploma</asp:ListItem>
                            <asp:ListItem Value="Degree">Degree</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                
                <asp:Label ID="lblProgStatus" runat="server" CssClass="block text-xs font-medium mb-3" Visible="false"></asp:Label>
                <asp:HiddenField ID="hfIsUpdateProg" runat="server" Value="false" />
                
                <div class="grid grid-cols-1 md:grid-cols-5 gap-3 bg-white p-4 border border-[#EBEBE9] rounded-lg mb-6 shrink-0 items-end">
                    <div>
                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Prog Code</label>
                        <asp:TextBox ID="txtProgCode" runat="server" CssClass="w-full bg-[#F7F7F5] p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] font-bold uppercase" placeholder="BSECS"></asp:TextBox>
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Programme Full Title Name</label>
                        <asp:TextBox ID="txtProgrammeName" runat="server" CssClass="w-full bg-[#F7F7F5] p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="Bachelor of Software Engineering in Computer Science"></asp:TextBox>
                    </div>
                    <div>
                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Tier Level</label>
                        <asp:DropDownList ID="ddlLevel" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] outline-none text-[#2F2F2F] cursor-pointer">
                            <asp:ListItem Value="Foundation">Foundation</asp:ListItem>
                            <asp:ListItem Value="Certificate">Certificate</asp:ListItem>
                            <asp:ListItem Value="Diploma">Diploma</asp:ListItem>
                            <asp:ListItem Value="Degree">Degree</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Total Credits</label>
                        <asp:TextBox ID="txtCreditHours" runat="server" TextMode="Number" CssClass="w-full bg-[#F7F7F5] p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="135"></asp:TextBox>
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Hosting Faculty Assignation</label>
                        <asp:DropDownList ID="ddlSchools" runat="server" CssClass="w-full bg-white p-2 text-xs rounded border border-[#EBEBE9] outline-none text-[#2F2F2F] cursor-pointer"></asp:DropDownList>
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Narrative Overview Description (Optional)</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="w-full bg-[#F7F7F5] p-2 text-xs rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F]" placeholder="Brief context overview tracking metrics..."></asp:TextBox>
                    </div>
                    <div>
                        <div class="flex gap-1.5">
                            <asp:Button ID="btnSaveProg" runat="server" Text="Save Programme" OnClick="btnSaveProg_Click" CssClass="w-full bg-[#1A1A1A] text-white font-medium text-xs py-2 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm text-center" />
                            <asp:Button ID="btnCancelProg" runat="server" Text="X" OnClick="btnCancelProg_Click" Visible="false" CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs px-2.5 py-2 rounded hover:bg-[#F4F4F2] transition-colors cursor-pointer" />
                        </div>
                    </div>
                </div>
                
                <div class="bg-white rounded-lg border border-[#EBEBE9] p-5 overflow-visible">
                    <asp:GridView ID="gvProgrammes" runat="server" AutoGenerateColumns="False" DataKeyNames="ProgrammeCode" 
                        OnRowCommand="gvProgrammes_RowCommand" OnPageIndexChanging="gvProgrammes_PageIndexChanging"
                        AllowPaging="True" PageSize="5" PagerStyle-CssClass="grid-pager" PagerSettings-Mode="NumericFirstLast"
                        CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                        
                        <Columns>
                            <asp:BoundField DataField="ProgrammeCode" HeaderText="Code" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] font-bold text-[#1A1A1A] w-24" />
                            <asp:BoundField DataField="ProgrammeName" HeaderText="Programme Qualification Title" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] font-medium text-[#1A1A1A]" />
                            <asp:BoundField DataField="Level" HeaderText="Tier Level" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] text-[#5F5E5B] w-28" />
                            <asp:BoundField DataField="FacultyName" HeaderText="Assigned Hosting Faculty" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] font-semibold text-zinc-600 w-48" />
                            <asp:BoundField DataField="TotalCreditHours" HeaderText="Credits" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] text-[#7C7B77] w-20 text-center" HeaderStyle-CssClass="text-center pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" />
                            
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-right" ItemStyle-CssClass="py-3.5 border-b border-[#F1F1EF] text-right w-36">
                                <ItemTemplate>
                                    <div class="inline-flex gap-1.5 justify-end w-full">
                                        <asp:Button ID="btnEditProg" runat="server" CommandName="EditProg" CommandArgument='<%# Eval("ProgrammeCode") %>' Text="Edit" CssClass="bg-zinc-100 hover:bg-zinc-200 text-zinc-800 text-[10px] font-medium px-2.5 py-1 rounded border border-zinc-200 cursor-pointer" />
                                        <asp:Button ID="btnDeleteProg" runat="server" CommandName="DeleteProg" CommandArgument='<%# Eval("ProgrammeCode") %>' Text="Delete" OnClientClick="return confirm('Drop selection?');" CssClass="bg-red-50 hover:bg-red-100 text-red-600 text-[10px] font-medium px-2.5 py-1 rounded border border-red-200 cursor-pointer" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>

                        <EmptyDataTemplate>
                            <div class="text-center py-10 px-4">
                                <span class="text-2xl text-zinc-300 block mb-2">⎔</span>
                                <p class="text-sm font-semibold text-[#1A1A1A]">No programs are created yet.</p>
                                <p class="text-xs text-[#7C7B77] mt-0.5">Fill out the staging panels above to log your first curriculum entry.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

        </div>
    </form>
</body>
</html>