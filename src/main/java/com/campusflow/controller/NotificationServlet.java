package com.campusflow.controller;

import com.campusflow.dao.NotificationDAO;
import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.NotificationBean;
import com.campusflow.model.UserBean;

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
 * Controller for viewing in-app notifications and managing read/unread status.
 */
@WebServlet(name = "NotificationServlet", urlPatterns = {"/notifications", "/notifications/api"})
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String uri = request.getRequestURI();
        if (uri.endsWith("/api")) {
            String action = request.getParameter("action");
            if ("count".equalsIgnoreCase(action)) {
                int unread = notificationDAO.countUnread(user.getUserId());
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                out.print("{\"unreadCount\":" + unread + "}");
                out.flush();
                return;
            }
        }

        List<NotificationBean> notifications = notificationDAO.findByRecipient(user.getUserId(), false);
        int unreadCount = notificationDAO.countUnread(user.getUserId());

        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", unreadCount);

        request.getRequestDispatcher("/WEB-INF/views/common/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String notifIdParam = request.getParameter("notificationId");

        if ("MARK_ALL".equalsIgnoreCase(action)) {
            notificationDAO.markAllAsRead(user.getUserId());
        } else if ("MARK_ONE".equalsIgnoreCase(action) && notifIdParam != null) {
            try {
                Long notifId = Long.parseLong(notifIdParam);
                notificationDAO.markAsRead(notifId, user.getUserId());
            } catch (NumberFormatException ignored) {}
        }

        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains("\n")) {
            response.sendRedirect(returnUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/notifications");
        }
    }
}
