<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "My Service Requests");
    List<RequestBean> requests = (List<RequestBean>) request.getAttribute("requests");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String selStatus = (String) request.getAttribute("selectedStatus");
    String selCat = (String) request.getAttribute("selectedCategory");
    String selPrio = (String) request.getAttribute("selectedPriority");
    String searchQuery = (String) request.getAttribute("searchQuery");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (totalCount == null) totalCount = 0;
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Requests - CampusFlow</title>
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
                    <h1 class="page-title">My Service Requests</h1>
                    <p class="page-description">Search, track progress, review staff remarks, and manage submitted tickets.</p>
                </div>
                <div>
                    <a href="<%= cp %>/student/request/create" class="btn btn-primary">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        <span>New Request</span>
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <!-- Filter & Search Bar -->
            <form action="<%= cp %>/student/requests" method="GET" class="filter-bar">
                <div class="filter-item" style="flex: 1; min-width: 200px;">
                    <input type="text" name="search" class="form-control" placeholder="Search by ID, title, or location..."
                           value="<%= searchQuery != null ? SecurityUtil.escapeHtml(searchQuery) : "" %>">
                </div>

                <div class="filter-item">
                    <select name="status" class="form-control" style="width: auto;">
                        <option value="ALL">All Statuses</option>
                        <option value="SUBMITTED" <%= "SUBMITTED".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Submitted</option>
                        <option value="ASSIGNED" <%= "ASSIGNED".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Assigned</option>
                        <option value="IN_PROGRESS" <%= "IN_PROGRESS".equalsIgnoreCase(selStatus) ? "selected" : "" %>>In Progress</option>
                        <option value="RESOLVED" <%= "RESOLVED".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Resolved</option>
                        <option value="CLOSED" <%= "CLOSED".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Closed</option>
                        <option value="CANCELLED" <%= "CANCELLED".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Cancelled</option>
                    </select>
                </div>

                <div class="filter-item">
                    <select name="priority" class="form-control" style="width: auto;">
                        <option value="ALL">All Priorities</option>
                        <option value="LOW" <%= "LOW".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Low</option>
                        <option value="MEDIUM" <%= "MEDIUM".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Medium</option>
                        <option value="HIGH" <%= "HIGH".equalsIgnoreCase(selPrio) ? "selected" : "" %>>High</option>
                        <option value="CRITICAL" <%= "CRITICAL".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Critical</option>
                    </select>
                </div>

                <div class="filter-item">
                    <button type="submit" class="btn btn-secondary">Filter</button>
                    <a href="<%= cp %>/student/requests" class="btn btn-secondary">Reset</a>
                </div>
            </form>

            <!-- Table Card -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Submitted Tickets (<%= totalCount %>)</span>
                    <span style="font-size: 0.8125rem; color: var(--text-subtle);">Showing Page <%= currentPage %> of <%= totalPages %></span>
                </div>
                <div class="card-body" style="padding: 0;">
                    <% if (requests == null || requests.isEmpty()) { %>
                        <div class="empty-state">
                            <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/>
                            </svg>
                            <h3 class="empty-state-title">No Requests Found</h3>
                            <p class="empty-state-desc">No tickets matched your filter criteria or search query.</p>
                            <a href="<%= cp %>/student/requests" class="btn btn-secondary btn-sm">Clear Filters</a>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Tracking ID</th>
                                        <th>Title</th>
                                        <th>Category</th>
                                        <th>Location</th>
                                        <th>Priority</th>
                                        <th>Status</th>
                                        <th>Submitted</th>
                                        <th style="text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (RequestBean r : requests) { %>
                                        <tr>
                                            <td style="font-family: var(--font-mono); font-weight: 600; color: var(--primary-700);">
                                                <%= r.getTrackingCode() %>
                                            </td>
                                            <td style="font-weight: 600;">
                                                <a href="<%= cp %>/student/request/details?id=<%= r.getRequestId() %>">
                                                    <%= SecurityUtil.escapeHtml(r.getTitle()) %>
                                                </a>
                                            </td>
                                            <td><%= SecurityUtil.escapeHtml(r.getCategory()) %></td>
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

                        <!-- Pagination -->
                        <% if (totalPages > 1) { %>
                            <div style="padding: 1rem 1.25rem;">
                                <div class="pagination">
                                    <% for (int p = 1; p <= totalPages; p++) { %>
                                        <a href="<%= cp %>/student/requests?page=<%= p %>&status=<%= selStatus != null ? selStatus : "" %>&category=<%= selCat != null ? selCat : "" %>&priority=<%= selPrio != null ? selPrio : "" %>&search=<%= searchQuery != null ? searchQuery : "" %>"
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
