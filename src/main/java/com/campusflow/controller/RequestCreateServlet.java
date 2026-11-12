package com.campusflow.controller;

import com.campusflow.dao.DepartmentDAO;
import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.DepartmentBean;
import com.campusflow.model.RequestBean;
import com.campusflow.model.UserBean;
import com.campusflow.service.RequestService;
import com.campusflow.service.RequestService.RequestResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller for creating new campus service requests.
 */
@WebServlet(name = "RequestCreateServlet", urlPatterns = {"/student/request/create"})
public class RequestCreateServlet extends HttpServlet {

    private final RequestService requestService = new RequestService();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<DepartmentBean> departments = departmentDAO.findAll(true);
        request.setAttribute("departments", departments);
        request.getRequestDispatcher("/WEB-INF/views/student/create-request.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean student = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        RequestBean req = new RequestBean();
        req.setTitle(request.getParameter("title"));
        req.setCategory(request.getParameter("category"));
        req.setLocation(request.getParameter("location"));
        req.setDescription(request.getParameter("description"));

        try {
            req.setUrgency(Integer.parseInt(request.getParameter("urgency")));
        } catch (NumberFormatException e) {
            req.setUrgency(1);
        }

        try {
            req.setImpact(Integer.parseInt(request.getParameter("impact")));
        } catch (NumberFormatException e) {
            req.setImpact(1);
        }

        try {
            req.setLocationWeight(Integer.parseInt(request.getParameter("locationWeight")));
        } catch (NumberFormatException e) {
            req.setLocationWeight(1);
        }

        RequestResult result = requestService.createRequest(req, student);

        if (result.isSuccess()) {
            session.setAttribute("flashSuccess", result.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/request/details?id=" + result.getRequest().getRequestId());
        } else {
            request.setAttribute("errorMessage", result.getMessage());
            request.setAttribute("formReq", req);
            request.setAttribute("departments", departmentDAO.findAll(true));
            request.getRequestDispatcher("/WEB-INF/views/student/create-request.jsp").forward(request, response);
        }
    }
}
