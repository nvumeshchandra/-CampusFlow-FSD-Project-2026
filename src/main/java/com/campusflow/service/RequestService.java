package com.campusflow.service;

import com.campusflow.config.DBConnection;
import com.campusflow.dao.NotificationDAO;
import com.campusflow.dao.RequestDAO;
import com.campusflow.dao.RequestHistoryDAO;
import com.campusflow.model.NotificationBean;
import com.campusflow.model.RequestBean;
import com.campusflow.model.RequestHistoryBean;
import com.campusflow.model.UserBean;
import com.campusflow.service.PriorityService.PriorityResult;
import com.campusflow.util.ValidationUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service managing request creation, updates, cancellation, and priority overrides.
 */
public class RequestService {

    private static final Logger LOGGER = Logger.getLogger(RequestService.class.getName());

    private final RequestDAO requestDAO = new RequestDAO();
    private final RequestHistoryDAO historyDAO = new RequestHistoryDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final WorkflowService workflowService = new WorkflowService();

    public static class RequestResult {
        private final boolean success;
        private final String message;
        private final RequestBean request;

        public RequestResult(boolean success, String message, RequestBean request) {
            this.success = success;
            this.message = message;
            this.request = request;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public RequestBean getRequest() { return request; }
    }

    /**
     * Submits a new service request from a student.
     */
    public RequestResult createRequest(RequestBean req, UserBean student) {
        if (student == null || !student.isStudent()) {
            return new RequestResult(false, "Only registered students can submit requests.", null);
        }
        if (!ValidationUtil.isNotEmpty(req.getTitle()) || req.getTitle().trim().length() < 5) {
            return new RequestResult(false, "Title must be at least 5 characters.", null);
        }
        if (!ValidationUtil.isNotEmpty(req.getCategory())) {
            return new RequestResult(false, "Category is required.", null);
        }
        if (!ValidationUtil.isNotEmpty(req.getDescription()) || req.getDescription().trim().length() < 10) {
            return new RequestResult(false, "Description must be at least 10 characters.", null);
        }
        if (!ValidationUtil.isNotEmpty(req.getLocation())) {
            return new RequestResult(false, "Location is required.", null);
        }
        if (!ValidationUtil.isBetween(req.getUrgency(), 1, 4)) {
            return new RequestResult(false, "Urgency must be between 1 and 4.", null);
        }
        if (!ValidationUtil.isBetween(req.getImpact(), 1, 4)) {
            return new RequestResult(false, "Impact must be between 1 and 4.", null);
        }
        if (!ValidationUtil.isBetween(req.getLocationWeight(), 1, 3)) {
            return new RequestResult(false, "Location facility type must be between 1 and 3.", null);
        }

        // Calculate Priority via Rule-Based Priority Engine
        PriorityResult priority = PriorityService.calculate(req.getUrgency(), req.getImpact(), req.getLocationWeight());
        req.setPriorityScore(priority.getScore());
        req.setPriority(priority.getPriority());
        req.setStatus("SUBMITTED");
        req.setUserId(student.getUserId());

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                RequestBean created = requestDAO.create(req, conn);
                if (created == null) {
                    conn.rollback();
                    return new RequestResult(false, "Failed to persist request to database.", null);
                }

                // Create History Audit Entry
                RequestHistoryBean history = new RequestHistoryBean();
                history.setRequestId(created.getRequestId());
                history.setActionType("CREATED");
                history.setOldStatus(null);
                history.setNewStatus("SUBMITTED");
                history.setRemarks("Issue submitted by student. Initial Priority: " + priority.getPriority() + " (" + priority.getDescription() + ")");
                history.setActorUserId(student.getUserId());
                historyDAO.create(history, conn);

                // Create In-App Notification
                NotificationBean notif = new NotificationBean();
                notif.setRecipientUserId(student.getUserId());
                notif.setRequestId(created.getRequestId());
                notif.setNotificationType("REQUEST_CREATED");
                notif.setMessage(String.format("Request [%s] submitted successfully. Assigned Priority: %s.",
                    created.getTrackingCode(), created.getPriority()));
                notificationDAO.create(notif, conn);

                conn.commit();
                return new RequestResult(true, "Request submitted successfully with Tracking ID: " + created.getTrackingCode(), created);
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Transaction rollback during request creation", e);
                return new RequestResult(false, "Database transaction error: " + e.getMessage(), null);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database connection error during request creation", e);
            return new RequestResult(false, "Database connection error.", null);
        }
    }

