<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageCourses.aspx.cs" Inherits="StudentManagementSystem.ManageCourses" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | Curriculum Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative">
        
        <div class="group fixed lg:relative left-0 top-0 h-full w-16 hover:w-64 bg-zinc-950 text-white flex flex-col justify-between border-r border-zinc-900 transition-all duration-300 ease-in-out z-50 p-4 overflow-hidden">
            <div>
                <h1 class="text-xl font-bold tracking-tighter text-white mb-8 h-8 flex items-center gap-4 whitespace-nowrap overflow-hidden pl-1">
                    <span class="w-4 h-4 rounded-sm bg-white shrink-0 block"></span> 
                    <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">UniTrack</span>
                </h1>
                
                <nav class="space-y-1.5">
                    <a href="AdminDashboard.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-lg shrink-0 w-4 text-center font-normal">⌂</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Dashboard Home</span>
                    </a>
                    <a href="CreateAccounts.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-base shrink-0 w-4 text-center font-bold">⍡</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Create Accounts</span>
                    </a>
                    <a href="ManageSchoolNPrograms.aspx" class="flex items-center gap-4 hover:bg-zinc-900 p-2 rounded-md font-medium text-sm transition-colors text-zinc-400 hover:text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-lg shrink-0 w-4 text-center font-normal">⎔</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Schools & Programs</span>
                    </a>
                    <a href="ManageCourses.aspx" class="flex items-center gap-4 bg-zinc-800 p-2 rounded-md font-semibold text-sm transition-colors text-white whitespace-nowrap overflow-hidden pl-2">
                        <span class="text-base shrink-0 w-4 text-center font-bold">▤</span>
                        <span class="opacity-0 group-hover:opacity-100 transition-opacity duration-300">Manage Courses</span>
                    </a>
                </nav>
            </div>
            
            <div class="w-full h-9 overflow-hidden relative flex items-center justify-start pl-2">
                <span class="text-red-500 font-bold text-lg absolute left-3 pointer-events-none group-hover:opacity-0 transition-opacity duration-200">⏻</span>
                <div class="w-full opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                    <asp:Button ID="btnLogout" runat="server" Text="Log Out" 
                        CssClass="w-full bg-red-950/40 border border-red-900/30 hover:bg-red-900/60 text-red-400 font-medium text-xs py-2 rounded transition-colors cursor-pointer text-center block" 
                        OnClick="btnLogout_Click" />
                </div>
            </div>
        </div>

        <div class="flex-1 pl-20 pr-10 py-10 lg:pl-10 overflow-y-auto bg-white h-full">
            <header class="mb-8 border-b border-[#F1F1EF] pb-5 flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                <div>
                    <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Curriculum Management</h2>
                    <p class="text-[#7C7B77] text-sm">Create, edit, and update institutional courses and credit hours.</p>
                </div>
                
                <div class="flex items-center gap-2 bg-[#F7F7F5] border border-[#EBEBE9] px-3 py-1.5 rounded-md h-fit">
                    <span class="text-xs font-bold text-[#7C7B77] uppercase tracking-wider">Filter By Programme:</span>
                    <asp:DropDownList ID="ddlFilterProgramme" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFilterProgramme_SelectedIndexChanged" CssClass="bg-transparent text-sm font-medium text-[#2F2F2F] outline-none cursor-pointer"></asp:DropDownList>
                </div>
            </header>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div class="bg-[#F7F7F5] p-6 rounded-lg border border-[#EBEBE9] h-fit">
                    <h3 class="text-sm font-semibold mb-6 text-[#1A1A1A]">Manage Course Details</h3>
                    <asp:HiddenField ID="hfCourseID" runat="server" />

                    <div class="space-y-4">
                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Course Code</label>
                            <asp:TextBox ID="txtCourseCode" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="e.g., BIT203"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Course Name</label>
                            <asp:TextBox ID="txtCourseName" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="e.g., UX Design"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Credit Hours</label>
                            <div class="relative">
                                <asp:TextBox ID="txtCreditHours" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="e.g., 3" text="3"></asp:TextBox>
        
                                <asp:CompareValidator ID="cvCreditHours" runat="server" 
                                    ControlToValidate="txtCreditHours" 
                                    Type="Integer" 
                                    Operator="DataTypeCheck" 
                                    ErrorMessage="Must be a valid integer number." 
                                    CssClass="block text-xs text-red-600 mt-1 font-medium" 
                                    Display="Dynamic" />
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Assigned Programme</label>
                            <asp:DropDownList ID="ddlProgrammes" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors cursor-pointer"></asp:DropDownList>
                        </div>

                        <div class="pt-2 space-y-2">
                            <asp:Button ID="btnSaveCourse" runat="server" Text="Register Course" 
                                CssClass="w-full bg-[#1A1A1A] text-white font-medium text-sm py-2.5 rounded hover:bg-[#2F2F2F] transition-colors cursor-pointer shadow-sm" 
                                OnClick="btnSaveCourse_Click" />
                            <asp:Button ID="btnCancelCourse" runat="server" Text="Cancel Edit" 
                                CssClass="w-full bg-white border border-[#EBEBE9] text-[#5F5E5B] text-xs py-2 rounded hover:bg-[#F4F4F2] transition-colors cursor-pointer" 
                                OnClick="btnCancelCourse_Click" Visible="false" />
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-2 bg-white rounded-lg border border-[#EBEBE9] p-6">
                    <asp:GridView ID="gvCourses" runat="server" AutoGenerateColumns="False" DataKeyNames="CourseID" OnRowCommand="gvCourses_RowCommand" CssClass="w-full text-left text-sm border-collapse" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="CourseCode" HeaderText="Code" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] font-bold text-[#1A1A1A] w-24" />
                            <asp:BoundField DataField="CourseName" HeaderText="Course Title" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-[#1A1A1A]" />
                            <asp:BoundField DataField="CreditHours" HeaderText="Credits" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-[#7C7B77] w-20" />
                            <asp:BoundField DataField="ProgrammeName" HeaderText="Programme" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-[#5F5E5B]" />
                            
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="pb-2 text-[#7C7B77] font-semibold border-b border-[#EBEBE9] text-xs uppercase" ItemStyle-CssClass="py-3 border-b border-[#F1F1EF] text-right w-44">
                                <ItemTemplate>
                                    <div class="inline-flex gap-2 justify-end w-full">
                                        <asp:Button ID="btnEditCourse" runat="server" CommandName="EditCourse" CommandArgument='<%# Eval("CourseID") %>' Text="Edit" 
                                            CssClass="bg-zinc-100 hover:bg-zinc-200 text-zinc-800 text-xs font-medium px-2.5 py-1 rounded transition-colors cursor-pointer border border-zinc-200" />
                                        
                                        <asp:Button ID="btnDeleteCourse" runat="server" CommandName="DeleteCourse" CommandArgument='<%# Eval("CourseID") %>' Text="Delete" 
                                            OnClientClick="return confirm('Are you sure you want to permanently drop this course from the curriculum layout?');" 
                                            CssClass="bg-red-50 hover:bg-red-100 text-red-600 text-xs font-medium px-2.5 py-1 rounded transition-colors cursor-pointer border border-red-200" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

    </form>
</body>
</html>