<%@ Page Title="Student Attendance" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentAttendance.aspx.cs" Inherits="StudentManagementSystem.Student.StudentAttendance" %>
<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bg-topbar-gradient h-[189px] w-full">
        <h2 class="text-[48px] font-bold text-white px-6 py-[90px] text-shadow">Attendance Records</h2>
    </div>

    <div class="m-[64px] flex flex-col gap-8">
        <!-- Current Courses -->
        <div>
            <h3 class="text-xl font-bold text-gray-800 mb-4 border-b pb-2">Current Courses</h3>
            <asp:Repeater ID="rptCurrentCourses" runat="server" OnItemDataBound="rptCurrentCourses_ItemDataBound">
                <ItemTemplate>
                    <div class="bg-white shadow-md rounded-lg overflow-hidden mb-6">
                        <div class="p-4 bg-gray-50 border-b">
                            <asp:Label ID="lblCourseCode" runat="server" CssClass="text-lg font-semibold text-main-color" />
                            <asp:Label ID="lblCourseName" runat="server" CssClass="block text-sm text-gray-500" />
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 p-4">
                            <div class="scrollable-table">
                                <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="False" CssClass="w-full compact-table"
                                    OnRowDataBound="gvAttendance_RowDataBound"
                                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 font-semibold text-sm uppercase tracking-wider"
                                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                                    AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None" EmptyDataText="No attendance records found.">
                                    <Columns>
                                        <asp:BoundField DataField="AttendanceDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField DataField="AttendanceStatus" HeaderText="Status" ItemStyle-HorizontalAlign="Center" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                            <!-- Right column with chart -->
                            <div class="bg-gray-50 p-4 rounded-lg flex flex-col items-center">
                                <h4 class="font-semibold text-gray-700 mb-2">Attendance Summary</h4>
                                <asp:Chart ID="chartAttendance" runat="server" Width="200" Height="200">
                                    <Series>
                                        <asp:Series Name="Attendance" ChartType="Doughnut"></asp:Series>
                                    </Series>
                                    <ChartAreas>
                                        <asp:ChartArea Name="ChartArea1"></asp:ChartArea>
                                    </ChartAreas>
                                    <Legends>
                                        <asp:Legend Name="Legend1" Docking="Bottom" />
                                    </Legends>
                                </asp:Chart>
                                <asp:Label ID="lblSummary" runat="server" CssClass="text-gray-700 mt-2 text-sm text-center" />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <SeparatorTemplate>
                    <hr class="my-2" />
                </SeparatorTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoCurrent" runat="server" CssClass="text-gray-500 italic" Visible="false" Text="No current courses." />
        </div>

        <!-- History Section -->
        <div>
            <h3 class="text-xl font-bold text-gray-800 mb-4 border-b pb-2">History (Past Courses)</h3>
            <asp:Repeater ID="rptHistoryCourses" runat="server" OnItemDataBound="rptHistoryCourses_ItemDataBound">
                <ItemTemplate>
                    <div class="bg-white shadow-md rounded-lg overflow-hidden mb-6">
                        <div class="p-4 bg-gray-50 border-b">
                            <asp:Label ID="lblCourseCode" runat="server" CssClass="text-lg font-semibold text-gray-700" />
                            <asp:Label ID="lblCourseName" runat="server" CssClass="block text-sm text-gray-500" />
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 p-4">
                            <div class="scrollable-table">
                                <asp:GridView ID="gvAttendance" runat="server" AutoGenerateColumns="False" CssClass="w-full compact-table"
                                    HeaderStyle-CssClass="bg-gray-100 text-gray-700 font-semibold text-sm uppercase tracking-wider"
                                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                                    AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None" EmptyDataText="No attendance records found.">
                                    <Columns>
                                        <asp:BoundField DataField="AttendanceDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField DataField="AttendanceStatus" HeaderText="Status" ItemStyle-HorizontalAlign="Center" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                            <div class="bg-gray-50 p-4 rounded-lg flex flex-col items-center">
                                <h4 class="font-semibold text-gray-700 mb-2">Attendance Summary</h4>
                                <asp:Chart ID="chartAttendance" runat="server" Width="200" Height="200">
                                    <Series>
                                        <asp:Series Name="Attendance" ChartType="Doughnut"></asp:Series>
                                    </Series>
                                    <ChartAreas>
                                        <asp:ChartArea Name="ChartArea1"></asp:ChartArea>
                                    </ChartAreas>
                                    <Legends>
                                        <asp:Legend Name="Legend1" Docking="Bottom" />
                                    </Legends>
                                </asp:Chart>
                                <asp:Label ID="lblSummary" runat="server" CssClass="text-gray-700 mt-2 text-sm text-center" />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoHistory" runat="server" CssClass="text-gray-500 italic" Visible="false" Text="No past courses." />
        </div>
    </div>
</asp:Content>