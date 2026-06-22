<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateAccounts.aspx.cs" Inherits="StudentManagementSystem.CreateAccounts" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Identity Management Desk</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #EBEBE9; border-radius: 10px; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative" onkeydown="if(event.keyCode==13) { return false; }">
        
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <!-- RESTORED: Original light blue top bar style theme layout elements with +Register Account at top-right -->
            <div class="relative bg-[#F4F7FE] border-b border-[#EBEBE9] px-12 py-8 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 shrink-0 overflow-hidden">
                
                <div class="absolute inset-0 pointer-events-none select-none opacity-20">
                    <svg class="w-full h-full" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="-20" cy="50%" r="60" fill="none" stroke="#3B82F6" stroke-width="4" />
                        <circle cx="40" cy="90%" r="40" fill="none" stroke="#F97316" stroke-width="2" stroke-dasharray="4 4" />
                        <circle cx="86%" cy="35%" r="70" fill="none" stroke="#10B981" stroke-width="10" /> 
                        <circle cx="93%" cy="60%" r="55" fill="none" stroke="#3B82F6" stroke-width="5" />  
                        <circle cx="98%" cy="85%" r="40" fill="none" stroke="#F97316" stroke-width="2.5" /> 
                    </svg>
                </div>

                <div class="relative z-10 flex items-center gap-4">
                    <div class="bg-[#3B82F6]/10 text-[#3B82F6] p-3.5 rounded-2xl border border-[#3B82F6]/20 shadow-sm flex items-center justify-center shrink-0">
                        <i class="fa-solid fa-users-gear text-lg"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-bold text-[#111625] tracking-tight">Identity Management</h2>
                        <p class="text-[#7C7B77] text-xs mt-0.5 font-medium">Monitor directory records, verify tier classifications, and provision user credentials.</p>
                    </div>
                </div>
                
                <div class="relative z-10 flex items-center gap-3 self-end sm:self-auto">
                    <asp:LinkButton ID="btnTriggerRegistrationModal" runat="server" OnClick="btnTriggerRegistrationModal_Click"
                        CssClass="bg-zinc-950 hover:bg-zinc-800 text-white font-semibold text-xs px-5 py-2.5 rounded-xl shadow-sm transition-colors flex items-center gap-2 cursor-pointer">
                        <span>+ Register Account</span>
                    </asp:LinkButton>
                </div>
            </div>

            <!-- Content Area Workspace -->
            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar space-y-6">
                
                <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3.5 rounded-xl shadow-sm mb-2" Visible="false"></asp:Label>

                <!-- Controls Layout Stack: Clean standalone elements above the grid card table -->
                <div class="flex flex-col gap-4 py-2">
                    
                    <!-- Search ID Function Box neatly aligned directly above your action filters -->
                    <div class="flex justify-start">
                        <div class="flex items-center gap-2 bg-white border border-zinc-200 ltr:pl-4 ltr:pr-2 rtl:pr-4 ltr:pl-2 py-1.5 rounded-xl shadow-sm shadow-black/5 min-w-[280px]">
                            <i class="fa-solid fa-magnifying-glass text-xs text-zinc-400 pl-2"></i>
                            <asp:TextBox ID="txtSearchUID" runat="server" AutoPostBack="true" OnTextChanged="txtSearchUID_TextChanged"
                                CssClass="bg-transparent text-xs font-medium text-[#2F2F2F] outline-none placeholder-zinc-400 w-full py-1 px-2" 
                                placeholder="Search account ID..."></asp:TextBox>
                            <asp:LinkButton ID="lnkClearSearch" runat="server" OnClick="lnkClearSearch_Click" Visible="false" 
                                CssClass="text-zinc-400 hover:text-zinc-600 px-2 text-xs font-bold font-sans">&times;</asp:LinkButton>
                        </div>
                    </div>

                    <!-- Filter Tabs, Cohort Dropdown Sorter, and Namelist Exporters Row -->
                    <div class="flex flex-col xl:flex-row xl:items-center xl:justify-between gap-4">
                        <div class="flex flex-wrap items-center gap-4">
                            <!-- Role Filter Tabs: Shows color accents matching table pills only when clicked active -->
                            <div class="inline-flex gap-2.5 shrink-0">
                                <asp:Button ID="btnFilterAll" runat="server" Text="ALL ACCOUNTS" OnClick="FilterButton_Click" CommandArgument="All" UseSubmitBehavior="false" />
                                <asp:Button ID="btnFilterAdmin" runat="server" Text="ADMIN" OnClick="FilterButton_Click" CommandArgument="Admin" UseSubmitBehavior="false" />
                                <asp:Button ID="btnFilterLecturer" runat="server" Text="LECTURER" OnClick="FilterButton_Click" CommandArgument="Lecturer" UseSubmitBehavior="false" />
                                <asp:Button ID="btnFilterStudent" runat="server" Text="STUDENT" OnClick="FilterButton_Click" CommandArgument="Student" UseSubmitBehavior="false" />
                            </div>

                            <!-- Cohort filtering program dropdown menu box -->
                            <div id="divProgSortWrapper" runat="server" class="flex items-center gap-2.5 bg-white border border-zinc-200 px-4 py-2 rounded-xl shadow-sm shadow-black/5">
                                <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Cohort Filter:</span>
                                <asp:DropDownList ID="ddlFilterProgramme" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProgramme_SelectedIndexChanged"
                                    CssClass="bg-transparent text-xs font-bold text-[#2F2F2F] outline-none cursor-pointer pr-1">
                                </asp:DropDownList>
                            </div>
                        </div>

                        <!-- Full Icon Text combo download exporters toolbar -->
                        <div class="flex items-center gap-2">
                            <asp:LinkButton ID="btnExportCSV" runat="server" OnClick="btnExportCSV_Click" CssClass="inline-flex items-center gap-2 bg-white border border-zinc-200 hover:bg-zinc-50 px-4 py-2 rounded-xl text-xs font-bold text-zinc-700 shadow-sm shadow-black/5 transition-all cursor-pointer">
                                <i class="fa-solid fa-file-csv text-sm text-emerald-600"></i> Export CSV
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnExportExcel" runat="server" OnClick="btnExportExcel_Click" CssClass="inline-flex items-center gap-2 bg-white border border-zinc-200 hover:bg-zinc-50 px-4 py-2 rounded-xl text-xs font-bold text-zinc-700 shadow-sm shadow-black/5 transition-all cursor-pointer">
                                <i class="fa-solid fa-file-excel text-sm text-green-600"></i> Export Excel
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnExportPDF" runat="server" OnClick="btnExportPDF_Click" CssClass="inline-flex items-center gap-2 bg-white border border-zinc-200 hover:bg-zinc-50 px-4 py-2 rounded-xl text-xs font-bold text-zinc-700 shadow-sm shadow-black/5 transition-all cursor-pointer">
                                <i class="fa-solid fa-file-pdf text-sm text-rose-600"></i> Export PDF
                            </asp:LinkButton>
                        </div>
                    </div>

                </div>

                <!-- Main User Directory Grid Table -->
                <div class="bg-white rounded-2xl border border-[#EBEBE9] shadow-sm overflow-hidden mt-2">
                    <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" DataKeyNames="UserID" OnRowCommand="gvUsers_RowCommand" 
                        CssClass="w-full text-center text-xs border-collapse" GridLines="None">
                        <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase border-b border-[#EBEBE9] text-center p-5 text-xs tracking-wider select-none" />
                        <RowStyle CssClass="border-b border-[#F1F1EF] hover:bg-[#FBFBFA]/70 text-[#2F2F2F] text-xs font-medium" />
                        <Columns>
                            
                            <asp:TemplateField HeaderText="ID" HeaderStyle-CssClass="py-5 px-4 w-28" ItemStyle-CssClass="py-6 px-4 text-center font-bold text-zinc-400 w-28 align-middle text-xs">
                                <ItemTemplate><%# Eval("DisplayID") %></ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Photo" HeaderStyle-CssClass="py-5 px-4 w-24" ItemStyle-CssClass="py-6 px-4 text-center w-24 align-middle">
                                <ItemTemplate>
                                    <div class="flex items-center justify-center w-full">
                                        <div class="w-9 h-9 rounded-full overflow-hidden border border-zinc-200 bg-zinc-50 flex items-center justify-center shadow-inner">
                                            <img src='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ProfilePictureUrl"))) ? ResolveUrl("~/images/profile_upload/default-avatar.jpg") : ResolveUrl(Convert.ToString(Eval("ProfilePictureUrl"))) %>' alt="Avatar" class="w-full h-full object-cover" />
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Username" HeaderText="Username / Email Address" HeaderStyle-CssClass="py-5 px-4" ItemStyle-CssClass="py-6 px-4 font-semibold text-zinc-800 text-center align-middle text-xs" />
                            
                            <asp:TemplateField HeaderText="Role Status" HeaderStyle-CssClass="py-5 px-4 w-32" ItemStyle-CssClass="py-6 px-4 text-center w-32 align-middle">
                                <ItemTemplate>
                                    <div class="flex items-center justify-center w-full">
                                        <span class='<%# Convert.ToString(Eval("Role")) == "Admin" ? "bg-blue-50 text-blue-600 border-blue-100" : Convert.ToString(Eval("Role")) == "Lecturer" ? "bg-orange-50 text-orange-600 border-orange-100" : "bg-emerald-50 text-emerald-600 border-emerald-100" %> px-3 py-1 text-[9px] font-bold rounded-full border shadow-sm uppercase tracking-wider inline-block text-center text-[10px]'><%# Eval("Role") %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Assigned Programme Track" HeaderStyle-CssClass="py-5 px-4 w-1/3 text-center" ItemStyle-CssClass="py-6 px-4 text-center font-semibold text-zinc-600 w-1/3 align-middle text-xs">
                                <ItemTemplate>
                                    <%# string.IsNullOrEmpty(Eval("ProgrammeName").ToString()) ? "-" : Eval("ProgrammeName") %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Action Controls Console" HeaderStyle-CssClass="py-5 px-4 w-52 pr-6" ItemStyle-CssClass="py-6 px-4 text-center w-52 pr-6 align-middle text-xs">
                                <ItemTemplate>
                                    <div class="inline-flex items-center gap-2 justify-center w-full text-xs">
                                        <asp:LinkButton ID="lnkEditUser" runat="server" CommandName="EditUser" CommandArgument='<%# Eval("UserID") + "," + Eval("Role") %>' CssClass="bg-zinc-50 hover:bg-zinc-100 border border-zinc-200 text-zinc-700 px-3 py-1.5 rounded-lg font-bold shadow-sm text-xs transition-colors"><i class="fa-solid fa-pen-to-square"></i> Edit</asp:LinkButton>
                                        <asp:LinkButton ID="lnkDeleteUser" runat="server" CommandName="DeleteUser" CommandArgument='<%# Eval("UserID") + "," + Eval("Role") %>' OnClientClick="return confirm('Permanently remove this account profile from central directories?');" CssClass="bg-red-50 hover:bg-red-100 border border-red-100 text-red-600 px-3 py-1.5 rounded-lg font-bold shadow-sm text-xs transition-colors"><i class="fa-solid fa-trash-can"></i> Delete</asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="text-center py-20 text-zinc-400 font-medium space-y-2">
                                <div class="text-3xl">🔍</div>
                                <p class="text-xs font-semibold text-zinc-800">No matching account entries located.</p>
                                <p class="text-[11px] text-zinc-400">Verify your active filters or clear the keyword tracking string input box values.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <!-- Identity profile setup overlay panel modal dialog box form -->
            <asp:Panel ID="pnlModalContainer" runat="server" Visible="false" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm transition-opacity">
                <div class="bg-[#F7F7F5] w-full max-w-md rounded-2xl border border-[#EBEBE9] shadow-2xl overflow-hidden">
                    
                    <div class="bg-white border-b border-[#EBEBE9] px-6 py-4 flex items-center justify-between">
                        <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider flex items-center gap-2">
                            <span>👤</span> <asp:Literal ID="litModalHeader" runat="server" Text="Register New Profile Instance"></asp:Literal>
                        </h3>
                        <asp:LinkButton ID="lnkCloseTop" runat="server" OnClick="btnCancelAccount_Click" class="text-[#9A9996] hover:text-[#1A1A1A] font-bold text-lg select-none">&times;</asp:LinkButton>
                    </div>

                    <div class="p-6 space-y-4 max-h-[75vh] overflow-y-auto custom-scrollbar">
                        <asp:HiddenField ID="hfUserID" runat="server" />
                        
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Full Registered Corporate Name</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-medium shadow-sm" placeholder="Enter full identity name"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">IC / Passport Serial Identification</label>
                            <asp:TextBox ID="txtIdentityNumber" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-medium shadow-sm" placeholder="Enter document serial digits"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Assigned Core Access Tier Role</label>
                            <asp:DropDownList ID="ddlRole" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlRole_SelectedIndexChanged"
                                CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-semibold cursor-pointer shadow-sm">
                                <asp:ListItem Value="">-- Choose Access Level --</asp:ListItem>
                                <asp:ListItem Value="Student">Student Cohort</asp:ListItem>
                                <asp:ListItem Value="Lecturer">Academic Lecturer</asp:ListItem>
                                <asp:ListItem Value="Admin">System Administrator</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- STUDENT FIELD REF HOOKS -->
                        <asp:Panel ID="pnlStudentFields" runat="server" Visible="false" class="space-y-4 bg-zinc-50 border border-zinc-200/60 p-4 rounded-xl">
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Assign Intake Semester Term</label>
                                <asp:DropDownList ID="ddlStudentSemester" runat="server" 
                                    CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none font-semibold cursor-pointer shadow-sm">
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Assign Qualification Programme Track</label>
                                <asp:DropDownList ID="ddlStudentProgramme" runat="server" 
                                    CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none font-semibold cursor-pointer shadow-sm">
                                </asp:DropDownList>
                            </div>
                        </asp:Panel>
                        
                        <p class="text-[10px] font-medium text-zinc-400 bg-zinc-100 p-2.5 rounded-lg border leading-relaxed"><i class="fa-solid fa-wand-magic-sparkles text-amber-500"></i> Corporate usernames and first-time matching pass keys are automatically generated via identity numbers structure patterns matrix.</p>
                    </div>

                    <div class="bg-white border-t border-[#EBEBE9] px-6 py-4 flex items-center justify-end gap-2">
                        <asp:Button ID="btnCancelAccount" runat="server" Text="Discard" OnClick="btnCancelAccount_Click" 
                            CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs font-semibold px-4 py-2 rounded-xl hover:bg-[#F4F4F2] transition-colors cursor-pointer" />
                        <asp:Button ID="btnCreateAccount" runat="server" Text="Register Account" OnClick="btnCreateAccount_Click"
                            CssClass="bg-zinc-950 text-white font-bold text-xs px-4 py-2 rounded-xl hover:bg-zinc-800 transition-colors cursor-pointer shadow-sm" />
                    </div>

                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>