<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusflow.util.SecurityUtil" %>
<%
    String cp = request.getContextPath();
    String nameVal = (String) request.getAttribute("name");
    String emailVal = (String) request.getAttribute("email");
    String phoneVal = (String) request.getAttribute("phone");
    if (nameVal == null) nameVal = "";
    if (emailVal == null) emailVal = "";
    if (phoneVal == null) phoneVal = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Registration - CampusFlow</title>
    <link rel="stylesheet" href="<%= cp %>/assets/css/main.css">
</head>
<body style="background: var(--bg-app); min-height: 100vh; display: flex; flex-direction: column;">

    <header style="background: white; border-bottom: 1px solid var(--border-subtle); height: 64px; display: flex; align-items: center; justify-content: space-between; padding: 0 2rem;">
        <a href="<%= cp %>/home" style="display: flex; align-items: center; gap: 0.75rem; text-decoration: none;">
            <img src="<%= cp %>/assets/images/logo.svg" alt="CampusFlow" style="width: 32px; height: 32px;">
            <span style="font-size: 1.2rem; font-weight: 800; color: var(--primary-900);">CampusFlow</span>
        </a>
        <a href="<%= cp %>/login" class="btn btn-secondary btn-sm">Already registered? Sign In</a>
    </header>

    <main style="flex: 1; display: flex; align-items: center; justify-content: center; padding: 2.5rem 1rem;">
        <div style="width: 100%; max-width: 480px;">
            <jsp:include page="/WEB-INF/views/common/messages.jsp" />

            <div class="card" style="box-shadow: var(--shadow-md);">
                <div class="card-header" style="flex-direction: column; align-items: flex-start; padding: 1.5rem 1.75rem 1rem;">
                    <h2 style="font-size: 1.35rem; font-weight: 700; color: var(--text-main);">Create Student Account</h2>
                    <p style="font-size: 0.85rem; color: var(--text-subtle); margin-top: 0.25rem;">
                        Register your college profile to report issues, track repairs, and provide service ratings.
                    </p>
                </div>

                <div class="card-body" style="padding: 1.75rem;">
                    <form action="<%= cp %>/register" method="POST">
                        <div class="form-group">
                            <label class="form-label">Full Name <span class="required">*</span></label>
                            <input type="text" name="name" class="form-control" required minlength="2"
                                   placeholder="e.g. Priya Sharma"
                                   value="<%= SecurityUtil.escapeHtml(nameVal) %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label">College Email Address <span class="required">*</span></label>
                            <input type="email" name="email" class="form-control" required
                                   placeholder="e.g. priya.sharma@campusflow.edu"
                                   value="<%= SecurityUtil.escapeHtml(emailVal) %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Phone Number (Optional)</label>
                            <input type="tel" name="phone" class="form-control"
                                   placeholder="e.g. 9876543210"
                                   value="<%= SecurityUtil.escapeHtml(phoneVal) %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Password <span class="required">*</span></label>
                            <input type="password" name="password" class="form-control" required minlength="6"
                                   placeholder="Minimum 6 characters (letters &amp; numbers)">
                            <div class="form-hint">Enforces PBKDF2 cryptographic salted hashing.</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Confirm Password <span class="required">*</span></label>
                            <input type="password" name="confirmPassword" class="form-control" required minlength="6"
                                   placeholder="Confirm password">
                        </div>

                        <button type="submit" class="btn btn-primary" style="width: 100%; padding: 0.75rem; font-size: 0.95rem;">
                            Register Student Account
                        </button>
                    </form>
                </div>
            </div>

            <div style="text-align: center; font-size: 0.85rem; color: var(--text-subtle); margin-top: 1rem;">
                Already have an account? <a href="<%= cp %>/login" style="font-weight: 600;">Sign in here</a>
            </div>
        </div>
    </main>

    <footer class="app-footer">
        <div>CampusFlow &bull; Oracle Database &bull; Apache Tomcat 9</div>
    </footer>
</body>
</html>
