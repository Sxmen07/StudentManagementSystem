<%@ Page Title="Course Enrollment" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseEnrol.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseEnrol" %>

<asp:Content ID="Content1" ContentPlaceHolderID="NavigationBar" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

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
        .btn-pay {
            background-color: #10b981;
            color: white;
            padding: 0.5rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 600;
            transition: background-color 0.15s ease;
        }
        .btn-pay:hover {
            background-color: #059669;
        }
        .btn-cancel {
            background-color: #f3f4f6;
            color: #374151;
            padding: 0.5rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 600;
            transition: background-color 0.15s ease;
        }
        .btn-cancel:hover {
            background-color: #e5e7eb;
        }
    </style>

    <div class="px-4 sm:px-6 lg:px-8 py-8 relative">

        <div class="mb-8">
            <h1 class="text-3xl font-bold text-gray-900 tracking-tight">Course Enrollment</h1>
            <p class="text-gray-500 mt-1 font-medium">Manage your academic schedule, enroll in new courses, or view your history.</p>
        </div>

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

                <div class="flex border-b border-gray-200 mb-6">
                    <asp:LinkButton ID="btnMyEnrollments" runat="server" OnClick="tabMyEnrollments_Click" Text="Current Enrollments"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                    <asp:LinkButton ID="btnAvailable" runat="server" OnClick="tabAvailable_Click" Text="Available Courses"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                    <asp:LinkButton ID="btnDropped" runat="server" OnClick="tabDropped_Click" Text="Dropped Courses"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                    <asp:LinkButton ID="btnHistory" runat="server" OnClick="tabHistory_Click" Text="Academic History"
                        CssClass="px-5 py-3 text-sm font-semibold border-b-2 transition-all duration-150 -mb-px" />
                </div>

                <!-- CURRENT ENROLLMENTS PANEL -->
                <asp:Panel ID="pnlMyEnrollments" runat="server" Visible="true">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Current Enrolled Courses</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Your currently active courses for the ongoing semester.</p>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvMyEnrollments" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" 
                                AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
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

                <!-- AVAILABLE COURSES PANEL -->
                <asp:Panel ID="pnlAvailable" runat="server" Visible="false">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Available Electives & Modules</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Offered modules available for sign‑up in the current open registration window.</p>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvAvailable" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" 
                                AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
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

                <!-- DROPPED COURSES PANEL -->
                <asp:Panel ID="pnlDropped" runat="server" Visible="false">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Withdrawn & Dropped Modules</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Modules dropped during this term session. You can re‑enroll if slots and dates permit.</p>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvDropped" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" 
                                AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
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

                <!-- ACADEMIC HISTORY PANEL -->
                <asp:Panel ID="pnlHistory" runat="server" Visible="false">
                    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                        <div class="p-5 border-b border-gray-200 bg-white">
                            <h3 class="text-lg font-bold text-gray-900">Completed Academic History</h3>
                            <p class="text-xs text-gray-500 mt-0.5">Historical timeline tracking all courses completed throughout your university curriculum timeline.</p>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False" CssClass="min-w-full divide-y divide-gray-200"
                                RowStyle-CssClass="hover:bg-gray-50 transition border-b border-gray-200" 
                                AlternatingRowStyle-CssClass="bg-gray-50" GridLines="None">
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

                <!-- PAYMENT MODAL -->
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
                        <div class="p-6 bg-gray-50 border-t border-gray-100 flex items-center justify-between">
                            <div>
                                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Total Due Amount</p>
                                <p class="text-2xl font-black text-emerald-600 mt-0.5">RM <asp:Label ID="lblModalTotal" runat="server" Text="0.00" /></p>
                            </div>
                            <div class="flex gap-3">
                                <button type="button" class="btn-cancel" onclick="closePaymentModal()">Cancel</button>
                                <asp:LinkButton ID="btnConfirmPayment" runat="server" CssClass="btn-pay" OnClick="btnConfirmPayment_Click">Confirm Payment</asp:LinkButton>
                            </div>
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

        function pageLoad() {
            // Re-apply styles on async postbacks
            document.querySelectorAll('input[value="Closed"]').forEach(function (btn) {
                btn.classList.add('bg-gray-100', 'text-gray-400', 'border-gray-200', 'cursor-not-allowed');
                btn.classList.remove('text-indigo-600', 'bg-indigo-50', 'hover:bg-indigo-100', 'border-indigo-200');
            });
        }
    </script>

</asp:Content>
