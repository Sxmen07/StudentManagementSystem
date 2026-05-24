<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerAttendanceTrack.aspx.cs" Inherits="StudentManagementPersonal.LecturerAttendanceTrack" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Lecturer Attendance Track</title>

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

        .card-box {
            background: white;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0px 2px 8px rgba(0,0,0,0.05);
        }

        .table-box {
            background: white;
            padding: 20px;
            border-radius: 12px;
            margin-top: 20px;
            box-shadow: 0px 2px 8px rgba(0,0,0,0.05);
        }

        .form-control,
        .form-select {
            border-radius: 10px;
            height: 45px;
        }

        .btn-save {
            background-color: #0d1b2a;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 10px;
        }

        .btn-save:hover {
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

        <a href="LecturerCourseMaterials.aspx">
            Course Materials
        </a>

        <a href="LecturerAttendanceTrack.aspx" class="active-page">
            Students
        </a>

        <a href="Login.aspx">Logout</a>

    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">

        <h1 class="mb-4">Attendance Tracking</h1>

        <!-- SUMMARY CARDS -->
        <div class="row">

            <div class="col-md-4">
                <div class="card-box">
                    <h5>Total Students</h5>

                    <h3>
                        <asp:Label ID="lblTotalStudents"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </h3>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-box">
                    <h5>Present Rate</h5>

                    <h3>
                        <asp:Label ID="lblPresentRate"
                            runat="server"
                            Text="0%">
                        </asp:Label>
                    </h3>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-box">
                    <h5>Absent Students</h5>

                    <h3>
                        <asp:Label ID="lblAbsent"
                            runat="server"
                            Text="0">
                        </asp:Label>
                    </h3>
                </div>
            </div>

        </div>

        <!-- FILTER SECTION -->
        <div class="table-box mt-4">

            <div class="row mb-4">

                <div class="col-md-4">

                    <label>Select Course</label>

                    <asp:DropDownList ID="ddlCourse"
                        runat="server"
                        CssClass="form-select">

                        <asp:ListItem>CS401 - Software Engineering</asp:ListItem>
                        <asp:ListItem>CS402 - Database Systems</asp:ListItem>
                        <asp:ListItem>CS403 - Machine Learning</asp:ListItem>

                    </asp:DropDownList>

                </div>

                <div class="col-md-4">

                    <label>Select Date</label>

                    <asp:TextBox ID="txtDate"
                        runat="server"
                        TextMode="Date"
                        CssClass="form-control">
                    </asp:TextBox>

                </div>

            </div>

            <!-- ATTENDANCE TABLE -->
            <asp:GridView ID="gvAttendance"
                runat="server"
                CssClass="table table-bordered table-hover"
                AutoGenerateColumns="False">

                <Columns>

                    <asp:BoundField DataField="StudentID" HeaderText="Student ID" />

                    <asp:BoundField DataField="StudentName" HeaderText="Student Name" />

                    <asp:BoundField DataField="Course" HeaderText="Course" />

                    <asp:TemplateField HeaderText="Attendance Status">

                        <ItemTemplate>

                            <asp:DropDownList ID="ddlStatus"
                                runat="server"
                                CssClass="form-select">

                                <asp:ListItem>Present</asp:ListItem>
                                <asp:ListItem>Absent</asp:ListItem>
                                <asp:ListItem>Late</asp:ListItem>

                            </asp:DropDownList>

                        </ItemTemplate>

                    </asp:TemplateField>

                </Columns>

            </asp:GridView>

            <!-- SAVE BUTTON -->
            <div class="mt-4">

                <asp:Button ID="btnSaveAttendance"
                    runat="server"
                    Text="Save Attendance"
                    CssClass="btn-save"
                    OnClick="btnSaveAttendance_Click" />

            </div>

        </div>

    </div>

</form>

</body>
</html>