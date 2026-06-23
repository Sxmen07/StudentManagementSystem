<%@ Page Title="Student Setting" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentSetting.aspx.cs" Inherits="StudentManagementSystems.Student.StudentSetting" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <header class="bg-topbar-gradient w-full">
    <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
        <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">
            Profile Settings
        </h1>
    </div>
</header>

    <div class="m-[64px] pb-16">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Student Settings</h2>

        <asp:Label ID="lblMessage" runat="server" CssClass="block mb-4 text-center p-2 rounded"></asp:Label>
        <asp:HiddenField ID="hdnPassword" runat="server" />
        <asp:HiddenField ID="hdnPhotoPath" runat="server" />

        <div class="flex justify-end gap-4 mb-6">
            <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 px-6 rounded-lg transition cursor-pointer" OnClick="btnEdit_Click" />
            <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-6 rounded-lg transition cursor-pointer" OnClick="btnSave_Click" Visible="false" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-6 rounded-lg transition cursor-pointer" OnClick="btnCancel_Click" Visible="false" />
        </div>

        <div class="flex flex-col items-start mb-8">
            <div class="w-32 h-32 min-w-[128px] min-h-[128px] max-w-[128px] max-h-[128px] rounded-full border-4 border-white shadow-lg overflow-hidden bg-gray-200">
                <asp:Image ID="ProfilePicture" runat="server" CssClass="w-full h-full object-cover" />
            </div>
            
            <div id="uploadContainer" runat="server" visible="false" class="mt-3 ml-2">
                <asp:FileUpload ID="fileUpload" runat="server" accept="image/jpeg,image/png,image/jpg" CssClass="mb-1 text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100" />
                <p class="text-xs text-gray-400">Supported formats: JPG, JPEG, PNG</p>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
            <h3 class="text-xl font-semibold text-gray-700 col-span-full mb-2">Student Information</h3>

            <div>
                <label class="block text-gray-600 font-medium">Student ID</label>
                <asp:TextBox ID="txtStudentID" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-100"
                    Placeholder="Student ID"
                    ReadOnly="true"></asp:TextBox>
            </div>

            <div>
                <label class="block text-gray-600 font-medium">Student Name</label>
                <asp:TextBox ID="txtStudentName" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-100"
                    Placeholder="Student Name"
                    ReadOnly="true"></asp:TextBox>
            </div>

            <div>
                <label class="block text-gray-600 font-medium">Student Email</label>
                <asp:TextBox ID="txtStudentEmail" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-100"
                    Placeholder="Student Email"
                    ReadOnly="true"></asp:TextBox>
            </div>

            <div>
                <label class="block text-gray-600 font-medium">Password</label>
                <asp:TextBox ID="txtPassword" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2"
                    Placeholder="******"
                    TextMode="Password"
                    Enabled="false"></asp:TextBox>
            </div>

            <div>
                <label class="block text-gray-600 font-medium">Personal Email</label>
                <asp:TextBox ID="txtPersonalEmail" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2"
                    Placeholder="Personal Email"
                    Enabled="false"></asp:TextBox>
            </div>

            <div>
                <label class="block text-gray-600 font-medium">Contact Number</label>
                <asp:TextBox ID="txtContactNumber" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2"
                    Placeholder="Contact Number"
                    Enabled="false"></asp:TextBox>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <h3 class="text-xl font-semibold text-gray-700 col-span-full mb-2">Programme Information</h3>

            <div>
                <label class="block text-gray-600 font-medium">Programme Code</label>
                <asp:TextBox ID="txtProgrammeCode" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-100"
                    Placeholder="Programme Code"
                    Enabled="false"></asp:TextBox>
            </div>

            <div>
                <label class="block text-gray-600 font-medium">Programme Name</label>
                <asp:TextBox ID="txtProgrammeName" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-100"
                    Placeholder="Programme Name"
                    Enabled="false"></asp:TextBox>
            </div>

            <div>
                <label class="block text-gray-600 font-medium">Intake Semester</label>
                <asp:TextBox ID="txtIntakeSemester" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-100"
                    Placeholder="Intake Semester"
                    Enabled="false"></asp:TextBox>
            </div>

            <div>
                <label class="block text-gray-600 font-medium">Intake Year</label>
                <asp:TextBox ID="txtIntakeYear" runat="server"
                    CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 bg-gray-100"
                    Placeholder="Intake Year"
                    Enabled="false"></asp:TextBox>
            </div>
        </div>
    </div> </asp:Content>