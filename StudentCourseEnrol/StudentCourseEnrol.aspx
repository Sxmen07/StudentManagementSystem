<%@ Page Title="Student Course Enrolment" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseEnrol.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseEnrol" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
    <!-- Any page-specific head content -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="bg-white">
        <h1> Course Catalog</h1>

        <div class="flex p-4">
            <div>
                <asp:TextBox ID="txtSearchCourse" runat="server" 
                    CssClass="form-control" 
                    Placeholder="Search courses..." 
                    AutoPostBack="true" 
                    OnTextChanged="txtSearchCourse_TextChanged" />
            </div>

            <div>
                <asp:Button ID="btnSearchCourse" runat="server" 
                    CssClass="btn btn-primary" 
                    Text="Search" 
                    OnClick="btnSearchCourse_Click" />
            </div>

            <div>
                <asp:Button ID="btnCancelSearch" runat="server" 
                    CssClass="btn btn-secondary" 
                    Text="Cancel" 
                    OnClick="btnCancelSearch_Click" />
            </div>
            <!--
            <asp:SearchBox ID="CourseSearchBox" runat="server" 
                Placeholder="Search courses..." 
                OnTextChanged="CourseSearchBox_TextChanged" 
                AutoPostBack="true" />
            <asp:FilterButton ID="FilterButton" runat="server" 
                Text="Filter" 
                OnClick="FilterButton_Click" />
            -->
        </div>

        <div>
            <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="False" CssClass="table table-striped">
                <Columns>
                    <asp:BoundField DataField="CourseCode" HeaderText="Course Code" />
                    <asp:BoundField DataField="CourseName" HeaderText="Course Name" />
                    <asp:BoundField DataField="CourseDescription" HeaderText="Description" />
                    <asp:BoundField DataField="SemesterName" HeaderText="Semester" />
                    <asp:BoundField DataField="LecturerName" HeaderText="Lecturer" />
                    <asp:BoundField DataField="Credits" HeaderText="Credits" />
                    <asp:ButtonField Text="Enroll" CommandName="Enroll" ButtonType="Button" CssClass="btn btn-success" />
                </Columns>
        </div>
    </div>

</asp:Content>
