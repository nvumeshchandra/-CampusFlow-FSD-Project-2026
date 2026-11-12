package com.campusflow.controller;

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
 * Controller displaying the student's request history with search, filtering, and pagination.
 */
@WebServlet(name = "RequestListServlet", urlPatterns = {"/student/requests"})
public class RequestListServlet extends HttpServlet {

    private final RequestDAO requestDAO = new RequestDAO();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean student = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String status = request.getParameter("status");
        String category = request.getParameter("category");
        String priority = request.getParameter("priority");
        String search = request.getParameter("search");

        int page = 1;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                page = Math.max(1, Integer.parseInt(pageParam));
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        int offset = (page - 1) * PAGE_SIZE;

        int totalCount = requestDAO.countRequests(student.getUserId(), null, null, status, category, priority, null, search);
        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        if (totalPages == 0) totalPages = 1;

        List<RequestBean> requests = requestDAO.findRequests(student.getUserId(), null, null, status, category, priority, null, search, offset, PAGE_SIZE);

        request.setAttribute("requests", requests);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("selectedPriority", priority);
        request.setAttribute("searchQuery", search);

        request.getRequestDispatcher("/WEB-INF/views/student/my-requests.jsp").forward(request, response);
    }
}
