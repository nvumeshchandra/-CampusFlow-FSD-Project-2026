<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    String cp = request.getContextPath();
    String emailVal = (String) request.getAttribute("email");
    if (emailVal == null) emailVal = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - CampusFlow</title>
    <link rel="stylesheet" href="<%= cp %>/assets/css/main.css">
</head>
<body style="background: var(--bg-app); min-height: 100vh; display: flex; flex-direction: column;">

    <header style="background: white; border-bottom: 1px solid var(--border-subtle); height: 64px; display: flex; align-items: center; justify-content: space-between; padding: 0 2rem;">
        <a href="<%= cp %>/home" style="display: flex; align-items: center; gap: 0.75rem; text-decoration: none;">
            <img src="<%= cp %>/assets/images/logo.svg" alt="CampusFlow" style="width: 32px; height: 32px;">
            <span style="font-size: 1.2rem; font-weight: 800; color: var(--primary-900);">CampusFlow</span>
        </a>
        <a href="<%= cp %>/register" class="btn btn-secondary btn-sm">Need an account? Register</a>
    </header>

    <main style="flex: 1; display: flex; align-items: center; justify-content: center; padding: 2.5rem 1rem;">
        <div style="width: 100%; max-width: 440px;">
            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div class="card" style="box-shadow: var(--shadow-md);">
                <div class="card-header" style="flex-direction: column; align-items: flex-start; padding: 1.5rem 1.75rem 1rem;">
                    <h2 style="font-size: 1.35rem; font-weight: 700; color: var(--text-main);">Sign in to CampusFlow</h2>
                    <p style="font-size: 0.85rem; color: var(--text-subtle); margin-top: 0.25rem;">
                        Enter your institutional email and password to access your role dashboard.
                    </p>
                </div>

                <div class="card-body" style="padding: 1.75rem;">
                    <form action="<%= cp %>/login" method="POST" id="loginForm">
                        <div class="form-group">
                            <label class="form-label">Email Address <span class="required">*</span></label>
                            <input type="email" name="email" id="loginEmail" class="form-control" required
                                   placeholder="e.g. student@campusflow.edu"
                                   value="<%= SecurityUtil.escapeHtml(emailVal) %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Password <span class="required">*</span></label>
                            <input type="password" name="password" id="loginPassword" class="form-control" required
                                   placeholder="Enter your password">
                        </div>

                        <button type="submit" class="btn btn-primary" style="width: 100%; padding: 0.75rem; font-size: 0.95rem;">
                            Sign In
                        </button>
                    </form>

                    <!-- Quick Demo Fill Section -->
                    <div style="margin-top: 1.5rem; padding-top: 1.25rem; border-top: 1px dashed var(--border-strong);">
                        <div style="font-size: 0.75rem; font-weight: 700; text-transform: uppercase; color: var(--text-subtle); margin-bottom: 0.65rem; text-align: center; letter-spacing: 0.05em;">
                            Quick Demonstration Fill
                        </div>
                        <div style="display: flex; gap: 0.5rem; justify-content: center;">
                            <button type="button" class="btn btn-secondary btn-sm" onclick="quickFill('admin@campusflow.edu', 'Admin@123')">
                                Admin
                            </button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="quickFill('it.staff@campusflow.edu', 'Staff@123')">
                                IT Staff
                            </button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="quickFill('student@campusflow.edu', 'Student@123')">
                                Student
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div style="text-align: center; font-size: 0.85rem; color: var(--text-subtle); margin-top: 1rem;">
                Are you a new student? <a href="<%= cp %>/register" style="font-weight: 600;">Create your account</a>
            </div>
        </div>
    </main>

    <footer class="app-footer">
        <div>CampusFlow &bull; Oracle Database &bull; Apache Tomcat 9</div>
    </footer>

    <script>
        function quickFill(email, pass) {
            document.getElementById('loginEmail').value = email;
            document.getElementById('loginPassword').value = pass;
        }
    </script>
</body>
</html>
