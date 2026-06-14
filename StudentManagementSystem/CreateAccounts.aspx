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
            
            <div class="bg-white border-b border-[#EBEBE9] px-12 py-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 shrink-0">
                <div>
                    <h2 class="text-xl font-bold text-[#111625] tracking-tight">Identity Management</h2>
                    <p class="text-[#7C7B77] text-xs mt-0.5">Monitor directory records, verify tier classifications, and provision user credentials.</p>
                </div>
                
                <div class="flex items-center gap-3 self-end sm:self-auto">
                    <div class="flex items-center gap-2 bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl px-3 py-1.5 shadow-sm">
                        <span class="text-[11px] font-bold text-[#7C7B77] uppercase tracking-wider">Access:</span>
                        <asp:DropDownList ID="ddlFilterRole" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterRole_SelectedIndexChanged" 
                            CssClass="bg-transparent text-xs font-semibold text-[#2F2F2F] outline-none cursor-pointer pr-1">
                            <asp:ListItem Value="All">All Tiers</asp:ListItem>
                            <asp:ListItem Value="Admin">Admins Only</asp:ListItem>
                            <asp:ListItem Value="Lecturer">Lecturers Only</asp:ListItem>
                            <asp:ListItem Value="Student">Students Only</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <asp:LinkButton ID="lnkOpenRegistration" runat="server" OnClick="lnkOpenRegistration_Click"
                        CssClass="bg-zinc-950 hover:bg-zinc-800 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-sm transition-colors flex items-center gap-2 cursor-pointer">
                        <span>+ Register Account</span>
                    </asp:LinkButton>
                </div>
            </div>

            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar">
                <div class="max-w-6xl mx-auto space-y-4">
                    
                    <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3.5 rounded-xl shadow-sm mb-2" Visible="false"></asp:Label>

                    <div class="bg-white rounded-2xl border border-[#EBEBE9] shadow-sm overflow-hidden">
                        <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" DataKeyNames="UserID" OnRowCommand="gvUsers_RowCommand" 
                            CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                            <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase tracking-wider border-b border-[#EBEBE9]" />
                            <RowStyle CssClass="border-b border-[#F1F1EF] hover:bg-[#FBFBFA]/70 transition-colors text-[#2F2F2F]" />
                            <Columns>
                                <asp:BoundField DataField="UserID" HeaderText="ID" 
                                    HeaderStyle-CssClass="p-4 w-24 text-[10px] text-center select-none" ItemStyle-CssClass="p-4 text-center font-bold text-zinc-400 w-24" />
                                
                                <asp:TemplateField HeaderText="Photo" HeaderStyle-CssClass="p-4 text-center text-[10px] w-24">
                                    <ItemTemplate>
                                        <div class="flex items-center justify-center w-full">
                                            <div class="w-8 h-8 rounded-full overflow-hidden border border-zinc-200 bg-zinc-50 flex items-center justify-center shadow-inner">
                                                <img src='<%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ProfilePictureUrl"))) 
                                                              ? ResolveUrl("~/images/profile_upload/default-avatar.jpg") 
                                                              : ResolveUrl(Convert.ToString(Eval("ProfilePictureUrl"))) %>' 
                                                     alt="Avatar" class="w-full h-full object-cover" />
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField DataField="Username" HeaderText="Username / Corporate Email Address" 
                                    HeaderStyle-CssClass="p-4 text-center text-[10px]" ItemStyle-CssClass="p-4 font-semibold text-zinc-800 text-center" />
                                
                                <asp:TemplateField HeaderText="Access Role Level Status" HeaderStyle-CssClass="p-4 text-center text-[10px]">
                                    <ItemTemplate>
                                        <div class="flex items-center justify-center w-full">
                                            <span class='<%# Convert.ToString(Eval("Role")) == "Admin" ? "bg-blue-50 text-blue-600 border-blue-100" : 
                                                               Convert.ToString(Eval("Role")) == "Lecturer" ? "bg-orange-50 text-orange-600 border-orange-100" : 
                                                               "bg-emerald-50 text-emerald-600 border-emerald-100" %> px-2.5 py-1 text-[10px] font-bold rounded-full border shadow-sm uppercase tracking-wider select-none inline-block'>
                                                <%# Eval("Role") %>
                                            </span>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                
                                <asp:TemplateField HeaderText="Action Controls Console" HeaderStyle-CssClass="p-4 text-center text-[10px] pr-6" ItemStyle-CssClass="p-4 text-center pr-6 w-48">
                                    <ItemTemplate>
                                        <div class="inline-flex items-center gap-1.5 justify-center w-full">
                                            <asp:LinkButton ID="lnkEditUser" runat="server" CommandName="EditUser" CommandArgument='<%# Eval("UserID") + "," + Eval("Role") %>'
                                                CssClass="bg-zinc-50 hover:bg-zinc-100 border border-zinc-200 text-zinc-700 px-3 py-1.5 rounded-lg text-[11px] font-semibold transition-colors shadow-sm cursor-pointer">
                                                <i class="fa-solid fa-pen-to-square text-[10px] opacity-70"></i> Edit
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="lnkDeleteUser" runat="server" CommandName="DeleteUser" CommandArgument='<%# Eval("UserID") + "," + Eval("Role") %>'
                                                OnClientClick="return confirm('Permanently remove this account profile from central directories? Access vectors close immediately.');"
                                                CssClass="bg-red-50 hover:bg-red-100/80 border border-red-100 text-red-600 px-3 py-1.5 rounded-lg text-[11px] font-semibold transition-colors shadow-sm cursor-pointer">
                                                <i class="fa-solid fa-trash-can text-[10px] opacity-70"></i> Delete
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center py-16 text-zinc-400 font-medium space-y-2">
                                    <div class="text-3xl">👥</div>
                                    <p class="text-xs text-[#9A9996]">No credential logs matched for the current role selection.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnlModalContainer" runat="server" Visible="false" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm transition-opacity">
                <div class="bg-[#F7F7F5] w-full max-w-md rounded-2xl border border-[#EBEBE9] shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
                    
                    <div class="bg-white border-b border-[#EBEBE9] px-6 py-4 flex items-center justify-between">
                        <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider flex items-center gap-2">
                            <span>👤</span> <asp:Literal ID="litModalHeader" runat="server" Text="Register New Profile Instance"></asp:Literal>
                        </h3>
                        <asp:LinkButton ID="lnkCloseTop" runat="server" OnClick="btnCancelAccount_Click" CssClass="text-[#9A9996] hover:text-[#1A1A1A] font-bold text-lg transition-colors cursor-pointer select-none">&times;</asp:LinkButton>
                    </div>

                    <div class="p-6 space-y-4">
                        <asp:HiddenField ID="hfUserID" runat="server" />
                        
                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Full Registered Corporate Name</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] transition-all font-medium shadow-sm" placeholder="e.g., John Doe"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">IC / Passport Serial Identification</label>
                            <asp:TextBox ID="txtIdentityNumber" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] transition-all font-medium shadow-sm" placeholder="e.g., 010203141234"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">System Username / Primary Email</label>
                            <asp:TextBox ID="txtNewUsername" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] transition-all font-medium shadow-sm" placeholder="e.g., staff@inti.edu.my"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Secure Password String</label>
                            <asp:TextBox ID="txtNewPassword" runat="server" CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] transition-all font-medium shadow-sm" placeholder="••••••••"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Assigned Core Access Tier Role</label>
                            <asp:DropDownList ID="ddlRole" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlRole_SelectedIndexChanged"
                                CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-semibold transition-all cursor-pointer shadow-sm">
                                <asp:ListItem Value="">-- Choose Access Level --</asp:ListItem>
                                <asp:ListItem Value="Student">Student Cohort</asp:ListItem>
                                <asp:ListItem Value="Lecturer">Academic Lecturer</asp:ListItem>
                                <asp:ListItem Value="Admin">System Administrator</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <asp:Panel ID="pnlSemesterSelection" runat="server" Visible="false">
                            <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Assign Target Intake Semester Term</label>
                            <asp:DropDownList ID="ddlStudentSemester" runat="server" 
                                CssClass="w-full bg-white p-2.5 text-xs rounded-xl border border-[#EBEBE9] focus:border-zinc-950 outline-none text-[#2F2F2F] font-semibold transition-all cursor-pointer shadow-sm">
                            </asp:DropDownList>
                        </asp:Panel>
                    </div>

                    <div class="bg-white border-t border-[#EBEBE9] px-6 py-4 flex items-center justify-end gap-2">
                        <asp:Button ID="btnCancelAccount" runat="server" Text="Discard" OnClick="btnCancelAccount_Click" 
                            CssClass="bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs font-semibold px-4 py-2 rounded-xl hover:bg-[#F4F4F2] transition-colors cursor-pointer" />
                        <asp:Button ID="btnCreateAccount" runat="server" Text="Register Account" ClientIDMode="Static" OnClick="btnCreateAccount_Click"
                            CssClass="bg-zinc-950 text-white font-bold text-xs px-4 py-2 rounded-xl hover:bg-zinc-800 transition-colors cursor-pointer shadow-sm" />
                    </div>

                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>