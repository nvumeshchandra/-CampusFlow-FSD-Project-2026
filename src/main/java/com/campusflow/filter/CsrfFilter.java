package com.campusflow.filter;

import com.campusflow.util.SecurityUtil;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter generating and enforcing CSRF tokens on state-changing POST requests.
 */
@WebFilter(filterName = "CsrfFilter", urlPatterns = {"/*"})
public class CsrfFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // Ensure session exists or token is initialized for view forms
        HttpSession session = request.getSession(true);
        String token = SecurityUtil.getOrCreateCsrfToken(session);
        request.setAttribute("csrfToken", token);

        String method = request.getMethod();
        String uri = request.getRequestURI().substring(request.getContextPath().length());

        // Validate on state-changing methods: POST
        if ("POST".equalsIgnoreCase(method)) {
            // Exclude public login and register which may establish new sessions
            if (!uri.equals("/login") && !uri.equals("/register")) {
                boolean valid = SecurityUtil.validateCsrfToken(request);
                if (!valid) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token.");
                    return;
                }
            }
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {}
}
