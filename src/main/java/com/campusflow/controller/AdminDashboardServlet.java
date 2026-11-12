package com.campusflow.controller;

import com.campusflow.dao.RequestDAO;
import com.campusflow.model.RequestBean;
import com.campusflow.service.AnalyticsService;
import com.campusflow.service.AnalyticsService.DashboardMetrics;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Controller for comprehensive Administrator Dashboard and Live Operations Center.
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final AnalyticsService analyticsService = new AnalyticsService();
    private final RequestDAO requestDAO = new RequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DashboardMetrics metrics = analyticsService.getMetrics();
        List<RequestBean> recentRequests = requestDAO.findRequests(null, null, null, null, null, null, null, null, 0, 8);
        List<RequestBean> unassignedQueue = requestDAO.findRequests(null, null, true, null, null, null, null, null, 0, 5);

        request.setAttribute("metrics", metrics);
        request.setAttribute("recentRequests", recentRequests);
        request.setAttribute("unassignedQueue", unassignedQueue);

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }
}
