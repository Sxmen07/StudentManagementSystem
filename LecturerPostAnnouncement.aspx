<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerPostAnnouncement.aspx.cs" Inherits="StudentManagementSystemPersonal.LecturerPostAnnouncement" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Announcements</title>

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

        .active-page {
            background-color: #1b263b;
            border-left: 4px solid #3b82f6;
        }

        .main-content {
            margin-left: 240px;
            padding: 30px;
        }

        .table-container {
            background: white;
            padding: 25px;
            border-radius: 15px;
            margin-top: 20px;
        }

        .form-control,
        .form-select {
            margin-bottom: 20px;
            border-radius: 10px;
            height: 45px;
        }

        textarea.form-control {
            height: 180px !important;
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

        .upload-box {
            border: 2px dashed #d1d5db;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            background-color: #f9fafb;
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

            <a href="LecturerMonitorAcademicProgress.aspx">Academic Progress</a>

            <a href="LecturerPostAnnouncement.aspx" class="active-page">
                Announcements
            </a>
            <a href="LecturerCourseMaterials.aspx">Course Materials</a>
            <a href="LecturerAttendanceTrack.aspx">Students</a>
            <a href="Login.aspx">Logout</a>

        </div>

        <!-- MAIN CONTENT -->
        <div class="main-content">

            <h1 class="mb-4">Post Announcement</h1>

            <div class="table-container">

                <div class="row">

                    <!-- LEFT SIDE -->
                    <div class="col-md-8">

                        <label>Announcement Title</label>

                        <asp:TextBox ID="txtTitle"
                            runat="server"
                            CssClass="form-control"
                            placeholder="Enter announcement title">
                        </asp:TextBox>

                        <label>Select Course</label>

                        <asp:DropDownList ID="ddlCourse"
                            runat="server"
                            CssClass="form-select">

                            <asp:ListItem>Select Course</asp:ListItem>
                            <asp:ListItem>CS401 - Software Engineering</asp:ListItem>
                            <asp:ListItem>CS402 - Database Systems</asp:ListItem>
                            <asp:ListItem>CS403 - Machine Learning</asp:ListItem>

                        </asp:DropDownList>

                        <label>Announcement Message</label>

                        <asp:TextBox ID="txtMessage"
                            runat="server"
                            TextMode="MultiLine"
                            CssClass="form-control"
                            placeholder="Write announcement here...">
                        </asp:TextBox>

                        <label>Schedule Date</label>

                        <asp:TextBox ID="txtDate"
                            runat="server"
                            TextMode="Date"
                            CssClass="form-control">
                        </asp:TextBox>

                    </div>

                    <!-- RIGHT SIDE -->
                    <div class="col-md-4">

                        <div class="upload-box">

                            <h5 class="mb-3">Upload Attachment</h5>

                            <p class="text-muted">
                                Upload PDF, Slides or Documents
                            </p>

                            <asp:FileUpload ID="fileUpload"
                                runat="server"
                                CssClass="form-control" />

                        </div>

                        <!-- ANNOUNCEMENT TYPE -->
                        <div class="mt-4">

                            <label>Announcement Type</label>

                            <asp:DropDownList ID="ddlType"
                                runat="server"
                                CssClass="form-select">

                                <asp:ListItem>General</asp:ListItem>
                                <asp:ListItem>Attendance Alert</asp:ListItem>
                                <asp:ListItem>Assignment Reminder</asp:ListItem>
                                <asp:ListItem>Exam Result</asp:ListItem>

                            </asp:DropDownList>

                        </div>

                        <!-- SEND OPTION -->
                        <div class="mt-4">

                            <label>Send To</label>

                            <asp:DropDownList ID="ddlSendOption"
                                runat="server"
                                CssClass="form-select"
                                AutoPostBack="true"
                                OnSelectedIndexChanged="ddlSendOption_SelectedIndexChanged">

                                <asp:ListItem>All Students</asp:ListItem>
                                <asp:ListItem>Single Student</asp:ListItem>

                            </asp:DropDownList>

                        </div>

                        <!-- STUDENT SELECTION -->
                        <asp:Panel ID="pnlStudentSelect"
                            runat="server"
                            Visible="false">

                            <label>Select Student</label>

                            <asp:DropDownList ID="ddlStudents"
                                runat="server"
                                CssClass="form-select">

                                <asp:ListItem>Select Student</asp:ListItem>
                                <asp:ListItem>ST001 - Adrian Lim</asp:ListItem>
                                <asp:ListItem>ST002 - Sarah Tan</asp:ListItem>
                                <asp:ListItem>ST003 - Daniel Lee</asp:ListItem>
                                <asp:ListItem>ST004 - Amanda Wong</asp:ListItem>

                            </asp:DropDownList>

                        </asp:Panel>

                        <!-- BUTTON -->
                        <div class="d-grid mt-4">

                            <asp:Button ID="btnPost"
                                runat="server"
                                Text="Post Announcement"
                                CssClass="btn-post"
                                OnClick="btnPost_Click" />

                        </div>

                    </div>

                </div>

            </div>

        </div>

    </form>

</body>
</html>