<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AuditAttendance.aspx.cs" Inherits="StudentManagementSystem.AuditAttendance" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Administrative Attendance Desk</title>
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
    <form id="form1" runat="server" class="h-full flex relative">
        
        <uc:Sidebar runat="server" ID="AdminSidebar" />

        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <div class="bg-white border-b border-[#EBEBE9] px-12 py-5 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 shrink-0">
                <div>
                    <h2 class="text-xl font-bold text-[#111625] tracking-tight">Attendance Audit Desk</h2>
                    <p class="text-[#7C7B77] text-xs mt-0.5">Cross-examine cohort logs, track lecturer submission strings, and extract institutional sheets.</p>
                </div>
                
                <div class="flex items-center gap-2 self-end sm:self-auto">
                    <asp:LinkButton ID="btnExportCSV" runat="server" OnClick="btnExportCSV_Click" CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 p-2.5 rounded-xl shadow-sm text-xs font-semibold transition-all">
                        <i class="fa-solid fa-file-csv text-zinc-500"></i> CSV
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportExcel" runat="server" OnClick="btnExportExcel_Click" CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 p-2.5 rounded-xl shadow-sm text-xs font-semibold transition-all">
                        <i class="fa-solid fa-file-excel text-emerald-600"></i> Excel
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportPDF" runat="server" OnClick="btnExportPDF_Click" CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 p-2.5 rounded-xl shadow-sm text-xs font-semibold transition-all">
                        <i class="fa-solid fa-file-pdf text-red-600"></i> PDF
                    </asp:LinkButton>
                </div>
            </div>

            <div class="bg-white border-b border-[#EBEBE9] px-12 py-4 flex flex-wrap items-center gap-3 shrink-0">
                <div class="flex flex-wrap items-center gap-2 text-xs font-medium">
                    <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl px-2.5 py-1.5 flex items-center gap-1">
                        <span class="text-[10px] font-bold text-zinc-400 uppercase">School:</span>
                        <asp:DropDownList ID="ddlSchool" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSchool_SelectedIndexChanged" CssClass="bg-transparent font-semibold outline-none cursor-pointer text-zinc-700"></asp:DropDownList>
                    </div>

                    <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl px-2.5 py-1.5 flex items-center gap-1">
                        <span class="text-[10px] font-bold text-zinc-400 uppercase">Program:</span>
                        <asp:DropDownList ID="ddlProgram" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProgram_SelectedIndexChanged" CssClass="bg-transparent font-semibold outline-none cursor-pointer text-zinc-700"></asp:DropDownList>
                    </div>

                    <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl px-2.5 py-1.5 flex items-center gap-1">
                        <span class="text-[10px] font-bold text-zinc-400 uppercase">Course:</span>
                        <asp:DropDownList ID="ddlCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged" CssClass="bg-transparent font-semibold outline-none cursor-pointer text-zinc-700"></asp:DropDownList>
                    </div>

                    <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl px-2.5 py-1.5 flex items-center gap-1">
                        <span class="text-[10px] font-bold text-zinc-400 uppercase">Lecturer:</span>
                        <asp:DropDownList ID="ddlLecturer" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLecturer_SelectedIndexChanged" CssClass="bg-transparent font-semibold outline-none cursor-pointer text-zinc-700"></asp:DropDownList>
                    </div>

                    <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl px-2.5 py-1 flex items-center gap-1">
                        <span class="text-[10px] font-bold text-zinc-400 uppercase">Date:</span>
                        <asp:TextBox ID="txtDateFilter" runat="server" TextMode="Date" AutoPostBack="true" OnTextChanged="txtDateFilter_TextChanged" CssClass="bg-transparent font-semibold outline-none cursor-pointer text-zinc-700 font-sans"></asp:TextBox>
                    </div>
                </div>
            </div>

            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar">
                <div class="w-full space-y-6">
                    
                    <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3.5 rounded-xl shadow-sm mb-2" Visible="false"></asp:Label>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="bg-white border border-[#EBEBE9] rounded-2xl p-5 flex items-center gap-4 shadow-sm w-full">
                            <div class="w-10 h-10 rounded-xl bg-zinc-100 flex items-center justify-center text-lg">👥</div>
                            <div>
                                <p class="text-[10px] font-bold text-zinc-400 uppercase tracking-wider">Class Cohort Size</p>
                                <h3 class="text-xl font-bold text-zinc-800"><asp:Literal ID="litTotalStudents" runat="server" Text="0"></asp:Literal> <span class="text-xs font-medium text-zinc-400">Enrolled</span></h3>
                            </div>
                        </div>

                        <div class="bg-white border border-[#EBEBE9] rounded-2xl p-5 flex items-center gap-4 shadow-sm w-full">
                            <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-lg">✔️</div>
                            <div>
                                <p class="text-[10px] font-bold text-zinc-400 uppercase tracking-wider">Attendance Rate</p>
                                <h3 class="text-xl font-bold text-zinc-800"><asp:Literal ID="litAttendanceRate" runat="server" Text="0.0%"></asp:Literal> <span class="text-xs font-medium text-emerald-600 font-sans"><asp:Literal ID="litAttendBracket" runat="server" Text="(0 attend)"></asp:Literal></span></h3>
                            </div>
                        </div>

                        <div class="bg-white border border-[#EBEBE9] rounded-2xl p-5 flex items-center gap-4 shadow-sm w-full">
                            <div class="w-10 h-10 rounded-xl bg-red-50 text-red-600 flex items-center justify-center text-lg">❌</div>
                            <div>
                                <p class="text-[10px] font-bold text-zinc-400 uppercase tracking-wider">Total Absenteeism</p>
                                <h3 class="text-xl font-bold text-zinc-800"><asp:Literal ID="litTotalAbsent" runat="server" Text="0"></asp:Literal> <span class="text-xs font-medium text-red-500">Absent Logs</span></h3>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white rounded-2xl border border-[#EBEBE9] shadow-sm overflow-hidden w-full">
                        <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="False" CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                            <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase tracking-wider border-b border-[#EBEBE9]" />
                            <RowStyle CssClass="border-b border-[#F1F1EF] hover:bg-[#FBFBFA]/70 transition-colors text-[#2F2F2F]" />
                            <Columns>
                                <asp:BoundField DataField="StudentRoleID" HeaderText="Student ID" 
                                    HeaderStyle-CssClass="p-4 w-32 text-[10px] text-center select-none" ItemStyle-CssClass="p-4 text-center font-bold text-zinc-700 w-32" />
                                
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

                                <asp:BoundField DataField="StudentName" HeaderText="Full Registered Name" 
                                    HeaderStyle-CssClass="p-4 text-center text-[10px]" ItemStyle-CssClass="p-4 font-semibold text-zinc-800 text-center" />
                                
                                <asp:TemplateField HeaderText="Attendance Status" HeaderStyle-CssClass="p-4 text-center text-[10px]">
                                    <ItemTemplate>
                                        <div class="flex items-center justify-center w-full">
                                            <span class='<%# Convert.ToString(Eval("AttendanceStatus")) == "Present" ? "bg-emerald-50 text-emerald-700 border-emerald-200" : 
                                                               Convert.ToString(Eval("AttendanceStatus")) == "Late" ? "bg-yellow-50 text-yellow-800 border-yellow-200" : 
                                                               "bg-red-50 text-red-700 border-red-200" %> px-3 py-1 text-[10px] font-bold rounded-full border shadow-sm uppercase tracking-wider select-none inline-block'>
                                                <%# Eval("AttendanceStatus") %>
                                            </span>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center py-16 text-zinc-400 font-medium space-y-2">
                                    <div class="text-3xl"> 📋</div>
                                    <p class="text-xs text-[#9A9996]">No attendance records discovered matching the selection parameters above.</p>
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