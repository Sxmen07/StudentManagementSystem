<%@ Page Title="Student Course Enrolment" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseEnrol.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseEnrol" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
    <!-- Any page-specific head content -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div>
        <div>
            <h1>Course Catalog</h1>
            <div class="p-4 mt-[24px]">
                <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="False" CssClass="table table-striped">
                    <Columns>
                        <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                        <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                        <asp:BoundField DataField="CourseDescription" HeaderText="Description" />
                        <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
                        <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" />
                        <asp:BoundField DataField="Credits" HeaderText="Credits" />
                        <asp:TemplateField HeaderText="Enroll">
                        <itemtemplate>
                            <asp:CheckBox ID="chkEnroll" runat="server" />
                        </itemtemplate>
                    </asp:TemplateField>
                    </Columns>

                </asp:GridView>
            </div>
            <div class="flex justify-end gap-4 mb-4">

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
        </div>




        <div>
            <h1>Currently Enrolled Courses</h1>
            <asp:GridView ID="gvEnrolledCourses" runat="server" AutoGenerateColumns="False" CssClass="table table-striped">
                <Columns>
                    <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                    <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                    <asp:BoundField DataField="CourseDescription" HeaderText="Description" />
                    <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
                    <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" />
                    <asp:BoundField DataField="Credits" HeaderText="Credits" />
                </Columns>
            </asp:GridView>
        </div>

        <div>
            <h1>Course Enrolled History</h1>
            <asp:GridView ID="gvCourseHistory" runat="server" AutoGenerateColumns="False" CssClass="table table-striped">
                <Columns>
                    <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                    <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                    <asp:BoundField DataField="CourseDescription" HeaderText="Description" />
                    <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
                    <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" />
                    <asp:BoundField DataField="Credits" HeaderText="Credits" />
                    <asp:BoundField DataField="EnrollmentDate" HeaderText="Enrollment Date" DataFormatString="{0:yyyy-MM-dd}" />
                </Columns>
                </asp:GridView>
        </div>
    </div>

</asp:Content>
