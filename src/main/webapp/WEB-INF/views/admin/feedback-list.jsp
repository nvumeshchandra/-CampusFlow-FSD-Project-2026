<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.campusflow.model.FeedbackBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "Feedback & Quality Reviews");
    List<FeedbackBean> feedbackList = (List<FeedbackBean>) request.getAttribute("feedbackList");
    Double avgRating = (Double) request.getAttribute("avgRating");
    Integer totalFeedback = (Integer) request.getAttribute("totalFeedback");
    Map<Integer, Integer> dist = (Map<Integer, Integer>) request.getAttribute("ratingDistribution");
    if (avgRating == null) avgRating = 0.0;
    if (totalFeedback == null) totalFeedback = 0;
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Feedback Reviews - CampusFlow</title>
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
                    <h1 class="page-title">Service Quality &amp; Student Feedback</h1>
                    <p class="page-description">Student satisfaction ratings, reviews, and qualitative feedback on campus issue resolutions.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <!-- Summary & Rating Distribution Cards -->
            <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 1.5rem; margin-bottom: 1.5rem;">
                <div class="card" style="text-align: center; padding: 2rem 1.5rem; display: flex; flex-direction: column; justify-content: center;">
                    <div style="font-size: 0.8125rem; font-weight: 700; text-transform: uppercase; color: var(--text-subtle); letter-spacing: 0.05em;">
                        Campus Overall Score
                    </div>
                    <div style="font-size: 3.5rem; font-weight: 800; color: var(--text-main); line-height: 1.1; margin: 0.5rem 0;">
                        <%= String.format("%.1f", avgRating) %>
                    </div>
                    <div style="color: #f59e0b; font-size: 1.5rem; margin-bottom: 0.5rem;">
                        &#9733;&#9733;&#9733;&#9733;&#9733;
                    </div>
                    <div style="font-size: 0.85rem; color: var(--text-subtle);">
                        Based on <%= totalFeedback %> verified student evaluation<%= totalFeedback == 1 ? "" : "s" %>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Rating Distribution</span>
                    </div>
                    <div class="card-body">
                        <% if (dist != null) {
                            for (int stars = 5; stars >= 1; stars--) {
                                int count = dist.getOrDefault(stars, 0);
                                int pct = totalFeedback > 0 ? Math.round((float) count / totalFeedback * 100) : 0;
                        %>
                            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.65rem; font-size: 0.85rem;">
                                <span style="width: 55px; font-weight: 600;"><%= stars %> Stars</span>
                                <div style="flex: 1; background: var(--bg-surface-alt); height: 10px; border-radius: 5px; overflow: hidden;">
                                    <div style="width: <%= pct %>%; background: #f59e0b; height: 100%; border-radius: 5px;"></div>
                                </div>
                                <span style="width: 60px; text-align: right; color: var(--text-subtle);"><%= count %> (<%= pct %>%)</span>
                            </div>
                        <%  }
                        } %>
                    </div>
                </div>
            </div>

            <!-- Feedback Submissions Table -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">All Student Feedback Submissions (<%= feedbackList != null ? feedbackList.size() : 0 %>)</span>
                </div>
                <div class="card-body" style="padding: 0;">
                    <% if (feedbackList == null || feedbackList.isEmpty()) { %>
                        <div class="empty-state">
                            <h3 class="empty-state-title">No Feedback Submissions Yet</h3>
                            <p class="empty-state-desc">Once students resolve and rate tickets, ratings and reviews will be cataloged here.</p>
                        </div>
                    <% } else { %>
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Ticket ID</th>
                                        <th>Issue Title</th>
                                        <th>Student</th>
                                        <th>Rating</th>
                                        <th>Written Review</th>
                                        <th>Submitted</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (FeedbackBean fb : feedbackList) { %>
                                        <tr>
                                            <td style="font-family: var(--font-mono); font-weight: 600; color: var(--primary-700);">
                                                <a href="<%= cp %>/admin/request/details?id=<%= fb.getRequestId() %>">
                                                    <%= fb.getTrackingCode() %>
                                                </a>
                                            </td>
                                            <td style="font-weight: 600;"><%= SecurityUtil.escapeHtml(fb.getRequestTitle()) %></td>
                                            <td><%= SecurityUtil.escapeHtml(fb.getStudentName()) %></td>
                                            <td>
                                                <span style="color: #f59e0b; font-weight: 700;">
                                                    <%= fb.getRating() %> / 5
                                                    <% for (int s = 0; s < fb.getRating(); s++) { %>&#9733;<% } %>
                                                </span>
                                            </td>
                                            <td style="max-width: 320px; font-size: 0.85rem; color: var(--text-muted);">
                                                <%= fb.getComments() != null && !fb.getComments().trim().isEmpty() ? SecurityUtil.escapeHtml(fb.getComments()) : "<span style='color:var(--text-subtle);'>No comment</span>" %>
                                            </td>
                                            <td style="font-size: 0.8125rem; color: var(--text-subtle);"><%= fb.getCreatedAt() %></td>
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
