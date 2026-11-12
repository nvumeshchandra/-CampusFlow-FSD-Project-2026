package com.campusflow.service;

import com.campusflow.config.DBConnection;
import com.campusflow.dao.NotificationDAO;
import com.campusflow.dao.RequestDAO;
import com.campusflow.dao.RequestHistoryDAO;
import com.campusflow.model.NotificationBean;
import com.campusflow.model.RequestBean;
import com.campusflow.model.RequestHistoryBean;
import com.campusflow.model.UserBean;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Enterprise Workflow State Machine enforcing permitted lifecycle transitions,
 * role authorization, audit trail creation, and in-app notifications.
 */
public class WorkflowService {

    private static final Logger LOGGER = Logger.getLogger(WorkflowService.class.getName());

    private final RequestDAO requestDAO = new RequestDAO();
    private final RequestHistoryDAO historyDAO = new RequestHistoryDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    public static class WorkflowResult {
        private final boolean success;
        private final String message;

        public WorkflowResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }

    /**
     * Validates whether a state transition is permitted for a given user role.
     */
    public boolean canTransition(String currentStatus, String targetStatus, UserBean actor, RequestBean req) {
        if (currentStatus == null || targetStatus == null || actor == null || req == null) {
            return false;
        }
        if (currentStatus.equalsIgnoreCase(targetStatus)) {
            return false; // No-op transition
        }
        if ("CLOSED".equalsIgnoreCase(currentStatus) || "CANCELLED".equalsIgnoreCase(currentStatus)) {
            return false; // Terminal states cannot transition
        }

        boolean isAdmin = actor.isAdmin();
        boolean isOwner = req.getUserId().equals(actor.getUserId());
        boolean isAssignedStaff = req.getAssignedStaffId() != null && req.getAssignedStaffId().equals(actor.getUserId());

        // 1. Transitions from SUBMITTED
        if ("SUBMITTED".equalsIgnoreCase(currentStatus)) {
            if ("ASSIGNED".equalsIgnoreCase(targetStatus)) {
                return isAdmin;
            }
            if ("CANCELLED".equalsIgnoreCase(targetStatus)) {
                return isOwner || isAdmin;
            }
            return false;
        }

        // 2. Transitions from ASSIGNED
        if ("ASSIGNED".equalsIgnoreCase(currentStatus)) {
            if ("IN_PROGRESS".equalsIgnoreCase(targetStatus)) {
                return isAssignedStaff || isAdmin;
            }
            if ("CANCELLED".equalsIgnoreCase(targetStatus)) {
                return isOwner || isAdmin;
            }
            return false;
        }

        // 3. Transitions from IN_PROGRESS
        if ("IN_PROGRESS".equalsIgnoreCase(currentStatus)) {
            if ("RESOLVED".equalsIgnoreCase(targetStatus)) {
                return isAssignedStaff || isAdmin;
            }
            return false;
        }

        // 4. Transitions from RESOLVED
        if ("RESOLVED".equalsIgnoreCase(currentStatus)) {
            if ("CLOSED".equalsIgnoreCase(targetStatus)) {
                return isOwner || isAdmin;
            }
            return false;
        }

        return false;
    }

    /**
     * Executes a state transition atomically inside an Oracle database transaction.
     */
    public WorkflowResult transitionStatus(Long requestId, String targetStatus, String remarks, UserBean actor) {
        if (requestId == null || targetStatus == null || actor == null) {
            return new WorkflowResult(false, "Invalid workflow transition parameters.");
        }

        RequestBean req = requestDAO.findById(requestId);
        if (req == null) {
            return new WorkflowResult(false, "Request not found.");
        }

        String oldStatus = req.getStatus();
        if (!canTransition(oldStatus, targetStatus, actor, req)) {
            return new WorkflowResult(false, String.format("Illegal transition from %s to %s for your role.", oldStatus, targetStatus));
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Timestamp now = new Timestamp(System.currentTimeMillis());
                Timestamp resolvedAt = "RESOLVED".equalsIgnoreCase(targetStatus) ? now : null;
                Timestamp closedAt = "CLOSED".equalsIgnoreCase(targetStatus) ? now : null;
                Timestamp cancelledAt = "CANCELLED".equalsIgnoreCase(targetStatus) ? now : null;
                String cancelReason = "CANCELLED".equalsIgnoreCase(targetStatus) ? remarks : null;

                // 1. Update Request table
                boolean updated = requestDAO.updateStatus(requestId, targetStatus, resolvedAt, closedAt, cancelledAt, cancelReason, conn);
                if (!updated) {
                    conn.rollback();
                    return new WorkflowResult(false, "Failed to update request status in database.");
                }

                // 2. Create History Audit Entry
                RequestHistoryBean history = new RequestHistoryBean();
                history.setRequestId(requestId);
                history.setActionType("STATUS_CHANGE");
                history.setOldStatus(oldStatus);
                history.setNewStatus(targetStatus);
                history.setRemarks(remarks != null && !remarks.trim().isEmpty() ? remarks.trim() : "Status changed to " + targetStatus);
                history.setActorUserId(actor.getUserId());
                historyDAO.create(history, conn);

                // 3. Generate In-App Notifications
                // Notify Requester (if actor is staff or admin)
                if (!req.getUserId().equals(actor.getUserId())) {
                    NotificationBean notifStudent = new NotificationBean();
                    notifStudent.setRecipientUserId(req.getUserId());
                    notifStudent.setRequestId(requestId);
                    notifStudent.setNotificationType("STATUS_UPDATE");
                    notifStudent.setMessage(String.format("Your request [%s] status was updated to %s by %s.",
                        req.getTrackingCode(), targetStatus, actor.getName()));
                    notificationDAO.create(notifStudent, conn);
                }

                // Notify Assigned Staff (if actor is student or admin and staff is assigned)
                if (req.getAssignedStaffId() != null && !req.getAssignedStaffId().equals(actor.getUserId())) {
                    NotificationBean notifStaff = new NotificationBean();
                    notifStaff.setRecipientUserId(req.getAssignedStaffId());
                    notifStaff.setRequestId(requestId);
                    notifStaff.setNotificationType("STATUS_UPDATE");
                    notifStaff.setMessage(String.format("Assigned request [%s] status was updated to %s by %s.",
                        req.getTrackingCode(), targetStatus, actor.getName()));
                    notificationDAO.create(notifStaff, conn);
                }

                conn.commit();
                return new WorkflowResult(true, "Request status successfully transitioned to " + targetStatus);
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Transaction rollback during status transition for request: " + requestId, e);
                return new WorkflowResult(false, "Database transaction error: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error during workflow transition", e);
            return new WorkflowResult(false, "Database connection error.");
        }
    }
}
