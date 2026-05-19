<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NavigationBar.aspx.cs" Inherits="StudentManagementSystem.NavigationBar.NavigationBar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>UniTrack</title>
    <link href="/Styles/output.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v6.7.2/css/all.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Lexend:wght@100..900&family=Roboto:ital,wght@0,100..900;1,100..900&display=swap" rel="stylesheet">
</head>
<body class="bg-neutral-200 font-roboto">
    <form id="form1" runat="server" class="">
        <div class="fixed top-0 left-0 flex flex-col w-80 h-screen bg-white shadow-lg">
            <!--TOP SECTION-->
            <div class="mt-4 ml-4">

                <div class="flex items-center p-8 border-b border-gray-100">
                    <i class="fa-regular fa-circle-user text-4xl text-main-color"></i>
                    <div class="ml-4 flex-1">
                        <h2 class="text-lg font-semibold text-gray-800">NAME</h2>
                        <p class="text-sm text-gray-500">user@gmail.com</p>
                    </div>
                    <a href="/Student/StudentProfile/StudentProfile.aspx"
                        <i class="fa-solid fa-angle-down text-gray-500 cursor-pointer ml-4"></i>
                    </a>
                    </div>
                </div>

                <!--MIDDLE SECTION-->
                <div class="flex-1 overflow-y-auto mt-1 p-4 text-[18px]">
                    <a href="/Student/StudentDashboard/StudentDashboard.aspx"
                        class="flex items-center gap-4 px-4 py-2 rounded-md text-black hover:bg-main-color-100 transition">
                        <i class="fa-solid fa-gauge-high"></i>
                        <span class="align-middle">Dashboard</span>
                    </a>
                    <a href="/Student/StudentCourse/StudentCourse.aspx"
                        class="flex items-center gap-4 px-4 py-2 rounded-md text-black hover:bg-main-color-100 transition">
                        <i class="fa-solid fa-book-open"></i>
                        <span class="align-middle">Courses</span>
                    </a>
                    <a href="/Student/StudentGrade/StudentGrade.aspx"
                        class="flex items-center gap-4 px-4 py-2 rounded-md text-black hover:bg-main-color-100 transition">
                        <i class="fa-solid fa-graduation-cap"></i>
                        <span class="align-middle">Grades</span>
                    </a>
                    <a href="/Student/StudentAttendance/StudentAttendance.aspx"
                        class="flex items-center gap-4 px-4 py-2 rounded-md text-black hover:bg-main-color-100 transition">
                        <i class="fa-solid fa-clipboard-list"></i>
                        <span class="align-middle">Attendance</span>
                    </a>
                    <a href="/Student/StudentAnnoucement/StudentAnnoucement.aspx"
                        class="flex items-center gap-4 px-4 py-2 rounded-md text-black hover:bg-main-color-100 transition">
                        <i class="fa-solid fa-bullhorn"></i>
                        <span class="align-middle">Announcements</span>
                    </a>
                </div>

                <!--BOTTOM SECTION-->
                <div class="mt-auto p-4 mb-2  text-[18px]">
                    <a href="/Login.aspx"
                        class="flex items-center gap-4 px-4 py-2 rounded-md text-balck hover:bg-red hover:text-white transition">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        <span class="align-middle">Log out</span>
                    </a>
                    <a href="/ContactAdmin.aspx"
                        class="flex items-center gap-4 px-4 py-2 rounded-md text-black hover:bg-main-color-100 transition">
                        <i class="fa-solid fa-envelope"></i>
                        <span class="align-middle">Contact Admin</span>
                    </a>
                </div>
            </div>
    </form>
</body>
</html>
