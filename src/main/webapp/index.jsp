<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusflow.model.UserBean" %>
<%@ page import="com.campusflow.filter.AuthenticationFilter" %>
<%
    UserBean loggedUser = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CampusFlow — Smart College Service &amp; Issue Management System</title>
    <link rel="stylesheet" href="<%= cp %>/assets/css/main.css">
    <style>
        .hero-section {
            background: linear-gradient(135deg, #ffffff 0%, #f0f7ff 100%);
            border-bottom: 1px solid var(--border-subtle);
            padding: 4.5rem 2rem 4rem;
            text-align: center;
        }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: #dbeafe;
            color: #1e40af;
            font-size: 0.8125rem;
            font-weight: 700;
            padding: 0.35rem 0.85rem;
            border-radius: var(--radius-full);
            margin-bottom: 1.25rem;
            letter-spacing: 0.03em;
        }
        .hero-title {
            font-size: 2.75rem;
            font-weight: 800;
            color: var(--text-main);
            letter-spacing: -0.03em;
            line-height: 1.2;
            max-width: 800px;
            margin: 0 auto 1.25rem;
        }
        .hero-desc {
            font-size: 1.15rem;
            color: var(--text-muted);
            max-width: 650px;
            margin: 0 auto 2.25rem;
            line-height: 1.6;
        }
        .hero-actions {
            display: flex;
            justify-content: center;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.75rem;
            max-width: 1200px;
            margin: 3.5rem auto 4rem;
            padding: 0 1.5rem;
        }
        .feature-card {
            background: white;
            border: 1px solid var(--border-subtle);
            border-radius: var(--radius-lg);
            padding: 1.75rem;
            box-shadow: var(--shadow-sm);
            transition: transform 0.15s ease;
        }
        .feature-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-md);
        }
        .feature-icon-box {
            width: 44px;
            height: 44px;
            border-radius: var(--radius-md);
            background: var(--primary-50);
            color: var(--primary-600);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.25rem;
        }
    </style>
</head>
<body style="background: var(--bg-app); min-height: 100vh; display: flex; flex-direction: column;">

    <!-- Public Topbar -->
    <header style="background: white; border-bottom: 1px solid var(--border-subtle); height: 68px; display: flex; align-items: center; justify-content: space-between; padding: 0 2.5rem;">
        <div style="display: flex; align-items: center; gap: 0.85rem;">
            <img src="<%= cp %>/assets/images/logo.svg" alt="CampusFlow" style="width: 36px; height: 36px;">
            <span style="font-size: 1.25rem; font-weight: 800; color: var(--primary-900); letter-spacing: -0.02em;">CampusFlow</span>
        </div>
        <div style="display: flex; align-items: center; gap: 1rem;">
            <% if (loggedUser != null) { %>
                <a href="<%= cp %>/home" class="btn btn-primary btn-sm">Enter Portal (<%= loggedUser.getRole() %>)</a>
                <a href="<%= cp %>/logout" class="btn btn-secondary btn-sm">Sign Out</a>
            <% } else { %>
                <a href="<%= cp %>/login" class="btn btn-secondary btn-sm">Sign In</a>
                <a href="<%= cp %>/register" class="btn btn-primary btn-sm">Student Registration</a>
            <% } %>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="hero-badge">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            <span>Oracle 10g/11g/19c &bull; Tomcat 9 &bull; Pure Java MVC</span>
        </div>
        <h1 class="hero-title">Smart College Service &amp; Issue Management System</h1>
        <p class="hero-desc">
            Streamlining campus operations: transparent student ticket tracking, deterministic rule-based priority routing, automated staff dispatching, and live administrative analytics.
        </p>
        <div class="hero-actions">
            <% if (loggedUser != null) { %>
                <a href="<%= cp %>/home" class="btn btn-primary" style="padding: 0.75rem 1.75rem; font-size: 1rem;">Go to My Dashboard &rarr;</a>
            <% } else { %>
                <a href="<%= cp %>/login" class="btn btn-primary" style="padding: 0.75rem 1.75rem; font-size: 1rem;">Access System Portal &rarr;</a>
                <a href="<%= cp %>/register" class="btn btn-secondary" style="padding: 0.75rem 1.75rem; font-size: 1rem;">Student Sign Up</a>
            <% } %>
        </div>
    </section>

    <!-- Features -->
    <main style="flex: 1;">
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon-box">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                </div>
                <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 0.5rem; color: var(--text-main);">Transparent Request Tracking</h3>
                <p style="font-size: 0.9rem; color: var(--text-muted); line-height: 1.55;">
                    Unique tracking codes (e.g. <code>CF-2026-00001</code>), chronological audit history timeline, progress remarks, and real-time status transitions.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-box">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                </div>
                <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 0.5rem; color: var(--text-main);">Rule-Based Priority Engine</h3>
                <p style="font-size: 0.9rem; color: var(--text-muted); line-height: 1.55;">
                    Deterministic multi-factor calculation combining Urgency (1-4), Impact (1-4), and Location Facility Type (1-3) into explainable LOW, MEDIUM, HIGH, or CRITICAL priorities.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-box">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                </div>
                <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 0.5rem; color: var(--text-main);">Role-Based Security &amp; Audit</h3>
                <p style="font-size: 0.9rem; color: var(--text-muted); line-height: 1.55;">
                    PBKDF2 salted password hashing, CSRF token validation, session protection, server-side workflow enforcement, and Oracle database ACID transactions.
                </p>
            </div>
        </div>

        <!-- Demonstration Demo Accounts Quick Reference -->
        <div style="max-width: 900px; margin: 0 auto 4rem; padding: 0 1.5rem;">
            <div class="card" style="border: 1px solid #bfdbfe; background: #f8fbff;">
                <div class="card-header" style="background: transparent;">
                    <span class="card-title" style="color: #1e40af;">Demonstration Accounts (Instant Evaluation)</span>
                    <span class="badge badge-assigned">PBKDF2 Authenticated</span>
                </div>
                <div class="card-body">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1rem; font-size: 0.85rem;">
                        <div style="background: white; padding: 0.85rem; border-radius: var(--radius-md); border: 1px solid var(--border-subtle);">
                            <strong style="color: #1e3a8a;">Administrator</strong><br>
                            Email: <code>admin@campusflow.edu</code><br>
                            Password: <code>Admin@123</code>
                        </div>
                        <div style="background: white; padding: 0.85rem; border-radius: var(--radius-md); border: 1px solid var(--border-subtle);">
                            <strong style="color: #065f46;">IT Staff</strong><br>
                            Email: <code>it.staff@campusflow.edu</code><br>
                            Password: <code>Staff@123</code>
                        </div>
                        <div style="background: white; padding: 0.85rem; border-radius: var(--radius-md); border: 1px solid var(--border-subtle);">
                            <strong style="color: #78350f;">Student</strong><br>
                            Email: <code>student@campusflow.edu</code><br>
                            Password: <code>Student@123</code>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer class="app-footer">
        <div>
            <strong>CampusFlow</strong> &mdash; Smart College Service &amp; Issue Management System
        </div>
        <div>
            <span>Oracle Database &bull; Apache Tomcat 9 &bull; Pure Java MVC Architecture</span>
        </div>
    </footer>
</body>
</html>
