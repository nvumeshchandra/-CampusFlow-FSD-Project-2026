package com.campusflow.controller;

import com.campusflow.dao.RequestDAO;
import com.campusflow.filter.AuthenticationFilter;
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

/**
 * Controller allowing students to edit eligible requests while still in SUBMITTED status.
 */
@WebServlet(name = "RequestEditServlet", urlPatterns = {"/student/request/edit"})
public class RequestEditServlet extends HttpServlet {

    private final RequestDAO requestDAO = new RequestDAO();
    private final RequestService requestService = new RequestService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean student = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/student/requests");
            return;
        }

        try {
            Long reqId = Long.parseLong(idParam);
            RequestBean req = requestDAO.findById(reqId);

            if (req == null || !req.getUserId().equals(student.getUserId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
                return;
            }

            if (!req.isEditableByStudent()) {
                session.setAttribute("flashError", "Requests can only be edited while in SUBMITTED status.");
                response.sendRedirect(request.getContextPath() + "/student/request/details?id=" + reqId);
                return;
            }

            request.setAttribute("req", req);
            request.getRequestDispatcher("/WEB-INF/views/student/edit-request.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/requests");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean student = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String idParam = request.getParameter("requestId");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/student/requests");
            return;
        }

        try {
            Long reqId = Long.parseLong(idParam);
            RequestBean req = new RequestBean();
            req.setRequestId(reqId);
            req.setTitle(request.getParameter("title"));
            req.setCategory(request.getParameter("category"));
            req.setLocation(request.getParameter("location"));
            req.setDescription(request.getParameter("description"));

            try { req.setUrgency(Integer.parseInt(request.getParameter("urgency"))); } catch (Exception e) { req.setUrgency(1); }
            try { req.setImpact(Integer.parseInt(request.getParameter("impact"))); } catch (Exception e) { req.setImpact(1); }
            try { req.setLocationWeight(Integer.parseInt(request.getParameter("locationWeight"))); } catch (Exception e) { req.setLocationWeight(1); }

            RequestResult result = requestService.editRequest(req, student);

            if (result.isSuccess()) {
                session.setAttribute("flashSuccess", "Request updated successfully.");
                response.sendRedirect(request.getContextPath() + "/student/request/details?id=" + reqId);
            } else {
                request.setAttribute("errorMessage", result.getMessage());
                request.setAttribute("req", req);
                request.getRequestDispatcher("/WEB-INF/views/student/edit-request.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/requests");
        }
    }
}
