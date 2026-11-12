<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.service.AnalyticsService.DashboardMetrics" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "Operations Dashboard");
    DashboardMetrics m = (DashboardMetrics) request.getAttribute("metrics");
    List<RequestBean> recentRequests = (List<RequestBean>) request.getAttribute("recentRequests");
    List<RequestBean> unassignedQueue = (List<RequestBean>) request.getAttribute("unassignedQueue");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Dashboard - CampusFlow</title>
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
                    <h1 class="page-title">Campus Operations Command Center</h1>
                    <p class="page-description">Real-time Oracle metrics, dispatch queues, workload analytics, and service quality.</p>
                </div>
                <div style="display: flex; gap: 0.75rem;">
                    <a href="<%= cp %>/admin/unassigned" class="btn btn-primary btn-sm">
                        Inspect Unassigned Queue (<%= m != null ? m.getUnassignedCount() : 0 %>)
                    </a>
                    <a href="<%= cp %>/admin/analytics" class="btn btn-secondary btn-sm">
                        Deep Analytics &rarr;
                    </a>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <!-- Core Operations Metrics Tiles -->
            <div class="grid-metrics">
                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Total Requests</span>
                        <div class="metric-icon" style="background:#eff6ff;color:#2563eb;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= m != null ? m.getTotalRequests() : 0 %></div>
                    <div class="metric-footer">Across all campus departments</div>
                </div>

                <div class="metric-card" style="<%= m != null && m.getUnassignedCount() > 0 ? "border-color: #fca5a5;" : "" %>">
                    <div class="metric-header">
                        <span class="metric-title" style="<%= m != null && m.getUnassignedCount() > 0 ? "color:#b91c1c;" : "" %>">Unassigned Queue</span>
                        <div class="metric-icon" style="background:#fee2e2;color:#dc2626;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        </div>
                    </div>
                    <div class="metric-value" style="<%= m != null && m.getUnassignedCount() > 0 ? "color:#dc2626;" : "" %>">
                        <%= m != null ? m.getUnassignedCount() : 0 %>
                    </div>
                    <div class="metric-footer">Awaiting department/staff assignment</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">In Progress</span>
                        <div class="metric-icon" style="background:#fef3c7;color:#d97706;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= m != null ? m.getInProgressCount() : 0 %></div>
                    <div class="metric-footer">Under active repair</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Resolved &amp; Closed</span>
                        <div class="metric-icon" style="background:#ecfdf5;color:#059669;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                        </div>
                    </div>
                    <div class="metric-value"><%= m != null ? (m.getResolvedCount() + m.getClosedCount()) : 0 %></div>
                    <div class="metric-footer">Successfully resolved tickets</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Average Satisfaction</span>
                        <div class="metric-icon" style="background:#fffbeb;color:#f59e0b;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        </div>
                    </div>
                    <div class="metric-value">
                        <%= m != null && m.getAverageRating() > 0 ? String.format("%.1f", m.getAverageRating()) : "N/A" %>
                        <span style="font-size: 1rem; color: #f59e0b;">&#9733;</span>
                    </div>
                    <div class="metric-footer"><%= m != null ? m.getTotalFeedbackCount() : 0 %> verified student reviews</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Avg Resolution Time</span>
                        <div class="metric-icon" style="background:#f1f5f9;color:#475569;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 14 14"/></svg>
                        </div>
                    </div>
                    <div class="metric-value">
                        <%= m != null && m.getAverageResolutionHours() > 0 ? String.format("%.1f h", m.getAverageResolutionHours()) : "N/A" %>
                    </div>
                    <div class="metric-footer">Oracle TIMESTAMP computation</div>
                </div>
            </div>

            <!-- Visual Summaries: Donut & Bar Charts (Native SVG Engine) -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 1.5rem; margin-bottom: 1.5rem;">
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Status Breakdown</span>
                    </div>
                    <div class="card-body">
                        <div id="statusDonutChart" style="min-height: 200px;"></div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Top Issue Categories</span>
                    </div>
                    <div class="card-body">
                        <div id="categoryBarChart" style="min-height: 200px;"></div>
                    </div>
                </div>
            </div>

            <!-- Unassigned Queue Immediate Dispatch Table -->
            <% if (unassignedQueue != null && !unassignedQueue.isEmpty()) { %>
                <div class="card" style="border: 1px solid #fca5a5;">
                    <div class="card-header" style="background: #fff5f5;">
                        <span class="card-title" style="color: #991b1b;">Immediate Action Required &mdash; Unassigned Queue</span>
                        <a href="<%= cp %>/admin/unassigned" class="btn btn-danger btn-sm">View All Unassigned</a>
                    </div>
                    <div class="card-body" style="padding: 0;">
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Tracking ID</th>
                                        <th>Title &amp; Category</th>
                                        <th>Location</th>
                                        <th>Priority</th>
                                        <th>Submitted By</th>
                                        <th>Date</th>
                                        <th style="text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (RequestBean r : unassignedQueue) { %>
                                        <tr>
                                            <td style="font-family: var(--font-mono); font-weight: 600; color: #dc2626;">
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
                                            <td><%= SecurityUtil.escapeHtml(r.getRequesterName()) %></td>
                                            <td style="font-size: 0.8125rem; color: var(--text-subtle);"><%= r.getCreatedAt() %></td>
                                            <td style="text-align: right;">
                                                <a href="<%= cp %>/admin/request/details?id=<%= r.getRequestId() %>" class="btn btn-primary btn-sm">
                                                    Assign Now
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            <% } %>

            <!-- Recent Campus Requests Table -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Recent Campus-Wide Requests</span>
                    <a href="<%= cp %>/admin/requests" class="btn btn-secondary btn-sm">View All Requests</a>
                </div>
                <div class="card-body" style="padding: 0;">
                    <% if (recentRequests == null || recentRequests.isEmpty()) { %>
                        <div class="empty-state">
                            <h3 class="empty-state-title">No Requests in Database</h3>
                            <p class="empty-state-desc">The college service queue is empty.</p>
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
                                        <th>Assigned Dept / Staff</th>
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
                                            <td style="font-size: 0.8125rem;">
                                                <div><%= r.getDepartmentName() != null ? SecurityUtil.escapeHtml(r.getDepartmentName()) : "<span style='color:var(--text-subtle);'>None</span>" %></div>
                                                <div style="color: var(--text-subtle);"><%= r.getAssignedStaffName() != null ? SecurityUtil.escapeHtml(r.getAssignedStaffName()) : "Unassigned" %></div>
                                            </td>
                                            <td style="text-align: right;">
                                                <a href="<%= cp %>/admin/request/details?id=<%= r.getRequestId() %>" class="btn btn-secondary btn-sm">
                                                    Manage
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
<script src="<%= cp %>/assets/js/charts.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        // Render Donut Chart for Status Distribution
        var statusData = [
            { label: "Submitted", value: <%= m != null ? m.getSubmittedCount() : 0 %> },
            { label: "Assigned", value: <%= m != null ? m.getAssignedCount() : 0 %> },
            { label: "In Progress", value: <%= m != null ? m.getInProgressCount() : 0 %> },
            { label: "Resolved", value: <%= m != null ? m.getResolvedCount() : 0 %> },
            { label: "Closed", value: <%= m != null ? m.getClosedCount() : 0 %> },
            { label: "Cancelled", value: <%= m != null ? m.getCancelledCount() : 0 %> }
        ];
        CampusFlowCharts.renderDonut("statusDonutChart", statusData, ["#0284c7", "#6366f1", "#f59e0b", "#10b981", "#64748b", "#ef4444"]);

        // Render Bar Chart for Top Categories
        var catData = [
            <% if (m != null && m.getCategoryDistribution() != null) {
                int count = 0;
                for (Map.Entry<String, Integer> entry : m.getCategoryDistribution().entrySet()) {
                    if (count++ >= 6) break;
            %>
                { label: "<%= SecurityUtil.escapeHtml(entry.getKey()) %>", value: <%= entry.getValue() %> },
            <%  }
            } %>
        ];
        CampusFlowCharts.renderBars("categoryBarChart", catData, "#2563eb");
    });
</script>
</body>
</html>
