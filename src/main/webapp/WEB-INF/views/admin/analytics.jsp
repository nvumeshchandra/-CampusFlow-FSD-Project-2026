<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.campusflow.service.AnalyticsService.DashboardMetrics" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "Operational Analytics");
    DashboardMetrics m = (DashboardMetrics) request.getAttribute("metrics");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campus Operational Analytics - CampusFlow</title>
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
                    <h1 class="page-title">Campus Operational Analytics</h1>
                    <p class="page-description">Institutional metrics queried dynamically from Oracle Database records.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <!-- Performance KPI Cards -->
            <div class="grid-metrics">
                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Total Inquiries</span>
                    </div>
                    <div class="metric-value"><%= m != null ? m.getTotalRequests() : 0 %></div>
                    <div class="metric-footer">Lifetime system records</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Avg Resolution Time</span>
                    </div>
                    <div class="metric-value">
                        <%= m != null && m.getAverageResolutionHours() > 0 ? String.format("%.1f hrs", m.getAverageResolutionHours()) : "N/A" %>
                    </div>
                    <div class="metric-footer">From submission to resolution</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Active Service Staff</span>
                    </div>
                    <div class="metric-value"><%= m != null ? m.getActiveStaffCount() : 0 %></div>
                    <div class="metric-footer">Across <%= m != null ? m.getActiveDepartmentsCount() : 0 %> departments</div>
                </div>

                <div class="metric-card">
                    <div class="metric-header">
                        <span class="metric-title">Satisfaction Rating</span>
                    </div>
                    <div class="metric-value">
                        <%= m != null && m.getAverageRating() > 0 ? String.format("%.1f", m.getAverageRating()) : "N/A" %>
                        <span style="font-size: 1.1rem; color: #f59e0b;">&#9733;</span>
                    </div>
                    <div class="metric-footer"><%= m != null ? m.getTotalFeedbackCount() : 0 %> student evaluations</div>
                </div>
            </div>

            <!-- Visual Charts Grid (Native SVG) -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 1.5rem; margin-bottom: 1.5rem;">
                <!-- Status Distribution Donut -->
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Lifecycle Status Distribution</span>
                    </div>
                    <div class="card-body">
                        <div id="analyticsStatusDonut" style="min-height: 220px;"></div>
                    </div>
                </div>

                <!-- Priority Distribution Donut -->
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Priority Level Breakdown</span>
                    </div>
                    <div class="card-body">
                        <div id="analyticsPriorityDonut" style="min-height: 220px;"></div>
                    </div>
                </div>

                <!-- Department Workloads Bar Chart -->
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Department Workload Distribution</span>
                    </div>
                    <div class="card-body">
                        <div id="analyticsDeptBars" style="min-height: 220px;"></div>
                    </div>
                </div>

                <!-- Issue Categories Bar Chart -->
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Issue Category Volume</span>
                    </div>
                    <div class="card-body">
                        <div id="analyticsCatBars" style="min-height: 220px;"></div>
                    </div>
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
        // Status Donut
        var statusData = [
            { label: "Submitted", value: <%= m != null ? m.getSubmittedCount() : 0 %> },
            { label: "Assigned", value: <%= m != null ? m.getAssignedCount() : 0 %> },
            { label: "In Progress", value: <%= m != null ? m.getInProgressCount() : 0 %> },
            { label: "Resolved", value: <%= m != null ? m.getResolvedCount() : 0 %> },
            { label: "Closed", value: <%= m != null ? m.getClosedCount() : 0 %> },
            { label: "Cancelled", value: <%= m != null ? m.getCancelledCount() : 0 %> }
        ];
        CampusFlowCharts.renderDonut("analyticsStatusDonut", statusData, ["#0284c7", "#6366f1", "#f59e0b", "#10b981", "#64748b", "#ef4444"]);

        // Priority Donut
        var prioData = [
            { label: "Critical", value: <%= m != null && m.getPriorityDistribution() != null ? m.getPriorityDistribution().getOrDefault("CRITICAL", 0) : 0 %> },
            { label: "High", value: <%= m != null && m.getPriorityDistribution() != null ? m.getPriorityDistribution().getOrDefault("HIGH", 0) : 0 %> },
            { label: "Medium", value: <%= m != null && m.getPriorityDistribution() != null ? m.getPriorityDistribution().getOrDefault("MEDIUM", 0) : 0 %> },
            { label: "Low", value: <%= m != null && m.getPriorityDistribution() != null ? m.getPriorityDistribution().getOrDefault("LOW", 0) : 0 %> }
        ];
        CampusFlowCharts.renderDonut("analyticsPriorityDonut", prioData, ["#dc2626", "#ea580c", "#d97706", "#64748b"]);

        // Department Bars
        var deptData = [
            <% if (m != null && m.getDepartmentDistribution() != null) {
                for (Map.Entry<String, Integer> entry : m.getDepartmentDistribution().entrySet()) { %>
                    { label: "<%= SecurityUtil.escapeHtml(entry.getKey()) %>", value: <%= entry.getValue() %> },
            <%  }
            } %>
        ];
        CampusFlowCharts.renderBars("analyticsDeptBars", deptData, "#6366f1");

        // Category Bars
        var catData = [
            <% if (m != null && m.getCategoryDistribution() != null) {
                for (Map.Entry<String, Integer> entry : m.getCategoryDistribution().entrySet()) { %>
                    { label: "<%= SecurityUtil.escapeHtml(entry.getKey()) %>", value: <%= entry.getValue() %> },
            <%  }
            } %>
        ];
        CampusFlowCharts.renderBars("analyticsCatBars", catData, "#2563eb");
    });
</script>
</body>
</html>
