<%@ Page Title="Course Enrollment" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseEnrol.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseEnrol" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style type="text/css">
        .stat-card { transition: all 0.25s ease-in-out; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); }
        .section-card { transition: all 0.2s ease-in-out; }
        .section-card:hover { box-shadow: 0 8px 20px rgba(0,0,0,0.06); }
        .btn-pay { background-color: #10b981; color: white; padding: 0.5rem 1.25rem; border-radius: 0.5rem; font-weight: 600; transition: background-color 0.15s ease; }
        .btn-pay:hover { background-color: #059669; }
        .btn-cancel { background-color: #f3f4f6; color: #374151; padding: 0.5rem 1.25rem; border-radius: 0.5rem; font-weight: 600; transition: background-color 0.15s ease; }
        .btn-cancel:hover { background-color: #e5e7eb; }

        /* Floating button – expand on hover */
        .float-btn {
            display: inline-flex !important;
            align-items: center;
            justify-content: center;
            background-color: #0095FD !important;
            color: white !important;
            border-radius: 9999px;
            padding: 0 !important;
            width: 56px;
            height: 56px;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            overflow: hidden;
            white-space: nowrap;
            box-shadow: 0 8px 25px rgba(0, 149, 253, 0.4);
            text-decoration: none !important;
            cursor: pointer;
        }
        .float-btn .btn-text { display: none; margin-left: 8px; font-size: 14px; font-weight: 700; color: white; }
        .float-btn:hover { width: auto; padding: 0 24px !important; background-color: #059669 !important; box-shadow: 0 12px 35px rgba(5, 150, 105, 0.5); }
        .float-btn:hover .btn-text { display: inline-block; }

        /* Drag‑and‑drop zone styles */
        #dropZone {
            border: 2px dashed #d1d5db;
            transition: all 0.2s ease;
        }
        #dropZone.dragover {
            border-color: #0095FD;
            background-color: #f0f7ff;
        }
        #dropZone.file-selected {
            border-color: #10b981;
            background-color: #ecfdf5;
        }
        #dropZone .browse-btn {
            background-color: #0095FD;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            font-weight: 600;
            font-size: 0.875rem;
            border: none;
            cursor: pointer;
            transition: background-color 0.15s;
        }
        #dropZone .browse-btn:hover {
            background-color: #0077cc;
        }
    </style>

    <!-- ===== GRADIENT HEADER ===== -->
    <header class="bg-topbar-gradient w-full">
        <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">Course Enrollment</h1>
            <p class="text-sm mt-1">Plan your semester and register for courses</p>
        </div>
    </header>

    <div class="w-full pl-2 sm:pl-4 lg:pl-6 pr-4 sm:pr-6 lg:pr-8 py-8 relative">

        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <asp:UpdatePanel ID="upEnrollment" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-5 mb-8 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                    <div class="flex items-center gap-3.5">
                        <div class="p-3 bg-indigo-50 rounded-lg text-indigo-600">
                            <i class="fa-solid fa-calendar-check text-xl"></i>
                        </div>
                        <div>
                            <h2 class="text-sm font-semibold text-gray-500 uppercase tracking-wider">Enrollment Status</h2>
                            <p class="text-lg font-bold text-gray-900 mt-0.5">
                                <asp:Label ID="lblEnrollmentStatus" runat="server" Text="Checking system status..." />
                            </p>
                        </div>
                    </div>
                    <div class="text-left sm:text-right">
                        <span class="text-xs font-semibold text-gray-400 uppercase tracking-wider block">Current Session</span>
                        <span class="text-sm font-bold text-indigo-600 block mt-0.5">
                            <asp:Label ID="lblTargetSemester" runat="server" Text="—" />
                        </span>
                    </div>
                </div>

                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                    <div class="stat-card bg-white p-5 rounded-xl border border-gray-200 shadow-sm text-center">
                        <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Enrolled Courses</p>
                        <p class="text-3xl font-black text-[#0095FD] mt-1"><asp:Label ID="lblEnrollmentCount" runat="server" Text="0" /></p>
                    </div>
                    <div class="stat-card bg-white p-5 rounded-xl border border-gray-200 shadow-sm text-center">
                        <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Credits Earned</p>
                        <p class="text-3xl font-black text-green-600 mt-1"><asp:Label ID="lblCreditsEarned" runat="server" Text="0" /></p>
                    </div>
                    <div class="stat-card bg-white p-5 rounded-xl border border-gray-200 shadow-sm text-center">
                        <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Required Credits</p>
                        <p class="text-3xl font-black text-red-500 mt-1"><asp:Label ID="lblTotalRequiredCredits" runat="server" Text="0" /></p>
                    </div>
                    <div class="stat-card bg-white p-5 rounded-xl border border-gray-200 shadow-sm text-center">
                        <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Current GPA</p>
                        <p class="text-3xl font-black text-indigo-600 mt-1"><asp:Label ID="lblCurrentGPA" runat="server" Text="0.00" /></p>
                    </div>
                </div>

                <!-- TABS -->
                <div class="flex flex-wrap border-b border-gray-200 mb-6 gap-1">
                    <asp:LinkButton ID="btnMyEnrollments" runat="server" OnClick="tabMyEnrollments_Click" Text="Current Enrollments"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                    <asp:LinkButton ID="btnAvailable" runat="server" OnClick="tabAvailable_Click" Text="Available Courses"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                    <asp:LinkButton ID="btnDropped" runat="server" OnClick="tabDropped_Click" Text="Dropped Courses"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                    <asp:LinkButton ID="btnHistory" runat="server" OnClick="tabHistory_Click" Text="Academic History"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                    <asp:LinkButton ID="btnPaymentHistory" runat="server" OnClick="tabPaymentHistory_Click" Text="Payment History"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                </div>

                <!-- PANEL: CURRENT ENROLLMENTS -->
                <asp:Panel ID="pnlMyEnrollments" runat="server" Visible="true">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Current Enrolled Courses</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Your currently active courses for the ongoing semester.</p>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvMyEnrollments" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="CourseCode" HeaderText="Course Code">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm font-medium text-gray-900" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="CourseName" HeaderText="Course Name">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 text-sm text-gray-700" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="Credits" HeaderText="Credits">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center text-gray-600" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="LecturerName" HeaderText="Lecturer">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 text-sm text-gray-600" />
                                    </asp:BoundField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemTemplate>
                                            <asp:Button ID="btnDrop" runat="server" Text="Drop Course" CommandArgument='<%# Eval("CourseOfferID") %>' OnClick="DropCourse_Click" 
                                                CssClass="px-3.5 py-1.5 text-xs font-semibold text-red-600 bg-red-50 hover:bg-red-100 border border-red-200 rounded-lg transition-colors duration-150 cursor-pointer"
                                                OnClientClick="return confirm('Are you sure you want to drop this course?');" />
                                        </ItemTemplate>
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center" />
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                        <asp:Label ID="lblNoEnrollments" runat="server" CssClass="block text-center py-10 text-gray-500 text-sm font-medium" Visible="false" Text="You are not enrolled in any courses for this semester." />
                    </div>
                </asp:Panel>

                <!-- PANEL: AVAILABLE COURSES -->
                <asp:Panel ID="pnlAvailable" runat="server" Visible="false">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Available Electives & Modules</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Offered modules available for sign‑up in the current open registration window.</p>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvAvailable" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="CourseCode" HeaderText="Course Code">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm font-medium text-gray-900" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="CourseName" HeaderText="Course Name">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 text-sm text-gray-700" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="Credits" HeaderText="Credits">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center text-gray-600" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="LecturerName" HeaderText="Lecturer">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 text-sm text-gray-600" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="CapacityInfo" HeaderText="Availability">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center text-gray-500 font-medium" />
                                    </asp:BoundField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemTemplate>
                                            <asp:Button ID="btnEnroll" runat="server" Text="Enroll" CommandArgument='<%# Eval("CourseOfferID") %>' OnClick="EnrollCourse_Click" 
                                                Enabled='<%# Convert.ToInt32(Eval("AvailableSlots")) > 0 %>'
                                                CssClass='<%# Convert.ToInt32(Eval("AvailableSlots")) > 0 ? "px-5 py-1.5 text-xs font-semibold text-indigo-600 bg-indigo-50 hover:bg-indigo-100 border border-indigo-200 rounded-lg transition-colors duration-150 cursor-pointer" : "px-5 py-1.5 text-xs font-semibold text-gray-400 bg-gray-100 border border-gray-200 rounded-lg cursor-not-allowed" %>' />
                                        </ItemTemplate>
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center" />
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                        <asp:Label ID="lblNoAvailable" runat="server" CssClass="block text-center py-10 text-gray-500 text-sm font-medium" Visible="false" Text="No additional courses available for enrollment at this time." />
                    </div>
                </asp:Panel>

                <!-- PANEL: DROPPED COURSES -->
                <asp:Panel ID="pnlDropped" runat="server" Visible="false">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Withdrawn & Dropped Modules</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Modules dropped during this term session. You can re‑enroll if slots and dates permit.</p>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvDropped" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="CourseCode" HeaderText="Course Code">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm font-medium text-gray-900" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="CourseName" HeaderText="Course Name">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 text-sm text-gray-700" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="Credits" HeaderText="Credits">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center text-gray-600" />
                                    </asp:BoundField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemTemplate>
                                            <asp:Button ID="btnReenroll" runat="server" Text="Re‑enroll" CommandArgument='<%# Eval("CourseOfferID") %>' OnClick="ReenrollCourse_Click" 
                                                CssClass="px-4 py-1.5 text-xs font-semibold text-green-600 bg-green-50 hover:bg-green-100 border border-green-200 rounded-lg transition-colors duration-150 cursor-pointer" />
                                        </ItemTemplate>
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center" />
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                        <asp:Label ID="lblNoDropped" runat="server" CssClass="block text-center py-10 text-gray-500 text-sm font-medium" Visible="false" Text="No dropped courses on record for this semester." />
                    </div>
                </asp:Panel>

                <!-- PANEL: ACADEMIC HISTORY -->
                <asp:Panel ID="pnlHistory" runat="server" Visible="false">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Completed Academic History</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Historical timeline tracking all courses completed throughout your university curriculum timeline.</p>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="SemesterYear" HeaderText="Semester">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-gray-600" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="CourseCode" HeaderText="Code">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm font-medium text-gray-900" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="CourseName" HeaderText="Name">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 text-sm text-gray-700" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="Grade" HeaderText="Grade">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center font-semibold text-gray-900" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="Credits" HeaderText="Cr">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center text-gray-700" />
                                    </asp:BoundField>
                                </Columns>
                            </asp:GridView>
                        </div>
                        <asp:Label ID="lblNoHistory" runat="server" CssClass="block text-center py-10 text-gray-500 text-sm font-medium" Visible="false" Text="No completed courses yet." />
                    </div>
                </asp:Panel>

                <!-- ===== PANEL: PAYMENT HISTORY (view‑only) ===== -->
                <asp:Panel ID="pnlPaymentHistory" runat="server" Visible="false">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Payment History</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Review all your past payment submissions and their verification status.</p>
                        </div>

                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvPaymentHistory" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="ReferenceID" HeaderText="Reference ID">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm font-mono font-semibold text-gray-700" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="SemesterDisplay" HeaderText="Semester">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-gray-600" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="RM {0:N2}">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center font-bold text-gray-900" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="PaymentDate" HeaderText="Payment Date" DataFormatString="{0:yyyy-MM-dd}">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center text-gray-600" />
                                    </asp:BoundField>
                                    <asp:TemplateField HeaderText="Proof">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemTemplate>
                                            <asp:HyperLink ID="lnkProof" runat="server" 
                                                NavigateUrl='<%# ResolveUrl(Eval("PaymentProof").ToString()) %>' 
                                                Target="_blank" 
                                                CssClass="text-indigo-600 hover:text-indigo-800 font-medium text-sm"
                                                Visible='<%# !string.IsNullOrEmpty(Eval("PaymentProof")?.ToString()) %>'>
                                                View Proof
                                            </asp:HyperLink>
                                            <span class="text-gray-400 text-sm" runat="server" 
                                                Visible='<%# string.IsNullOrEmpty(Eval("PaymentProof")?.ToString()) %>'>—</span>
                                        </ItemTemplate>
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Student Status">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemTemplate>
                                            <span class='<%# GetStudentStatusBadge(Eval("StudentStatus").ToString()) %>'>
                                                <%# Eval("StudentStatus") %>
                                            </span>
                                        </ItemTemplate>
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Verification">
                                        <HeaderStyle CssClass="px-8 py-4 text-center text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemTemplate>
                                            <span class='<%# GetVerifiedStatusBadge(Eval("VerifiedStatus").ToString()) %>'>
                                                <%# Eval("VerifiedStatus") %>
                                            </span>
                                        </ItemTemplate>
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm text-center" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Comments">
                                        <HeaderStyle CssClass="px-8 py-4 text-left text-xs font-medium bg-[#0095FD] text-white uppercase tracking-wider" />
                                        <ItemTemplate>
                                            <span class="text-sm text-gray-600"><%# Eval("Comments") %></span>
                                        </ItemTemplate>
                                        <ItemStyle CssClass="px-8 py-4 whitespace-nowrap text-sm" />
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                        <asp:Label ID="lblNoPayments" runat="server" CssClass="block text-center py-10 text-gray-500 text-sm font-medium" 
                            Visible="false" Text="No payment records found." />
                    </div>
                </asp:Panel>

                <!-- ===== PAYMENT MODAL (Invoice Summary + Upload) ===== -->
                <div id="paymentModal" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center" style="display:none;">
                    <div class="bg-white rounded-xl shadow-xl border border-gray-200 max-w-lg w-full overflow-hidden mx-4">
                        <div class="p-6 border-b border-gray-100 bg-gray-50">
                            <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                                <i class="fas fa-receipt text-emerald-600"></i> Review Invoice Summary
                            </h3>
                            <p class="text-xs text-gray-500 mt-1">Please confirm tuition amounts before executing secure transaction gateways.</p>
                        </div>
                        <div class="p-6 max-h-60 overflow-y-auto">
                            <asp:Repeater ID="rptPaymentCourses" runat="server">
                                <ItemTemplate>
                                    <div class="flex items-center justify-between py-2.5 border-b border-gray-100 last:border-0">
                                        <div>
                                            <p class="text-sm font-bold text-gray-800"><%# Eval("CourseCode") %></p>
                                            <p class="text-xs text-gray-500 mt-0.5"><%# Eval("CourseName") %></p>
                                        </div>
                                        <p class="text-sm font-black text-gray-900">RM <%# Convert.ToDecimal(Eval("Price")).ToString("N2") %></p>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <div class="p-6 bg-gray-50 border-t border-gray-100">
                            <div>
                                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Total Due Amount</p>
                                <p class="text-2xl font-black text-emerald-600 mt-0.5">RM <asp:Label ID="lblModalTotal" runat="server" Text="0.00" /></p>
                            </div>

                            <!-- ===== NEW DRAG‑AND‑DROP UPLOAD ZONE ===== -->
                            <div class="mt-4 pt-4 border-t border-gray-200">
                                <p class="text-sm font-semibold text-gray-700 mb-2">Upload Payment Receipt</p>
                                <div class="space-y-3">
                                    <div>
                                        <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider">Amount Paid</label>
                                        <asp:TextBox ID="txtPayAmount" runat="server" TextMode="Number" step="0.01" 
                                            CssClass="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#0095FD]" 
                                            placeholder="0.00" />
                                    </div>
                                    <div>
                                        <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider">Payment Date</label>
                                        <asp:TextBox ID="txtPayDate" runat="server" TextMode="Date" 
                                            CssClass="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#0095FD]" />
                                    </div>

                                    <!-- Drag‑and‑drop zone -->
                                    <div>
                                        <label class="block text-xs font-semibold text-gray-600 uppercase tracking-wider">Receipt (JPG/PNG/PDF)</label>
                                        <div id="dropZone" class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-[#0095FD] transition-colors cursor-pointer bg-gray-50">
                                            <div class="flex flex-col items-center justify-center">
                                                <i class="fas fa-cloud-upload-alt text-3xl text-gray-400 mb-2"></i>
                                                <p class="text-sm text-gray-600">Drag &amp; drop your file here, or</p>
                                                <button type="button" id="browseBtn" class="browse-btn mt-2">Browse</button>
                                                <p id="fileNameDisplay" class="mt-2 text-xs text-gray-500"></p>
                                            </div>
                                        </div>
                                        <!-- Hidden FileUpload – still used for server‑side processing -->
                                        <asp:FileUpload ID="fuPaymentProof" runat="server" style="display:none;" />
                                    </div>

                                    <asp:Label ID="lblModalStatus" runat="server" CssClass="text-sm font-medium" />
                                </div>
                            </div>
                        </div>
                        <div class="p-6 bg-gray-50 border-t border-gray-100 flex justify-end gap-3">
                            <button type="button" class="btn-cancel" onclick="closePaymentModal()">Cancel</button>
                            <asp:LinkButton ID="btnConfirmPayment" runat="server" CssClass="btn-pay" OnClick="btnConfirmPayment_Click">
                                <i class="fas fa-upload mr-2"></i> Confirm Payment
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>

                <!-- FLOATING PAYMENT BUTTON -->
                <asp:Panel ID="pnlFloatingPayment" runat="server" CssClass="fixed bottom-8 right-8 z-50">
                    <asp:LinkButton ID="btnPayFloating" runat="server" 
                        CssClass="float-btn"
                        OnClick="btnPayAll_Click"
                        Text="<i class='fas fa-credit-card text-lg'></i><span class='btn-text'> Payment</span>" />
                </asp:Panel>

            </ContentTemplate>
        </asp:UpdatePanel>

    </div>

    <script type="text/javascript">
        function openPaymentModal() {
            var modal = document.getElementById('paymentModal');
            if (modal) modal.style.display = 'flex';
        }
        function closePaymentModal() {
            var modal = document.getElementById('paymentModal');
            if (modal) modal.style.display = 'none';
        }

        // Drag‑and‑drop initialisation
        function initFileUpload() {
            var dropZone = document.getElementById('dropZone');
            var fileInput = document.getElementById('<%= fuPaymentProof.ClientID %>');
            var browseBtn = document.getElementById('browseBtn');
            var fileNameDisplay = document.getElementById('fileNameDisplay');

            if (!dropZone || !fileInput) return;

            // Click on drop zone (except on the browse button) opens file picker
            dropZone.addEventListener('click', function (e) {
                if (e.target !== browseBtn) {
                    fileInput.click();
                }
            });
            browseBtn.addEventListener('click', function (e) {
                e.stopPropagation();
                fileInput.click();
            });

            // Drag events
            dropZone.addEventListener('dragover', function (e) {
                e.preventDefault();
                dropZone.classList.add('dragover');
            });
            dropZone.addEventListener('dragleave', function (e) {
                e.preventDefault();
                dropZone.classList.remove('dragover');
            });
            dropZone.addEventListener('drop', function (e) {
                e.preventDefault();
                dropZone.classList.remove('dragover');
                if (e.dataTransfer.files.length) {
                    fileInput.files = e.dataTransfer.files;
                    updateFileName(fileInput.files[0]);
                }
            });

            // File input change (triggered by browse or drop)
            fileInput.addEventListener('change', function () {
                if (this.files.length) {
                    updateFileName(this.files[0]);
                } else {
                    updateFileName(null);
                }
            });

            function updateFileName(file) {
                if (file) {
                    var sizeKB = (file.size / 1024).toFixed(1);
                    fileNameDisplay.textContent = file.name + ' (' + sizeKB + ' KB)';
                    dropZone.classList.add('file-selected');
                } else {
                    fileNameDisplay.textContent = '';
                    dropZone.classList.remove('file-selected');
                }
            }

            // If a file was previously selected (postback), restore the display
            // (The FileUpload control loses its value after postback, so we don't restore)
        }

        // Re‑initialise after every partial postback (UpdatePanel)
        function pageLoad() {
            initFileUpload();

            // Re‑apply styles to disabled buttons (existing code)
            document.querySelectorAll('input[value="Closed"]').forEach(function (btn) {
                btn.classList.add('bg-gray-100', 'text-gray-400', 'border-gray-200', 'cursor-not-allowed');
                btn.classList.remove('text-indigo-600', 'bg-indigo-50', 'hover:bg-indigo-100', 'border-indigo-200');
            });
        }

        // Also initialise on full page load
        window.onload = function () {
            initFileUpload();
        };
    </script>

</asp:Content>
