package com.campusflow.controller;

import com.campusflow.dao.DepartmentDAO;
import com.campusflow.dao.UserDAO;
import com.campusflow.model.DepartmentBean;
import com.campusflow.model.UserBean;
import com.campusflow.util.PasswordUtil;
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
 * Controller for Administrative User Management: user listing, activation/deactivation,
 * and staff-to-department assignments.
 */
@WebServlet(name = "UserManagementServlet", urlPatterns = {"/admin/users"})
public class UserManagementServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roleFilter = request.getParameter("role");
        String statusFilter = request.getParameter("status");
        String search = request.getParameter("search");

        List<UserBean> users = userDAO.findAll(roleFilter, statusFilter, search);
        List<DepartmentBean> departments = departmentDAO.findAll(true);

        request.setAttribute("users", users);
        request.setAttribute("departments", departments);
        request.setAttribute("selectedRole", roleFilter);
        request.setAttribute("selectedStatus", statusFilter);
        request.setAttribute("searchQuery", search);

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

        request.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        if ("TOGGLE_STATUS".equalsIgnoreCase(action)) {
            String idParam = request.getParameter("userId");
            String newStatus = request.getParameter("targetStatus");
            if (idParam != null && newStatus != null) {
                try {
                    Long userId = Long.parseLong(idParam);
                    boolean ok = userDAO.updateAccountStatus(userId, newStatus);
                    if (ok) {
                        session.setAttribute("flashSuccess", "User account status updated to " + newStatus + ".");
                    } else {
                        session.setAttribute("flashError", "Failed to update account status.");
                    }
                } catch (NumberFormatException ignored) {}
            }
        } else if ("ASSIGN_DEPT".equalsIgnoreCase(action)) {
            String idParam = request.getParameter("userId");
            String deptParam = request.getParameter("departmentId");
            if (idParam != null) {
                try {
                    Long userId = Long.parseLong(idParam);
                    Long deptId = (deptParam != null && !deptParam.trim().isEmpty() && !"-1".equals(deptParam))
                        ? Long.parseLong(deptParam.trim()) : null;
                    boolean ok = userDAO.updateStaffDepartment(userId, deptId);
                    if (ok) {
                        session.setAttribute("flashSuccess", "Staff department assignment updated.");
                    } else {
                        session.setAttribute("flashError", "Failed to update department assignment.");
                    }
                } catch (NumberFormatException ignored) {}
            }
        } else if ("CREATE_STAFF".equalsIgnoreCase(action)) {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String deptParam = request.getParameter("departmentId");
            String phone = request.getParameter("phone");

            if (!ValidationUtil.isNotEmpty(name) || !ValidationUtil.isValidEmail(email) || !ValidationUtil.isValidPassword(password)) {
                session.setAttribute("flashError", "Invalid name, email, or password for staff creation.");
            } else if (userDAO.findByEmail(email.trim()) != null) {
                session.setAttribute("flashError", "An account with this email already exists.");
            } else {
                Long deptId = (deptParam != null && !deptParam.trim().isEmpty() && !"-1".equals(deptParam))
                    ? Long.parseLong(deptParam) : null;
                String salt = PasswordUtil.generateSalt();
                String hash = PasswordUtil.hashPassword(password, salt);

                UserBean staff = new UserBean();
                staff.setName(name.trim());
                staff.setEmail(email.trim().toLowerCase());
                staff.setPasswordHash(hash);
                staff.setPasswordSalt(salt);
                staff.setRole("STAFF");
                staff.setDepartmentId(deptId);
                staff.setPhone(phone);
                staff.setAccountStatus("ACTIVE");

                boolean ok = userDAO.create(staff);
                if (ok) {
                    session.setAttribute("flashSuccess", "New staff account created successfully.");
                } else {
                    session.setAttribute("flashError", "Database error creating staff account.");
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
