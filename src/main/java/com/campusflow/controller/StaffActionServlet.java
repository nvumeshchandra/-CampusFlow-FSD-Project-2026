package com.campusflow.controller;

import com.campusflow.dao.RequestDAO;
import com.campusflow.dao.RequestHistoryDAO;
import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.RequestBean;
import com.campusflow.model.RequestHistoryBean;
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
 * Controller handling staff workflow actions: accept/start work, update progress remarks, mark resolved.
 */
@WebServlet(name = "StaffActionServlet", urlPatterns = {"/staff/request/action"})
public class StaffActionServlet extends HttpServlet {

    private final WorkflowService workflowService = new WorkflowService();
    private final RequestDAO requestDAO = new RequestDAO();
    private final RequestHistoryDAO historyDAO = new RequestHistoryDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean staff = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String idParam = request.getParameter("requestId");
        String action = request.getParameter("action");
        String remarks = request.getParameter("remarks");

        if (idParam == null || action == null) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }

        try {
            Long reqId = Long.parseLong(idParam);
            RequestBean req = requestDAO.findById(reqId);
            if (req == null) {
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                return;
            }

            // Ensure assigned staff or admin
            if (!staff.isAdmin() && (req.getAssignedStaffId() == null || !req.getAssignedStaffId().equals(staff.getUserId()))) {
                session.setAttribute("flashError", "You are not assigned to this request.");
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                return;
            }

            if ("START_WORK".equalsIgnoreCase(action)) {
                WorkflowResult result = workflowService.transitionStatus(reqId, "IN_PROGRESS",
                    (remarks != null && !remarks.trim().isEmpty() ? remarks : "Staff started work on issue"), staff);
                if (result.isSuccess()) {
                    session.setAttribute("flashSuccess", "Request accepted! Status changed to IN_PROGRESS.");
                } else {
                    session.setAttribute("flashError", result.getMessage());
                }
            } else if ("RESOLVE".equalsIgnoreCase(action)) {
                if (remarks == null || remarks.trim().length() < 5) {
                    session.setAttribute("flashError", "Please provide detailed resolution remarks (min 5 characters).");
                } else {
                    WorkflowResult result = workflowService.transitionStatus(reqId, "RESOLVED", remarks, staff);
                    if (result.isSuccess()) {
                        session.setAttribute("flashSuccess", "Request marked as RESOLVED! Student has been notified.");
                    } else {
                        session.setAttribute("flashError", result.getMessage());
                    }
                }
            } else if ("ADD_REMARK".equalsIgnoreCase(action)) {
                if (remarks != null && !remarks.trim().isEmpty()) {
                    RequestHistoryBean h = new RequestHistoryBean();
                    h.setRequestId(reqId);
                    h.setActionType("PROGRESS_UPDATE");
                    h.setOldStatus(req.getStatus());
                    h.setNewStatus(req.getStatus());
                    h.setRemarks("Staff Note: " + remarks.trim());
                    h.setActorUserId(staff.getUserId());
                    historyDAO.create(h);
                    session.setAttribute("flashSuccess", "Progress remark recorded.");
                }
            }

            response.sendRedirect(request.getContextPath() + "/staff/request/details?id=" + reqId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
        }
    }
}
