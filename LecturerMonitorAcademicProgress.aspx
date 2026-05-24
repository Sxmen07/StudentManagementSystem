<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerMonitorAcademicProgress.aspx.cs" Inherits="StudentManagementPersonal.LecturerMonitorAcademicProgress" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Monitor Academic Progress</title>

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
            border-radius: 15px;
            padding: 20px;
            color: white;
        }

        .blue {
            background-color: #3b82f6;
        }

        .green {
            background-color: #10b981;
        }

        .orange {
            background-color: #f59e0b;
        }

        .red {
            background-color: #ef4444;
        }

        .table-container {
            background: white;
            padding: 20px;
            border-radius: 15px;
            margin-top: 30px;
        }

        .search-box {
            margin-bottom: 20px;
        }

        .form-control,
        .form-select {
            border-radius: 10px;
            height: 45px;
        }

        .status-good {
            background-color: #d1fae5;
            color: #065f46;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
        }

        .status-risk {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
        }

        .btn-filter {
            background-color: #0d1b2a;
            color: white;
            border: none;
            padding: 10px 25px;
            border-radius: 10px;
        }

        .btn-filter:hover {
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

            <a href="LecturerMonitorAcademicProgress.aspx" class="active-page">
                Academic Progress
            </a>

            <a href="LecturerPostAnnouncement.aspx">Announcements</a>
            <a href="LecturerCourseMaterials.aspx">Course Materials</a>
            <a href="LecturerAttendanceTrack.aspx">Students</a>
            <a href="Login.aspx">Logout</a>

        </div>

        <!-- MAIN CONTENT -->
        <div class="main-content">

            <h1 class="mb-4">Monitor Academic Progress</h1>

            <!-- CARDS -->
            <div class="row">

                <div class="col-md-3">
                    <div class="card-box blue">
                        <h3>
                            <asp:Label ID="lblTotalStudents" runat="server"></asp:Label>
                        </h3>
                        <p>Total Students</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card-box green">
                        <h3>
                            <asp:Label ID="lblAverageAttendance" runat="server"></asp:Label>
                        </h3>
                        <p>Average Attendance</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card-box orange">
                        <h3>
                            <asp:Label ID="lblAverageGrade" runat="server"></asp:Label>
                        </h3>
                        <p>Average Grade</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card-box red">
                        <h3>
                            <asp:Label ID="lblRiskStudents" runat="server"></asp:Label>
                        </h3>
                        <p>At Risk Students</p>
                    </div>
                </div>

            </div>

            <!-- SEARCH & FILTER -->
            <div class="table-container">

                <div class="row search-box">

                    <div class="col-md-4">

                        <asp:TextBox ID="txtSearch"
                            runat="server"
                            CssClass="form-control"
                            placeholder="Search student name or ID">
                        </asp:TextBox>

                    </div>

                    <div class="col-md-3">

                        <asp:DropDownList ID="ddlFilter"
                            runat="server"
                            CssClass="form-select">

                            <asp:ListItem>All Students</asp:ListItem>
                            <asp:ListItem>At Risk</asp:ListItem>
                            <asp:ListItem>Good Performance</asp:ListItem>

                        </asp:DropDownList>

                    </div>

                    <div class="col-md-3">

                        <asp:DropDownList ID="ddlSort"
                            runat="server"
                            CssClass="form-select">

                            <asp:ListItem>Sort By</asp:ListItem>
                            <asp:ListItem>Attendance</asp:ListItem>
                            <asp:ListItem>Grade</asp:ListItem>
                            <asp:ListItem>Name</asp:ListItem>

                        </asp:DropDownList>

                    </div>

                    <div class="col-md-2">

                        <asp:Button ID="btnFilter"
                            runat="server"
                            Text="Apply"
                            CssClass="btn-filter w-100"
                            OnClick="btnFilter_Click" />

                    </div>

                </div>

                <!-- TABLE -->
                <asp:GridView ID="gvProgress"
                    runat="server"
                    CssClass="table table-bordered table-hover"
                    AutoGenerateColumns="False">

                    <Columns>

                        <asp:BoundField DataField="StudentID" HeaderText="Student ID" />

                        <asp:BoundField DataField="StudentName" HeaderText="Student Name" />

                        <asp:BoundField DataField="Attendance" HeaderText="Attendance %" />

                        <asp:BoundField DataField="CurrentGrade" HeaderText="Current Grade" />

                        <asp:TemplateField HeaderText="Risk Status">

                            <ItemTemplate>

                                <asp:Label ID="lblStatus"
                                    runat="server"
                                    Text='<%# Eval("Status") %>'
                                    CssClass='<%# Eval("Status").ToString() == "At Risk" ? "status-risk" : "status-good" %>'>
                                </asp:Label>

                            </ItemTemplate>

                        </asp:TemplateField>

                    </Columns>

                </asp:GridView>

            </div>

        </div>

    </form>

</body>
</html>