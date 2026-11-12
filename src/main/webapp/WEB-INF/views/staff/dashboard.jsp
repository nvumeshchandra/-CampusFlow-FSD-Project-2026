<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.filter.AuthenticationFilter" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "Staff Assigned Tasks");
    UserBean staff = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    List<RequestBean> queue = (List<RequestBean>) request.getAttribute("assignedQueue");

    Integer totalAssigned = (Integer) request.getAttribute("totalAssigned");
    Integer pendingStart = (Integer) request.getAttribute("pendingStart");
    Integer inProgress = (Integer) request.getAttribute("inProgress");
    Integer resolvedCount = (Integer) request.getAttribute("resolvedCount");
    Integer unreadNotifs = (Integer) request.getAttribute("unreadNotifs");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");

    String selStatus = (String) request.getAttribute("selectedStatus");
    String selCat = (String) request.getAttribute("selectedCategory");
    String selPrio = (String) request.getAttribute("selectedPriority");
    String searchQuery = (String) request.getAttribute("searchQuery");

    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard - CampusFlow</title>
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
                    <h1 class="page-title">Technician &amp; Staff Dashboard</h1>
                    <p class="page-description">
                        Work queue for <strong><%= SecurityUtil.escapeHtml(staff.getName()) %></strong> &bull;
                        <%= staff.getDepartmentName() != null ? SecurityUtil.escapeHtml(staff.getDepartmentName()) : "All Departments" %>
                    </p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <!-- Workload Metric Tiles -->
            <div class="grid-metrics">
                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Total Assigned</span>
                        <div class="metric-icon" style="background:#eff6ff;color:#2563eb;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= totalAssigned != null ? totalAssigned : 0 %></div>
                    <div class="metric-footer">Lifetime assigned tickets</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Awaiting Start</span>
                        <div class="metric-icon" style="background:#fef3c7;color:#d97706;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= pendingStart != null ? pendingStart : 0 %></div>
                    <div class="metric-footer">Status: ASSIGNED</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">In Progress</span>
                        <div class="metric-icon" style="background:#e0e7ff;color:#4338ca;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= inProgress != null ? inProgress : 0 %></div>
                    <div class="metric-footer">Actively undergoing repair</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Resolved &amp; Closed</span>
                        <div class="metric-icon" style="background:#ecfdf5;color:#059669;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= resolvedCount != null ? resolvedCount : 0 %></div>
                    <div class="metric-footer">Completed service assignments</div>
                </div>
            </div>

            <!-- Filter & Search Bar -->
            <form action="<%= cp %>/staff/dashboard" method="GET" class="filter-bar">
                <div class="filter-item" style="flex: 1; min-width: 200px;">
                    <input type="text" name="search" class="form-control" placeholder="Search assigned queue..."
                           value="<%= searchQuery != null ? SecurityUtil.escapeHtml(searchQuery) : "" %>">
                </div>

                <div class="filter-item">
                    <select name="status" class="form-control" style="width: auto;">
                        <option value="ALL">All Statuses</option>
                        <option value="ASSIGNED" <%= "ASSIGNED".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Assigned (Pending Start)</option>
                        <option value="IN_PROGRESS" <%= "IN_PROGRESS".equalsIgnoreCase(selStatus) ? "selected" : "" %>>In Progress</option>
                        <option value="RESOLVED" <%= "RESOLVED".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Resolved</option>
                        <option value="CLOSED" <%= "CLOSED".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Closed</option>
                    </select>
                </div>

                <div class="filter-item">
                    <select name="priority" class="form-control" style="width: auto;">
                        <option value="ALL">All Priorities</option>
                        <option value="CRITICAL" <%= "CRITICAL".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Critical</option>
                        <option value="HIGH" <%= "HIGH".equalsIgnoreCase(selPrio) ? "selected" : "" %>>High</option>
                        <option value="MEDIUM" <%= "MEDIUM".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Medium</option>
                        <option value="LOW" <%= "LOW".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Low</option>
                    </select>
                </div>

                <div class="filter-item">
                    <button type="submit" class="btn btn-secondary">Filter</button>
                    <a href="<%= cp %>/staff/dashboard" class="btn btn-secondary">Reset</a>
                </div>
            </form>

            <!-- Assigned Task Queue -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Assigned Tasks Queue (<%= totalCount != null ? totalCount : 0 %>)</span>
                </div>
                <div class="card-body" style="padding: 0;">
                    <% if (queue == null || queue.isEmpty()) { %>
                        <div class="empty-state">
                            <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                            </svg>
                            <h3 class="empty-state-title">No Assigned Work</h3>
                            <p class="empty-state-desc">Your task queue is currently clear.</p>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Tracking ID</th>
                                        <th>Issue Title</th>
                                        <th>Student Requester</th>
                                        <th>Location</th>
                                        <th>Priority</th>
                                        <th>Status</th>
                                        <th>Assigned Date</th>
                                        <th style="text-align: right;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (RequestBean r : queue) { %>
                                        <tr>
                                            <td style="font-family: var(--font-mono); font-weight: 600; color: var(--primary-700);">
                                                <%= r.getTrackingCode() %>
                                            </td>
                                            <td>
                                                <div style="font-weight: 600;"><%= SecurityUtil.escapeHtml(r.getTitle()) %></div>
                                                <div style="font-size: 0.75rem; color: var(--text-subtle);"><%= SecurityUtil.escapeHtml(r.getCategory()) %></div>
                                            </td>
                                            <td>
                                                <div><%= SecurityUtil.escapeHtml(r.getRequesterName()) %></div>
                                                <div style="font-size: 0.75rem; color: var(--text-subtle);"><%= SecurityUtil.escapeHtml(r.getRequesterEmail()) %></div>
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
                                                <%= r.getUpdatedAt() %>
                                            </td>
                                            <td style="text-align: right;">
                                                <div style="display: flex; gap: 0.4rem; justify-content: flex-end;">
                                                    <% if ("ASSIGNED".equalsIgnoreCase(r.getStatus())) { %>
                                                        <form action="<%= cp %>/staff/request/action" method="POST" style="margin: 0;">
                                                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                                            <input type="hidden" name="requestId" value="<%= r.getRequestId() %>">
                                                            <input type="hidden" name="action" value="START_WORK">
                                                            <button type="submit" class="btn btn-primary btn-sm">Start Work</button>
                                                        </form>
                                                    <% } %>
                                                    <a href="<%= cp %>/staff/request/details?id=<%= r.getRequestId() %>" class="btn btn-secondary btn-sm">
                                                        Inspect
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>

                        <% if (totalPages > 1) { %>
                            <div style="padding: 1rem 1.25rem;">
                                <div class="pagination">
                                    <% for (int p = 1; p <= totalPages; p++) { %>
                                        <a href="<%= cp %>/staff/dashboard?page=<%= p %>&status=<%= selStatus != null ? selStatus : "" %>&category=<%= selCat != null ? selCat : "" %>&priority=<%= selPrio != null ? selPrio : "" %>&search=<%= searchQuery != null ? searchQuery : "" %>"
                                           class="pagination-link <%= p == currentPage ? "active" : "" %>">
                                            <%= p %>
                                        </a>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
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
