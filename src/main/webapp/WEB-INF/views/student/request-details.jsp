<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.model.RequestHistoryBean" %>
<%@ page import="com.campusflow.model.FeedbackBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    RequestBean req = (RequestBean) request.getAttribute("req");
    List<RequestHistoryBean> historyList = (List<RequestHistoryBean>) request.getAttribute("historyList");
    FeedbackBean feedback = (FeedbackBean) request.getAttribute("feedback");
    request.setAttribute("pageTitle", req != null ? req.getTrackingCode() : "Request Details");
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= req != null ? req.getTrackingCode() : "Ticket" %> - CampusFlow</title>
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
                    <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.25rem;">
                        <h1 class="page-title" style="font-family: var(--font-mono);"><%= req.getTrackingCode() %></h1>
                        <span class="badge badge-<%= req.getStatus().toLowerCase() %>" style="font-size: 0.85rem; padding: 0.35rem 0.85rem;">
                            <%= req.getStatus().replace('_', ' ') %>
                        </span>
                        <span class="badge badge-<%= req.getPriority().toLowerCase() %>" style="font-size: 0.85rem; padding: 0.35rem 0.85rem;">
                            <%= req.getPriority() %> PRIORITY
                        </span>
                    </div>
                    <p class="page-description">Submitted on <%= req.getCreatedAt() %> &bull; <%= SecurityUtil.escapeHtml(req.getCategory()) %></p>
                </div>

                <div style="display: flex; gap: 0.75rem;">
                    <% if (req.isEditableByStudent()) { %>
                        <a href="<%= cp %>/student/request/edit?id=<%= req.getRequestId() %>" class="btn btn-secondary">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                            <span>Edit Request</span>
                        </a>
                    <% } %>

                    <% if (req.isCancellableByStudent()) { %>
                        <button type="button" class="btn btn-danger btn-sm" data-modal-target="cancelModal">
                            Cancel Request
                        </button>
                    <% } %>

                    <% if (req.isFeedbackEligible()) { %>
                        <a href="<%= cp %>/student/feedback?requestId=<%= req.getRequestId() %>" class="btn btn-success">
                            Submit Service Feedback &rarr;
                        </a>
                    <% } %>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem; align-items: start;">
                <!-- Left Details & Timeline Column -->
                <div>
                    <!-- Primary Ticket Information -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title"><%= SecurityUtil.escapeHtml(req.getTitle()) %></span>
                        </div>
                        <div class="card-body">
                            <div style="margin-bottom: 1.25rem;">
                                <div style="font-size: 0.8125rem; font-weight: 600; color: var(--text-subtle); text-transform: uppercase;">Location</div>
                                <div style="font-size: 0.95rem; font-weight: 600; color: var(--text-main); margin-top: 0.15rem;">
                                    <%= SecurityUtil.escapeHtml(req.getLocation()) %>
                                </div>
                            </div>

                            <div style="margin-bottom: 1.5rem;">
                                <div style="font-size: 0.8125rem; font-weight: 600; color: var(--text-subtle); text-transform: uppercase;">Issue Description</div>
                                <div style="font-size: 0.95rem; color: var(--text-muted); line-height: 1.6; margin-top: 0.35rem; white-space: pre-line; background: var(--bg-surface-alt); padding: 1rem; border-radius: var(--radius-md); border: 1px solid var(--border-subtle);">
                                    <%= SecurityUtil.escapeHtml(req.getDescription()) %>
                                </div>
                            </div>

                            <!-- Priority Engine Breakdown -->
                            <div style="background: #f8fbff; border: 1px solid #bfdbfe; border-radius: var(--radius-md); padding: 1rem;">
                                <div style="font-size: 0.85rem; font-weight: 700; color: #1e40af; margin-bottom: 0.5rem;">
                                    Rule-Based Priority Score Breakdown
                                </div>
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 0.75rem; font-size: 0.8125rem;">
                                    <div><strong>Urgency:</strong> <%= req.getUrgency() %> / 4</div>
                                    <div><strong>Impact:</strong> <%= req.getImpact() %> / 4</div>
                                    <div><strong>Facility:</strong> <%= req.getLocationWeight() %> / 3</div>
                                    <div><strong>Score:</strong> <span style="font-weight: 700; color: #1e3a8a;"><%= req.getPriorityScore() %> / 11</span></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Submitted Feedback Display (if present) -->
                    <% if (feedback != null) { %>
                        <div class="card" style="border-left: 4px solid #10b981;">
                            <div class="card-header">
                                <span class="card-title">Your Submitted Feedback</span>
                                <span style="color: #f59e0b; font-size: 1.25rem;">
                                    <% for (int s = 0; s < feedback.getRating(); s++) { %>&#9733;<% } %>
                                    <% for (int s = feedback.getRating(); s < 5; s++) { %>&#9734;<% } %>
                                </span>
                            </div>
                            <div class="card-body">
                                <p style="font-size: 0.9rem; color: var(--text-muted);">
                                    <%= feedback.getComments() != null && !feedback.getComments().trim().isEmpty() ? SecurityUtil.escapeHtml(feedback.getComments()) : "No written comments provided." %>
                                </p>
                                <div style="font-size: 0.75rem; color: var(--text-subtle); margin-top: 0.5rem;">
                                    Submitted on <%= feedback.getCreatedAt() %>
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <!-- Audit Timeline History -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">Request Audit Timeline</span>
                            <span style="font-size: 0.8125rem; color: var(--text-subtle);">Complete chronological history</span>
                        </div>
                        <div class="card-body">
                            <% if (historyList == null || historyList.isEmpty()) { %>
                                <p style="color: var(--text-subtle); font-size: 0.9rem;">No history logged yet.</p>
                            <% } else { %>
                                <div class="timeline">
                                    <% for (RequestHistoryBean h : historyList) { %>
                                        <div class="timeline-item">
                                            <div class="timeline-point"></div>
                                            <div class="timeline-content">
                                                <div class="timeline-meta">
                                                    <span><strong><%= SecurityUtil.escapeHtml(h.getActorName()) %></strong> (<%= h.getActorRole() %>)</span>
                                                    <span><%= h.getCreatedAt() %></span>
                                                </div>
                                                <div class="timeline-title">
                                                    Action: <%= h.getActionType() %>
                                                    <% if (h.getNewStatus() != null) { %>
                                                        &rarr; <span class="badge badge-<%= h.getNewStatus().toLowerCase() %>" style="font-size:0.65rem;"><%= h.getNewStatus() %></span>
                                                    <% } %>
                                                </div>
                                                <% if (h.getRemarks() != null && !h.getRemarks().trim().isEmpty()) { %>
                                                    <div class="timeline-desc">
                                                        <%= SecurityUtil.escapeHtml(h.getRemarks()) %>
                                                    </div>
                                                <% } %>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Right Sidebar Meta Column -->
                <div>
                    <!-- Assignment Status Card -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">Service Assignment</span>
                        </div>
                        <div class="card-body" style="font-size: 0.875rem;">
                            <div style="margin-bottom: 1rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem; text-transform: uppercase;">Assigned Department</div>
                                <div style="font-weight: 600; color: var(--text-main); margin-top: 0.2rem;">
                                    <%= req.getDepartmentName() != null ? SecurityUtil.escapeHtml(req.getDepartmentName()) : "<span style='color:var(--text-subtle);font-weight:normal;'>Awaiting administrative dispatch</span>" %>
                                </div>
                            </div>

                            <div style="margin-bottom: 1rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem; text-transform: uppercase;">Assigned Technician / Staff</div>
                                <div style="font-weight: 600; color: var(--text-main); margin-top: 0.2rem;">
                                    <%= req.getAssignedStaffName() != null ? SecurityUtil.escapeHtml(req.getAssignedStaffName()) : "<span style='color:var(--text-subtle);font-weight:normal;'>Unassigned</span>" %>
                                </div>
                            </div>

                            <div style="border-top: 1px solid var(--border-subtle); padding-top: 0.75rem; margin-top: 0.75rem;">
                                <div style="color: var(--text-subtle); font-size: 0.75rem;">Resolution Milestone:</div>
                                <div style="font-size: 0.8125rem; font-weight: 500; margin-top: 0.2rem;">
                                    <%= req.getResolvedAt() != null ? "Resolved on " + req.getResolvedAt() : "Resolution in progress" %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    </main>
</div>

<!-- Cancellation Modal Dialog -->
<% if (req.isCancellableByStudent()) { %>
    <div class="modal-overlay" id="cancelModal">
        <div class="modal-dialog">
            <div class="modal-header">
                <span class="modal-title">Cancel Service Request</span>
                <button type="button" class="modal-close">&times;</button>
            </div>
            <form action="<%= cp %>/student/request/cancel" method="POST">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                <div class="modal-body">
                    <p style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 1rem;">
                        Are you sure you want to cancel ticket <strong><%= req.getTrackingCode() %></strong>? Once cancelled, no further dispatch or work will take place.
                    </p>
                    <div class="form-group">
                        <label class="form-label">Cancellation Reason <span class="required">*</span></label>
                        <textarea name="reason" class="form-control" rows="3" required
                                  placeholder="e.g. Issue resolved on its own, duplicate submission, etc."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-modal-close>Keep Request</button>
                    <button type="submit" class="btn btn-danger">Confirm Cancellation</button>
                </div>
            </form>
        </div>
    </div>
<% } %>

<script src="<%= cp %>/assets/js/app.js"></script>
</body>
</html>
