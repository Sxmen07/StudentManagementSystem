<%@ Page Title="Course Enrollment" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseEnrol.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseEnrol" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Font Awesome CDN (if not already in master) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style type="text/css">
        .stat-card {
            transition: all 0.25s ease-in-out;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
        }
        .section-card {
            transition: all 0.2s ease-in-out;
        }
        .section-card:hover {
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.06);
        }
        .gv-header-dark th {
            color: #ffffff !important;
            background-color: #111827 !important;
        }
        .btn-enroll {
            background-color: #0095FD;
            color: white;
            transition: all 0.2s;
        }
        .btn-enroll:hover {
            background-color: #0070c0;
        }
        .btn-drop {
            background-color: #dc2626;
            color: white;
            transition: all 0.2s;
        }
        .btn-drop:hover {
            background-color: #b91c1c;
        }
        .btn-reenroll {
            background-color: #16a34a;
            color: white;
            transition: all 0.2s;
        }
        .btn-reenroll:hover {
            background-color: #15803d;
        }
        .btn-closed {
            background-color: #9ca3af !important;
            color: white !important;
            cursor: not-allowed !important;
        }
    </style>

    <!-- ============================================================ -->
    <!-- GRADIENT HEADER                                               -->
    <!-- ============================================================ -->
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">Course Enrollment</h1>
            <p class="text-sm mt-1">Plan your semester and register for courses</p>
        </div>
    </header>

    <!-- ============================================================ -->
    <!-- MAIN CONTENT                                                  -->
    <!-- ============================================================ -->
    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8">

        <!-- ScriptManager – remove if your MasterPage already has one -->
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <!-- UPDATE PANEL – all changing content goes here -->
        <asp:UpdatePanel ID="upEnrollment" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <!-- Enrollment Period Alert -->
                <asp:Label ID="lblEnrollmentStatus" runat="server" CssClass="block mb-6"></asp:Label>

                <!-- 2x Summary Cards -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
                    <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                        <div class="w-10 h-10 rounded-lg bg-[#111827] flex items-center justify-center text-white text-lg flex-shrink-0">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <div>
                            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Current GPA</p>
                            <p class="text-2xl font-bold text-[#111827]">
                                <asp:Label ID="lblCurrentGPA" runat="server" Text="—" />
                            </p>
                        </div>
                    </div>
                    <div class="stat-card bg-white rounded-xl border border-gray-200 shadow-sm p-5 flex items-start gap-4">
                        <div class="w-10 h-10 rounded-lg bg-[#0095FD] flex items-center justify-center text-white text-lg flex-shrink-0">
                            <i class="fas fa-graduation-cap"></i>
                        </div>
                        <div>
                            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Credits Earned</p>
                            <p class="text-2xl font-bold text-[#0095FD]">
                                <asp:Label ID="lblCreditsEarned" runat="server" Text="0" /> / <asp:Label ID="lblTotalRequiredCredits" runat="server" Text="0" />
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Current Semester Enrollment -->
                <div class="section-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden mb-6">
                    <div class="px-6 py-4 bg-[#111827] border-b border-gray-200 flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-white">
                            <i class="fas fa-check-circle mr-2"></i>Current Semester Enrollment
                        </h3>
                    </div>
                    <div class="overflow-x-auto">
                        <asp:GridView ID="gvCurrentEnrolled" runat="server" AutoGenerateColumns="False"
                            CssClass="min-w-full bg-white text-sm"
                            HeaderStyle-CssClass="gv-header-dark"
                            RowStyle-CssClass="border-b border-gray-100 hover:bg-gray-50 transition"
                            AlternatingRowStyle-CssClass="bg-gray-50"
                            GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="px-4 py-3 font-medium text-gray-900" />
                                <asp:BoundField DataField="CourseName" HeaderText="Name" ItemStyle-CssClass="px-4 py-3 text-gray-700" />
                                <asp:BoundField DataField="Instructor" HeaderText="Instructor" ItemStyle-CssClass="px-4 py-3 text-gray-700" />
                                <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-CssClass="px-4 py-3 text-center text-gray-700" />
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:Button ID="btnDrop" runat="server" Text="Drop" CommandArgument='<%# Eval("CourseOfferID") %>'
                                            OnClick="DropCourse_Click" CssClass="btn-drop text-xs px-3 py-1 rounded" />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="px-4 py-3 text-center" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <asp:Label ID="lblNoCurrent" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="You are not enrolled in any current courses." />
                </div>

                <!-- Dropped Courses -->
                <div class="section-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden mb-6">
                    <div class="px-6 py-4 bg-[#111827] border-b border-gray-200 flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-white">
                            <i class="fas fa-times-circle mr-2"></i>Dropped Courses (This Semester)
                        </h3>
                    </div>
                    <div class="overflow-x-auto">
                        <asp:GridView ID="gvDropped" runat="server" AutoGenerateColumns="False"
                            CssClass="min-w-full bg-white text-sm"
                            HeaderStyle-CssClass="gv-header-dark"
                            RowStyle-CssClass="border-b border-gray-100 hover:bg-gray-50 transition"
                            AlternatingRowStyle-CssClass="bg-gray-50"
                            GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="px-4 py-3 font-medium text-gray-900" />
                                <asp:BoundField DataField="CourseName" HeaderText="Name" ItemStyle-CssClass="px-4 py-3 text-gray-700" />
                                <asp:BoundField DataField="Instructor" HeaderText="Instructor" ItemStyle-CssClass="px-4 py-3 text-gray-700" />
                                <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-CssClass="px-4 py-3 text-center text-gray-700" />
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:Button ID="btnReenroll" runat="server" Text="Re‑enroll" CommandArgument='<%# Eval("CourseOfferID") %>'
                                            OnClick="ReenrollCourse_Click" CssClass="btn-reenroll text-xs px-3 py-1 rounded" />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="px-4 py-3 text-center" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <asp:Label ID="lblNoDropped" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="No dropped courses for this semester." />
                </div>

                <!-- Available for Enrollment -->
                <div class="section-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden mb-6">
                    <div class="px-6 py-4 bg-[#111827] border-b border-gray-200 flex justify-between items-center">
                        <div>
                            <h3 class="text-lg font-semibold text-white">
                                <i class="fas fa-plus-circle mr-2"></i>Available for Enrollment
                            </h3>
                            <p class="text-sm text-white/70">
                                <asp:Label ID="lblTargetSemester" runat="server" Text="Next Semester" />
                            </p>
                        </div>
                    </div>
                    <div class="overflow-x-auto">
                        <asp:GridView ID="gvAvailable" runat="server" AutoGenerateColumns="False"
                            CssClass="min-w-full bg-white text-sm"
                            HeaderStyle-CssClass="gv-header-dark"
                            RowStyle-CssClass="border-b border-gray-100 hover:bg-gray-50 transition"
                            AlternatingRowStyle-CssClass="bg-gray-50"
                            GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="CourseCode" HeaderText="Code" ItemStyle-CssClass="px-4 py-3 font-medium text-gray-900" />
                                <asp:BoundField DataField="CourseName" HeaderText="Name" ItemStyle-CssClass="px-4 py-3 text-gray-700" />
                                <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-CssClass="px-4 py-3 text-center text-gray-700" />
                                <asp:BoundField DataField="Schedule" HeaderText="Schedule" ItemStyle-CssClass="px-4 py-3 text-gray-700" />
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:Button ID="btnEnroll" runat="server" Text="Enroll" CommandArgument='<%# Eval("CourseOfferID") %>'
                                            OnClick="EnrollCourse_Click" CssClass="btn-enroll text-xs px-3 py-1 rounded" />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="px-4 py-3 text-center" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <asp:Label ID="lblNoAvailable" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="No courses available for enrollment at this time." />
                </div>

                <!-- Academic History -->
                <div class="section-card bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                    <div class="px-6 py-4 bg-[#111827] border-b border-gray-200 flex justify-between items-center">
                        <h3 class="text-lg font-semibold text-white">
                            <i class="fas fa-history mr-2"></i>Academic History
                        </h3>
                    </div>
                    <div class="overflow-x-auto">
                        <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False"
                            CssClass="min-w-full bg-white text-sm"
                            HeaderStyle-CssClass="gv-header-dark"
                            RowStyle-CssClass="border-b border-gray-100 hover:bg-gray-50 transition"
                            AlternatingRowStyle-CssClass="bg-gray-50"
                            GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="SemesterYear" HeaderText="Semester" ItemStyle-CssClass="px-4 py-3 text-gray-700" />
                                <asp:BoundField DataField="CourseCode" HeaderText="Course Code" ItemStyle-CssClass="px-4 py-3 font-medium text-gray-900" />
                                <asp:BoundField DataField="CourseName" HeaderText="Course Name" ItemStyle-CssClass="px-4 py-3 text-gray-700" />
                                <asp:BoundField DataField="Grade" HeaderText="Grade" ItemStyle-CssClass="px-4 py-3 text-center font-semibold text-gray-900" />
                                <asp:BoundField DataField="Credits" HeaderText="Credits" ItemStyle-CssClass="px-4 py-3 text-center text-gray-700" />
                            </Columns>
                        </asp:GridView>
                    </div>
                    <asp:Label ID="lblNoHistory" runat="server" CssClass="block p-6 text-center text-gray-500" Visible="false" Text="No completed courses yet." />
                </div>

            </ContentTemplate>
        </asp:UpdatePanel>

    </div>

    <!-- Script to apply "Closed" class to disabled buttons -->
    <script type="text/javascript">
        (function () {
            document.querySelectorAll('input[value="Closed"]').forEach(function (btn) {
                btn.classList.add('btn-closed');
                btn.disabled = true;
            });
        })();
    </script>

</asp:Content>
