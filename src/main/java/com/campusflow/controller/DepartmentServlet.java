package com.campusflow.controller;

import com.campusflow.dao.DepartmentDAO;
import com.campusflow.model.DepartmentBean;
import com.campusflow.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller for managing campus service departments.
 */
@WebServlet(name = "DepartmentServlet", urlPatterns = {"/admin/departments"})
public class DepartmentServlet extends HttpServlet {

    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<DepartmentBean> departments = departmentDAO.findAll(false);
        request.setAttribute("departments", departments);

        HttpSession session = request.getSession();
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

        request.getRequestDispatcher("/WEB-INF/views/admin/departments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        String name = request.getParameter("departmentName");
        String description = request.getParameter("description");
        String status = request.getParameter("activeStatus");

        if (!ValidationUtil.isNotEmpty(name)) {
            session.setAttribute("flashError", "Department name is required.");
            response.sendRedirect(request.getContextPath() + "/admin/departments");
            return;
        }

        if ("CREATE".equalsIgnoreCase(action)) {
            DepartmentBean existing = departmentDAO.findByName(name.trim());
            if (existing != null) {
                session.setAttribute("flashError", "A department with this name already exists.");
                response.sendRedirect(request.getContextPath() + "/admin/departments");
                return;
            }

            DepartmentBean dept = new DepartmentBean();
            dept.setDepartmentName(name.trim());
            dept.setDescription(description);
            dept.setActiveStatus(status != null ? status : "ACTIVE");

            boolean ok = departmentDAO.create(dept);
            if (ok) {
                session.setAttribute("flashSuccess", "Department created successfully.");
            } else {
                session.setAttribute("flashError", "Failed to create department.");
            }
        } else if ("UPDATE".equalsIgnoreCase(action)) {
            String idParam = request.getParameter("departmentId");
            if (idParam != null) {
                try {
                    Long deptId = Long.parseLong(idParam);
                    DepartmentBean dept = new DepartmentBean();
                    dept.setDepartmentId(deptId);
                    dept.setDepartmentName(name.trim());
                    dept.setDescription(description);
                    dept.setActiveStatus(status != null ? status : "ACTIVE");

                    boolean ok = departmentDAO.update(dept);
                    if (ok) {
                        session.setAttribute("flashSuccess", "Department updated successfully.");
                    } else {
                        session.setAttribute("flashError", "Failed to update department.");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("flashError", "Invalid department ID.");
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/departments");
    }
}
