package com.campusflow.controller;

import com.campusflow.dao.DepartmentDAO;
import com.campusflow.dao.FeedbackDAO;
import com.campusflow.dao.RequestDAO;
import com.campusflow.dao.RequestHistoryDAO;
import com.campusflow.dao.UserDAO;
import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.DepartmentBean;
import com.campusflow.model.FeedbackBean;
import com.campusflow.model.RequestBean;
import com.campusflow.model.RequestHistoryBean;
import com.campusflow.model.UserBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller providing detailed request inspection, audit history timeline,
 * and role-appropriate actions for Students, Staff, and Administrators.
 */
@WebServlet(name = "RequestDetailsServlet", urlPatterns = {
    "/student/request/details",
    "/staff/request/details",
    "/admin/request/details"
})
public class RequestDetailsServlet extends HttpServlet {

    private final RequestDAO requestDAO = new RequestDAO();
    private final RequestHistoryDAO historyDAO = new RequestHistoryDAO();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String idParam = request.getParameter("id");
        String codeParam = request.getParameter("code");

        RequestBean req = null;
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                req = requestDAO.findById(Long.parseLong(idParam.trim()));
            } catch (NumberFormatException ignored) {}
        } else if (codeParam != null && !codeParam.trim().isEmpty()) {
            req = requestDAO.findByTrackingCode(codeParam.trim());
        }

        if (req == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "The requested service ticket does not exist.");
            return;
        }

        // Authorization check
        if (user.isStudent() && !req.getUserId().equals(user.getUserId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You can only view your own requests.");
            return;
        }

        // Audit History Timeline
        List<RequestHistoryBean> historyList = historyDAO.findByRequestId(req.getRequestId());

        // Feedback
        FeedbackBean feedback = feedbackDAO.findByRequestId(req.getRequestId());

        // Flash messages
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

        request.setAttribute("req", req);
        request.setAttribute("historyList", historyList);
        request.setAttribute("feedback", feedback);

        // Role-specific view dispatching
        String uri = request.getRequestURI();
        if (uri.contains("/admin/")) {
            List<DepartmentBean> departments = departmentDAO.findAll(true);
            request.setAttribute("departments", departments);
            if (req.getDepartmentId() != null) {
                List<UserBean> deptStaff = userDAO.findStaffByDepartment(req.getDepartmentId());
                request.setAttribute("deptStaff", deptStaff);
            }
            request.getRequestDispatcher("/WEB-INF/views/admin/request-details.jsp").forward(request, response);
        } else if (uri.contains("/staff/")) {
            request.getRequestDispatcher("/WEB-INF/views/staff/request-details.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/views/student/request-details.jsp").forward(request, response);
        }
    }
}
