<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "My Account Profile");
    UserBean user = (UserBean) request.getAttribute("user");
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - CampusFlow</title>
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
                    <h1 class="page-title">Account Profile</h1>
                    <p class="page-description">Manage personal details, contact preferences, and account security credentials.</p>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.5rem;">
                <!-- Profile Details -->
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Profile Information</span>
                        <span class="badge badge-<%= user != null && user.isActive() ? "active" : "inactive" %>">
                            <%= user != null ? user.getAccountStatus() : "" %>
                        </span>
                    </div>
                    <div class="card-body">
                        <form action="<%= cp %>/profile" method="POST">
                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                            <input type="hidden" name="action" value="UPDATE_PROFILE">

                            <div class="form-group">
                                <label class="form-label">Full Name <span class="required">*</span></label>
                                <input type="text" name="name" class="form-control" required
                                       value="<%= user != null ? SecurityUtil.escapeHtml(user.getName()) : "" %>">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Email Address (Read-Only)</label>
                                <input type="email" class="form-control" readonly disabled
                                       style="background: var(--bg-surface-alt); cursor: not-allowed;"
                                       value="<%= user != null ? SecurityUtil.escapeHtml(user.getEmail()) : "" %>">
                                <div class="form-hint">Institutional emails cannot be changed directly.</div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Account Role</label>
                                <input type="text" class="form-control" readonly disabled
                                       style="background: var(--bg-surface-alt); cursor: not-allowed; font-weight: 600;"
                                       value="<%= user != null ? user.getRole() : "" %>">
                            </div>

                            <% if (user != null && user.getDepartmentName() != null) { %>
                                <div class="form-group">
                                    <label class="form-label">Assigned Department</label>
                                    <input type="text" class="form-control" readonly disabled
                                           style="background: var(--bg-surface-alt); cursor: not-allowed;"
                                           value="<%= SecurityUtil.escapeHtml(user.getDepartmentName()) %>">
                                </div>
                            <% } %>

                            <div class="form-group">
                                <label class="form-label">Phone Number</label>
                                <input type="tel" name="phone" class="form-control" placeholder="e.g. 9876543210"
                                       value="<%= user != null && user.getPhone() != null ? SecurityUtil.escapeHtml(user.getPhone()) : "" %>">
                            </div>

                            <button type="submit" class="btn btn-primary" style="width: 100%;">
                                Save Changes
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Password Change -->
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Security &amp; Password</span>
                    </div>
                    <div class="card-body">
                        <form action="<%= cp %>/profile" method="POST">
                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                            <input type="hidden" name="action" value="CHANGE_PASSWORD">

                            <div class="form-group">
                                <label class="form-label">Current Password <span class="required">*</span></label>
                                <input type="password" name="currentPassword" class="form-control" required
                                       placeholder="Enter your current password">
                            </div>

                            <div class="form-group">
                                <label class="form-label">New Password <span class="required">*</span></label>
                                <input type="password" name="newPassword" class="form-control" required minlength="6"
                                       placeholder="Minimum 6 chars (letters &amp; numbers)">
                                <div class="form-hint">Must contain at least one letter and one number.</div>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Confirm New Password <span class="required">*</span></label>
                                <input type="password" name="confirmPassword" class="form-control" required minlength="6"
                                       placeholder="Re-enter new password">
                            </div>

                            <button type="submit" class="btn btn-secondary" style="width: 100%;">
                                Change Password
                            </button>
                        </form>
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
