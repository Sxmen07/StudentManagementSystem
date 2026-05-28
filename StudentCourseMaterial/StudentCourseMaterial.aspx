<%@ Page Title="Course Material" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseMaterial.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseMaterial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bg-topbar-gradient h-[150px] w-full">
        <h2 class="text-[48px] font-bold text-white px-6 py-[60px] text-shadow">Course Material</h2>
    </div>
    <div class="m-8">
        <asp:Label ID="lblCourseTitle" runat="server" CssClass="text-2xl font-bold" />
        <hr class="my-4" />
        <asp:Repeater ID="rptMaterials" runat="server">
            <ItemTemplate>
                <div class="border p-4 mb-4 rounded">
                    <h3 class="text-lg font-semibold"><%# Eval("Title") %></h3>
                    <p><%# Eval("Description") %></p>
                    <a href='<%# Eval("FileUrl") %>' target="_blank" class="text-blue-500">Download</a>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>