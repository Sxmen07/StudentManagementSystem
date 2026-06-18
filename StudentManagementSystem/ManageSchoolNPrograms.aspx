<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageSchoolNPrograms.aspx.cs" Inherits="StudentManagementSystem.ManageSchoolNPrograms" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Academic Structure Desk</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #EBEBE9; border-radius: 10px; }
        
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

        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <div class="bg-white border-b border-[#EBEBE9] px-12 py-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 shrink-0">
                <div>
                    <h2 class="text-xl font-bold text-[#111625] tracking-tight">Curriculum & Structural Dashboard</h2>
                    <p class="text-[#7C7B77] text-xs mt-0.5">Configure operational terms, academic management faculties, and complete graduation programs.</p>
                </div>
            </div>

            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar space-y-8">
                
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
                    
                    <div class="bg-white border border-[#EBEBE9] rounded-2xl p-6 shadow-sm space-y-4">
                        <div class="border-b border-[#F1F1EF] pb-3">
                            <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider flex items-center gap-2">
                                <span>🗓️</span> Academic Semesters Term Registry
                            </h3>
                        </div>
                        
                        <asp:Label ID="lblSemesterStatus" runat="server" CssClass="block text-[11px] font-medium p-2.5 rounded-xl bg-zinc-50 border border-zinc-100" Visible="false"></asp:Label>
                        <asp:HiddenField ID="hfSemesterID" runat="server" />
                        
                        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Intake Block</label>
                                <asp:TextBox ID="txtSemesterTerm" runat="server" CssClass="w-full bg-white p-2 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-medium" placeholder="Jan Term"></asp:TextBox>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Year</label>
                                <asp:TextBox ID="txtAcademicYear" runat="server" TextMode="Number" CssClass="w-full bg-white p-2 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-medium" placeholder="2026"></asp:TextBox>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Start (MM-DD)</label>
                                <asp:TextBox ID="txtStartDay" runat="server" CssClass="w-full bg-white p-2 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-medium" placeholder="01-01"></asp:TextBox>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">End (MM-DD)</label>
                                <asp:TextBox ID="txtEndDay" runat="server" CssClass="w-full bg-white p-2 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-medium" placeholder="03-31"></asp:TextBox>
                            </div>
                        </div>

                        <div class="flex items-center justify-end gap-2 pt-1 border-t border-[#F1F1EF]">
                            <asp:Button ID="btnCancelSemester" runat="server" Text="Discard" OnClick="btnCancelSemester_Click" Visible="false" CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs font-semibold px-3 py-1.5 rounded-xl hover:bg-[#F4F4F2]" />
                            <asp:Button ID="btnSaveSemester" runat="server" Text="Save Term" OnClick="btnSaveSemester_Click" CssClass="bg-zinc-950 text-white font-bold text-xs px-4 py-1.5 rounded-xl hover:bg-zinc-800 shadow-sm" />
                        </div>
                        
                        <div class="rounded-xl border border-[#EBEBE9] overflow-hidden max-h-[200px] overflow-y-auto custom-scrollbar">
                            <asp:GridView ID="gvSemesters" runat="server" AutoGenerateColumns="False" DataKeyNames="SemesterID" OnRowCommand="gvSemesters_RowCommand" CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                                <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase tracking-wider border-b border-[#EBEBE9] text-[10px]" />
                                <RowStyle CssClass="border-b border-[#F1F1EF] hover:bg-[#FBFBFA] text-[#2F2F2F]" />
                                <Columns>
                                    <asp:BoundField DataField="Semester" HeaderText="Term" HeaderStyle-CssClass="p-3" ItemStyle-CssClass="p-3 font-semibold text-[#1A1A1A]" />
                                    <asp:BoundField DataField="AcademicYear" HeaderText="Year" HeaderStyle-CssClass="p-3" ItemStyle-CssClass="p-3 font-medium text-zinc-500" />
                                    <asp:BoundField DataField="StartMonthDay" HeaderText="Start" HeaderStyle-CssClass="p-3" ItemStyle-CssClass="p-3 text-[#5F5E5B]" />
                                    <asp:BoundField DataField="EndMonthDay" HeaderText="End" HeaderStyle-CssClass="p-3" ItemStyle-CssClass="p-3 text-[#5F5E5B]" />
                                    <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="p-3 text-right text-[10px]" ItemStyle-CssClass="p-3 text-right w-20">
                                        <ItemTemplate>
                                            <div class="inline-flex gap-1 justify-end">
                                                <asp:LinkButton ID="btnEditSem" runat="server" CommandName="EditSemester" CommandArgument='<%# Eval("SemesterID") %>' CssClass="text-zinc-500 hover:text-zinc-950 text-xs"><i class="fa-solid fa-pen-to-square"></i></asp:LinkButton>
                                                <asp:LinkButton ID="btnDeleteSem" runat="server" CommandName="DeleteSemester" CommandArgument='<%# Eval("SemesterID") %>' OnClientClick="return confirm('Delete term record?');" CssClass="text-red-400 hover:text-red-600 text-xs"><i class="fa-solid fa-trash-can"></i></asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    <div class="bg-white border border-[#EBEBE9] rounded-2xl p-6 shadow-sm space-y-4">
                        <div class="border-b border-[#F1F1EF] pb-3">
                            <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider flex items-center gap-2">
                                <span>🏛️</span> Academic Management Faculties
                            </h3>
                        </div>
                        
                        <asp:Label ID="lblSchoolStatus" runat="server" CssClass="block text-[11px] font-medium p-2.5 rounded-xl bg-zinc-50 border border-zinc-100" Visible="false"></asp:Label>
                        <asp:HiddenField ID="hfSchoolID" runat="server" />
                        
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Faculty Name Designation</label>
                            <asp:TextBox ID="txtSchoolName" runat="server" CssClass="w-full bg-white p-2 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-medium" placeholder="e.g., School of Computing"></asp:TextBox>
                        </div>

                        <div class="flex items-center justify-end gap-2 pt-1 border-t border-[#F1F1EF]">
                            <asp:Button ID="btnCancelSchool" runat="server" Text="Discard" OnClick="btnCancelSchool_Click" Visible="false" CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs font-semibold px-3 py-1.5 rounded-xl hover:bg-[#F4F4F2]" />
                            <asp:Button ID="btnSaveSchool" runat="server" Text="Save Faculty" OnClick="btnSaveSchool_Click" CssClass="bg-zinc-950 text-white font-bold text-xs px-4 py-1.5 rounded-xl hover:bg-zinc-800 shadow-sm" />
                        </div>
                        
                        <div class="rounded-xl border border-[#EBEBE9] overflow-hidden max-h-[200px] overflow-y-auto custom-scrollbar">
                            <asp:GridView ID="gvSchools" runat="server" AutoGenerateColumns="False" DataKeyNames="FacultyID" OnRowCommand="gvSchools_RowCommand" CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                                <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase tracking-wider border-b border-[#EBEBE9] text-[10px]" />
                                <RowStyle CssClass="border-b border-[#F1F1EF] hover:bg-[#FBFBFA] text-[#2F2F2F]" />
                                <Columns>
                                    <asp:BoundField DataField="FacultyName" HeaderText="Faculty Designation Title" HeaderStyle-CssClass="p-3" ItemStyle-CssClass="p-3 font-semibold text-[#1A1A1A]" />
                                    <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="p-3 text-right text-[10px]" ItemStyle-CssClass="p-3 text-right w-20">
                                        <ItemTemplate>
                                            <div class="inline-flex gap-1 justify-end">
                                                <asp:LinkButton ID="btnEditSchool" runat="server" CommandName="EditSchool" CommandArgument='<%# Eval("FacultyID") %>' CssClass="text-zinc-500 hover:text-zinc-950 text-xs"><i class="fa-solid fa-pen-to-square"></i></asp:LinkButton>
                                                <asp:LinkButton ID="btnDeleteSchool" runat="server" CommandName="DeleteSchool" CommandArgument='<%# Eval("FacultyID") %>' OnClientClick="return confirm('Wiping this faculty might cause database constraints conflict if connected to existing programs. Proceed?');" CssClass="text-red-400 hover:text-red-600 text-xs"><i class="fa-solid fa-trash-can"></i></asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

                <div class="bg-white border border-[#EBEBE9] rounded-2xl p-6 shadow-sm space-y-4">
                    
                    <div class="border-b border-[#EBEBE9] pb-3 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                        <div>
                            <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider flex items-center gap-2">
                                <span>🎓</span> Academic Qualification Programmes Core
                            </h3>
                        </div>
                        
                        <div class="flex flex-wrap items-center gap-3 self-end md:self-auto">
                            <div class="flex items-center gap-2 bg-[#F7F7F5] border border-[#EBEBE9] px-3 py-1.5 rounded-xl shadow-sm">
                                <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Level:</span>
                                <asp:DropDownList ID="ddlFilterLevel" runat="server" AutoPostBack="True" OnSelectedIndexChanged="Filters_SelectedIndexChanged" CssClass="bg-transparent text-xs font-semibold outline-none cursor-pointer text-[#2F2F2F]">
                                    <asp:ListItem Value="All">All Tiers</asp:ListItem>
                                    <asp:ListItem Value="Foundation">Foundation</asp:ListItem>
                                    <asp:ListItem Value="Certificate">Certificate</asp:ListItem>
                                    <asp:ListItem Value="Diploma">Diploma</asp:ListItem>
                                    <asp:ListItem Value="Degree">Degree</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            
                            <div class="flex items-center gap-2 bg-[#F7F7F5] border border-[#EBEBE9] px-3 py-1.5 rounded-xl shadow-sm">
                                <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Faculty:</span>
                                <asp:DropDownList ID="ddlFilterSchool" runat="server" AutoPostBack="True" OnSelectedIndexChanged="Filters_SelectedIndexChanged" CssClass="bg-transparent text-xs font-semibold outline-none cursor-pointer text-[#2F2F2F]"></asp:DropDownList>
                            </div>

                            <div class="inline-flex rounded-xl shadow-sm border border-zinc-200 bg-white p-1 gap-1">
                                <asp:LinkButton ID="btnExportCSV" runat="server" OnClick="btnExportCSV_Click" ToolTip="Export to CSV" CssClass="p-1.5 text-xs text-zinc-600 hover:text-zinc-950 rounded-lg hover:bg-zinc-50 transition-colors">
                                    <i class="fa-solid fa-file-csv text-base text-emerald-600"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnExportExcel" runat="server" OnClick="btnExportExcel_Click" ToolTip="Export to Excel" CssClass="p-1.5 text-xs text-zinc-600 hover:text-zinc-950 rounded-lg hover:bg-zinc-50 transition-colors">
                                    <i class="fa-solid fa-file-excel text-base text-green-600"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnExportPDF" runat="server" OnClick="btnExportPDF_Click" ToolTip="Export to PDF" CssClass="p-1.5 text-xs text-zinc-600 hover:text-zinc-950 rounded-lg hover:bg-zinc-50 transition-colors">
                                    <i class="fa-solid fa-file-pdf text-base text-rose-600"></i>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                    
                    <asp:Label ID="lblProgStatus" runat="server" CssClass="block text-[11px] font-medium p-2.5 rounded-xl bg-zinc-50 border border-zinc-100" Visible="false"></asp:Label>
                    <asp:HiddenField ID="hfIsUpdateProg" runat="server" Value="false" />
                    
                    <div class="bg-[#F7F7F5] rounded-xl border border-[#EBEBE9] p-5 space-y-4">
                        <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Prog Code</label>
                                <asp:TextBox ID="txtProgCode" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none font-bold uppercase" placeholder="BSECS"></asp:TextBox>
                            </div>
                            <div class="md:col-span-2">
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Programme Full Title Name</label>
                                <asp:TextBox ID="txtProgrammeName" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none" placeholder="Bachelor of Software Engineering"></asp:TextBox>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Tier Level</label>
                                <asp:DropDownList ID="ddlLevel" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none font-semibold cursor-pointer">
                                    <asp:ListItem Value="Foundation">Foundation</asp:ListItem>
                                    <asp:ListItem Value="Certificate">Certificate</asp:ListItem>
                                    <asp:ListItem Value="Diploma">Diploma</asp:ListItem>
                                    <asp:ListItem Value="Degree">Degree</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Total Credits</label>
                                <asp:TextBox ID="txtCreditHours" runat="server" TextMode="Number" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none" placeholder="135"></asp:TextBox>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-5 gap-4 items-end">
                            <div class="md:col-span-2">
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Hosting Faculty Assignation</label>
                                <asp:DropDownList ID="ddlSchools" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none font-semibold cursor-pointer"></asp:DropDownList>
                            </div>
                            <div class="md:col-span-2">
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Narrative Overview Description (Optional)</label>
                                <asp:TextBox ID="txtDescription" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none" placeholder="Brief overview parameters..."></asp:TextBox>
                            </div>
                            <div class="flex gap-2">
                                <asp:Button ID="btnCancelProg" runat="server" Text="Discard" OnClick="btnCancelProg_Click" Visible="false" CssClass="w-1/2 bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs font-semibold py-2.5 rounded-xl hover:bg-[#F4F4F2]" />
                                <asp:Button ID="btnSaveProg" runat="server" Text="Save Programme" OnClick="btnSaveProg_Click" CssClass="flex-1 bg-zinc-950 text-white font-bold text-xs py-2.5 rounded-xl hover:bg-zinc-800 shadow-sm" />
                            </div>
                        </div>
                    </div>
                    
                    <div class="bg-white rounded-xl border border-[#EBEBE9] overflow-hidden shadow-sm">
                        <asp:GridView ID="gvProgrammes" runat="server" AutoGenerateColumns="False" DataKeyNames="ProgrammeCode" 
                            OnRowCommand="gvProgrammes_RowCommand" OnPageIndexChanging="gvProgrammes_PageIndexChanging"
                            AllowPaging="True" PageSize="5" PagerStyle-CssClass="grid-pager py-3 bg-[#F7F7F5] border-t border-[#EBEBE9]" PagerSettings-Mode="NumericFirstLast"
                            CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                            <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase tracking-wider border-b border-[#EBEBE9] text-[10px]" />
                            <RowStyle CssClass="border-b border-[#F1F1EF] hover:bg-[#FBFBFA]/60 text-[#2F2F2F]" />
                            <Columns>
                                <asp:BoundField DataField="ProgrammeCode" HeaderText="Code" HeaderStyle-CssClass="p-4" ItemStyle-CssClass="p-4 font-bold text-zinc-900 w-24" />
                                <asp:BoundField DataField="ProgrammeName" HeaderText="Programme Qualification Title" HeaderStyle-CssClass="p-4" ItemStyle-CssClass="p-4 font-semibold text-zinc-800" />
                                <asp:BoundField DataField="Level" HeaderText="Tier Level" HeaderStyle-CssClass="p-4" ItemStyle-CssClass="p-4 text-[#5F5E5B] w-28" />
                                <asp:BoundField DataField="FacultyName" HeaderText="Assigned Hosting Faculty" HeaderStyle-CssClass="p-4" ItemStyle-CssClass="p-4 font-medium text-zinc-500 w-48" />
                                <asp:BoundField DataField="TotalCreditHours" HeaderText="Credits" HeaderStyle-CssClass="p-4 text-center" ItemStyle-CssClass="p-4 text-center font-bold text-zinc-400 w-20" />
                                <asp:TemplateField HeaderText="Action Controls" HeaderStyle-CssClass="p-4 text-right text-[10px] pr-6" ItemStyle-CssClass="p-4 text-right pr-6 w-32">
                                    <ItemTemplate>
                                        <div class="inline-flex gap-1 justify-end w-full">
                                            <asp:Button ID="btnEditProg" runat="server" CommandName="EditProg" CommandArgument='<%# Eval("ProgrammeCode") %>' Text="Edit" CssClass="bg-zinc-50 hover:bg-zinc-100 border border-zinc-200 text-zinc-700 px-2 py-1 rounded-lg font-semibold" />
                                            <asp:Button ID="btnDeleteProg" runat="server" CommandName="DeleteProg" CommandArgument='<%# Eval("ProgrammeCode") %>' Text="Delete" OnClientClick="return confirm('Drop selection?');" CssClass="bg-red-50 hover:bg-red-100 text-red-600 px-2 py-1 rounded-lg font-semibold" />
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center py-12 px-4 text-zinc-400 font-medium space-y-2">
                                    <span class="text-2xl text-zinc-300 block">⎔</span>
                                    <p class="text-xs font-semibold text-[#1A1A1A]">No programmes match your tier selection configuration.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>

            </div>
        </div>
    </form>
</body>
</html>