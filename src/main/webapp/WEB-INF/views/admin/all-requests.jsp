<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.model.DepartmentBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "Campus Requests Repository");
    List<RequestBean> requests = (List<RequestBean>) request.getAttribute("requests");
    List<DepartmentBean> departments = (List<DepartmentBean>) request.getAttribute("departments");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");

    String selStatus = (String) request.getAttribute("selectedStatus");
    String selCat = (String) request.getAttribute("selectedCategory");
    String selPrio = (String) request.getAttribute("selectedPriority");
    Long selDeptId = (Long) request.getAttribute("selectedDeptId");
    String searchQuery = (String) request.getAttribute("searchQuery");
    Boolean isUnassignedView = (Boolean) request.getAttribute("isUnassignedView");

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
    <title>All Campus Requests - CampusFlow</title>
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
                    <h1 class="page-title"><%= Boolean.TRUE.equals(isUnassignedView) ? "Unassigned Service Queue" : "All Campus Service Requests" %></h1>
                    <p class="page-description">Search, filter, assign, and manage issues across all college facilities.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <!-- Filter Bar -->
            <form action="<%= cp %>/admin/requests" method="GET" class="filter-bar">
                <div class="filter-item" style="flex: 1; min-width: 180px;">
                    <input type="text" name="search" class="form-control" placeholder="Search ID, title, student..."
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
                        <option value="CRITICAL" <%= "CRITICAL".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Critical</option>
                        <option value="HIGH" <%= "HIGH".equalsIgnoreCase(selPrio) ? "selected" : "" %>>High</option>
                        <option value="MEDIUM" <%= "MEDIUM".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Medium</option>
                        <option value="LOW" <%= "LOW".equalsIgnoreCase(selPrio) ? "selected" : "" %>>Low</option>
                    </select>
                </div>

                <div class="filter-item">
                    <select name="deptId" class="form-control" style="width: auto;">
                        <option value="">All Departments</option>
                        <% if (departments != null) {
                            for (DepartmentBean d : departments) { %>
                                <option value="<%= d.getDepartmentId() %>" <%= selDeptId != null && selDeptId.equals(d.getDepartmentId()) ? "selected" : "" %>>
                                    <%= SecurityUtil.escapeHtml(d.getDepartmentName()) %>
                                </option>
                        <%  }
                        } %>
                    </select>
                </div>

                <div class="filter-item">
                    <button type="submit" class="btn btn-secondary">Filter</button>
                    <a href="<%= cp %>/admin/requests" class="btn btn-secondary">Reset</a>
                </div>
            </form>

            <!-- Table Card -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Campus Records (<%= totalCount %>)</span>
                    <span style="font-size: 0.8125rem; color: var(--text-subtle);">Page <%= currentPage %> of <%= totalPages %></span>
                </div>
                <div class="card-body" style="padding: 0;">
                    <% if (requests == null || requests.isEmpty()) { %>
                        <div class="empty-state">
                            <h3 class="empty-state-title">No Requests Found</h3>
                            <p class="empty-state-desc">No tickets matched the specified search and filter criteria.</p>
                            <a href="<%= cp %>/admin/requests" class="btn btn-secondary btn-sm">Clear Filters</a>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Tracking ID</th>
                                        <th>Title &amp; Category</th>
                                        <th>Requester</th>
                                        <th>Location</th>
                                        <th>Priority</th>
                                        <th>Status</th>
                                        <th>Assigned Dept / Staff</th>
                                        <th>Date</th>
                                        <th style="text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (RequestBean r : requests) { %>
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
                                            <td style="font-size: 0.8125rem;">
                                                <div><%= r.getDepartmentName() != null ? SecurityUtil.escapeHtml(r.getDepartmentName()) : "<span style='color:var(--danger-main);font-weight:600;'>Unassigned</span>" %></div>
                                                <div style="color: var(--text-subtle);"><%= r.getAssignedStaffName() != null ? SecurityUtil.escapeHtml(r.getAssignedStaffName()) : "No Staff" %></div>
                                            </td>
                                            <td style="font-size: 0.8125rem; color: var(--text-subtle);">
                                                <%= r.getCreatedAt() %>
                                            </td>
                                            <td style="text-align: right;">
                                                <a href="<%= cp %>/admin/request/details?id=<%= r.getRequestId() %>" class="btn btn-secondary btn-sm">
                                                    Inspect
                                                </a>
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
                                        <a href="<%= cp %>/admin/requests?page=<%= p %>&status=<%= selStatus != null ? selStatus : "" %>&category=<%= selCat != null ? selCat : "" %>&priority=<%= selPrio != null ? selPrio : "" %>&deptId=<%= selDeptId != null ? selDeptId : "" %>&search=<%= searchQuery != null ? searchQuery : "" %>"
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
