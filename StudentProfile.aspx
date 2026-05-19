<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Inherits="StudentManagementSystem.Student.StudentProfile" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Student Profile</title>
    <link href="/Styles/output.css" rel="stylesheet" />
</head>

<body class="bg-gray-100">
    <form id="form1" runat="server" class="max-w-4xl mx-auto p-6">
        <div class="bg-white rounded-lg shadow-md p-6">
            <h2 class="text-2xl font-bold text-gray-800 mb-6">Student Profile</h2>

            <asp:Label ID="lblMessage" runat="server" CssClass="block mb-4 text-center p-2 rounded"></asp:Label>

            <!-- Buttons -->
            <div class="flex gap-4 mb-6">
                <asp:Button ID="btnEdit" runat="server"
                    Text="Edit"
                    CssClass="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 px-6 rounded-lg transition cursor-pointer"
                    OnClick="btnEdit_Click" />
                <asp:Button ID="btnSave" runat="server"
                    Text="Save"
                    CssClass="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-6 rounded-lg transition cursor-pointer"
                    OnClick="btnSave_Click"
                    Visible="false" />
                <asp:Button ID="btnCancel" runat="server"
                    Text="Cancel"
                    CssClass="bg-gray-500 hover:bg-gray-600 text-white font-semibold py-2 px-6 rounded-lg transition cursor-pointer"
                    OnClick="btnCancel_Click"
                    Visible="false" />
            </div>

            <!-- Student Information Section -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                <h3 class="text-xl font-semibold text-gray-700 col-span-full mb-2">Student Information</h3>
                
                <div>
                    <label class="block text-gray-600 font-medium">Student ID</label>
                    <asp:TextBox ID="txtStudentID" runat="server"
                        CssClass="w-full border border-gray-300 rounded-lg px-3 py-2 bg-main-color-100"
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
                        Placeholder="Password"
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

            <!-- Programme Information Section -->
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
        </div>
    </form>
</body>
</html>
