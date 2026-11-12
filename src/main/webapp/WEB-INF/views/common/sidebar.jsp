<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.filter.AuthenticationFilter" %>
<%
    UserBean currentUser = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    String currentUri = request.getRequestURI();
    String cp = request.getContextPath();
%>
<aside class="app-sidebar">
    <div class="sidebar-brand">
        <img src="<%= cp %>/assets/images/logo.svg" alt="CampusFlow" class="sidebar-logo">
        <span class="sidebar-title">CampusFlow</span>
    </div>

    <nav class="sidebar-nav">
        <% if (currentUser != null && currentUser.isStudent()) { %>
            <div class="nav-section-title">Student Portal</div>
            <a href="<%= cp %>/student/dashboard" class="nav-item <%= currentUri.endsWith("/student/dashboard") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                <span>Dashboard</span>
            </a>
            <a href="<%= cp %>/student/request/create" class="nav-item <%= currentUri.contains("/student/request/create") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                <span>New Request</span>
            </a>
            <a href="<%= cp %>/student/requests" class="nav-item <%= (currentUri.contains("/student/requests") || currentUri.contains("/student/request/details")) && !currentUri.contains("/student/request/create") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                <span>My Requests</span>
            </a>
        <% } else if (currentUser != null && currentUser.isStaff()) { %>
            <div class="nav-section-title">Staff Portal</div>
            <a href="<%= cp %>/staff/dashboard" class="nav-item <%= currentUri.endsWith("/staff/dashboard") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                <span>My Dashboard</span>
            </a>
            <a href="<%= cp %>/staff/requests" class="nav-item <%= currentUri.contains("/staff/requests") || currentUri.contains("/staff/request/details") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                <span>Assigned Tasks</span>
            </a>
        <% } else if (currentUser != null && currentUser.isAdmin()) { %>
            <div class="nav-section-title">Operations</div>
            <a href="<%= cp %>/admin/dashboard" class="nav-item <%= currentUri.endsWith("/admin/dashboard") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                <span>Operations Dashboard</span>
            </a>
            <a href="<%= cp %>/admin/requests" class="nav-item <%= currentUri.endsWith("/admin/requests") || currentUri.contains("/admin/request/details") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                <span>All Campus Requests</span>
            </a>
            <a href="<%= cp %>/admin/unassigned" class="nav-item <%= currentUri.endsWith("/admin/unassigned") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <span>Unassigned Queue</span>
            </a>

            <div class="nav-section-title">Administration</div>
            <a href="<%= cp %>/admin/departments" class="nav-item <%= currentUri.contains("/admin/departments") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                <span>Departments</span>
            </a>
            <a href="<%= cp %>/admin/users" class="nav-item <%= currentUri.contains("/admin/users") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                <span>User Management</span>
            </a>
            <a href="<%= cp %>/admin/feedback" class="nav-item <%= currentUri.contains("/admin/feedback") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                <span>Feedback & Reviews</span>
            </a>
            <a href="<%= cp %>/admin/analytics" class="nav-item <%= currentUri.contains("/admin/analytics") ? "active" : "" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                <span>Analytics & Reports</span>
            </a>
        <% } %>

        <div class="nav-section-title">General</div>
        <a href="<%= cp %>/notifications" class="nav-item <%= currentUri.contains("/notifications") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
            <span>Notifications</span>
        </a>
        <a href="<%= cp %>/profile" class="nav-item <%= currentUri.contains("/profile") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
            <span>My Profile</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <% if (currentUser != null) { %>
            <div class="user-badge">
                <div class="user-avatar">
                    <%= currentUser.getName().substring(0, 1).toUpperCase() %>
                </div>
                <div class="user-info">
                    <div class="user-name"><%= com.campusflow.util.SecurityUtil.escapeHtml(currentUser.getName()) %></div>
                    <div class="user-role"><%= currentUser.getRole() %></div>
                </div>
            </div>
            <div style="margin-top: 0.75rem;">
                <a href="<%= cp %>/logout" class="btn btn-secondary btn-sm" style="width: 100%;">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    <span>Sign Out</span>
                </a>
            </div>
        <% } %>
    </div>
</aside>
