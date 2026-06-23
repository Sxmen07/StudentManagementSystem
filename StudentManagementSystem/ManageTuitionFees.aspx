<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageTuitionFees.aspx.cs" Inherits="StudentManagementSystem.ManageTuitionFees" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Tuition Pricing Workspace</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #EBEBE9; border-radius: 10px; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <div class="relative bg-[#FFFDF0] border-b border-[#EBEBE9] px-12 py-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 shrink-0 overflow-hidden">
                <div class="absolute inset-0 pointer-events-none select-none opacity-20">
                    <svg class="w-full h-full" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="-10" cy="50%" r="55" fill="none" stroke="#FBBF24" stroke-width="4" />
                        <circle cx="92%" cy="30%" r="65" fill="none" stroke="#F97316" stroke-width="8" />
                        <circle cx="96%" cy="65%" r="45" fill="none" stroke="#FBBF24" stroke-width="3" stroke-dasharray="4 4" />
                    </svg>
                </div>

                <div class="relative z-10 flex items-center gap-4">
                    <div class="bg-[#F97316]/10 text-[#F97316] p-3 rounded-2xl border border-[#F97316]/20 shadow-sm flex items-center justify-center shrink-0">
                        <i class="fa-solid fa-file-invoice-dollar text-lg"></i>
                    </div>
                    <div>
                        <h2 class="text-xl font-bold text-[#111625] tracking-tight">Tuition & Fee Control Terminal</h2>
                        <p class="text-[#7C7B77] text-xs mt-0.5 font-medium">Manage base program course rates, evaluate outstanding student balance parameters, and review system invoices.</p>
                    </div>
                </div>
            </div>

            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar">
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 items-stretch w-full">
                    
                    <div class="flex flex-col gap-6 h-full">
                        
                        <div class="bg-white border border-[#EBEBE9] rounded-2xl p-6 shadow-sm space-y-4 shrink-0">
                            <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-[#F1F1EF] pb-2">Set Program Base Rates</h3>
                            <asp:Label ID="lblPriceStatus" runat="server" CssClass="block text-xs font-medium p-2.5 rounded-xl bg-zinc-50 border border-zinc-100" Visible="false"></asp:Label>
                            <asp:HiddenField ID="hfSelectedProgCode" runat="server" />
                            
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Select Academic Programme</label>
                                    <asp:DropDownList ID="ddlProgrammes" runat="server" CssClass="w-full bg-[#F7F7F5] p-2.5 text-xs rounded-xl border border-[#EBEBE9] font-semibold outline-none cursor-pointer"></asp:DropDownList>
                                </div>
                                <div>
                                    <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Price Rate / Subject (RM)</label>
                                    <asp:TextBox ID="txtPricePerCourse" runat="server" CssClass="w-full bg-[#F7F7F5] p-2.5 text-xs rounded-xl border border-[#EBEBE9] outline-none font-medium" placeholder="0.00"></asp:TextBox>
                                </div>
                            </div>
                            <div class="flex justify-end gap-2 pt-2">
                                <asp:Button ID="btnCancelEdit" runat="server" Text="Discard" OnClick="btnCancelEdit_Click" Visible="false" CssClass="bg-white border border-[#EBEBE9] text-zinc-600 font-bold text-xs px-4 py-2 rounded-xl" />
                                <asp:Button ID="btnUpdatePrice" runat="server" Text="Update Pricing Rate" OnClick="btnUpdatePrice_Click" CssClass="bg-zinc-950 text-white font-bold text-xs px-5 py-2 rounded-xl hover:bg-zinc-800 shadow-sm" />
                            </div>
                        </div>

                        <div class="bg-white border border-[#EBEBE9] rounded-2xl p-6 shadow-sm space-y-4 flex-1 flex flex-col justify-between overflow-hidden">
                            <div class="space-y-4">
                                <div class="flex items-center justify-between border-b border-[#EBEBE9] pb-3">
                                    <span class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider">Programme Pricing Index</span>
                                    <div class="flex items-center gap-3">
                                        <asp:DropDownList ID="ddlSortFaculty" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSortFaculty_SelectedIndexChanged" CssClass="bg-[#F7F7F5] border border-[#EBEBE9] p-1.5 text-[11px] font-bold rounded-xl outline-none text-[#2F2F2F] cursor-pointer"></asp:DropDownList>
                                        <div class="inline-flex rounded-xl border border-zinc-200 p-0.5 bg-white shadow-sm gap-0.5">
                                            <asp:LinkButton ID="lnkExportCSV" runat="server" OnClick="lnkExportCSV_Click" CssClass="p-1.5 text-zinc-500 hover:text-zinc-950" ToolTip="CSV"><i class="fa-solid fa-file-csv text-sm"></i></asp:LinkButton>
                                            <asp:LinkButton ID="lnkExportExcel" runat="server" OnClick="lnkExportExcel_Click" CssClass="p-1.5 text-zinc-500 hover:text-zinc-950" ToolTip="Excel"><i class="fa-solid fa-file-excel text-sm"></i></asp:LinkButton>
                                            <asp:LinkButton ID="lnkExportPDF" runat="server" OnClick="lnkExportPDF_Click" CssClass="p-1.5 text-zinc-500 hover:text-zinc-950" ToolTip="Export to PDF Report"><i class="fa-solid fa-file-pdf text-sm"></i></asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="rounded-xl border border-[#EBEBE9] overflow-hidden overflow-y-auto custom-scrollbar max-h-[300px]">
                                    <asp:GridView ID="gvProgPricingList" runat="server" AutoGenerateColumns="False" DataKeyNames="ProgrammeCode" OnRowCommand="gvProgPricingList_RowCommand" CssClass="w-full text-left text-xs border-collapse font-sans" GridLines="None">
                                        <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase text-[10px] border-b border-[#EBEBE9]" />
                                        <RowStyle CssClass="border-b border-[#F1F1EF] hover:bg-[#FBFBFA]/70 text-[#2F2F2F]" />
                                        <Columns>
                                            
                                            <asp:TemplateField HeaderText="Code" HeaderStyle-CssClass="p-4 w-1/5" ItemStyle-CssClass="p-4 font-bold text-zinc-900 w-1/5 align-middle">
                                                <ItemTemplate>
                                                    <%# Eval("ProgrammeCode") %>
                                                </ItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Programme Name" HeaderStyle-CssClass="p-4 w-3/5" ItemStyle-CssClass="p-4 font-semibold text-zinc-800 w-3/5 align-middle">
                                                <ItemTemplate>
                                                    <%# Eval("ProgrammeName") %>
                                                </ItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Price/Subject" HeaderStyle-CssClass="p-4 w-1/5 text-right pr-6" ItemStyle-CssClass="p-4 text-right font-bold text-zinc-700 w-1/5 align-middle pr-6">
                                                <ItemTemplate>
                                                    <%# String.Format("RM {0:N2}", Eval("PricePerCourse")) %>
                                                </ItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="p-4 text-center w-12" ItemStyle-CssClass="p-4 text-center w-12 align-middle">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkSelectPrice" runat="server" CommandName="SelectPrice" CommandArgument='<%# Eval("ProgrammeCode") %>' CssClass="text-blue-500 hover:text-blue-700 font-semibold inline-flex items-center justify-center"><i class="fa-solid fa-pen-to-square text-sm"></i></asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateField>

                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white border border-[#EBEBE9] rounded-2xl p-6 shadow-sm flex flex-col justify-between h-full min-h-[500px]">
                        <div class="space-y-6 flex-1 flex flex-col justify-start">
                            <div>
                                <h3 class="text-xs font-bold text-[#1A1A1A] uppercase tracking-wider border-b border-[#F1F1EF] pb-2.5">Evaluate Individual Student Account</h3>
                                <p class="text-[11px] text-zinc-400 mt-1">Audit terms, enrollment logs, and session fees directly from your connected indexes.</p>
                            </div>
                            
                            <div class="grid grid-cols-1 sm:grid-cols-12 gap-4 items-end bg-[#F7F7F5] p-4 rounded-xl border border-[#EBEBE9] shrink-0">
                                <div class="sm:col-span-8">
                                    <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider mb-1.5">Enter Student Account ID Reference</label>
                                    <asp:TextBox ID="txtSearchStudentID" runat="server" CssClass="w-full bg-white p-3 text-xs rounded-xl border border-[#EBEBE9] font-bold outline-none uppercase shadow-sm" placeholder="e.g., S1001"></asp:TextBox>
                                </div>
                                <div class="sm:col-span-4">
                                    <asp:Button ID="btnCalculateAdminBilling" runat="server" Text="Fetch Account Profile" OnClick="btnCalculateAdminBilling_Click" CssClass="w-full bg-zinc-950 text-white font-bold text-xs py-3 rounded-xl hover:bg-zinc-800 transition-colors cursor-pointer shadow-sm text-center" />
                                </div>
                            </div>
                            <asp:Label ID="lblAdminBillStatus" runat="server" CssClass="block text-xs font-medium p-3.5 rounded-xl bg-red-50 border border-red-100 text-red-600" Visible="false"></asp:Label>

                            <asp:Panel ID="pnlAdminInvoiceStatementView" runat="server" Visible="false" class="space-y-6 pt-2 flex-1 flex flex-col justify-between">
                                <div class="space-y-6">
                                    <div class="grid grid-cols-2 gap-x-6 gap-y-4 text-xs bg-zinc-50/60 p-5 rounded-xl border border-[#EBEBE9]">
                                        <div>
                                            <p class="text-[#7C7B77] font-medium tracking-tight">Student Name</p>
                                            <p class="font-bold text-zinc-900 text-sm mt-0.5"><asp:Literal ID="litInvoiceStudentName" runat="server"></asp:Literal></p>
                                        </div>
                                        <div>
                                            <p class="text-[#7C7B77] font-medium tracking-tight">System Identifier</p>
                                            <p class="font-bold text-zinc-800 mt-0.5"><asp:Literal ID="litInvoiceDisplayID" runat="server"></asp:Literal></p>
                                        </div>
                                        <div>
                                            <p class="text-[#7C7B77] font-medium tracking-tight">Active Session Term & Year</p>
                                            <p class="font-semibold text-zinc-800 mt-0.5"><asp:Literal ID="litInvoiceSemester" runat="server"></asp:Literal></p>
                                        </div>
                                        <div>
                                            <p class="text-[#7C7B77] font-medium tracking-tight">Payment Ledger Status</p>
                                            <div class="mt-1">
                                                <span class="inline-block px-3 py-1 rounded-full font-bold text-[10px] uppercase tracking-wider border shadow-sm"><asp:Literal ID="litInvoicePaymentStatus" runat="server"></asp:Literal></span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="space-y-2">
                                        <label class="block text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Registered Syllabus Course Options for Session Time</label>
                                        <div class="rounded-xl border border-[#EBEBE9] overflow-hidden max-h-[160px] overflow-y-auto custom-scrollbar">
                                            <asp:GridView ID="gvInvoiceItems" runat="server" AutoGenerateColumns="False" CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                                                <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold p-3 border-b border-[#EBEBE9]" />
                                                <RowStyle CssClass="border-b border-[#F1F1EF] text-[#2F2F2F]" />
                                                <Columns>
                                                    <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="p-3 font-bold text-zinc-400 w-28" />
                                                    <asp:BoundField DataField="CourseName" HeaderText="Module Description Track" ItemStyle-CssClass="p-3 font-medium text-zinc-800" />
                                                    <asp:BoundField DataField="UnitPrice" HeaderText="Rate" DataFormatString="RM {0:N2}" ItemStyle-CssClass="p-3 text-right font-semibold text-zinc-600 w-28" HeaderStyle-CssClass="text-right pr-3" />
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>
                                </div>

                                <div class="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-[#F1F1EF] shrink-0">
                                    <div class="text-center sm:text-left">
                                        <span class="text-[9px] font-bold text-[#7C7B77] uppercase tracking-wider block">Total Statement Value</span>
                                        <h3 class="text-2xl font-black text-zinc-950 tracking-tight">RM <asp:Literal ID="litInvoiceTotalAmount" runat="server">0.00</asp:Literal></h3>
                                    </div>
                                    <div class="flex items-center gap-3 w-full sm:w-auto">
                                        <asp:Button ID="btnMarkAsPaid" runat="server" Text="Mark As Paid" OnClick="btnMarkAsPaid_Click" CssClass="bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs px-5 py-3 rounded-xl shadow-sm transition-all cursor-pointer" />
                                        <asp:Button ID="btnGeneratePDFInvoice" runat="server" Text="Print Invoice Receipt" OnClick="btnGeneratePDFInvoice_Click" CssClass="bg-zinc-950 hover:bg-zinc-800 text-white font-bold text-xs px-5 py-3 rounded-xl shadow-sm transition-all cursor-pointer" />
                                    </div>
                                </div>
                            </asp:Panel>
                        </div>
                    </div>

                </div>
            </div>

        </div>
    </form>
</body>
</html>