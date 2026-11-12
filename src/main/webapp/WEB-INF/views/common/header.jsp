<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.filter.AuthenticationFilter" %>
<%@ page import="com.campusflow.dao.NotificationDAO" %>
<%
    UserBean headerUser = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    String contextPath = request.getContextPath();
    int headerUnreadCount = 0;
    if (headerUser != null) {
        NotificationDAO notifDAO = new NotificationDAO();
        headerUnreadCount = notifDAO.countUnread(headerUser.getUserId());
    }
%>
<header class="app-topbar">
    <div class="topbar-left">
        <button class="btn-sidebar-toggle" aria-label="Toggle Navigation">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/>
            </svg>
        </button>

        <div class="breadcrumb">
            <span>CampusFlow</span>
            <span class="breadcrumb-separator">/</span>
            <span class="breadcrumb-current"><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Portal" %></span>
        </div>
    </div>

    <div class="topbar-right">
        <% if (headerUser != null) { %>
            <a href="<%= contextPath %>/notifications" class="notif-bell-btn" title="View In-App Notifications">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>
                </svg>
                <% if (headerUnreadCount > 0) { %>
                    <span class="notif-count-badge"><%= headerUnreadCount %></span>
                <% } %>
            </a>

            <a href="<%= contextPath %>/profile" class="btn btn-secondary btn-sm" style="display: flex; align-items: center; gap: 0.5rem;">
                <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: #10b981;"></span>
                <span><%= com.campusflow.util.SecurityUtil.escapeHtml(headerUser.getName().split(" ")[0]) %></span>
            </a>
        <% } %>
    </div>
</header>
