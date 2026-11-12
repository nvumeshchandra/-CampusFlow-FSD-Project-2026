package com.campusflow.controller;

import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.UserBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Public Landing Page Controller.
 * Routes authenticated users directly to their designated role dashboard.
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"", "/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            UserBean user = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
            if (user != null) {
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    return;
                } else if (user.isStaff()) {
                    response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                    return;
                } else if (user.isStudent()) {
                    response.sendRedirect(request.getContextPath() + "/student/dashboard");
                    return;
                }
            }
        }
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
