<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.DepartmentBean" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "Create Campus Request");
    List<DepartmentBean> departments = (List<DepartmentBean>) request.getAttribute("departments");
    RequestBean formReq = (RequestBean) request.getAttribute("formReq");
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit New Service Request - CampusFlow</title>
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
                    <h1 class="page-title">Submit Campus Service Request</h1>
                    <p class="page-description">
                        Log an equipment fault, maintenance requirement, or campus amenity issue for institutional dispatch.
                    </p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem; align-items: start;">
                <!-- Main Form -->
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Issue Details</span>
                        <span style="font-size: 0.8125rem; color: var(--text-subtle);">All fields marked <span class="required" style="color:var(--danger-main);">*</span> are required</span>
                    </div>
                    <div class="card-body">
                        <form action="<%= cp %>/student/request/create" method="POST" id="createRequestForm">
                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

                            <div class="form-group">
                                <label class="form-label">Issue Category <span class="required">*</span></label>
                                <select name="category" class="form-control" required>
                                    <option value="">-- Select Relevant Service Category --</option>
                                    <option value="IT / Computer" <%= formReq != null && "IT / Computer".equals(formReq.getCategory()) ? "selected" : "" %>>IT / Computer / Wi-Fi</option>
                                    <option value="Electrical" <%= formReq != null && "Electrical".equals(formReq.getCategory()) ? "selected" : "" %>>Electrical &amp; Power Systems</option>
                                    <option value="Water / Plumbing" <%= formReq != null && "Water / Plumbing".equals(formReq.getCategory()) ? "selected" : "" %>>Water &amp; Plumbing</option>
                                    <option value="Classroom" <%= formReq != null && "Classroom".equals(formReq.getCategory()) ? "selected" : "" %>>Classroom &amp; Lab Amenities</option>
                                    <option value="Hostel" <%= formReq != null && "Hostel".equals(formReq.getCategory()) ? "selected" : "" %>>Hostel &amp; Residential Maintenance</option>
                                    <option value="Transport" <%= formReq != null && "Transport".equals(formReq.getCategory()) ? "selected" : "" %>>Campus Transport &amp; Parking</option>
                                    <option value="Academic" <%= formReq != null && "Academic".equals(formReq.getCategory()) ? "selected" : "" %>>Academic Support &amp; Library</option>
                                    <option value="Cleaning" <%= formReq != null && "Cleaning".equals(formReq.getCategory()) ? "selected" : "" %>>Cleaning &amp; Housekeeping</option>
                                    <option value="Maintenance" <%= formReq != null && "Maintenance".equals(formReq.getCategory()) ? "selected" : "" %>>General Maintenance</option>
                                    <option value="Other" <%= formReq != null && "Other".equals(formReq.getCategory()) ? "selected" : "" %>>Other Facility Inquiry</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Request Title <span class="required">*</span></label>
                                <input type="text" name="title" class="form-control" required minlength="5" maxlength="200"
                                       placeholder="e.g. Lab 3 Projector not powering on"
                                       value="<%= formReq != null ? SecurityUtil.escapeHtml(formReq.getTitle()) : "" %>">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Specific Location <span class="required">*</span></label>
                                <input type="text" name="location" class="form-control" required maxlength="150"
                                       placeholder="e.g. Block B, 2nd Floor, Room 204 (AI Lab)"
                                       value="<%= formReq != null ? SecurityUtil.escapeHtml(formReq.getLocation()) : "" %>">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Detailed Description <span class="required">*</span></label>
                                <textarea name="description" class="form-control" rows="4" required minlength="10" maxlength="2000"
                                          placeholder="Describe what occurred, any error codes, fixture labels, or steps observed..."><%= formReq != null ? SecurityUtil.escapeHtml(formReq.getDescription()) : "" %></textarea>
                            </div>

                            <!-- Rule-Based Priority Engine Factor Inputs -->
                            <div style="background: var(--bg-surface-alt); border: 1px solid var(--border-subtle); border-radius: var(--radius-md); padding: 1.25rem; margin-bottom: 1.5rem;">
                                <div style="font-size: 0.9rem; font-weight: 700; color: var(--text-main); margin-bottom: 0.25rem;">
                                    Priority Assessment Factors
                                </div>
                                <div style="font-size: 0.8rem; color: var(--text-subtle); margin-bottom: 1rem;">
                                    The system calculates deterministic urgency and impacts using the College Priority Engine.
                                </div>

                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem;">
                                    <div>
                                        <label class="form-label" style="font-size: 0.8125rem;">Urgency Level <span class="required">*</span></label>
                                        <select name="urgency" id="urgencySelect" class="form-control" required>
                                            <option value="1" <%= formReq != null && formReq.getUrgency() == 1 ? "selected" : "" %>>1 - Low (Minor / Cosmetic)</option>
                                            <option value="2" <%= formReq == null || formReq.getUrgency() == 2 ? "selected" : "" %>>2 - Medium (Standard Delay)</option>
                                            <option value="3" <%= formReq != null && formReq.getUrgency() == 3 ? "selected" : "" %>>3 - High (Blocks Activity)</option>
                                            <option value="4" <%= formReq != null && formReq.getUrgency() == 4 ? "selected" : "" %>>4 - Critical (Safety/Hazard)</option>
                                        </select>
                                    </div>

                                    <div>
                                        <label class="form-label" style="font-size: 0.8125rem;">Impact Scope <span class="required">*</span></label>
                                        <select name="impact" id="impactSelect" class="form-control" required>
                                            <option value="1" <%= formReq != null && formReq.getImpact() == 1 ? "selected" : "" %>>1 - Single User</option>
                                            <option value="2" <%= formReq == null || formReq.getImpact() == 2 ? "selected" : "" %>>2 - Small Group / Room</option>
                                            <option value="3" <%= formReq != null && formReq.getImpact() == 3 ? "selected" : "" %>>3 - Department / Floor</option>
                                            <option value="4" <%= formReq != null && formReq.getImpact() == 4 ? "selected" : "" %>>4 - Campus-Wide</option>
                                        </select>
                                    </div>

                                    <div>
                                        <label class="form-label" style="font-size: 0.8125rem;">Facility Classification <span class="required">*</span></label>
                                        <select name="locationWeight" id="locationSelect" class="form-control" required>
                                            <option value="1" <%= formReq != null && formReq.getLocationWeight() == 1 ? "selected" : "" %>>1 - General Area / Lawn</option>
                                            <option value="2" <%= formReq == null || formReq.getLocationWeight() == 2 ? "selected" : "" %>>2 - Classroom / Laboratory</option>
                                            <option value="3" <%= formReq != null && formReq.getLocationWeight() == 3 ? "selected" : "" %>>3 - Critical Facility / Exam Hall</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary" style="padding: 0.75rem 1.5rem; font-size: 0.95rem;">
                                Submit Service Ticket &rarr;
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Priority Engine Live Preview Card -->
                <div class="card" style="position: sticky; top: 80px;">
                    <div class="card-header">
                        <span class="card-title">Priority Engine Preview</span>
                    </div>
                    <div class="card-body">
                        <div style="text-align: center; padding: 1rem 0;">
                            <div style="font-size: 0.8125rem; color: var(--text-subtle); margin-bottom: 0.5rem;">Calculated Priority</div>
                            <span id="priorityPreview" class="badge badge-medium" style="font-size: 1.15rem; padding: 0.45rem 1.25rem;">
                                MEDIUM
                            </span>
                            <div id="priorityScorePreview" style="font-size: 0.85rem; font-weight: 600; color: var(--text-muted); margin-top: 0.75rem;">
                                Score: 6 / 11
                            </div>
                        </div>

                        <div style="font-size: 0.8rem; color: var(--text-subtle); border-top: 1px solid var(--border-subtle); padding-top: 1rem; line-height: 1.5;">
                            <strong>Transparent Evaluation Formula:</strong><br>
                            <code>score = urgency (1-4) + impact (1-4) + location (1-3)</code>
                            <ul style="margin-left: 1.25rem; margin-top: 0.5rem;">
                                <li>Score 3-4: <strong>LOW</strong></li>
                                <li>Score 5-6: <strong>MEDIUM</strong></li>
                                <li>Score 7-8: <strong>HIGH</strong></li>
                                <li>Score 9-11: <strong>CRITICAL</strong></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    </main>
</div>
<script src="<%= cp %>/assets/js/app.js"></script>
</body>
</html>
