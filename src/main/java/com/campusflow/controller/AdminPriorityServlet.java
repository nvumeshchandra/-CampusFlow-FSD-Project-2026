package com.campusflow.controller;

import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.UserBean;
import com.campusflow.service.RequestService;
import com.campusflow.service.RequestService.RequestResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller for Administrative Priority Overrides with recorded justification.
 */
@WebServlet(name = "AdminPriorityServlet", urlPatterns = {"/admin/request/priority"})
public class AdminPriorityServlet extends HttpServlet {

    private final RequestService requestService = new RequestService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean admin = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String idParam = request.getParameter("requestId");
        String priority = request.getParameter("priority");
        String reason = request.getParameter("reason");

        if (idParam == null || priority == null) {
            response.sendRedirect(request.getContextPath() + "/admin/requests");
            return;
        }

        try {
            Long reqId = Long.parseLong(idParam);
            RequestResult result = requestService.overridePriority(reqId, priority, reason, admin);

            if (result.isSuccess()) {
                session.setAttribute("flashSuccess", "Priority overridden to " + priority.toUpperCase() + ".");
            } else {
                session.setAttribute("flashError", result.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/admin/request/details?id=" + reqId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/requests");
        }
    }
}
