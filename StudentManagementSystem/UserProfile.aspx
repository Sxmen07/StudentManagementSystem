<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserProfile.aspx.cs" Inherits="StudentManagementSystem.UserProfile" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#FBFBFA]">
<head runat="server">
    <title>UniTrack | My Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
    </style>
</head>
<body class="h-full w-full m-0 p-0 text-[#2F2F2F] bg-[#FBFBFA] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative" enctype="multipart/form-data">
        
        <!-- REUSABLE SIDEBAR -->
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 pl-20 pr-10 py-10 lg:pl-10 overflow-y-auto bg-white h-full">
            <header class="mb-8 border-b border-[#F1F1EF] pb-5">
                <h2 class="text-2xl font-bold tracking-tight text-[#1A1A1A]">Account Settings</h2>
                <p class="text-[#7C7B77] text-sm">Manage your institutional presence, contact metrics, and secure identity parameters.</p>
            </header>

            <div class="max-w-2xl bg-[#F7F7F5] rounded-xl border border-[#EBEBE9] p-8 shadow-sm">
                <asp:Label ID="lblStatus" runat="server" CssClass="block text-xs font-medium mb-6 p-2.5 rounded-md" Visible="false"></asp:Label>
                
                <div class="flex flex-col sm:flex-row gap-6 items-center border-b border-[#EBEBE9] pb-8 mb-6">
                    <!-- AVATAR RENDER FRAME -->
                    <div class="relative w-28 h-28 rounded-full border-2 border-zinc-200 overflow-hidden bg-zinc-200 shrink-0">
                        <asp:Image ID="imgAvatar" runat="server" ImageUrl="~/Uploads/default-avatar.png" CssClass="w-full h-full object-cover" />
                    </div>
                    
                    <div class="text-center sm:text-left space-y-1">
                        <asp:Label ID="lblDisplayHeaderName" runat="server" CssClass="text-lg font-bold text-[#1A1A1A] block"></asp:Label>
                        <span class="inline-block bg-zinc-950 text-white text-[10px] font-bold tracking-wider uppercase px-2 py-0.5 rounded">
                            <asp:Literal ID="litBadgeRole" runat="server"></asp:Literal>
                        </span>
                        
                        <!-- PROFILE PICTURE UPLOADER (Hidden by default, shows on Edit mode) -->
                        <asp:Panel ID="pnlPhotoUpload" runat="server" Visible="false" class="pt-2">
                            <asp:FileUpload ID="fuAvatar" runat="server" CssClass="text-xs text-zinc-500 file:mr-4 file:py-1 file:px-2 file:rounded-md file:border-0 file:text-xs file:font-semibold file:bg-zinc-900 file:text-white hover:file:bg-zinc-800 cursor-pointer" />
                        </asp:Panel>
                    </div>
                </div>

                <!-- INFO GRID CONFIGURATION -->
                <div class="space-y-5">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Institutional ID</label>
                            <asp:TextBox ID="txtUserID" runat="server" ReadOnly="true" CssClass="w-full bg-zinc-100 p-2.5 text-sm rounded border border-[#EBEBE9] outline-none text-[#5F5E5B] font-medium cursor-not-allowed"></asp:TextBox>
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Assigned Access Role</label>
                            <asp:TextBox ID="txtRole" runat="server" ReadOnly="true" CssClass="w-full bg-zinc-100 p-2.5 text-sm rounded border border-[#EBEBE9] outline-none text-[#5F5E5B] font-medium cursor-not-allowed"></asp:TextBox>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Full Registered Name</label>
                        <asp:TextBox ID="txtFullName" runat="server" ReadOnly="true" CssClass="w-full bg-zinc-100 p-2.5 text-sm rounded border border-[#EBEBE9] outline-none text-[#2F2F2F] transition-colors"></asp:TextBox>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Corporate Identity Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" ReadOnly="true" CssClass="w-full bg-zinc-100 p-2.5 text-sm rounded border border-[#EBEBE9] outline-none text-[#2F2F2F] transition-colors"></asp:TextBox>
                    </div>

                    <!-- RE-AUTHENTICATION PASSWORD BLOCK (Visible only on Edit mode) -->
                    <asp:Panel ID="pnlPasswordBlock" runat="server" Visible="false">
                        <label class="block text-xs font-bold text-[#7C7B77] uppercase tracking-wider mb-2">Modify Security Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="w-full bg-white p-2.5 text-sm rounded border border-[#EBEBE9] focus:border-[#1A1A1A] outline-none text-[#2F2F2F] transition-colors" placeholder="Leave blank to retain current password"></asp:TextBox>
                    </asp:Panel>

                    <!-- CONTROLLER ACTIONS INTERFACE BUTTONS -->
                    <div class="pt-4 flex items-center justify-end gap-3 border-t border-[#EBEBE9]">
                        <asp:Button ID="btnEditToggle" runat="server" Text="Modify Profile Parameters" OnClick="btnEditToggle_Click"
                            CssClass="bg-zinc-900 text-white hover:bg-zinc-800 text-xs font-medium px-4 py-2.5 rounded transition-colors cursor-pointer" />
                        
                        <asp:Button ID="btnSaveChanges" runat="server" Text="Synchronize Profile Changes" OnClick="btnSaveChanges_Click" Visible="false"
                            CssClass="bg-emerald-600 text-white hover:bg-emerald-500 text-xs font-medium px-4 py-2.5 rounded transition-colors cursor-pointer" />
                        
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Discard" OnClick="btnCancelEdit_Click" Visible="false"
                            CssClass="bg-white border border-[#EBEBE9] text-zinc-600 hover:bg-zinc-50 text-xs font-medium px-4 py-2.5 rounded transition-colors cursor-pointer" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>