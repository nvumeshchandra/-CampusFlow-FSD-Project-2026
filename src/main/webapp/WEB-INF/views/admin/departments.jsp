<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.campusflow.model.DepartmentBean" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    request.setAttribute("pageTitle", "Department Management");
    List<DepartmentBean> departments = (List<DepartmentBean>) request.getAttribute("departments");
    String csrfToken = (String) request.getAttribute("csrfToken");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Departments Management - CampusFlow</title>
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
                    <h1 class="page-title">Campus Service Departments</h1>
                    <p class="page-description">Configure institutional service departments, view technician allocations, and manage active operations.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-primary" data-modal-target="createDeptModal">
                        + Add New Department
                    </button>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Registered Departments (<%= departments != null ? departments.size() : 0 %>)</span>
                </div>
                <div class="card-body" style="padding: 0;">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Department Name</th>
                                    <th>Description</th>
                                    <th>Assigned Staff</th>
                                    <th>Active Issues</th>
                                    <th>Status</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (departments != null) {
                                    for (DepartmentBean d : departments) { %>
                                        <tr>
                                            <td style="font-family: var(--font-mono); font-weight: 600;"><%= d.getDepartmentId() %></td>
                                            <td style="font-weight: 600;"><%= SecurityUtil.escapeHtml(d.getDepartmentName()) %></td>
                                            <td style="color: var(--text-muted); font-size: 0.8125rem;"><%= SecurityUtil.escapeHtml(d.getDescription()) %></td>
                                            <td>
                                                <span class="badge badge-assigned"><%= d.getStaffCount() %> Technicians</span>
                                            </td>
                                            <td>
                                                <span class="badge badge-<%= d.getActiveRequestsCount() > 0 ? "in_progress" : "closed" %>">
                                                    <%= d.getActiveRequestsCount() %> Open
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge badge-<%= d.isActive() ? "active" : "inactive" %>">
                                                    <%= d.getActiveStatus() %>
                                                </span>
                                            </td>
                                            <td style="text-align: right;">
                                                <button type="button" class="btn btn-secondary btn-sm"
                                                        onclick="editDept(<%= d.getDepartmentId() %>, '<%= SecurityUtil.escapeHtml(d.getDepartmentName()) %>', '<%= d.getDescription() != null ? SecurityUtil.escapeHtml(d.getDescription()) : "" %>', '<%= d.getActiveStatus() %>')">
                                                    Edit
                                                </button>
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

<!-- Modal: Create Department -->
<div class="modal-overlay" id="createDeptModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Create Campus Department</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/admin/departments" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="action" value="CREATE">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Department Name <span class="required">*</span></label>
                    <input type="text" name="departmentName" class="form-control" required placeholder="e.g. Audiovisual &amp; Multimedia Systems">
                </div>
                <div class="form-group">
                    <label class="form-label">Description / Scope of Work</label>
                    <textarea name="description" class="form-control" rows="3" placeholder="Facilities, amenities, and equipment managed by this unit..."></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Status <span class="required">*</span></label>
                    <select name="activeStatus" class="form-control">
                        <option value="ACTIVE" selected>ACTIVE</option>
                        <option value="INACTIVE">INACTIVE</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Create Department</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Edit Department -->
<div class="modal-overlay" id="editDeptModal">
    <div class="modal-dialog">
        <div class="modal-header">
            <span class="modal-title">Edit Department</span>
            <button type="button" class="modal-close">&times;</button>
        </div>
        <form action="<%= cp %>/admin/departments" method="POST">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="action" value="UPDATE">
            <input type="hidden" name="departmentId" id="editDeptId">
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Department Name <span class="required">*</span></label>
                    <input type="text" name="departmentName" id="editDeptName" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea name="description" id="editDeptDesc" class="form-control" rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Status <span class="required">*</span></label>
                    <select name="activeStatus" id="editDeptStatus" class="form-control">
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="INACTIVE">INACTIVE</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<script src="<%= cp %>/assets/js/app.js"></script>
<script>
    function editDept(id, name, desc, status) {
        document.getElementById('editDeptId').value = id;
        document.getElementById('editDeptName').value = name;
        document.getElementById('editDeptDesc').value = desc;
        document.getElementById('editDeptStatus').value = status;
        document.getElementById('editDeptModal').classList.add('active');
    }
</script>
</body>
</html>
