package com.campusflow.controller;

import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.UserBean;
import com.campusflow.service.RequestService;
import com.campusflow.service.WorkflowService.WorkflowResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller for cancelling an eligible request.
 */
@WebServlet(name = "RequestCancelServlet", urlPatterns = {"/student/request/cancel", "/admin/request/cancel"})
public class RequestCancelServlet extends HttpServlet {

    private final RequestService requestService = new RequestService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String idParam = request.getParameter("requestId");
        String reason = request.getParameter("reason");

        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            Long reqId = Long.parseLong(idParam);
            WorkflowResult result = requestService.cancelRequest(reqId, reason, user);

            String redirectUrl = user.isAdmin()
                ? request.getContextPath() + "/admin/request/details?id=" + reqId
                : request.getContextPath() + "/student/request/details?id=" + reqId;

            if (result.isSuccess()) {
                session.setAttribute("flashSuccess", "Request has been cancelled.");
            } else {
                session.setAttribute("flashError", result.getMessage());
            }

            response.sendRedirect(redirectUrl);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
