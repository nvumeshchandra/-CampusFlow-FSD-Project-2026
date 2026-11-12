package com.campusflow.controller;

import com.campusflow.dao.NotificationDAO;
import com.campusflow.dao.RequestDAO;
import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.RequestBean;
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
 * Controller for Student Dashboard.
 */
@WebServlet(name = "StudentDashboardServlet", urlPatterns = {"/student/dashboard"})
public class StudentDashboardServlet extends HttpServlet {

    private final RequestDAO requestDAO = new RequestDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean student = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        Long studentId = student.getUserId();

        // Count metrics for student
        int totalRequests = requestDAO.countRequests(studentId, null, null, null, null, null, null, null);
        int submittedCount = requestDAO.countRequests(studentId, null, null, "SUBMITTED", null, null, null, null);
        int assignedCount = requestDAO.countRequests(studentId, null, null, "ASSIGNED", null, null, null, null);
        int inProgressCount = requestDAO.countRequests(studentId, null, null, "IN_PROGRESS", null, null, null, null);
        int resolvedCount = requestDAO.countRequests(studentId, null, null, "RESOLVED", null, null, null, null);
        int closedCount = requestDAO.countRequests(studentId, null, null, "CLOSED", null, null, null, null);
        int unreadNotifs = notificationDAO.countUnread(studentId);

        // Recent 5 requests
        List<RequestBean> recentRequests = requestDAO.findRequests(studentId, null, null, null, null, null, null, null, 0, 5);

        request.setAttribute("totalRequests", totalRequests);
        request.setAttribute("activeRequests", submittedCount + assignedCount + inProgressCount);
        request.setAttribute("resolvedRequests", resolvedCount + closedCount);
        request.setAttribute("unreadNotifs", unreadNotifs);
        request.setAttribute("recentRequests", recentRequests);

        request.getRequestDispatcher("/WEB-INF/views/student/dashboard.jsp").forward(request, response);
    }
}
