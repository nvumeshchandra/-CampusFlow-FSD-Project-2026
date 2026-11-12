package com.campusflow.controller;

import com.campusflow.dao.FeedbackDAO;
import com.campusflow.dao.RequestDAO;
import com.campusflow.filter.AuthenticationFilter;
import com.campusflow.model.FeedbackBean;
import com.campusflow.model.RequestBean;
import com.campusflow.model.UserBean;
import com.campusflow.service.FeedbackService;
import com.campusflow.service.FeedbackService.FeedbackResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller handling feedback submission by students and feedback review by administrators.
 */
@WebServlet(name = "FeedbackServlet", urlPatterns = {"/student/feedback", "/admin/feedback"})
public class FeedbackServlet extends HttpServlet {

    private final FeedbackService feedbackService = new FeedbackService();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final RequestDAO requestDAO = new RequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String uri = request.getRequestURI();
        if (uri.contains("/admin/")) {
            List<FeedbackBean> feedbackList = feedbackDAO.findAll();
            double avgRating = feedbackDAO.getAverageRating();
            int total = feedbackDAO.countTotalFeedback();

            request.setAttribute("feedbackList", feedbackList);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("totalFeedback", total);
            request.setAttribute("ratingDistribution", feedbackDAO.getRatingDistribution());

            request.getRequestDispatcher("/WEB-INF/views/admin/feedback-list.jsp").forward(request, response);
        } else {
            String reqIdParam = request.getParameter("requestId");
            if (reqIdParam == null) {
                response.sendRedirect(request.getContextPath() + "/student/requests");
                return;
            }

            try {
                Long reqId = Long.parseLong(reqIdParam);
                RequestBean req = requestDAO.findById(reqId);
                if (req == null || !req.getUserId().equals(user.getUserId())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
                    return;
                }

                if (!req.isFeedbackEligible()) {
                    session.setAttribute("flashError", "Feedback is only eligible for resolved/closed requests that have not been rated yet.");
                    response.sendRedirect(request.getContextPath() + "/student/request/details?id=" + reqId);
                    return;
                }

                request.setAttribute("req", req);
                request.getRequestDispatcher("/WEB-INF/views/student/feedback.jsp").forward(request, response);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/student/requests");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserBean student = (UserBean) session.getAttribute(AuthenticationFilter.SESSION_USER_KEY);

        String reqIdParam = request.getParameter("requestId");
        String ratingParam = request.getParameter("rating");
        String comments = request.getParameter("comments");

        if (reqIdParam == null || ratingParam == null) {
            response.sendRedirect(request.getContextPath() + "/student/requests");
            return;
        }

        try {
            Long reqId = Long.parseLong(reqIdParam);
            int rating = Integer.parseInt(ratingParam);

            FeedbackResult result = feedbackService.submitFeedback(reqId, rating, comments, student);

            if (result.isSuccess()) {
                session.setAttribute("flashSuccess", result.getMessage());
            } else {
                session.setAttribute("flashError", result.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/student/request/details?id=" + reqId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/requests");
        }
    }
}
