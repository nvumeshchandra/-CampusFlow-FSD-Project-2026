<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - CampusFlow</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/main.css">
</head>
<body style="display:flex; align-items:center; justify-content:center; min-height:100vh; background-color: var(--bg-app);">
    <div style="background: white; border: 1px solid var(--border-subtle); border-radius: var(--radius-lg); padding: 3rem; text-align: center; max-width: 480px; box-shadow: var(--shadow-md);">
        <div style="width: 64px; height: 64px; border-radius: 50%; background: #e0f2fe; color: #0284c7; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem;">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M16 16s-1.5-2-4-2-4 2-4 2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>
        </div>
        <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--text-main); margin-bottom: 0.5rem;">404 - Page Not Found</h1>
        <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 1.5rem;">
            The page or service ticket you requested could not be located on the campus portal.
        </p>
        <a href="<%= request.getContextPath() %>/home" class="btn btn-primary">Return to Dashboard</a>
    </div>
</body>
</html>
