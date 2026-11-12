<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    RequestBean req = (RequestBean) request.getAttribute("req");
    request.setAttribute("pageTitle", "Edit Request " + (req != null ? req.getTrackingCode() : ""));
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Request <%= req != null ? req.getTrackingCode() : "" %> - CampusFlow</title>
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
                    <h1 class="page-title">Edit Request Details</h1>
                    <p class="page-description">Modify submission details while the ticket is pending initial review.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div class="card" style="max-width: 760px;">
                <div class="card-header">
                    <span class="card-title">Editing <%= req.getTrackingCode() %></span>
                    <span class="badge badge-submitted">SUBMITTED</span>
                </div>
                <div class="card-body">
                    <form action="<%= cp %>/student/request/edit" method="POST">
                        <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                        <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">

                        <div class="form-group">
                            <label class="form-label">Issue Category <span class="required">*</span></label>
                            <select name="category" class="form-control" required>
                                <option value="IT / Computer" <%= "IT / Computer".equals(req.getCategory()) ? "selected" : "" %>>IT / Computer / Wi-Fi</option>
                                <option value="Electrical" <%= "Electrical".equals(req.getCategory()) ? "selected" : "" %>>Electrical &amp; Power Systems</option>
                                <option value="Water / Plumbing" <%= "Water / Plumbing".equals(req.getCategory()) ? "selected" : "" %>>Water &amp; Plumbing</option>
                                <option value="Classroom" <%= "Classroom".equals(req.getCategory()) ? "selected" : "" %>>Classroom &amp; Lab Amenities</option>
                                <option value="Hostel" <%= "Hostel".equals(req.getCategory()) ? "selected" : "" %>>Hostel &amp; Residential Maintenance</option>
                                <option value="Transport" <%= "Transport".equals(req.getCategory()) ? "selected" : "" %>>Campus Transport &amp; Parking</option>
                                <option value="Academic" <%= "Academic".equals(req.getCategory()) ? "selected" : "" %>>Academic Support &amp; Library</option>
                                <option value="Cleaning" <%= "Cleaning".equals(req.getCategory()) ? "selected" : "" %>>Cleaning &amp; Housekeeping</option>
                                <option value="Maintenance" <%= "Maintenance".equals(req.getCategory()) ? "selected" : "" %>>General Maintenance</option>
                                <option value="Other" <%= "Other".equals(req.getCategory()) ? "selected" : "" %>>Other Facility Inquiry</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Request Title <span class="required">*</span></label>
                            <input type="text" name="title" class="form-control" required minlength="5" maxlength="200"
                                   value="<%= SecurityUtil.escapeHtml(req.getTitle()) %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Specific Location <span class="required">*</span></label>
                            <input type="text" name="location" class="form-control" required maxlength="150"
                                   value="<%= SecurityUtil.escapeHtml(req.getLocation()) %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Detailed Description <span class="required">*</span></label>
                            <textarea name="description" class="form-control" rows="4" required minlength="10" maxlength="2000"><%= SecurityUtil.escapeHtml(req.getDescription()) %></textarea>
                        </div>

                        <!-- Priority Assessment Update -->
                        <div style="background: var(--bg-surface-alt); border: 1px solid var(--border-subtle); border-radius: var(--radius-md); padding: 1.25rem; margin-bottom: 1.5rem;">
                            <div style="font-size: 0.85rem; font-weight: 700; color: var(--text-main); margin-bottom: 0.75rem;">
                                Update Priority Factors
                            </div>
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem;">
                                <div>
                                    <label class="form-label" style="font-size: 0.8125rem;">Urgency Level <span class="required">*</span></label>
                                    <select name="urgency" id="urgencySelect" class="form-control" required>
                                        <option value="1" <%= req.getUrgency() == 1 ? "selected" : "" %>>1 - Low</option>
                                        <option value="2" <%= req.getUrgency() == 2 ? "selected" : "" %>>2 - Medium</option>
                                        <option value="3" <%= req.getUrgency() == 3 ? "selected" : "" %>>3 - High</option>
                                        <option value="4" <%= req.getUrgency() == 4 ? "selected" : "" %>>4 - Critical</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="form-label" style="font-size: 0.8125rem;">Impact Scope <span class="required">*</span></label>
                                    <select name="impact" id="impactSelect" class="form-control" required>
                                        <option value="1" <%= req.getImpact() == 1 ? "selected" : "" %>>1 - Single User</option>
                                        <option value="2" <%= req.getImpact() == 2 ? "selected" : "" %>>2 - Small Group</option>
                                        <option value="3" <%= req.getImpact() == 3 ? "selected" : "" %>>3 - Department</option>
                                        <option value="4" <%= req.getImpact() == 4 ? "selected" : "" %>>4 - Campus-Wide</option>
                                    </select>
                                </div>
                                <div>
                                    <label class="form-label" style="font-size: 0.8125rem;">Facility Classification <span class="required">*</span></label>
                                    <select name="locationWeight" id="locationSelect" class="form-control" required>
                                        <option value="1" <%= req.getLocationWeight() == 1 ? "selected" : "" %>>1 - General Area</option>
                                        <option value="2" <%= req.getLocationWeight() == 2 ? "selected" : "" %>>2 - Classroom / Lab</option>
                                        <option value="3" <%= req.getLocationWeight() == 3 ? "selected" : "" %>>3 - Critical Facility</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div style="display: flex; gap: 1rem;">
                            <button type="submit" class="btn btn-primary">Save Changes</button>
                            <a href="<%= cp %>/student/request/details?id=<%= req.getRequestId() %>" class="btn btn-secondary">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    </main>
</div>
<script src="<%= cp %>/assets/js/app.js"></script>
</body>
</html>
