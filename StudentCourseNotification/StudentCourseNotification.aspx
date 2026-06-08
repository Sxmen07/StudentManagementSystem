<%@ Page Title="Notification Details" Language="C#" MasterPageFile="~/Student/StudentNavigationBar/StudentMaster.master" AutoEventWireup="true" CodeBehind="StudentCourseNotification.aspx.cs" Inherits="StudentManagementSystem.Student.StudentCourseNotification" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="bg-topbar-gradient h-[150px] w-full">
        <h2 class="text-[48px] font-bold text-white px-6 py-[60px] text-shadow">Notification Details</h2>
    </div>

    <div class="max-w-5xl mx-auto px-4 py-8">
        <!-- Back button -->
        <div class="mb-6">
            <asp:HyperLink ID="hlBackToCourse" runat="server" CssClass="inline-flex items-center text-indigo-600 hover:text-indigo-800 font-medium">
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
                Back to Course Material
            </asp:HyperLink>
        </div>

        <!-- Main card with Gmail-like layout -->
        <div class="bg-white rounded-xl overflow-hidden">
            <div class="p-6 md:p-8">
                <!-- Header: Title + metadata (right-aligned) -->
                <!-- Header: Title + metadata (right-aligned on same row) -->
                <div class="flex flex-row justify-between items-start gap-4 mb-6">
                    <h1 class="text-2xl md:text-3xl font-bold text-gray-900 break-words flex-1">
                        <asp:Label ID="lblTitle" runat="server" />
                    </h1>
                    <div class="text-sm text-gray-500 space-y-1 text-right flex-shrink-0">
                        <div class="flex items-center justify-end gap-1 whitespace-nowrap">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                            <span>
                                <asp:Label ID="lblDate" runat="server" /></span>
                        </div>
                        <div class="flex items-center justify-end gap-1 whitespace-nowrap">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                            </svg>
                            <span>
                                <asp:Label ID="lblSender" runat="server" /></span>
                        </div>
                    </div>
                </div>

                <!-- Divider -->
                <hr class="my-4" />

                <!-- Content -->
                <div class="text-black whitespace-pre-line leading-relaxed">
                    <asp:Label ID="lblDescription" runat="server" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
