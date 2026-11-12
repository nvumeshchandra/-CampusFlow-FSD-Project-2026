<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.model.DepartmentBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "User & Access Management");
    List<UserBean> users = (List<UserBean>) request.getAttribute("users");
    List<DepartmentBean> departments = (List<DepartmentBean>) request.getAttribute("departments");

    String selRole = (String) request.getAttribute("selectedRole");
    String selStatus = (String) request.getAttribute("selectedStatus");
    String searchQuery = (String) request.getAttribute("searchQuery");

    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - CampusFlow</title>
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
                    <h1 class="page-title">User Accounts &amp; Access Control</h1>
                    <p class="page-description">Manage student, staff, and administrator credentials, departmental affiliations, and account activation.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-primary" data-modal-target="createStaffModal">
                        + Onboard Staff Member
                    </button>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <!-- Filter Bar -->
            <form action="<%= cp %>/admin/users" method="GET" class="filter-bar">
                <div class="filter-item" style="flex: 1; min-width: 200px;">
                    <input type="text" name="search" class="form-control" placeholder="Search by name or email..."
                           value="<%= searchQuery != null ? SecurityUtil.escapeHtml(searchQuery) : "" %>">
                </div>

                <div class="filter-item">
                    <select name="role" class="form-control" style="width: auto;">
                        <option value="ALL">All Roles</option>
                        <option value="STUDENT" <%= "STUDENT".equalsIgnoreCase(selRole) ? "selected" : "" %>>Students</option>
                        <option value="STAFF" <%= "STAFF".equalsIgnoreCase(selRole) ? "selected" : "" %>>Staff / Technicians</option>
                        <option value="ADMIN" <%= "ADMIN".equalsIgnoreCase(selRole) ? "selected" : "" %>>Administrators</option>
                    </select>
                </div>

                <div class="filter-item">
                    <select name="status" class="form-control" style="width: auto;">
                        <option value="ALL">All Statuses</option>
                        <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Active</option>
                        <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(selStatus) ? "selected" : "" %>>Inactive</option>
                    </select>
                </div>

                <div class="filter-item">
                    <button type="submit" class="btn btn-secondary">Filter</button>
                    <a href="<%= cp %>/admin/users" class="btn btn-secondary">Reset</a>
                </div>
            </form>

            <!-- Users Table Card -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Registered Accounts (<%= users != null ? users.size() : 0 %>)</span>
                </div>
                <div class="card-body" style="padding: 0;">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Department</th>
                                    <th>Phone</th>
                                    <th>Status</th>
                                    <th style="text-align: right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (users != null) {
                                    for (UserBean u : users) { %>
                                        <tr>
                                            <td style="font-family: var(--font-mono); font-weight: 600;"><%= u.getUserId() %></td>
                                            <td style="font-weight: 600;"><%= SecurityUtil.escapeHtml(u.getName()) %></td>
                                            <td><%= SecurityUtil.escapeHtml(u.getEmail()) %></td>
                                            <td>
                                                <span class="badge badge-<%= "ADMIN".equals(u.getRole()) ? "critical" : ("STAFF".equals(u.getRole()) ? "assigned" : "low") %>">
                                                    <%= u.getRole() %>
                                                </span>
                                            </td>
                                            <td>
                                                <%= u.getDepartmentName() != null ? SecurityUtil.escapeHtml(u.getDepartmentName()) : "<span style='color:var(--text-subtle);'>None</span>" %>
                                            </td>
                                            <td><%= u.getPhone() != null ? SecurityUtil.escapeHtml(u.getPhone()) : "-" %></td>
                                            <td>
                                                <span class="badge badge-<%= u.isActive() ? "active" : "inactive" %>">
                                                    <%= u.getAccountStatus() %>
                                                </span>
                                            </td>
                                            <td style="text-align: right;">
                                                <div style="display: flex; gap: 0.4rem; justify-content: flex-end;">
                                                    <% if (u.isStaff()) { %>
                                                        <button type="button" class="btn btn-secondary btn-sm"
                                                                onclick="openAssignDeptModal(<%= u.getUserId() %>, '<%= SecurityUtil.escapeHtml(u.getName()) %>', <%= u.getDepartmentId() %>)">
                                                            Dept
                                                        </button>
                                                    <% } %>

                                                    <% if (!u.isAdmin()) { %>
                                                        <form action="<%= cp %>/admin/users" method="POST" style="margin: 0;">
                                                            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                                                            <input type="hidden" name="action" value="TOGGLE_STATUS">
                                                            <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                                            <input type="hidden" name="targetStatus" value="<%= u.isActive() ? "INACTIVE" : "ACTIVE" %>">
                                                            <button type="submit" class="btn btn-sm <%= u.isActive() ? "btn-danger" : "btn-success" %>"
                                                                    data-confirm="Are you sure you want to <%= u.isActive() ? "deactivate" : "activate" %> <%= SecurityUtil.escapeHtml(u.getName()) %>?">
                                                                <%= u.isActive() ? "Deactivate" : "Activate" %>
                                                            </button>
                                                        </form>
                                                    <% } %>
                                                </div>
                                            </td>
                                        </tr>
                                <%  }
                                } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />
    </main>
