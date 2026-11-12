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
    request.setAttribute("pageTitle", "Staff Inspection - " + req.getTrackingCode());
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= req.getTrackingCode() %> - Staff Task Inspection - CampusFlow</title>
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
                    <p class="page-description">Assigned Service Task &bull; <%= SecurityUtil.escapeHtml(req.getCategory()) %></p>
                </div>

                <div style="display: flex; gap: 0.75rem;">
                    <% if ("ASSIGNED".equalsIgnoreCase(req.getStatus())) { %>
                        <form action="<%= cp %>/staff/request/action" method="POST" style="margin: 0;">
                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                            <input type="hidden" name="action" value="START_WORK">
                            <button type="submit" class="btn btn-primary">
                                &check; Accept &amp; Start Work
                            </button>
                        </form>
                    <% } else if ("IN_PROGRESS".equalsIgnoreCase(req.getStatus())) { %>
                        <button type="button" class="btn btn-secondary" data-modal-target="remarkModal">
                            + Add Progress Remark
                        </button>
                        <button type="button" class="btn btn-success" data-modal-target="resolveModal">
                            &check; Mark as Resolved
                        </button>
                    <% } %>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem; align-items: start;">
                <!-- Left Details & History -->
                <div>
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

                            <div style="background: #f8fbff; border: 1px solid #bfdbfe; border-radius: var(--radius-md); padding: 1rem;">
                                <div style="font-size: 0.85rem; font-weight: 700; color: #1e40af; margin-bottom: 0.5rem;">
                                    Priority Scoring Profile
                                </div>
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 0.75rem; font-size: 0.8125rem;">
                                    <div><strong>Urgency:</strong> <%= req.getUrgency() %> / 4</div>
                                    <div><strong>Impact:</strong> <%= req.getImpact() %> / 4</div>
                                    <div><strong>Facility Weight:</strong> <%= req.getLocationWeight() %> / 3</div>
                                    <div><strong>Computed Score:</strong> <span style="font-weight: 700; color: #1e3a8a;"><%= req.getPriorityScore() %> / 11</span></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Feedback Display if present -->
                    <% if (feedback != null) { %>
                        <div class="card" style="border-left: 4px solid #10b981;">
                            <div class="card-header">
                                <span class="card-title">Student Satisfaction Rating</span>
                                <span style="color: #f59e0b; font-size: 1.25rem;">
                                    <% for (int s = 0; s < feedback.getRating(); s++) { %>&#9733;<% } %>
                                    <% for (int s = feedback.getRating(); s < 5; s++) { %>&#9734;<% } %>
                                </span>
                            </div>
                            <div class="card-body">
                                <p style="font-size: 0.9rem; color: var(--text-muted);">
                                    <%= feedback.getComments() != null && !feedback.getComments().trim().isEmpty() ? SecurityUtil.escapeHtml(feedback.getComments()) : "No remarks provided." %>
                                </p>
                            </div>
                        </div>
                    <% } %>

                    <!-- Audit Timeline History -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">Task Timeline &amp; Remarks</span>
                        </div>
                        <div class="card-body">
                            <% if (historyList == null || historyList.isEmpty()) { %>
                                <p style="color: var(--text-subtle); font-size: 0.9rem;">No timeline events recorded.</p>
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
                                                    <%= h.getActionType() %>
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

                <!-- Right Requester Info Column -->
                <div>
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">Requester Information</span>
                        </div>
                        <div class="card-body" style="font-size: 0.875rem;">
                            <div style="margin-bottom: 1rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem; text-transform: uppercase;">Student Name</div>
                                <div style="font-weight: 600; color: var(--text-main); margin-top: 0.15rem;">
                                    <%= SecurityUtil.escapeHtml(req.getRequesterName()) %>
                                </div>
                            </div>
                            <div style="margin-bottom: 1rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem; text-transform: uppercase;">Email Contact</div>
                                <div style="color: var(--text-main); margin-top: 0.15rem;">
                                    <a href="mailto:<%= SecurityUtil.escapeHtml(req.getRequesterEmail()) %>">
                                        <%= SecurityUtil.escapeHtml(req.getRequesterEmail()) %>
                                    </a>
                                </div>
                            </div>
                            <div style="border-top: 1px solid var(--border-subtle); padding-top: 0.75rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem; text-transform: uppercase;">Submitted Date</div>
                                <div style="color: var(--text-main); margin-top: 0.15rem;">
                                    <%= req.getCreatedAt() %>
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

<!-- Modal: Progress Remarks -->
<div class="modal-overlay" id="remarkModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Record Progress Remark</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/staff/request/action" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
            <input type="hidden" name="action" value="ADD_REMARK">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Technician Notes / Progress Update <span class="required">*</span></label>
                    <textarea name="remarks" class="form-control" rows="4" required
                              placeholder="e.g. Diagnostic complete. Sourced replacement bulb from IT inventory. Installing this afternoon."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Remark</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Mark as Resolved -->
<div class="modal-overlay" id="resolveModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Mark Issue as Resolved</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/staff/request/action" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
            <input type="hidden" name="action" value="RESOLVE">
            <div class="modal-body">
                <p style="font-size: 0.875rem; color: var(--text-muted); margin-bottom: 1rem;">
                    Please detail the remedial action taken to fix this issue. The student will be notified and invited to submit service feedback.
                </p>
                <div class="form-group">
                    <label class="form-label">Resolution Summary <span class="required">*</span></label>
                    <textarea name="remarks" class="form-control" rows="4" required minlength="5"
                              placeholder="e.g. Replaced faulty HDMI cable and re-calibrated projector output. Verified power input and display connectivity."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-success">Confirm Resolution &rarr;</button>
            </div>
        </form>
    </div>
</div>

<script src="<%= cp %>/assets/js/app.js"></script>
</body>
</html>
