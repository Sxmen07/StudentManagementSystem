<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TrackStudentGrades.aspx.cs" Inherits="StudentManagementSystem.TrackStudentGrades" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %> <!--REGISTER SIDEBAR -->

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full overflow-hidden">
<head runat="server">
    <title>UniTrack | Academic Performance Tracker</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        .grid-pager table { margin: 0 auto; }
        .grid-pager td { padding: 0 6px; }
        .grid-pager a { color: #7C7B77; font-size: 11px; text-decoration: none; font-weight: 500; }
        .grid-pager a:hover { color: #1A1A1A; text-decoration: underline; }
        .grid-pager span { color: #1A1A1A; font-size: 11px; font-weight: 700; border-bottom: 2px solid #1A1A1A; padding-bottom: 2px; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <!-- SIDEBAR HEREE -->
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 pl-20 pr-10 py-8 lg:pl-24 bg-white space-y-6 flex flex-col h-screen overflow-y-auto">
            <header class="border-b border-[#F1F1EF] pb-4 shrink-0 flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                <div>
                    <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Student Performance & Standing Tracker</h2>
                    <p class="text-[#7C7B77] text-sm">Monitor student grade averages, analyze risk thresholds, and manage scholastic status categories.</p>
                </div>
                
                <div class="flex flex-wrap items-center gap-3 bg-[#F7F7F5] border border-[#EBEBE9] p-2 rounded-lg h-fit">
                    <div class="flex items-center gap-1">
                        <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Status:</span>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged" CssClass="bg-white border border-[#EBEBE9] p-1 text-xs rounded font-medium outline-none cursor-pointer">
                            <asp:ListItem Value="All">All Standings</asp:ListItem>
                            <asp:ListItem Value="Normal">Normal Only</asp:ListItem>
                            <asp:ListItem Value="In Risk">In Risk Only</asp:ListItem>
                            <asp:ListItem Value="Warning">Warning Only</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="flex items-center gap-1">
                        <span class="text-[10px] font-bold text-[#7C7B77] uppercase tracking-wider">Sort By:</span>
                        <asp:DropDownList ID="ddlSortExpression" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSortExpression_SelectedIndexChanged" CssClass="bg-white border border-[#EBEBE9] p-1 text-xs rounded font-medium outline-none cursor-pointer">
                            <asp:ListItem Value="StudentName ASC">Name (A-Z)</asp:ListItem>
                            <asp:ListItem Value="StudentName DESC">Name (Z-A)</asp:ListItem>
                            <asp:ListItem Value="EstimatedCGPA DESC">CGPA (Highest)</asp:ListItem>
                            <asp:ListItem Value="EstimatedCGPA ASC">CGPA (Lowest)</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </header>

            <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium" Visible="false"></asp:Label>

            <div class="bg-[#F7F7F5] border border-[#EBEBE9] rounded-xl p-5 shadow-sm flex-1 overflow-visible">
                <div class="bg-white rounded-lg border border-[#EBEBE9] p-4">
                    <asp:GridView ID="gvStudentGrades" runat="server" AutoGenerateColumns="False" 
                        AllowPaging="True" PageSize="6" PagerStyle-CssClass="grid-pager" PagerSettings-Mode="NumericFirstLast"
                        OnPageIndexChanging="gvStudentGrades_PageIndexChanging" OnRowDataBound="gvStudentGrades_RowDataBound"
                        CssClass="w-full text-left text-xs border-collapse" GridLines="None">
                        
                        <Columns>
                            <asp:BoundField DataField="StudentID" HeaderText="Student ID" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-zinc-400 w-24 text-center" HeaderStyle-CssClass="text-center pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" />                            <asp:BoundField DataField="StudentName" HeaderText="Student Name" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] font-semibold text-[#1A1A1A]" />
                            <asp:BoundField DataField="StudentEmail" HeaderText="Institutional Email" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-[#5F5E5B]" />
                            <asp:BoundField DataField="ProgrammeCode" HeaderText="Prog" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] font-bold text-zinc-500 text-center w-20" HeaderStyle-CssClass="text-center pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px]" />                            
                            <%-- CGPA Column --%>
                            <asp:TemplateField HeaderText="Estimated CGPA" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-center" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-center font-bold text-[#1A1A1A] w-28">
                                <ItemTemplate>
                                    <%# Eval("EstimatedCGPA", "{0:F2}") %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Status Badge Column with Container for Color Injections --%>
                            <asp:TemplateField HeaderText="Scholastic Standing" HeaderStyle-CssClass="pb-3 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] uppercase text-[10px] text-center" ItemStyle-CssClass="py-4 border-b border-[#F1F1EF] text-center w-36">
                                <ItemTemplate>
                                    <asp:Label ID="lblStandingBadge" runat="server" Text='<%# Eval("StandingStatus") %>' 
                                        CssClass="inline-block px-3 py-1 rounded-full text-[10px] font-bold tracking-wide uppercase shadow-sm"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>

                        <EmptyDataTemplate>
                            <div class="text-center py-12 px-4">
                                <span class="text-3xl text-zinc-300 block mb-2">⍠</span>
                                <p class="text-sm font-semibold text-[#1A1A1A]">No student profile matching the current criteria was found.</p>
                                <p class="text-xs text-[#7C7B77] mt-0.5">Confirm student database synchronization states exist inside your tables.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

    </form>
</body>
</html>