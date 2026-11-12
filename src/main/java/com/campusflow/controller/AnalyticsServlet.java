package com.campusflow.controller;

import com.campusflow.service.AnalyticsService;
import com.campusflow.service.AnalyticsService.DashboardMetrics;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Controller for dedicated Campus Operational Analytics and Performance Charts.
 */
@WebServlet(name = "AnalyticsServlet", urlPatterns = {"/admin/analytics"})
public class AnalyticsServlet extends HttpServlet {

    private final AnalyticsService analyticsService = new AnalyticsService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DashboardMetrics metrics = analyticsService.getMetrics();
        request.setAttribute("metrics", metrics);
        request.getRequestDispatcher("/WEB-INF/views/admin/analytics.jsp").forward(request, response);
    }
}
