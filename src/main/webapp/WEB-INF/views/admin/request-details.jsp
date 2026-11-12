<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.model.RequestHistoryBean" %>
<%@ page import="com.campusflow.model.FeedbackBean" %>
<%@ page import="com.campusflow.model.DepartmentBean" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    RequestBean req = (RequestBean) request.getAttribute("req");
    List<RequestHistoryBean> historyList = (List<RequestHistoryBean>) request.getAttribute("historyList");
    FeedbackBean feedback = (FeedbackBean) request.getAttribute("feedback");
    List<DepartmentBean> departments = (List<DepartmentBean>) request.getAttribute("departments");
    List<UserBean> deptStaff = (List<UserBean>) request.getAttribute("deptStaff");

    request.setAttribute("pageTitle", "Admin Dispatch: " + req.getTrackingCode());
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= req.getTrackingCode() %> - Admin Management - CampusFlow</title>
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
                    <p class="page-description">Administrative Dispatch &amp; Operations Center</p>
                </div>

                <div style="display: flex; gap: 0.75rem; flex-wrap: wrap;">
                    <% if (!req.isTerminal()) { %>
                        <button type="button" class="btn btn-primary btn-sm" data-modal-target="assignModal">
                            <%= req.getAssignedStaffId() != null || req.getDepartmentId() != null ? "Reassign Dispatch" : "Assign Department & Staff" %>
                        </button>
                        <button type="button" class="btn btn-secondary btn-sm" data-modal-target="priorityModal">
                            Override Priority
                        </button>
                    <% } %>

                    <% if ("RESOLVED".equalsIgnoreCase(req.getStatus())) { %>
                        <form action="<%= cp %>/admin/request/status" method="POST" style="margin: 0;">
                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
                            <input type="hidden" name="targetStatus" value="CLOSED">
                            <input type="hidden" name="remarks" value="Officially closed by campus administrator.">
                            <button type="submit" class="btn btn-success btn-sm">
                                &check; Close Ticket
                            </button>
                        </form>
                    <% } %>

                    <% if (!req.isTerminal()) { %>
                        <button type="button" class="btn btn-danger btn-sm" data-modal-target="cancelModal">
                            Cancel Ticket
                        </button>
                    <% } %>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem; align-items: start;">
                <!-- Left Details & Timeline Column -->
                <div>
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title"><%= SecurityUtil.escapeHtml(req.getTitle()) %></span>
                            <span style="font-size: 0.8125rem; color: var(--text-subtle);"><%= SecurityUtil.escapeHtml(req.getCategory()) %></span>
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

                            <!-- Priority Engine Factor Breakdown -->
                            <div style="background: #f8fbff; border: 1px solid #bfdbfe; border-radius: var(--radius-md); padding: 1rem;">
                                <div style="font-size: 0.85rem; font-weight: 700; color: #1e40af; margin-bottom: 0.5rem;">
                                    Rule-Based Priority Calculation
                                </div>
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 0.75rem; font-size: 0.8125rem;">
                                    <div><strong>Urgency:</strong> <%= req.getUrgency() %> / 4</div>
                                    <div><strong>Impact:</strong> <%= req.getImpact() %> / 4</div>
                                    <div><strong>Facility Weight:</strong> <%= req.getLocationWeight() %> / 3</div>
                                    <div><strong>Calculated Score:</strong> <span style="font-weight: 700; color: #1e3a8a;"><%= req.getPriorityScore() %> / 11</span></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Student Feedback (if submitted) -->
                    <% if (feedback != null) { %>
                        <div class="card" style="border-left: 4px solid #10b981;">
                            <div class="card-header">
                                <span class="card-title">Student Satisfaction Feedback</span>
                                <span style="color: #f59e0b; font-size: 1.25rem;">
                                    <% for (int s = 0; s < feedback.getRating(); s++) { %>&#9733;<% } %>
                                    <% for (int s = feedback.getRating(); s < 5; s++) { %>&#9734;<% } %>
                                </span>
                            </div>
                            <div class="card-body">
                                <p style="font-size: 0.9rem; color: var(--text-muted);">
                                    <%= feedback.getComments() != null && !feedback.getComments().trim().isEmpty() ? SecurityUtil.escapeHtml(feedback.getComments()) : "No written comments." %>
                                </p>
                                <div style="font-size: 0.75rem; color: var(--text-subtle); margin-top: 0.5rem;">
                                    Submitted by <%= SecurityUtil.escapeHtml(feedback.getStudentName()) %> on <%= feedback.getCreatedAt() %>
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <!-- Audit Timeline History -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">Complete Audit Timeline</span>
                            <span style="font-size: 0.8125rem; color: var(--text-subtle);">Transaction-verified records</span>
                        </div>
                        <div class="card-body">
                            <% if (historyList == null || historyList.isEmpty()) { %>
                                <p style="color: var(--text-subtle); font-size: 0.9rem;">No audit records.</p>
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

                <!-- Right Meta & Assignment Column -->
                <div>
                    <!-- Assignment Card -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">Current Assignment</span>
                        </div>
                        <div class="card-body" style="font-size: 0.875rem;">
                            <div style="margin-bottom: 1rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem; text-transform: uppercase;">Assigned Department</div>
                                <div style="font-weight: 600; color: var(--text-main); margin-top: 0.2rem;">
                                    <%= req.getDepartmentName() != null ? SecurityUtil.escapeHtml(req.getDepartmentName()) : "<span style='color:var(--danger-main);'>Awaiting Assignment</span>" %>
                                </div>
                            </div>
                            <div style="margin-bottom: 1rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem; text-transform: uppercase;">Assigned Staff</div>
                                <div style="font-weight: 600; color: var(--text-main); margin-top: 0.2rem;">
                                    <%= req.getAssignedStaffName() != null ? SecurityUtil.escapeHtml(req.getAssignedStaffName()) : "<span style='color:var(--text-subtle);'>Unassigned Staff</span>" %>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Requester Card -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">Student Requester</span>
                        </div>
                        <div class="card-body" style="font-size: 0.875rem;">
                            <div style="margin-bottom: 0.75rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem;">Name:</div>
                                <div style="font-weight: 600;"><%= SecurityUtil.escapeHtml(req.getRequesterName()) %></div>
                            </div>
                            <div style="margin-bottom: 0.75rem;">
                                <div style="color: var(--text-subtle); font-size: 0.8rem;">Email:</div>
                                <div><a href="mailto:<%= SecurityUtil.escapeHtml(req.getRequesterEmail()) %>"><%= SecurityUtil.escapeHtml(req.getRequesterEmail()) %></a></div>
                            </div>
                            <div>
                                <div style="color: var(--text-subtle); font-size: 0.8rem;">Submitted:</div>
                                <div><%= req.getCreatedAt() %></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    </main>
</div>

<!-- Modal: Assign Department and Staff -->
<div class="modal-overlay" id="assignModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Dispatch &amp; Assign Ticket</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/admin/request/assign" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Service Department <span class="required">*</span></label>
                    <select name="departmentId" id="assignDeptSelect" class="form-control" required>
                        <option value="">-- Select Handling Department --</option>
                        <% if (departments != null) {
                            for (DepartmentBean d : departments) { %>
                                <option value="<%= d.getDepartmentId() %>" <%= req.getDepartmentId() != null && req.getDepartmentId().equals(d.getDepartmentId()) ? "selected" : "" %>>
                                    <%= SecurityUtil.escapeHtml(d.getDepartmentName()) %>
                                </option>
                        <%  }
                        } %>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Assign Specific Staff Member (Optional)</label>
                    <select name="staffId" id="assignStaffSelect" class="form-control">
                        <option value="">-- Unassigned (Department Queue) --</option>
                        <% if (deptStaff != null) {
                            for (UserBean s : deptStaff) { %>
                                <option value="<%= s.getUserId() %>" <%= req.getAssignedStaffId() != null && req.getAssignedStaffId().equals(s.getUserId()) ? "selected" : "" %>>
                                    <%= SecurityUtil.escapeHtml(s.getName()) %> (<%= SecurityUtil.escapeHtml(s.getEmail()) %>)
                                </option>
                        <%  }
                        } %>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Administrative Dispatch Remarks</label>
                    <textarea name="remarks" class="form-control" rows="3"
                              placeholder="e.g. Expedited classroom exam hall fixture. Priority dispatch."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Assignment &rarr;</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Override Priority -->
<div class="modal-overlay" id="priorityModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Override Calculated Priority</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/admin/request/priority" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Target Priority Level <span class="required">*</span></label>
                    <select name="priority" class="form-control" required>
                        <option value="LOW" <%= "LOW".equalsIgnoreCase(req.getPriority()) ? "selected" : "" %>>LOW</option>
                        <option value="MEDIUM" <%= "MEDIUM".equalsIgnoreCase(req.getPriority()) ? "selected" : "" %>>MEDIUM</option>
                        <option value="HIGH" <%= "HIGH".equalsIgnoreCase(req.getPriority()) ? "selected" : "" %>>HIGH</option>
                        <option value="CRITICAL" <%= "CRITICAL".equalsIgnoreCase(req.getPriority()) ? "selected" : "" %>>CRITICAL</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Justification Reason <span class="required">*</span></label>
                    <textarea name="reason" class="form-control" rows="3" required minlength="5"
                              placeholder="e.g. Mid-term examination scheduled in this room tomorrow morning. Escalated."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Apply Override</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Cancel Ticket -->
<div class="modal-overlay" id="cancelModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Cancel Ticket</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/admin/request/cancel" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Administrative Cancellation Reason <span class="required">*</span></label>
                    <textarea name="reason" class="form-control" rows="3" required
                              placeholder="e.g. Duplicate ticket, voided by campus department, etc."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Back</button>
                <button type="submit" class="btn btn-danger">Confirm Cancellation</button>
            </div>
        </form>
    </div>
</div>

<script src="<%= cp %>/assets/js/app.js"></script>
</body>
</html>
