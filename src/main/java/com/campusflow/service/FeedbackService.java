package com.campusflow.service;

import com.campusflow.config.DBConnection;
import com.campusflow.dao.FeedbackDAO;
import com.campusflow.dao.NotificationDAO;
import com.campusflow.dao.RequestDAO;
import com.campusflow.dao.RequestHistoryDAO;
import com.campusflow.model.FeedbackBean;
import com.campusflow.model.NotificationBean;
import com.campusflow.model.RequestBean;
import com.campusflow.model.RequestHistoryBean;
import com.campusflow.model.UserBean;
import com.campusflow.util.ValidationUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service managing student service feedback and ratings.
 */
public class FeedbackService {

    private static final Logger LOGGER = Logger.getLogger(FeedbackService.class.getName());

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final RequestDAO requestDAO = new RequestDAO();
    private final RequestHistoryDAO historyDAO = new RequestHistoryDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    public static class FeedbackResult {
        private final boolean success;
        private final String message;

        public FeedbackResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }

    public FeedbackResult submitFeedback(Long requestId, int rating, String comments, UserBean student) {
        if (requestId == null || student == null) {
            return new FeedbackResult(false, "Invalid feedback parameters.");
        }
        if (!student.isStudent()) {
            return new FeedbackResult(false, "Only the student who submitted the request can submit feedback.");
        }
        if (!ValidationUtil.isBetween(rating, 1, 5)) {
            return new FeedbackResult(false, "Please provide a valid rating between 1 and 5 stars.");
        }

        RequestBean req = requestDAO.findById(requestId);
        if (req == null) {
            return new FeedbackResult(false, "Request not found.");
        }
        if (!req.getUserId().equals(student.getUserId())) {
            return new FeedbackResult(false, "You cannot submit feedback for a request you did not submit.");
        }
        if (!"RESOLVED".equalsIgnoreCase(req.getStatus()) && !"CLOSED".equalsIgnoreCase(req.getStatus())) {
            return new FeedbackResult(false, "Feedback can only be provided after the issue has been resolved or closed.");
        }

        // Check duplicate
        FeedbackBean existing = feedbackDAO.findByRequestId(requestId);
        if (existing != null) {
            return new FeedbackResult(false, "Feedback has already been submitted for this request.");
        }

        FeedbackBean fb = new FeedbackBean();
        fb.setRequestId(requestId);
        fb.setStudentUserId(student.getUserId());
        fb.setRating(rating);
        fb.setComments(comments != null ? comments.trim() : "");

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean created = feedbackDAO.create(fb);
                if (!created) {
                    conn.rollback();
                    return new FeedbackResult(false, "Failed to record feedback in database.");
                }

                // Add to history
                RequestHistoryBean history = new RequestHistoryBean();
                history.setRequestId(requestId);
                history.setActionType("FEEDBACK_SUBMITTED");
                history.setOldStatus(req.getStatus());
                history.setNewStatus(req.getStatus());
                history.setRemarks(String.format("Student submitted feedback: %d/5 Stars. %s",
                    rating, (comments != null && !comments.trim().isEmpty() ? "Comments: " + comments.trim() : "")));
                history.setActorUserId(student.getUserId());
                historyDAO.create(history, conn);

                // If staff was assigned, notify staff of rating
                if (req.getAssignedStaffId() != null) {
                    NotificationBean notifStaff = new NotificationBean();
                    notifStaff.setRecipientUserId(req.getAssignedStaffId());
                    notifStaff.setRequestId(requestId);
                    notifStaff.setNotificationType("FEEDBACK_RECEIVED");
                    notifStaff.setMessage(String.format("Student rated resolved request [%s] with %d/5 stars.",
                        req.getTrackingCode(), rating));
                    notificationDAO.create(notifStaff, conn);
                }

                conn.commit();
                return new FeedbackResult(true, "Thank you! Your feedback has been recorded.");
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Transaction error submitting feedback for request: " + requestId, e);
                return new FeedbackResult(false, "Database transaction error: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error submitting feedback", e);
            return new FeedbackResult(false, "Database connection error.");
        }
    }
}
