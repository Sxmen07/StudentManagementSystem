<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentTuitionInvoices.aspx.cs" Inherits="StudentManagementSystem.StudentTuitionInvoices" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | My Financial Account Statements</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style type="text/css">body { font-family: 'Poppins', sans-serif; }</style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <uc:Navbar runat="server" ID="StudentSidebar" />

        <div class="flex-1 overflow-y-auto bg-[#FBFBFA] h-full flex flex-col">
            
            <div class="bg-white border-b border-[#EBEBE9] px-12 py-6 shrink-0 flex items-center justify-between">
                <div>
                    <h2 class="text-xl font-bold text-[#111625] tracking-tight">Personal Financial Statements</h2>
                    <p class="text-[#7C7B77] text-xs mt-0.5">Review active semester term enrollment breakdowns and download official fee receipts.</p>
                </div>
                
                <asp:LinkButton ID="lnkRecoverPrint" runat="server" OnClick="lnkRecoverPrint_Click"
                    CssClass="bg-zinc-950 hover:bg-zinc-800 text-white font-semibold text-xs px-4 py-2.5 rounded-xl shadow-sm flex items-center gap-2 cursor-pointer">
                    <i class="fa-solid fa-print text-[11px]"></i> <span>Re-print Active Invoice</span>
                </asp:LinkButton>
            </div>

            <div class="flex-1 px-12 py-8 overflow-y-auto custom-scrollbar">
                
                <asp:Label ID="lblStudentBillStatus" runat="server" CssClass="block text-xs font-medium p-4 rounded-xl max-w-2xl bg-zinc-100 text-zinc-500 font-semibold" Visible="false"></asp:Label>

                <asp:Panel ID="pnlStudentInvoiceView" runat="server" Visible="false" class="bg-white border border-[#EBEBE9] rounded-2xl p-8 shadow-sm max-w-3xl space-y-6">
                    <div class="flex justify-between items-start border-b border-[#F1F1EF] pb-5">
                        <div class="space-y-1">
                            <span class="text-emerald-600 text-[10px] font-bold uppercase tracking-wider bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-100">Verified Invoice Statement</span>
                            <h4 class="text-base font-bold text-zinc-900 pt-1"><asp:Literal ID="litStudentName" runat="server"></asp:Literal></h4>
                            <p class="text-xs text-zinc-400 font-medium">My Identity Code: <span class="text-zinc-700 font-bold"><asp:Literal ID="litStudentDisplayID" runat="server"></asp:Literal></span></p>
                        </div>
                        <div class="text-right text-xs text-zinc-400 space-y-0.5">
                            <p>Statement Date: <span class="text-zinc-800 font-semibold"><asp:Literal ID="litStudentDate" runat="server"></asp:Literal></span></p>
                            <p>Active Term Block: <span class="text-zinc-800 font-semibold"><asp:Literal ID="litStudentSemester" runat="server"></asp:Literal></span></p>
                            <p>Enrolled Programme Track: <span class="text-zinc-800 font-semibold"><asp:Literal ID="litStudentProg" runat="server"></asp:Literal></span></p>
                        </div>
                    </div>

                    <div class="rounded-xl border border-[#EBEBE9] overflow-hidden">
                        <asp:GridView ID="gvStudentInvoiceItems" runat="server" AutoGenerateColumns="False" class="w-full text-left text-xs border-collapse" GridLines="None">
                            <HeaderStyle CssClass="bg-[#F7F7F5] text-[#7C7B77] font-bold uppercase tracking-wider text-[10px] p-3" />
                            <RowStyle CssClass="border-b border-[#F1F1EF] text-[#2F2F2F]" />
                            <Columns>
                                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" HeaderStyle-CssClass="p-3" ItemStyle-CssClass="p-3 font-bold text-zinc-400 w-32" />
                                <asp:BoundField DataField="CourseName" HeaderText="Enrolled Syllabus Module Name" HeaderStyle-CssClass="p-3" ItemStyle-CssClass="p-3 font-semibold text-zinc-800" />
                                <asp:BoundField DataField="UnitPrice" HeaderText="Term Unit Pricing Rate" DataFormatString="RM {0:N2}" HeaderStyle-CssClass="p-3 text-right" ItemStyle-CssClass="p-3 text-right font-medium text-zinc-600 w-32" />
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="flex items-center justify-between pt-2 border-t border-[#F1F1EF]">
                        <p class="text-[11px] text-[#7C7B77] font-medium"><i class="fa-solid fa-circle-info text-blue-500"></i> Invoice generated automatically via account term registration links.</p>
                        <div class="text-right space-y-0.5">
                            <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Total Semester Balance Due</span>
                            <h3 class="text-2xl font-black text-zinc-950">RM <asp:Literal ID="litStudentTotalAmount" runat="server">0.00</asp:Literal></h3>
                        </div>
                    </div>
                </asp:Panel>

            </div>
        </div>
    </form>
</body>
</html>