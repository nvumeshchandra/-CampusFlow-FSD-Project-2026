<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - CampusFlow</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
</head>
<body style="display:flex; align-items:center; justify-content:center; min-height:100vh; background-color: var(--bg-app);">
    <div style="background: white; border: 1px solid var(--border-subtle); border-radius: var(--radius-lg); padding: 3rem; text-align: center; max-width: 480px; box-shadow: var(--shadow-md);">
        <div style="width: 64px; height: 64px; border-radius: 50%; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem;">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
        </div>
        <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--text-main); margin-bottom: 0.5rem;">403 - Access Denied</h1>
        <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 1.5rem;">
            You do not have administrative or role-based clearance to access this resource or perform this operation.
        </p>
        <a href="<%= request.getContextPath() %>/home" class="btn btn-primary">Return to My Dashboard</a>
    </div>
</body>
</html>
