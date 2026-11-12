package com.campusflow.controller;

import com.campusflow.dao.UserDAO;
import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.UserBean;
import com.campusflow.service.AssignmentService;
import com.campusflow.service.AssignmentService.AssignmentResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Controller for assigning requests to departments and staff members.
 */
@WebServlet(name = "AdminAssignmentServlet", urlPatterns = {"/admin/request/assign", "/admin/api/staff-by-dept"})
public class AdminAssignmentServlet extends HttpServlet {

    private final AssignmentService assignmentService = new AssignmentService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uri = request.getRequestURI();
        if (uri.endsWith("/staff-by-dept")) {
            // Dynamic staff lookup by department ID for dropdowns
            String deptParam = request.getParameter("departmentId");
            if (deptParam != null && !deptParam.trim().isEmpty()) {
                try {
                    Long deptId = Long.parseLong(deptParam.trim());
                    List<UserBean> staffList = userDAO.findStaffByDepartment(deptId);
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    PrintWriter out = response.getWriter();
                    StringBuilder json = new StringBuilder("[");
                    for (int i = 0; i < staffList.size(); i++) {
                        UserBean s = staffList.get(i);
                        json.append(String.format("{\"userId\":%d,\"name\":\"%s\",\"email\":\"%s\"}",
                            s.getUserId(), s.getName().replace("\"", "\\\""), s.getEmail()));
                        if (i < staffList.size() - 1) json.append(",");
                    }
                    json.append("]");
                    out.print(json.toString());
                    out.flush();
                    return;
                } catch (NumberFormatException ignored) {}
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/requests");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean admin = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String idParam = request.getParameter("requestId");
        String deptParam = request.getParameter("departmentId");
        String staffParam = request.getParameter("staffId");
        String remarks = request.getParameter("remarks");

        if (idParam == null || deptParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/requests");
            return;
        }

        try {
            Long reqId = Long.parseLong(idParam);
            Long deptId = Long.parseLong(deptParam);
            Long staffId = (staffParam != null && !staffParam.trim().isEmpty() && !"-1".equals(staffParam))
                ? Long.parseLong(staffParam.trim()) : null;

            AssignmentResult result = assignmentService.assignRequest(reqId, deptId, staffId, remarks, admin);

            if (result.isSuccess()) {
                session.setAttribute("flashSuccess", result.getMessage());
            } else {
                session.setAttribute("flashError", result.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/admin/request/details?id=" + reqId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/requests");
        }
    }
}
