<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserProfile.aspx.cs" CodeBehind="UserProfile.aspx.cs" Inherits="StudentManagementSystem.UserProfile" %>
<%@ Register Src="~/Sidebar.ascx" TagPrefix="uc" TagName="Navbar" %> <!-- REGISTER SIDEBAR CONTROLL -->

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full bg-[#F3F4F6]">
<head runat="server">
    <title>UniTrack | My Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style type="text/css">
        body { font-family: 'Poppins', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #E4E4E7; border-radius: 10px; }
    </style>
</head>

<body class="h-full w-full m-0 p-0 text-[#1F2937] bg-[#F3F4F6] overflow-hidden">
    <form id="form1" runat="server" class="h-full flex relative" enctype="multipart/form-data">
        
        <!-- ASCX SIDEBAR -->
        <uc:Navbar runat="server" ID="AdminSidebar" />

        <div class="flex-1 overflow-y-auto h-full custom-scrollbar bg-[#F9FAFB] relative pb-12">
            
            <asp:Panel ID="pnlBannerBackground" runat="server" CssClass="w-full h-64 bg-gradient-to-r from-[#CAD9FA] via-[#E2EDF7] to-[#FFF9D3] bg-cover bg-center relative"></asp:Panel>

            <div class="max-w-6xl mx-auto px-4 sm:px-8 relative -mt-10 z-10">
                
                <div class="flex flex-col md:flex-row items-center md:items-center justify-between gap-6 mb-8">
                    <div class="flex flex-col md:flex-row items-center md:items-center gap-5 text-center md:text-left">
                        <div class="relative w-36 h-36 rounded-full border-4 border-white shadow-md overflow-hidden bg-white shrink-0 group">
                            <asp:Image ID="imgAvatar" runat="server" ImageUrl="~/profile_upload/default-avatar.jpg" CssClass="w-full h-full object-cover" />
                            <asp:Panel ID="pnlAvatarOverlay" runat="server" Visible="false" CssClass="absolute inset-0 bg-black/40 flex items-center justify-center transition-opacity cursor-pointer">
                                <i class="fa-solid fa-camera text-white text-xl"></i>
                            </asp:Panel>
                        </div>
                        
                        <div class="mt-4">
                            <div class="flex flex-col sm:flex-row items-center gap-3 justify-center md:justify-start">
                                <asp:Label ID="lblDisplayHeaderName" runat="server" CssClass="text-3xl font-bold text-[#111827] tracking-tight"></asp:Label>
                                <span class="bg-[#0095FD] text-white text-xs font-semibold px-3 py-1 rounded-full shadow-sm">
                                    <asp:Literal ID="litBadgeRole" runat="server"></asp:Literal>
                                </span>
                            </div>
                            
                            <p class="text-gray-500 text-sm mt-1 font-medium">
                                <asp:Literal ID="litSubHeaderTitle" runat="server"></asp:Literal>
                            </p>
                        </div>
                    </div>
                    
                    <div class="flex items-center gap-3">
                        <asp:LinkButton ID="btnEditToggle" runat="server" OnClick="btnEditToggle_Click"
                            CssClass="bg-white border border-[#E5E7EB] text-gray-700 hover:bg-gray-50 text-sm font-semibold px-5 py-2 rounded-xl transition-all shadow-sm flex items-center gap-2 cursor-pointer">
                            <i class="fa-solid fa-pen text-xs text-gray-500"></i> Edit
                        </asp:LinkButton>
                        
                        <asp:LinkButton ID="btnSaveChanges" runat="server" OnClick="btnSaveChanges_Click" Visible="false"
                            CssClass="bg-[#0095FD] text-white hover:bg-[#0082dd] text-sm font-semibold px-5 py-2 rounded-xl transition-all shadow-md flex items-center gap-2 cursor-pointer">
                            <i class="fa-solid fa-check text-xs"></i> Save Changes
                        </asp:LinkButton>
                        
                        <asp:LinkButton ID="btnCancelEdit" runat="server" OnClick="btnCancelEdit_Click" Visible="false"
                            CssClass="bg-white border border-gray-300 text-gray-600 hover:bg-gray-50 text-sm font-semibold px-5 py-2 rounded-xl transition-all shadow-sm cursor-pointer">
                            Discard
                        </asp:LinkButton>
                    </div>
                </div>

                <asp:Label ID="lblStatus" runat="server" CssClass="block text-sm font-medium mb-6 p-4 rounded-xl shadow-sm" Visible="false"></asp:Label>

                <div class="bg-white rounded-2xl border border-gray-200/80 p-6 md:p-10 shadow-sm min-h-[400px]">
                    
                    <asp:Panel ID="pnlUploadControls" runat="server" Visible="false" CssClass="bg-gray-50 border border-gray-200 p-5 rounded-xl mb-8 grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Upload Profile Photo</label>
                            <asp:FileUpload ID="fuAvatar" runat="server" CssClass="text-xs text-gray-500 file:mr-4 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:text-xs file:font-semibold file:bg-gray-900 file:text-white hover:file:bg-gray-800 cursor-pointer w-full" />
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Upload Background Banner Image</label>
                            <asp:FileUpload ID="fuBackground" runat="server" CssClass="text-xs text-gray-500 file:mr-4 file:py-1.5 file:px-3 file:rounded-md file:border-0 file:text-xs file:font-semibold file:bg-gray-900 file:text-white hover:file:bg-gray-800 cursor-pointer w-full" />
                        </div>
                    </asp:Panel>

                    <div class="space-y-6 max-w-3xl">
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Institutional ID</label>
                                <asp:TextBox ID="txtUserID" runat="server" ReadOnly="true" CssClass="w-full bg-gray-50 p-3 text-sm rounded-xl border border-gray-200 outline-none text-gray-400 font-medium cursor-not-allowed shadow-inner"></asp:TextBox>
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Assigned Access Role</label>
                                <asp:TextBox ID="txtRole" runat="server" ReadOnly="true" CssClass="w-full bg-gray-50 p-3 text-sm rounded-xl border border-gray-200 outline-none text-gray-400 font-medium cursor-not-allowed shadow-inner"></asp:TextBox>
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Full Registered Name</label>
                            <asp:TextBox ID="txtFullName" runat="server" ReadOnly="true" CssClass="w-full bg-gray-50 p-3 text-sm rounded-xl border border-gray-200 outline-none text-gray-700 transition-all font-medium"></asp:TextBox>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Corporate Identity Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" ReadOnly="true" CssClass="w-full bg-gray-50 p-3 text-sm rounded-xl border border-gray-200 outline-none text-gray-700 transition-all font-medium"></asp:TextBox>
                        </div>

                        <asp:Panel ID="pnlPasswordBlock" runat="server" Visible="false" class="pt-2">
                            <label class="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Modify Security Password</label>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="w-full bg-white p-3 text-sm rounded-xl border border-gray-300 focus:border-[#0095FD] focus:ring-2 focus:ring-[#0095FD]/20 outline-none text-gray-700 transition-all font-medium" placeholder="Leave blank to retain current security entry string"></asp:TextBox>
                        </asp:Panel>
                    </div>

                </div>
            </div>
        </div>
    </form>
</body>
</html>