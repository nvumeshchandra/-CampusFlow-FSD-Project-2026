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
 * Controller for Staff Dashboard and assigned task queue.
 */
@WebServlet(name = "StaffDashboardServlet", urlPatterns = {"/staff/dashboard", "/staff/requests"})
public class StaffDashboardServlet extends HttpServlet {

    private final RequestDAO requestDAO = new RequestDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean staff = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
        Long staffId = staff.getUserId();

        String status = request.getParameter("status");
        String category = request.getParameter("category");
        String priority = request.getParameter("priority");
        String search = request.getParameter("search");

        int page = 1;
        try {
            String p = request.getParameter("page");
            if (p != null) page = Math.max(1, Integer.parseInt(p));
        } catch (NumberFormatException ignored) {}

        int offset = (page - 1) * PAGE_SIZE;

        // Staff workload metrics
        int totalAssigned = requestDAO.countRequests(null, staffId, null, null, null, null, null, null);
        int pendingStart = requestDAO.countRequests(null, staffId, null, "ASSIGNED", null, null, null, null);
        int inProgress = requestDAO.countRequests(null, staffId, null, "IN_PROGRESS", null, null, null, null);
        int resolved = requestDAO.countRequests(null, staffId, null, "RESOLVED", null, null, null, null);
        int closed = requestDAO.countRequests(null, staffId, null, "CLOSED", null, null, null, null);
        int unreadNotifs = notificationDAO.countUnread(staffId);

        int totalCount = requestDAO.countRequests(null, staffId, null, status, category, priority, null, search);
        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;

        List<RequestBean> assignedQueue = requestDAO.findRequests(null, staffId, null, status, category, priority, null, search, offset, PAGE_SIZE);

        request.setAttribute("totalAssigned", totalAssigned);
        request.setAttribute("pendingStart", pendingStart);
        request.setAttribute("inProgress", inProgress);
        request.setAttribute("resolvedCount", resolved + closed);
        request.setAttribute("unreadNotifs", unreadNotifs);

        request.setAttribute("assignedQueue", assignedQueue);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("selectedPriority", priority);
        request.setAttribute("searchQuery", search);

        request.getRequestDispatcher("/WEB-INF/views/staff/dashboard.jsp").forward(request, response);
    }
}
