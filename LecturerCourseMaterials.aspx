<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerCourseMaterials.aspx.cs" Inherits="StudentManagementPersonal.LecturerCourseMaterials" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Post Course Materials</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />

    <style>

        body {
            margin: 0;
            font-family: Arial;
            background-color: #f5f7fb;
        }

        .sidebar {
            width: 240px;
            height: 100vh;
            background-color: #0d1b2a;
            position: fixed;
            color: white;
            padding-top: 20px;
        }

        .sidebar h2 {
            text-align: center;
            margin-bottom: 40px;
        }

        .sidebar a {
            display: block;
            color: white;
            text-decoration: none;
            padding: 15px 25px;
        }

        .sidebar a:hover {
            background-color: #1b263b;
        }

        /* FIXED ACTIVE PAGE STYLE */
        .active-page {
            background-color: #1b263b;
            border-left: 4px solid #3b82f6;
        }

        .main-content {
            margin-left: 240px;
            padding: 30px;
        }

        .card-box {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0px 2px 8px rgba(0,0,0,0.05);
        }

        .form-control,
        .form-select {
            margin-bottom: 15px;
            border-radius: 10px;
            height: 45px;
        }

        textarea.form-control {
            height: 120px !important;
            resize: none;
        }

        .btn-post {
            background-color: #0d1b2a;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 10px;
        }

        .btn-post:hover {
            background-color: #1b263b;
        }

    </style>

</head>

<body>

<form id="form1" runat="server">

    <!-- SIDEBAR -->
    <div class="sidebar">

        <h2>Lecturer</h2>

        <a href="LectureProfile.aspx">Dashboard</a>
        <a href="Grades.aspx">Grades</a>
        <a href="LecturerMonitorAcademicProgress.aspx">
            Academic Progress
        </a>
        <a href="LecturerPostAnnouncement.aspx">
            Announcements
        </a>

        <a href="LecturerCourseMaterials.aspx" class="active-page">
            Course Materials
        </a>
        <a href="LecturerAttendanceTrack.aspx">
            Students
        </a>
        <a href="Login.aspx">
            Logout
        </a>

    </div>

    <!-- MAIN -->
    <div class="main-content">

        <h1 class="mb-4">Post Course Materials</h1>

        <div class="card-box">

            <!-- TITLE -->
            <label>Material Title</label>

            <asp:TextBox ID="txtTitle"
                runat="server"
                CssClass="form-control">
            </asp:TextBox>

            <!-- COURSE -->
            <label>Select Course</label>

            <asp:DropDownList ID="ddlCourse"
                runat="server"
                CssClass="form-select">

                <asp:ListItem>CS401 - Software Engineering</asp:ListItem>
                <asp:ListItem>CS402 - Database Systems</asp:ListItem>
                <asp:ListItem>CS403 - Machine Learning</asp:ListItem>

            </asp:DropDownList>

            <!-- DESCRIPTION -->
            <label>Description</label>

            <asp:TextBox ID="txtDescription"
                runat="server"
                TextMode="MultiLine"
                CssClass="form-control">
            </asp:TextBox>

            <!-- FILE UPLOAD -->
            <label>Upload File</label>

            <asp:FileUpload ID="fileUpload"
                runat="server"
                CssClass="form-control" />

            <!-- SCHEDULE DATE -->
            <label>Schedule Publish Date</label>

            <asp:TextBox ID="txtDate"
                runat="server"
                TextMode="Date"
                CssClass="form-control">
            </asp:TextBox>

            <!-- BUTTON -->
            <asp:Button ID="btnPost"
                runat="server"
                Text="Post Material"
                CssClass="btn-post w-100"
                OnClick="btnPost_Click" />

        </div>

    </div>

</form>

</body>
</html>