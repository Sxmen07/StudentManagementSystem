<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageEnrollment.aspx.cs" Inherits="StudentManagementSystem.ManageEnrollment" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Enrollment Capacity Monitor</title>
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
            
            <div class="bg-white border-b border-[#EBEBE9] px-12 py-5 flex items-center justify-between shrink-0">
                <div>
                    <h2 class="text-xl font-bold text-[#111625] tracking-tight">Course Enrollment Controls</h2>
                    <p class="text-[#7C7B77] text-xs mt-0.5">Deploy available modules, activate intake terms, and authorize lecturer section allocations.</p>
                </div>
                
                <div class="flex items-center gap-2">
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

            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar">
                <div class="w-full space-y-6">
                    
                    <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium p-3.5 rounded-xl shadow-sm mb-2" Visible="false"></asp:Label>

                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
                        
                        <div class="bg-[#F7F7F5] border border-[#EBEBE9] p-6 rounded-2xl shadow-sm space-y-4">
                            <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-[#EBEBE9] pb-2">Deploy Active Offer Slot</h3>
                            
                            <div class="space-y-3.5 text-xs">
                                <div>
                                    <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Target Hosting School</label>
                                    <asp:DropDownList ID="ddlSchool" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSchool_SelectedIndexChanged"
                                        CssClass="w-full bg-white p-2.5 rounded-xl border border-[#EBEBE9] outline-none font-semibold cursor-pointer text-zinc-700 shadow-sm"></asp:DropDownList>
                                </div>

                                <div>
                                    <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Associated Academic Program</label>
                                    <asp:DropDownList ID="ddlProgram" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProgram_SelectedIndexChanged"
                                        CssClass="w-full bg-white p-2.5 rounded-xl border border-[#EBEBE9] outline-none font-semibold cursor-pointer text-zinc-700 shadow-sm"></asp:DropDownList>
                                </div>

                                <div>
                                    <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Curriculum Course Module</label>
                                    <asp:DropDownList ID="ddlCourse" runat="server"
                                        CssClass="w-full bg-white p-2.5 rounded-xl border border-[#EBEBE9] outline-none font-semibold cursor-pointer text-zinc-700 shadow-sm"></asp:DropDownList>
                                </div>

                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Intake Semester</label>
                                        <asp:DropDownList ID="ddlSemester" runat="server"
                                            CssClass="w-full bg-white p-2.5 rounded-xl border border-[#EBEBE9] outline-none font-semibold cursor-pointer text-zinc-700 shadow-sm"></asp:DropDownList>
                                    </div>
                                    <div>
                                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Max Intake Seats</label>
                                        <asp:TextBox ID="txtMaxCapacity" runat="server" TextMode="Number" Text="40" min="1" max="200"
                                            CssClass="w-full bg-white p-2.5 rounded-xl border border-[#EBEBE9] outline-none font-bold text-zinc-700 shadow-sm font-sans"></asp:TextBox>
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1">Authorized Academic Lecturer</label>
                                    <asp:DropDownList ID="ddlLecturer" runat="server"
                                        CssClass="w-full bg-white p-2.5 rounded-xl border border-[#EBEBE9] outline-none font-semibold cursor-pointer text-zinc-700 shadow-sm"></asp:DropDownList>
                                </div>

                                <div class="pt-2">
                                    <asp:Button ID="btnOpenEnrollment" runat="server" Text="Deploy & Open Enrollment" OnClick="btnOpenEnrollment_Click"
                                        CssClass="w-full bg-zinc-950 hover:bg-zinc-800 text-white font-bold py-2.5 rounded-xl transition-colors cursor-pointer shadow-md text-center" />
                                </div>
                            </div>
                        </div>

                        <div class="lg:col-span-2 bg-white border border-[#EBEBE9] rounded-2xl p-6 shadow-sm space-y-4 w-full">
                            
                            <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-3 flex flex-wrap items-center gap-3 text-xs font-medium w-full">
                                <span class="text-[10px] font-bold text-zinc-400 uppercase tracking-wider"><i class="fa-solid fa-filter"></i> Sort Registry:</span>
                                
                                <div class="flex items-center gap-1 bg-white border border-[#EBEBE9] px-2.5 py-1 rounded-lg shadow-sm">
                                    <span class="text-[9px] text-zinc-400 uppercase font-bold">School:</span>
                                    <asp:DropDownList ID="ddlSortSchool" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSortSchool_SelectedIndexChanged" CssClass="outline-none cursor-pointer font-bold text-zinc-700 bg-transparent"></asp:DropDownList>
                                </div>

                                <div class="flex items-center gap-1 bg-white border border-[#EBEBE9] px-2.5 py-1 rounded-lg shadow-sm">
                                    <span class="text-[9px] text-zinc-400 uppercase font-bold">Program:</span>
                                    <asp:DropDownList ID="ddlSortProgram" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSortProgram_SelectedIndexChanged" CssClass="outline-none cursor-pointer font-bold text-zinc-700 bg-transparent"></asp:DropDownList>
                                </div>

                                <div class="flex items-center gap-1 bg-white border border-[#EBEBE9] px-2.5 py-1 rounded-lg shadow-sm">
                                    <span class="text-[9px] text-zinc-400 uppercase font-bold">Lecturer:</span>
                                    <asp:DropDownList ID="ddlSortLecturer" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSortLecturer_SelectedIndexChanged" CssClass="outline-none cursor-pointer font-bold text-zinc-700 bg-transparent"></asp:DropDownList>
                                </div>
                            </div>

                            <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-zinc-100 pb-2">Active Deployment Pipeline Registry</h3>
                            
                            <div class="overflow-hidden rounded-xl border border-[#EBEBE9] w-full">
                                <asp:GridView ID="gvCourseOffers" runat="server" AutoGenerateColumns="False" DataKeyNames="CourseOfferID" 
                                    OnRowCommand="gvCourseOffers_RowCommand" OnRowEditing="gvCourseOffers_RowEditing" 
                                    OnRowCancelingEdit="gvCourseOffers_RowCancelingEdit" OnRowUpdating="gvCourseOffers_RowUpdating"
                                    OnRowDataBound="gvCourseOffers_RowDataBound"
                                    CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                                    <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase tracking-wider border-b border-[#EBEBE9]" />
                                    <RowStyle CssClass="border-b border-[#F1F1EF] hover:bg-[#FBFBFA]/70 transition-colors text-[#2F2F2F]" />
                                    <Columns>
                                        
                                        <asp:TemplateField HeaderText="Module Specification Details" HeaderStyle-CssClass="p-4 text-[10px] text-left" ItemStyle-CssClass="p-4 text-left font-sans">
                                            <ItemTemplate>
                                                <div class="flex flex-col gap-0.5 max-w-xs truncate">
                                                    <span class="font-bold text-zinc-800 text-xs truncate">[<%# Eval("CourseCode") %>] <%# Eval("CourseName") %></span>
                                                    <span class="text-[10px] text-zinc-400 font-semibold uppercase tracking-wide truncate"><%# Eval("ProgrammeName") %></span>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:BoundField DataField="Semester" HeaderText="Semester" ReadOnly="true"
                                            HeaderStyle-CssClass="p-4 text-center text-[10px] w-24" ItemStyle-CssClass="p-4 text-center font-bold text-zinc-600 font-sans w-24" />

                                        <asp:TemplateField HeaderText="Assigned Lecturer" HeaderStyle-CssClass="p-4 text-center text-[10px] w-44" ItemStyle-CssClass="p-4 text-center w-44">
                                            <ItemTemplate>
                                                <span class="font-medium text-zinc-600"><%# Eval("LecturerName") %></span>
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <div class="flex justify-center w-full px-1">
                                                    <asp:DropDownList ID="ddlGridLecturer" runat="server" CssClass="w-full bg-zinc-50 p-1.5 rounded-lg border border-zinc-300 text-[11px] font-semibold text-zinc-700 shadow-inner cursor-pointer"></asp:DropDownList>
                                                    <asp:HiddenField ID="hfHiddenLecturerID" runat="server" Value='<%# Eval("LecturerID") %>' />
                                                </div>
                                            </EditItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Enrolment Capacity Stats" HeaderStyle-CssClass="p-4 text-center text-[10px] w-48" ItemStyle-CssClass="p-4 text-center w-48">
                                            <ItemTemplate>
                                                <div class="flex flex-col items-center justify-center gap-1 mx-auto text-center w-full">
                                                    <div class="w-24 bg-zinc-100 rounded-full h-1.5 overflow-hidden border border-zinc-200/60 shadow-inner">
                                                        <div class='<%# Convert.ToDouble(Eval("TotalEnrolled")) * 100.0 / Convert.ToDouble(Eval("MaxCapacity")) >= 90.0 ? "bg-red-400" : "bg-emerald-400" %> h-full'
                                                             style='width: <%# Math.Min(100.0, Convert.ToDouble(Eval("TotalEnrolled")) * 100.0 / Convert.ToDouble(Eval("MaxCapacity"))).ToString("0.0") %>%;'></div>
                                                    </div>
                                                    <span class="text-[10px] font-bold text-zinc-700 font-sans block">
                                                        <%# Eval("TotalEnrolled") %> / <%# Eval("MaxCapacity") %> Seats (<%# (Convert.ToDouble(Eval("TotalEnrolled")) * 100.0 / Convert.ToDouble(Eval("MaxCapacity"))).ToString("0.0") %>%)
                                                    </span>
                                                    <span class="text-[9px] font-semibold text-zinc-400 font-sans block">
                                                        <%# Convert.ToInt32(Eval("MaxCapacity")) - Convert.ToInt32(Eval("TotalEnrolled")) %> spaces left
                                                    </span>
                                                </div>
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <div class="flex flex-col items-center justify-center gap-1 mx-auto text-center w-full">
                                                    <asp:TextBox ID="txtGridMaxCapacity" runat="server" Text='<%# Eval("MaxCapacity") %>' TextMode="Number" min="1" max="200"
                                                        CssClass="w-16 bg-zinc-50 p-1 rounded-lg border border-zinc-300 text-center font-bold text-zinc-700 text-xs shadow-inner font-sans"></asp:TextBox>
                                                </div>
                                            </EditItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Actions Console" HeaderStyle-CssClass="p-4 text-center text-[10px] w-36 pr-4" ItemStyle-CssClass="p-4 text-center w-36 pr-4">
                                            <ItemTemplate>
                                                <div class="flex flex-col gap-1 items-center justify-center w-full">
                                                    <asp:LinkButton ID="lnkEditOffer" runat="server" CommandName="Edit"
                                                        CssClass="text-blue-600 hover:text-blue-800 text-[11px] font-bold transition-colors cursor-pointer shadow-none">
                                                        <i class="fa-solid fa-pen-to-square"></i> Edit Offer
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="lnkDeleteOffer" runat="server" CommandName="CloseOffer" CommandArgument='<%# Eval("CourseOfferID") %>'
                                                        CssClass="text-red-500 hover:text-red-700 text-[10px] font-bold transition-colors cursor-pointer uppercase tracking-wider">
                                                        Drop Offer
                                                    </asp:LinkButton>
                                                </div>
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <div class="flex flex-col gap-1 items-center justify-center w-full">
                                                    <asp:LinkButton ID="lnkUpdateOffer" runat="server" CommandName="Update"
                                                        CssClass="bg-zinc-950 text-white font-bold px-3 py-1 rounded-lg text-[10px] hover:bg-zinc-800 shadow-sm transition-all cursor-pointer">
                                                        Save
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="lnkCancelOffer" runat="server" CommandName="Cancel"
                                                        CssClass="bg-white border border-zinc-300 text-zinc-600 font-semibold px-2.5 py-1 rounded-lg text-[10px] hover:bg-zinc-50 shadow-sm transition-all cursor-pointer">
                                                        Cancel
                                                    </asp:LinkButton>
                                                </div>
                                            </EditItemTemplate>
                                        </asp:TemplateField>
                                        
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="text-center py-16 text-zinc-400 font-medium space-y-2 w-full">
                                            <span class="text-2xl block">🌐</span>
                                            <p class="text-xs text-[#9A9996]">No active deployment logs detected matching current filtering criteria.</p>
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </form>
</body>
</html>