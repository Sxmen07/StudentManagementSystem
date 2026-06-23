<%@ Page Title="Notification Details" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseNotification.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseNotification" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <header class="bg-topbar-gradient w-full">
    <div class="px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-12">
        <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold animate-welcome">
            Notification
        </h1>
        <!-- subtitle -->
        <p class=" text-sm mt-1">View and get your course materials.</p>
    </div>
</header>

    <!-- Full width container, no centering, only left/right padding -->
    <div class="w-full px-6 sm:px-8 lg:px-10 py-8">
        <!-- Back button -->
        <div class="mb-6">
            <asp:HyperLink ID="hlBackToCourse" runat="server" CssClass="inline-flex items-center text-indigo-600 hover:text-indigo-800 font-medium">
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
                Back
            </asp:HyperLink>
        </div>

        <!-- Main card – now wider because parent is not constrained -->
        <div class="overflow-hidden">
            <div class="p-6 md:p-8 lg:p-10">
                <div class="flex flex-row justify-between items-start gap-4 mb-6">
                    <h1 class="text-2xl md:text-3xl font-bold text-gray-900 break-words flex-1">
                        <asp:Label ID="lblTitle" runat="server" />
                    </h1>
                    <div class="text-sm text-gray-500 space-y-1 text-right flex-shrink-0">
                        <div class="flex items-center justify-end gap-1 whitespace-nowrap">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                            <span><asp:Label ID="lblDate" runat="server" /></span>
                        </div>
                        <div class="flex items-center justify-end gap-1 whitespace-nowrap">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                            </svg>
                            <span><asp:Label ID="lblSender" runat="server" /></span>
                        </div>
                    </div>
                </div>

                <hr class="my-4" />

                <div class="text-black whitespace-pre-line leading-relaxed text-base">
                    <asp:Label ID="lblDescription" runat="server" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>