package com.campusflow.controller;

import com.campusflow.dao.UserDAO;
import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.UserBean;
import com.campusflow.service.AuthService;
import com.campusflow.service.AuthService.AuthResult;
import com.campusflow.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller for viewing and managing individual user profile and credentials.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean sessionUser = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        // Fetch fresh record from DB
        UserBean user = userDAO.findById(sessionUser.getUserId());
        request.setAttribute("user", user);

        String flashSuccess = (String) session.getAttribute("flashSuccess");
        if (flashSuccess != null) {
            request.setAttribute("successMessage", flashSuccess);
            session.removeAttribute("flashSuccess");
        }
        String flashError = (String) session.getAttribute("flashError");
        if (flashError != null) {
            request.setAttribute("errorMessage", flashError);
            session.removeAttribute("flashError");
        }

        request.getRequestDispatcher("/WEB-INF/views/common/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean sessionUser = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
        String action = request.getParameter("action");

        if ("UPDATE_PROFILE".equalsIgnoreCase(action)) {
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");

            if (!ValidationUtil.isNotEmpty(name) || name.trim().length() < 2) {
                session.setAttribute("flashError", "Full name must be at least 2 characters.");
            } else if (phone != null && !phone.trim().isEmpty() && !ValidationUtil.isValidPhone(phone)) {
                session.setAttribute("flashError", "Please enter a valid phone number.");
            } else {
                UserBean updated = new UserBean();
                updated.setUserId(sessionUser.getUserId());
                updated.setName(name.trim());
                updated.setPhone(phone != null ? phone.trim() : null);

                boolean ok = userDAO.updateProfile(updated);
                if (ok) {
                    sessionUser.setName(name.trim());
                    sessionUser.setPhone(phone != null ? phone.trim() : null);
                    session.setAttribute("flashSuccess", "Profile details updated successfully.");
                } else {
                    session.setAttribute("flashError", "Failed to update profile details.");
                }
            }
        } else if ("CHANGE_PASSWORD".equalsIgnoreCase(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword != null && !newPassword.equals(confirmPassword)) {
                session.setAttribute("flashError", "New password confirmation does not match.");
            } else {
                AuthResult result = authService.changePassword(sessionUser.getUserId(), currentPassword, newPassword);
                if (result.isSuccess()) {
                    session.setAttribute("flashSuccess", "Password changed successfully.");
                } else {
                    session.setAttribute("flashError", result.getMessage());
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
