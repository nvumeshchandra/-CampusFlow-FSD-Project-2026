<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.NotificationBean" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.filter.AuthenticationFilter" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "In-App Notifications");
    UserBean user = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    List<NotificationBean> notifications = (List<NotificationBean>) request.getAttribute("notifications");
    Integer unreadCount = (Integer) request.getAttribute("unreadCount");
    if (unreadCount == null) unreadCount = 0;
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>In-App Notifications - CampusFlow</title>
    <link rel="stylesheet" href="<%= cp %>/assets/css/main.css">
</head>
<body data-context-path="<%= cp %>">
<div class="app-container">
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <main class="app-main">
        <jsp:include page="/WEB-INF/views/common/header.jsp" />

        <div class="page-content">
            <div class="page-header">
                <div>
                    <h1 class="page-title">Notification Center</h1>
                    <p class="page-description">Persistent database-backed campus service notifications and status alerts.</p>
                </div>
                <% if (unreadCount > 0) { %>
                    <form action="<%= cp %>/notifications" method="POST" style="margin: 0;">
                        <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                        <input type="hidden" name="action" value="MARK_ALL">
                        <button type="submit" class="btn btn-secondary btn-sm">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                            <span>Mark All as Read</span>
                        </button>
                    </form>
                <% } %>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Activity Updates (<%= notifications != null ? notifications.size() : 0 %>)</span>
                    <span style="font-size: 0.8125rem; color: var(--text-subtle);">
                        <%= unreadCount %> unread alert<%= unreadCount == 1 ? "" : "s" %>
                    </span>
                </div>
                <div class="card-body" style="padding: 0;">
                    <% if (notifications == null || notifications.isEmpty()) { %>
                        <div class="empty-state">
                            <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>
                            </svg>
                            <h3 class="empty-state-title">No Notifications</h3>
                            <p class="empty-state-desc">You are completely up to date. Service updates will appear here automatically.</p>
                        </div>
                    <% } else { %>
                        <div style="display: flex; flex-direction: column;">
                            <% for (NotificationBean n : notifications) { %>
                                <div style="display: flex; align-items: flex-start; justify-content: space-between; padding: 1rem 1.25rem; border-bottom: 1px solid var(--border-subtle); background: <%= n.isRead() ? "#ffffff" : "#f0f7ff" %>;">
                                    <div style="display: flex; gap: 0.875rem;">
                                        <div style="width: 10px; height: 10px; border-radius: 50%; margin-top: 0.35rem; background: <%= n.isRead() ? "transparent" : "#2563eb" %>; border: 1px solid <%= n.isRead() ? "var(--border-strong)" : "#2563eb" %>;"></div>
                                        <div>
                                            <div style="font-size: 0.9rem; font-weight: <%= n.isRead() ? "500" : "600" %>; color: var(--text-main);">
                                                <%= SecurityUtil.escapeHtml(n.getMessage()) %>
                                            </div>
                                            <div style="display: flex; align-items: center; gap: 0.75rem; margin-top: 0.25rem; font-size: 0.75rem; color: var(--text-subtle);">
                                                <span><%= n.getCreatedAt() %></span>
                                                <% if (n.getTrackingCode() != null) { %>
                                                    <span>&bull;</span>
                                                    <span style="font-family: var(--font-mono); font-weight: 600;"><%= n.getTrackingCode() %></span>
                                                <% } %>
                                                <span>&bull;</span>
                                                <span class="badge badge-<%= n.isRead() ? "closed" : "submitted" %>" style="font-size: 0.65rem; padding: 0.15rem 0.4rem;">
                                                    <%= n.isRead() ? "READ" : "NEW" %>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                                        <% if (n.getRequestId() != null) {
                                            String detailsPath = cp + "/student/request/details?id=" + n.getRequestId();
                                            if (user.isAdmin()) detailsPath = cp + "/admin/request/details?id=" + n.getRequestId();
                                            else if (user.isStaff()) detailsPath = cp + "/staff/request/details?id=" + n.getRequestId();
                                        %>
                                            <a href="<%= detailsPath %>" class="btn btn-secondary btn-sm" style="font-size: 0.75rem;">
                                                View Request
                                            </a>
                                        <% } %>
                                        <% if (!n.isRead()) { %>
                                            <form action="<%= cp %>/notifications" method="POST" style="margin: 0;">
                                                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                                <input type="hidden" name="action" value="MARK_ONE">
                                                <input type="hidden" name="notificationId" value="<%= n.getNotificationId() %>">
                                                <button type="submit" class="btn btn-secondary btn-sm" title="Mark as read" style="font-size: 0.75rem; padding: 0.35rem 0.5rem;">
                                                    &check;
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    </main>
</div>
<script src="<%= cp %>/assets/js/app.js"></script>
</body>
</html>