</div>

<!-- Modal: Onboard New Staff Member -->
<div class="modal-overlay" id="createStaffModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Onboard New Technician / Staff</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/admin/users" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="action" value="CREATE_STAFF">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Full Name <span class="required">*</span></label>
                    <input type="text" name="name" class="form-control" required placeholder="e.g. Samuel Kumar">
                </div>
                <div class="form-group">
                    <label class="form-label">Institutional Email <span class="required">*</span></label>
                    <input type="email" name="email" class="form-control" required placeholder="e.g. samuel.k@campusflow.edu">
                </div>
                <div class="form-group">
                    <label class="form-label">Temporary Password <span class="required">*</span></label>
                    <input type="password" name="password" class="form-control" required minlength="6" placeholder="Min 6 chars (letters &amp; numbers)">
                </div>
                <div class="form-group">
                    <label class="form-label">Assigned Department</label>
                    <select name="departmentId" class="form-control">
                        <option value="">-- No Department Assigned --</option>
                        <% if (departments != null) {
                            for (DepartmentBean d : departments) { %>
                                <option value="<%= d.getDepartmentId() %>"><%= SecurityUtil.escapeHtml(d.getDepartmentName()) %></option>
                        <%  }
                        } %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Contact Phone</label>
                    <input type="tel" name="phone" class="form-control" placeholder="e.g. 9876543210">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Create Staff Account</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Assign Staff Department -->
<div class="modal-overlay" id="assignDeptModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Assign Department to Staff</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/admin/users" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="action" value="ASSIGN_DEPT">
            <input type="hidden" name="userId" id="assignStaffUserId">
            <div class="modal-body">
                <p style="font-size: 0.9rem; margin-bottom: 1rem;">
                    Updating department assignment for <strong id="assignStaffUserName"></strong>:
                </p>
                <div class="form-group">
                    <label class="form-label">Service Department</label>
                    <select name="departmentId" id="assignStaffDeptSelect" class="form-control">
                        <option value="-1">-- Unassigned --</option>
                        <% if (departments != null) {
                            for (DepartmentBean d : departments) { %>
                                <option value="<%= d.getDepartmentId() %>"><%= SecurityUtil.escapeHtml(d.getDepartmentName()) %></option>
                        <%  }
                        } %>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Update Assignment</button>
            </div>
        </form>
    </div>
</div>

<script src="<%= cp %>/assets/js/app.js"></script>
<script>
    function openAssignDeptModal(userId, name, deptId) {
        document.getElementById('assignStaffUserId').value = userId;
        document.getElementById('assignStaffUserName').textContent = name;
        document.getElementById('assignStaffDeptSelect').value = deptId ? deptId : "-1";
        document.getElementById('assignDeptModal').classList.add('active');
    }
</script>
</body>
</html>
