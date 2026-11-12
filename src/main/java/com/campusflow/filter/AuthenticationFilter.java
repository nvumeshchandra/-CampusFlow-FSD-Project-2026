package com.campusflow.filter;

import com.campusflow.model.UserBean;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter enforcing session-based authentication and role-based URL authorization.
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/*"})
public class AuthenticationFilter implements Filter {

    public static final String SESSION_USER_KEY = "LOGGED_IN_USER";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String contextPath = request.getContextPath();
        String uri = request.getRequestURI().substring(contextPath.length());

        // Allow static assets
        if (uri.startsWith("/assets/") || uri.endsWith(".css") || uri.endsWith(".js") || uri.endsWith(".svg") || uri.endsWith(".png") || uri.endsWith(".ico")) {
            chain.doFilter(req, res);
            return;
        }

        // Allow public pages
        if (isPublicUri(uri)) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        UserBean user = (session != null) ? (UserBean) session.getAttribute(SESSION_USER_KEY) : null;

        if (user == null) {
            // Unauthenticated user attempting to access private route
            response.sendRedirect(contextPath + "/login?error=session_expired");
            return;
        }

        // Account status check
        if (!user.isActive()) {
            session.invalidate();
            response.sendRedirect(contextPath + "/login?error=account_deactivated");
            return;
        }

        // Role-based authorization checks
        if (uri.startsWith("/admin/") && !user.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrator role required.");
            return;
        }

        if (uri.startsWith("/staff/") && !user.isStaff() && !user.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Staff role required.");
            return;
        }

        if (uri.startsWith("/student/") && !user.isStudent() && !user.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Student role required.");
            return;
        }

        chain.doFilter(req, res);
    }

    private boolean isPublicUri(String uri) {
        return uri.equals("") || uri.equals("/") || uri.equals("/index.jsp") ||
               uri.equals("/login") || uri.equals("/register") || uri.equals("/logout") ||
               uri.equals("/access-denied") || uri.equals("/error");
    }

    @Override
    public void destroy() {}
}
