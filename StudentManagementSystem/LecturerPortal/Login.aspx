<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="LecturerPortal.Login" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Lecturer Login</title>

    <style>
        * {box-sizing: border-box;}

        body {
            margin: 0;
            min-height: 100vh;
            overflow: hidden;
            font-family: 'Segoe UI', sans-serif;
        }

        .bg {
            position: fixed;
            top: -20px;
            left: -20px;
            right: -20px;
            bottom: -20px;

            background-image: url('<%= ResolveUrl("~/Pictures/Lecture.jpg") %>');
            background-size: cover;
            background-position: center;

            filter: blur(12px);
            transform: scale(1.08);

            z-index: -2;
        }

        .bg::after {
            content: '';
            position: absolute;
            inset: 0;

            background: rgba(255,255,255,0.35);
        }

        form {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-card {
            width: 420px;
            padding: 40px;

            background: white;

            border-radius: 22px;

            box-shadow: 0 25px 60px rgba(0,0,0,0.25);

            text-align: center;
        }

        .logo {
            width: 75px;
            height: 75px;
            margin: 0 auto 20px;

            border-radius: 22px;

            background: linear-gradient(135deg,#2563eb,#7c3aed);

            color: white;
            font-size: 28px;
            font-weight: 800;

            display: flex;
            align-items: center;
            justify-content: center;

            box-shadow: 0 10px 25px rgba(37,99,235,.4);
        }

        h2 {
            margin: 0;
            color: #111827;
            font-size: 32px;
            font-weight: 800;
        }

        .subtitle {
            margin: 10px 0 30px;
            color: #6b7280;
            font-size: 14px;
        }

        .input-field {
            width: 100%;
            padding: 14px 16px;
            margin-bottom: 15px;
            border: none;
            border-radius: 8px;
            background: #f1f5f9;
            color: #111827 !important;
            font-size: 14px;
            outline: none;
        }

        .input-field::placeholder {
            color: #6b7280 !important;
            opacity: 1;
        }

        input::placeholder {
            color: #6b7280 !important;
            opacity: 1;
        }

        .input-field:focus {
            background: #eef2ff;
            box-shadow: 0 0 0 2px #6366f1;
        }

        .input-field::placeholder {
            color: rgba(255,255,255,.65);
        }

        .input-field:focus {
            border-color: rgba(255,255,255,.4);
            background: rgba(255,255,255,.18);
        }

        .login-btn {
            width: 100%;
            padding: 15px;

            border: none;
            border-radius: 12px;

            background: linear-gradient(135deg,#2563eb,#7c3aed);

            color: white;
            font-size: 15px;
            font-weight: 700;

            cursor: pointer;
            transition: .3s;
        }

        .login-btn:hover {
            transform: translateY(-2px);

            box-shadow:
                0 12px 25px rgba(37,99,235,.35);
        }

        .error {
            display: block;
            color: #dc2626;
            background: #fee2e2;
            padding: 10px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 15px;
        }

        .bottom-brand {
            position: fixed;
            left: 40px;
            bottom: 35px;

            color: white;
        }

        .bottom-brand h1 {
            margin: 0;
            font-size: 48px;
            font-weight: 900;
            letter-spacing: 1px;
        }

        .bottom-brand p {
            margin-top: 8px;
            opacity: .8;
            font-size: 14px;
        }
    </style>
</head>

    <body>

        <div class="bg"></div>

        <form id="form1" runat="server">

            <div class="login-card">

                <div class="logo">UT</div>

                <h2>Welcome Back!</h2>
                <p class="subtitle">Sign in to access the Lecturer Portal</p>

                <asp:TextBox
                    ID="txtEmail"
                    runat="server"
                    CssClass="input-field"
                    placeholder="Email Address" />

                <asp:TextBox
                    ID="txtPassword"
                    runat="server"
                    TextMode="Password"
                    CssClass="input-field"
                    placeholder="Password" />

                <asp:Label
                    ID="lblError"
                    runat="server"
                    CssClass="error"
                    Visible="false" />

                <asp:Button
                    ID="btnLogin"
                    runat="server"
                    Text="Login"
                    CssClass="login-btn"
                    OnClick="btnLogin_Click" />

            </div>

            <div class="bottom-brand">
                <h1>UniTrack</h1>
                <p>Lecturer Management System</p>
            </div>

        </form>

    </body>
</html>