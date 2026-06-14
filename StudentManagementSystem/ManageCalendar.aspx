<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageCalendar.aspx.cs" Inherits="StudentManagementSystem.ManageCalendar" %>
<%@ Import Namespace="StudentManagementSystem" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Academic Calendar Registry</title>
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
        
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <div class="bg-white border-b border-[#EBEBE9] px-12 py-5 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 shrink-0">
                <div>
                    <h2 class="text-xl font-bold text-[#111625] tracking-tight">Academic Calendar</h2>
                    <p class="text-[#7C7B77] text-xs mt-0.5">Plan single or multi-day institutional milestones, assign statutory holidays, and export records.</p>
                </div>
                
                <div class="flex flex-wrap items-center gap-2">
                    <div class="flex items-center gap-2 bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl px-3 py-1.5 shadow-sm">
                        <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Active Term:</span>
                        <asp:DropDownList ID="ddlSemesterFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSemesterFilter_SelectedIndexChanged"
                            CssClass="bg-transparent text-xs font-semibold text-[#2F2F2F] outline-none cursor-pointer pr-1">
                        </asp:DropDownList>
                    </div>

                    <asp:LinkButton ID="btnExportCSV" runat="server" OnClick="btnExportCSV_Click" title="Export CSV"
                        CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 p-2.5 rounded-xl shadow-sm text-xs font-semibold transition-all">
                        <i class="fa-solid fa-file-csv text-zinc-500"></i> CSV
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportExcel" runat="server" OnClick="btnExportExcel_Click" title="Export Excel"
                        CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 p-2.5 rounded-xl shadow-sm text-xs font-semibold transition-all">
                        <i class="fa-solid fa-file-excel text-emerald-600"></i> Excel
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportPDF" runat="server" OnClick="btnExportPDF_Click" title="Export PDF"
                        CssClass="bg-white border border-[#EBEBE9] text-zinc-700 hover:bg-zinc-50 p-2.5 rounded-xl shadow-sm text-xs font-semibold transition-all">
                        <i class="fa-solid fa-file-pdf text-red-600"></i> PDF
                    </asp:LinkButton>
                </div>
            </div>

            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar">
                <div class="w-full space-y-6">
                    
                    <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3 rounded-xl shadow-sm" Visible="false"></asp:Label>

                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
                        
                        <div class="lg:col-span-2 bg-white border border-[#EBEBE9] rounded-2xl shadow-sm overflow-hidden p-6 space-y-4">
                            
                            <div class="flex items-center justify-between border-b border-zinc-100 pb-4">
                                <asp:LinkButton ID="btnPrevMonth" runat="server" OnClick="btnPrevMonth_Click" CssClass="text-zinc-500 hover:text-zinc-900 font-bold p-1">&larr; Previous</asp:LinkButton>
                                <h3 class="text-sm font-bold text-zinc-800 uppercase tracking-wider">
                                    <asp:Literal ID="litCurrentMonthYear" runat="server"></asp:Literal>
                                </h3>
                                <asp:LinkButton ID="btnNextMonth" runat="server" OnClick="btnNextMonth_Click" CssClass="text-zinc-500 hover:text-zinc-900 font-bold p-1">Next &rarr;</asp:LinkButton>
                            </div>

                            <div class="grid grid-cols-7 gap-1 text-center font-bold text-[10px] text-zinc-400 uppercase tracking-widest py-1">
                                <div>Sun</div><div>Mon</div><div>Tue</div><div>Wed</div><div>Thu</div><div>Fri</div><div>Sat</div>
                            </div>

                            <div class="grid grid-cols-7 gap-1.5 min-h-[320px]">
                                <asp:Repeater ID="rptCalendarCells" runat="server" OnItemCommand="rptCalendarCells_ItemCommand">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkSelectDay" runat="server" CommandName="SelectDay" CommandArgument='<%# Eval("FullDateString") %>' Enabled='<%# Eval("IsCurrentMonth") %>'
                                            CssClass='<%# "p-2 rounded-xl border flex flex-col justify-between items-start min-h-[64px] transition-all cursor-pointer group text-left " + 
                                                          (Convert.ToBoolean(Eval("IsCurrentMonth")) ? "bg-zinc-50/40 border-zinc-100 hover:border-zinc-400 hover:bg-white" : "bg-zinc-100/20 border-transparent text-zinc-300 pointer-events-none") %>'>
                                            
                                            <span class='<%# "text-xs font-bold " + (Convert.ToBoolean(Eval("IsToday")) ? "bg-zinc-950 text-white w-5 h-5 rounded-full flex items-center justify-center shadow-sm" : "text-zinc-600") %>'>
                                                <%# Eval("DayNumber") %>
                                            </span>

                                            <div class="w-full mt-1.5 space-y-1 overflow-hidden">
                                                <asp:Repeater ID="rptCellEvents" runat="server" DataSource='<%# Eval("CellEventsList") %>'>
                                                    <ItemTemplate>
                                                        <div style='background-color: <%# Eval("HexColor").ToString() == "#3B82F6" ? "#EFF6FF" : 
                                                                                      Eval("HexColor").ToString() == "#EAB308" ? "#FEF9C3" : 
                                                                                      Eval("HexColor").ToString() == "#EF4444" ? "#FEE2E2" : "#ECFDF5" %>; 
                                                                     color: <%# Eval("HexColor").ToString() == "#3B82F6" ? "#1E40AF" : 
                                                                            Eval("HexColor").ToString() == "#EAB308" ? "#854D0E" : 
                                                                            Eval("HexColor").ToString() == "#EF4444" ? "#991B1B" : "#065F46" %>; 
                                                                     border: 1px solid <%# Eval("HexColor").ToString() == "#3B82F6" ? "#BFDBFE" : 
                                                                                             Eval("HexColor").ToString() == "#EAB308" ? "#FEF08A" : 
                                                                                             Eval("HexColor").ToString() == "#EF4444" ? "#FCA5A5" : "#A7F3D0" %>;'
                                                             class="text-[9px] font-bold px-1.5 py-0.5 rounded truncate max-w-full block shadow-sm select-none">
                                                            <%# Eval("EventName") %>
                                                        </div>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </div>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                        </div>

                        <div class="bg-white border border-[#EBEBE9] rounded-2xl shadow-sm p-6 space-y-4">
                            <div class="border-b border-zinc-100 pb-2">
                                <h4 class="text-xs font-bold text-zinc-800 uppercase tracking-wider flex items-center gap-1.5">
                                    <span>🗓️</span> <asp:Literal ID="litFormActionTitle" runat="server" Text="Schedule Planning Console"></asp:Literal>
                                </h4>
                                <asp:HiddenField ID="hfActiveEventID" runat="server" />
                            </div>

                            <div class="space-y-3.5 text-xs">
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <label class="block text-[10px] font-bold text-zinc-400 uppercase tracking-wider mb-1">Start Date</label>
                                        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="w-full bg-zinc-50 p-2 rounded-xl border border-zinc-200 outline-none focus:border-zinc-950 font-medium font-sans text-zinc-700"></asp:TextBox>
                                    </div>
                                    <div>
                                        <label class="block text-[10px] font-bold text-zinc-400 uppercase tracking-wider mb-1">End Date (Optional)</label>
                                        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="w-full bg-zinc-50 p-2 rounded-xl border border-zinc-200 outline-none focus:border-zinc-950 font-medium font-sans text-zinc-700" placeholder="Single day if blank"></asp:TextBox>
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-[10px] font-bold text-zinc-400 uppercase tracking-wider mb-1">Event Header Title</label>
                                    <asp:TextBox ID="txtEventName" runat="server" CssClass="w-full bg-zinc-50 p-2.5 rounded-xl border border-zinc-200 outline-none focus:border-zinc-950 font-medium text-zinc-700" placeholder="e.g., Mid-Term Examination Week..."></asp:TextBox>
                                </div>

                                <div>
                                    <label class="block text-[10px] font-bold text-zinc-400 uppercase tracking-wider mb-1">Event Classification Mapping Type</label>
                                    <asp:DropDownList ID="ddlColorType" runat="server" CssClass="w-full bg-white p-2.5 rounded-xl border border-zinc-200 font-semibold cursor-pointer outline-none text-zinc-700">
                                        <asp:ListItem Value="#3B82F6">Standard Academic Milestone (Blue)</asp:ListItem>
                                        <asp:ListItem Value="#EAB308">Public Holiday / Closure Day (Yellow)</asp:ListItem>
                                        <asp:ListItem Value="#EF4444">Critical Examination Period (Red)</asp:ListItem>
                                        <asp:ListItem Value="#10B981">System Event / Activity Layer (Green)</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div>
                                    <label class="block text-[10px] font-bold text-zinc-400 uppercase tracking-wider mb-1">Description / Guidelines Summary</label>
                                    <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="w-full bg-zinc-50 p-2.5 rounded-xl border border-zinc-200 outline-none focus:border-zinc-950 font-medium resize-none text-zinc-700" placeholder="Enter scheduling details here..."></asp:TextBox>
                                </div>

                                <div class="pt-2">
                                    <asp:Button ID="btnSaveEvent" runat="server" Text="Commit Schedule" OnClick="btnSaveEvent_Click"
                                        CssClass="w-full bg-zinc-950 text-white font-bold py-2.5 rounded-xl hover:bg-zinc-800 transition-all cursor-pointer shadow-sm mb-2" />
                                    
                                    <asp:Button ID="btnDeleteEvent" runat="server" Text="Delete Scheduled Range" OnClick="btnDeleteEvent_Click" Visible="false" 
                                        OnClientClick="return confirm('Purge this date event configuration permanently? If a date range is given, ALL matching instances in that window will be deleted.');"
                                        CssClass="w-full bg-red-50 border border-red-200 text-red-600 font-bold py-2.5 rounded-xl hover:bg-red-100 text-xs transition-all cursor-pointer shadow-sm" />
                                </div>
                            </div>

                            <div class="pt-2 border-t border-zinc-100">
                                <h5 class="text-[10px] font-bold text-zinc-400 uppercase tracking-wider mb-2">Events For Selected Day:</h5>
                                <div class="space-y-1.5 max-h-[120px] overflow-y-auto custom-scrollbar">
                                    <asp:Repeater ID="rptDayAgenda" runat="server" OnItemCommand="rptDayAgenda_ItemCommand">
                                        <ItemTemplate>
                                            <div class="p-2.5 bg-zinc-50 border border-zinc-100 rounded-xl flex items-center justify-between text-xs gap-3">
                                                <div class="flex items-center gap-2 truncate">
                                                    <span style='background-color: <%# Eval("HexColor") %>;' class="w-2 h-2 rounded-full shrink-0"></span>
                                                    <span class="font-bold text-zinc-800 truncate"><%# Eval("EventName") %></span>
                                                </div>
                                                <asp:LinkButton ID="lnkSelectAgenda" runat="server" CommandName="SelectEvent" CommandArgument='<%# Eval("EventID") %>'
                                                    CssClass="text-blue-600 hover:text-blue-800 font-bold text-[11px] shrink-0">Edit</asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            <asp:Panel runat="server" Visible='<%# rptDayAgenda.Items.Count == 0 %>' class="text-zinc-400 py-3 text-center font-medium text-[11px]">
                                                No events logged on this date cell.
                                            </asp:Panel>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>

                        </div>
                    </div>

                </div>
            </div>

        </div>
    </form>
</body>
</html>