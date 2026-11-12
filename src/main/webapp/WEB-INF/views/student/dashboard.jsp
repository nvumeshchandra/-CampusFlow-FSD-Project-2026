<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.filter.AuthenticationFilter" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "Student Dashboard");
    UserBean student = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    List<RequestBean> recentRequests = (List<RequestBean>) request.getAttribute("recentRequests");
    Integer totalRequests = (Integer) request.getAttribute("totalRequests");
    Integer activeRequests = (Integer) request.getAttribute("activeRequests");
    Integer resolvedRequests = (Integer) request.getAttribute("resolvedRequests");
    Integer unreadNotifs = (Integer) request.getAttribute("unreadNotifs");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - CampusFlow</title>
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
                    <h1 class="page-title">Welcome back, <%= SecurityUtil.escapeHtml(student.getName().split(" ")[0]) %>!</h1>
                    <p class="page-description">Track campus maintenance, classroom IT equipment, and service requests.</p>
                </div>
                <div>
                    <a href="<%= cp %>/student/request/create" class="btn btn-primary">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        <span>Submit New Request</span>
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <!-- Metrics Grid -->
            <div class="grid-metrics">
                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Total Submitted</span>
                        <div class="metric-icon" style="background:#eff6ff;color:#2563eb;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= totalRequests != null ? totalRequests : 0 %></div>
                    <div class="metric-footer">All lifetime campus requests</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">In Progress / Active</span>
                        <div class="metric-icon" style="background:#fef3c7;color:#d97706;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= activeRequests != null ? activeRequests : 0 %></div>
                    <div class="metric-footer">Currently pending or undergoing service</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Resolved &amp; Closed</span>
                        <div class="metric-icon" style="background:#ecfdf5;color:#059669;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= resolvedRequests != null ? resolvedRequests : 0 %></div>
                    <div class="metric-footer">Successfully completed issues</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Unread Alerts</span>
                        <div class="metric-icon" style="background:#fef2f2;color:#dc2626;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= unreadNotifs != null ? unreadNotifs : 0 %></div>
                    <div class="metric-footer">
                        <a href="<%= cp %>/notifications">View Notification Center &rarr;</a>
                    </div>
                </div>
            </div>

            <!-- Recent Requests Table -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Recent Service Requests</span>
                    <a href="<%= cp %>/student/requests" class="btn btn-secondary btn-sm">View All Requests</a>
                </div>
                <div class="card-body" style="padding: 0;">
                    <% if (recentRequests == null || recentRequests.isEmpty()) { %>
                        <div class="empty-state">
                            <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                            </svg>
                            <h3 class="empty-state-title">No Requests Submitted Yet</h3>
                            <p class="empty-state-desc">You have not created any campus service or maintenance tickets yet.</p>
                            <a href="<%= cp %>/student/request/create" class="btn btn-primary btn-sm">Submit First Request</a>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Tracking ID</th>
                                        <th>Title &amp; Category</th>
                                        <th>Location</th>
                                        <th>Priority</th>
                                        <th>Status</th>
                                        <th>Created Date</th>
                                        <th style="text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (RequestBean r : recentRequests) { %>
                                        <tr>
                                            <td style="font-family: var(--font-mono); font-weight: 600; color: var(--primary-700);">
                                                <%= r.getTrackingCode() %>
                                            </td>
                                            <td>
                                                <div style="font-weight: 600;"><%= SecurityUtil.escapeHtml(r.getTitle()) %></div>
                                                <div style="font-size: 0.75rem; color: var(--text-subtle);"><%= SecurityUtil.escapeHtml(r.getCategory()) %></div>
                                            </td>
                                            <td><%= SecurityUtil.escapeHtml(r.getLocation()) %></td>
                                            <td>
                                                <span class="badge badge-<%= r.getPriority().toLowerCase() %>">
                                                    <%= r.getPriority() %>
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge badge-<%= r.getStatus().toLowerCase() %>">
                                                    <%= r.getStatus().replace('_', ' ') %>
                                                </span>
                                            </td>
                                            <td style="font-size: 0.8125rem; color: var(--text-subtle);">
                                                <%= r.getCreatedAt() %>
                                            </td>
                                            <td style="text-align: right;">
                                                <a href="<%= cp %>/student/request/details?id=<%= r.getRequestId() %>" class="btn btn-secondary btn-sm">
                                                    Details
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
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
