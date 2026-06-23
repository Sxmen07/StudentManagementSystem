<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="StudentManagementSystem.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" class="h-full w-full overflow-hidden">
<head runat="server">
    <title>UniTrack Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    
    <style type="text/css">
        body { 
            font-family: 'Poppins', sans-serif; 
        }
    </style>
</head>
<body class="h-full w-full overflow-hidden m-0 p-0">
    <form id="form1" runat="server" class="h-full w-full">
        
        <div class="relative w-screen h-screen flex justify-center items-center bg-cover bg-center no-repeat" 
             style="background-image: linear-gradient(rgba(0, 0, 0, 0.45), rgba(0, 0, 0, 0.45)), url('images/login_bg.jpg');">
            
            <div class="bg-white px-[45px] py-[50px] rounded-[20px] w-full max-w-[440px] shadow-none text-center z-10">
                
                <div class="mb-[25px]">
                    <img src="images/INTI_Logo.png" alt="INTI Logo" class="w-[200px] h-auto mx-auto" />
                </div>

                <h2 class="text-[32px] font-bold text-black mb-[35px] tracking-tight">Welcome Back!</h2>

                <div class="mb-5">
                    <div class="relative w-full overflow-hidden rounded-t-md">
                        <asp:TextBox ID="txtUsername" runat="server" 
                            CssClass="peer w-full bg-[#F0F0F0] p-4 text-base text-black outline-none placeholder-gray-500" 
                            Placeholder="Username"></asp:TextBox>
                        <span class="absolute bottom-0 left-0 w-full h-[3px] bg-black scale-x-0 transition-transform duration-300 ease-out origin-center peer-focus:scale-x-100"></span>
                    </div>
                </div>

                <div class="mb-5">
                    <div class="relative w-full overflow-hidden rounded-t-md">
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" 
                            CssClass="peer w-full bg-[#F0F0F0] p-4 text-base text-black outline-none placeholder-gray-500" 
                            Placeholder="Password"></asp:TextBox>
                        <span class="absolute bottom-0 left-0 w-full h-[3px] bg-black scale-x-0 transition-transform duration-300 ease-out origin-center peer-focus:scale-x-100"></span>
                    </div>
                </div>

                <div class="text-right -mt-[10px] mb-[30px]">
                    <span class="text-xs text-black font-medium">Forgot password? <a href="ForgotPassword(Optional).aspx" class="text-blue-700 underline">Click Here</a></span>
                </div>

                <div class="mb-[35px]">
                    <asp:Button ID="btnLogin" runat="server" Text="Login" 
                        CssClass="w-full bg-black text-white py-4 text-base font-semibold rounded-md cursor-pointer hover:bg-zinc-800 transition-colors" 
                        OnClick="btnLogin_Click" />
                </div>

                <div class="mt-[25px]">
                    <span class="text-xs text-black font-medium">Don't have an account? <a href="ContactAdmin.aspx" class="text-blue-700 underline">Contact Admin</a></span>
                </div>
                
                <asp:Label ID="lblError" runat="server" ForeColor="Red" Font-Size="Small" Style="display:block; text-align:center; margin-top:10px; font-weight:500;"></asp:Label>
            </div>
            
            <div class="absolute bottom-10 left-10 text-white text-left hidden sm:block">
                <h1 class="text-[56px] font-bold leading-none mb-2 tracking-tighter">UniTrack</h1>
                <p class="text-sm opacity-85 font-light">UniTrack (Malaysia) Sdn Bhd. All Rights Reserved.</p>
            </div>
            
        </div>
    </form>
</body>
</html>