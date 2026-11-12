package com.campusflow.controller;

import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.UserBean;
import com.campusflow.service.WorkflowService;
import com.campusflow.service.WorkflowService.WorkflowResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller for Administrative Workflow Transitions (e.g., closing resolved requests).
 */
@WebServlet(name = "AdminStatusServlet", urlPatterns = {"/admin/request/status"})
public class AdminStatusServlet extends HttpServlet {

    private final WorkflowService workflowService = new WorkflowService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean admin = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String idParam = request.getParameter("requestId");
        String targetStatus = request.getParameter("targetStatus");
        String remarks = request.getParameter("remarks");

        if (idParam == null || targetStatus == null) {
            response.sendRedirect(request.getContextPath() + "/admin/requests");
            return;
        }

        try {
            Long reqId = Long.parseLong(idParam);
            WorkflowResult result = workflowService.transitionStatus(reqId, targetStatus, remarks, admin);

            if (result.isSuccess()) {
                session.setAttribute("flashSuccess", result.getMessage());
            } else {
                session.setAttribute("flashError", result.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/admin/request/details?id=" + reqId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/requests");
        }
    }
}
