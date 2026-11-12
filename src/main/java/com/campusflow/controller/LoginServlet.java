package com.campusflow.controller;

import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.UserBean;
import com.campusflow.service.AuthService;
import com.campusflow.service.AuthService.AuthResult;
import com.campusflow.util.SecurityUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller handling user authentication and session establishment.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute(AuthenticationFilter.SESSION_USER_KEY) != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String errorParam = request.getParameter("error");
        if ("session_expired".equalsIgnoreCase(errorParam)) {
            request.setAttribute("errorMessage", "Your session has expired. Please log in again.");
        } else if ("account_deactivated".equalsIgnoreCase(errorParam)) {
            request.setAttribute("errorMessage", "Your account has been deactivated. Contact an administrator.");
        }

        if ("true".equalsIgnoreCase(request.getParameter("registered"))) {
            request.setAttribute("successMessage", "Account created successfully! You can now log in.");
        } else if ("true".equalsIgnoreCase(request.getParameter("logged_out"))) {
            request.setAttribute("successMessage", "You have been logged out securely.");
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        AuthResult result = authService.login(email, password);

        if (result.isSuccess()) {
            // Prevent Session Fixation by creating a clean new session
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute(AuthenticationFilter.SESSION_USER_KEY, result.getUser());
            SecurityUtil.getOrCreateCsrfToken(newSession);

            UserBean user = result.getUser();
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else if (user.isStaff()) {
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/student/dashboard");
            }
        } else {
            request.setAttribute("errorMessage", result.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }
}
