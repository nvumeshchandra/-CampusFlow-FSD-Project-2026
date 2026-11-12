<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusflow.model.RequestBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    RequestBean req = (RequestBean) request.getAttribute("req");
    request.setAttribute("pageTitle", "Submit Feedback - " + (req != null ? req.getTrackingCode() : ""));
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Feedback - CampusFlow</title>
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
                    <h1 class="page-title">Service Resolution Feedback</h1>
                    <p class="page-description">Help us improve campus amenities by sharing your satisfaction rating.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div class="card" style="max-width: 640px;">
                <div class="card-header">
                    <span class="card-title">Feedback for <%= req.getTrackingCode() %></span>
                    <span class="badge badge-<%= req.getStatus().toLowerCase() %>"><%= req.getStatus() %></span>
                </div>
                <div class="card-body">
                    <div style="background: var(--bg-surface-alt); padding: 1rem; border-radius: var(--radius-md); margin-bottom: 1.5rem; font-size: 0.9rem;">
                        <strong>Issue:</strong> <%= SecurityUtil.escapeHtml(req.getTitle()) %><br>
                        <strong>Resolved by:</strong> <%= req.getAssignedStaffName() != null ? SecurityUtil.escapeHtml(req.getAssignedStaffName()) : "Campus Service" %>
                    </div>

                    <form action="<%= cp %>/student/feedback" method="POST">
                        <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                        <input type="hidden" name="requestId" value="<%= req.getRequestId() %>">

                        <div class="form-group" style="text-align: center; margin-bottom: 2rem;">
                            <label class="form-label" style="margin-bottom: 0.75rem;">Your Service Rating <span class="required">*</span></label>
                            <div class="star-rating">
                                <input type="radio" id="star5" name="rating" value="5" required>
                                <label for="star5" title="5 stars - Outstanding">&#9733;</label>

                                <input type="radio" id="star4" name="rating" value="4">
                                <label for="star4" title="4 stars - Good">&#9733;</label>

                                <input type="radio" id="star3" name="rating" value="3">
                                <label for="star3" title="3 stars - Satisfactory">&#9733;</label>

                                <input type="radio" id="star2" name="rating" value="2">
                                <label for="star2" title="2 stars - Substandard">&#9733;</label>

                                <input type="radio" id="star1" name="rating" value="1">
                                <label for="star1" title="1 star - Poor">&#9733;</label>
                            </div>
                            <div class="form-hint">Click a star to rate from 1 (Poor) to 5 (Outstanding)</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Review Remarks / Comments (Optional)</label>
                            <textarea name="comments" class="form-control" rows="4" maxlength="1000"
                                      placeholder="Was the resolution prompt? Did the technician communicate clearly?"></textarea>
                        </div>

                        <div style="display: flex; gap: 1rem;">
                            <button type="submit" class="btn btn-success" style="padding: 0.75rem 1.5rem;">
                                Submit Feedback &rarr;
                            </button>
                            <a href="<%= cp %>/student/request/details?id=<%= req.getRequestId() %>" class="btn btn-secondary">
                                Back to Request
                            </a>
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
