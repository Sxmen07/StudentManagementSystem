<%@ Page Title="Student Course Enrolment" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseEnrol.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseEnrol" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
    <!-- Any page-specific head content -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div>
        <div class="p-6">
            <h2 class="text-2xl font-bold text-gray-800 mb-6">Courses</h2>
            <h3 class="text-xl font-semibold col-span-full mb-4">Course Catalog</h3>
            <div class="overflow-x-auto shadow-md rounded-lg mb-8">
                <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="False"
                    CssClass="min-w-full bg-white rounded-lg overflow-hidden spacious-grid"
                    HeaderStyle-CssClass="bg-main-color text-white font-semibold text-sm uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ItemStyle-Width="12%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="CourseName" HeaderText="Course Name" ItemStyle-Width="20%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="CourseDescription" HeaderText="Description" ItemStyle-Width="35%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="SemesterName" HeaderText="Semester" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" ItemStyle-Width="15%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-Width="5%" ItemStyle-HorizontalAlign="Center" />
                        <asp:TemplateField HeaderText="Enroll">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkEnroll" runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>

                </asp:GridView>
            </div>
            <div class="flex justify-end gap-4 mb-4 p-4">

                <div>
                    <asp:Button ID="btnEnrollCourse" runat="server"
                        CssClass="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 px-6 rounded-lg transition cursor-pointer"
                        Text="Enroll"
                        OnClick="btnEnrollCourse_Click" />
                </div>

                <div>
                    <asp:Button ID="btnResetEnroll" runat="server"
                        CssClass="bg-red hover:bg-red-600 text-white font-semibold py-2 px-6 rounded-lg transition cursor-pointer"
                        Text="Reset"
                        OnClick="btnResetEnroll_Click" />
                </div>
            </div>

            <div class="mt-8">
                <h3 class="text-xl font-semibold col-span-full mb-4">Currently Enrolled Courses</h3>
                <div class="overflow-x-auto shadow-md rounded-lg mb-8">
                    <asp:GridView ID="gvEnrolledCourses" runat="server" AutoGenerateColumns="False"
                        CssClass="min-w-full bg-white rounded-lg overflow-hidden spacious-grid"
                        HeaderStyle-CssClass="bg-main-color text-white font-semibold text-sm uppercase tracking-wider"
                        RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                        AlternatingRowStyle-CssClass="bg-gray-50"
                        GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ItemStyle-Width="12%" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="CourseName" HeaderText="Course Name" ItemStyle-Width="20%" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="CourseDescription" HeaderText="Description" ItemStyle-Width="35%" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="SemesterName" HeaderText="Semester" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" ItemStyle-Width="15%" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-Width="5%" ItemStyle-HorizontalAlign="Center" />
                        </Columns>

                    </asp:GridView>
                </div>
            </div>

            <h3 class="text-xl font-semibold col-span-full mb-4">Enrolled Courses</h3>
            <div class="overflow-x-auto shadow-md rounded-lg mb-8">
                <asp:GridView ID="gvCourseHistory" runat="server" AutoGenerateColumns="False"
                    CssClass="min-w-full bg-white rounded-lg overflow-hidden spacious-grid"
                    HeaderStyle-CssClass="bg-main-color text-white font-semibold text-sm uppercase tracking-wider"
                    RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                    AlternatingRowStyle-CssClass="bg-gray-50"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ItemStyle-Width="12%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="CourseName" HeaderText="Course Name" ItemStyle-Width="20%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="CourseDescription" HeaderText="Description" ItemStyle-Width="35%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="SemesterName" HeaderText="Semester" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" ItemStyle-Width="15%" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-Width="5%" ItemStyle-HorizontalAlign="Center" />
                    </Columns>

                </asp:GridView>
            </div>

        </div>





    </div>

</asp:Content>