    /**
     * Edits an eligible request (allowed only when status is SUBMITTED).
     */
    public RequestResult editRequest(RequestBean formReq, UserBean user) {
        if (formReq.getRequestId() == null || user == null) {
            return new RequestResult(false, "Invalid parameters.", null);
        }

        RequestBean existing = requestDAO.findById(formReq.getRequestId());
        if (existing == null) {
            return new RequestResult(false, "Request not found.", null);
        }

        if (!user.isAdmin() && (!user.isStudent() || !existing.getUserId().equals(user.getUserId()))) {
            return new RequestResult(false, "You are not authorized to edit this request.", null);
        }

        if (!user.isAdmin() && !existing.isEditableByStudent()) {
            return new RequestResult(false, "Request cannot be edited once it has been assigned or processed.", null);
        }

        PriorityResult priority = PriorityService.calculate(formReq.getUrgency(), formReq.getImpact(), formReq.getLocationWeight());
        formReq.setPriorityScore(priority.getScore());
        formReq.setPriority(priority.getPriority());

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean ok = requestDAO.updateDetails(formReq, conn);
                if (!ok) {
                    conn.rollback();
                    return new RequestResult(false, "Failed to update request details.", null);
                }

                RequestHistoryBean history = new RequestHistoryBean();
                history.setRequestId(formReq.getRequestId());
                history.setActionType("EDITED");
                history.setOldStatus(existing.getStatus());
                history.setNewStatus(existing.getStatus());
                history.setRemarks("Request details updated. Priority recalculated: " + priority.getPriority());
                history.setActorUserId(user.getUserId());
                historyDAO.create(history, conn);

                conn.commit();
                return new RequestResult(true, "Request updated successfully.", formReq);
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Transaction error during request edit", e);
                return new RequestResult(false, "Database error: " + e.getMessage(), null);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error during request edit", e);
            return new RequestResult(false, "Database connection error.", null);
        }
    }

    /**
     * Cancels a request by student or admin.
     */
    public WorkflowService.WorkflowResult cancelRequest(Long requestId, String reason, UserBean user) {
        return workflowService.transitionStatus(requestId, "CANCELLED", reason != null ? "Cancelled: " + reason : "Cancelled by user", user);
    }

    /**
     * Admin overrides calculated priority with recorded reason.
     */
    public RequestResult overridePriority(Long requestId, String newPriority, String reason, UserBean admin) {
        if (requestId == null || admin == null || !admin.isAdmin()) {
            return new RequestResult(false, "Unauthorized priority override.", null);
        }
        if (!ValidationUtil.isNotEmpty(reason)) {
            return new RequestResult(false, "A recorded justification reason is required for priority overrides.", null);
        }

        RequestBean existing = requestDAO.findById(requestId);
        if (existing == null) {
            return new RequestResult(false, "Request not found.", null);
        }

        int score = existing.getPriorityScore();
        if ("LOW".equalsIgnoreCase(newPriority)) score = 3;
        else if ("MEDIUM".equalsIgnoreCase(newPriority)) score = 5;
        else if ("HIGH".equalsIgnoreCase(newPriority)) score = 7;
        else if ("CRITICAL".equalsIgnoreCase(newPriority)) score = 10;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean ok = requestDAO.overridePriority(requestId, existing.getUrgency(), existing.getImpact(),
                    existing.getLocationWeight(), score, newPriority.toUpperCase(), conn);
                if (!ok) {
                    conn.rollback();
                    return new RequestResult(false, "Failed to update priority in database.", null);
                }

                RequestHistoryBean history = new RequestHistoryBean();
                history.setRequestId(requestId);
                history.setActionType("PRIORITY_OVERRIDE");
                history.setOldStatus(existing.getStatus());
                history.setNewStatus(existing.getStatus());
                history.setRemarks(String.format("Priority manually overridden from %s to %s by Admin. Justification: %s",
                    existing.getPriority(), newPriority.toUpperCase(), reason.trim()));
                history.setActorUserId(admin.getUserId());
                historyDAO.create(history, conn);

                NotificationBean notif = new NotificationBean();
                notif.setRecipientUserId(existing.getUserId());
                notif.setRequestId(requestId);
                notif.setNotificationType("PRIORITY_CHANGED");
                notif.setMessage(String.format("Priority for request [%s] was updated to %s by campus admin.",
                    existing.getTrackingCode(), newPriority.toUpperCase()));
                notificationDAO.create(notif, conn);

                conn.commit();
                return new RequestResult(true, "Priority overridden successfully.", existing);
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Transaction error during priority override", e);
                return new RequestResult(false, "Database error: " + e.getMessage(), null);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error during priority override", e);
            return new RequestResult(false, "Database connection error.", null);
        }
    }
}
