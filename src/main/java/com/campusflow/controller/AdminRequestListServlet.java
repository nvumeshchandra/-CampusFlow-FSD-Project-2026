package com.campusflow.controller;

import com.campusflow.dao.DepartmentDAO;
import com.campusflow.dao.RequestDAO;
import com.campusflow.model.DepartmentBean;
import com.campusflow.model.RequestBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Controller displaying campus-wide service requests with search, multi-faceted filtering, and pagination.
 */
@WebServlet(name = "AdminRequestListServlet", urlPatterns = {"/admin/requests", "/admin/unassigned"})
public class AdminRequestListServlet extends HttpServlet {

    private final RequestDAO requestDAO = new RequestDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uri = request.getRequestURI();
        boolean isUnassignedRoute = uri.contains("/admin/unassigned");

        String status = isUnassignedRoute ? "SUBMITTED" : request.getParameter("status");
        String category = request.getParameter("category");
        String priority = request.getParameter("priority");
        String search = request.getParameter("search");
        Boolean unassignedOnly = isUnassignedRoute ? Boolean.TRUE : "true".equalsIgnoreCase(request.getParameter("unassigned"));

        Long deptId = null;
        try {
            String deptParam = request.getParameter("deptId");
            if (deptParam != null && !deptParam.trim().isEmpty()) {
                deptId = Long.parseLong(deptParam.trim());
            }
        } catch (NumberFormatException ignored) {}

        int page = 1;
        try {
            String p = request.getParameter("page");
            if (p != null) page = Math.max(1, Integer.parseInt(p));
        } catch (NumberFormatException ignored) {}

        int offset = (page - 1) * PAGE_SIZE;

        int totalCount = requestDAO.countRequests(null, null, unassignedOnly, status, category, priority, deptId, search);
        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;

        List<RequestBean> requests = requestDAO.findRequests(null, null, unassignedOnly, status, category, priority, deptId, search, offset, PAGE_SIZE);
        List<DepartmentBean> departments = departmentDAO.findAll(false);

        request.setAttribute("requests", requests);
        request.setAttribute("departments", departments);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("selectedPriority", priority);
        request.setAttribute("selectedDeptId", deptId);
        request.setAttribute("searchQuery", search);
        request.setAttribute("isUnassignedView", isUnassignedRoute || Boolean.TRUE.equals(unassignedOnly));

        request.getRequestDispatcher("/WEB-INF/views/admin/all-requests.jsp").forward(request, response);
    }
}
