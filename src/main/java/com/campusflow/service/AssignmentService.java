package com.campusflow.service;

import com.campusflow.config.DBConnection;
import com.campusflow.dao.DepartmentDAO;
import com.campusflow.dao.NotificationDAO;
import com.campusflow.dao.RequestDAO;
import com.campusflow.dao.RequestHistoryDAO;
import com.campusflow.dao.UserDAO;
import com.campusflow.model.DepartmentBean;
import com.campusflow.model.NotificationBean;
import com.campusflow.model.RequestBean;
import com.campusflow.model.RequestHistoryBean;
import com.campusflow.model.UserBean;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service managing department and staff assignments and reassignments.
 */
public class AssignmentService {

    private static final Logger LOGGER = Logger.getLogger(AssignmentService.class.getName());

    private final RequestDAO requestDAO = new RequestDAO();
    private final RequestHistoryDAO historyDAO = new RequestHistoryDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    public static class AssignmentResult {
        private final boolean success;
        private final String message;

        public AssignmentResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }

    public AssignmentResult assignRequest(Long requestId, Long departmentId, Long staffId, String remarks, UserBean adminUser) {
        if (requestId == null || departmentId == null || adminUser == null || !adminUser.isAdmin()) {
            return new AssignmentResult(false, "Unauthorized or missing assignment parameters.");
        }

        RequestBean req = requestDAO.findById(requestId);
        if (req == null) {
            return new AssignmentResult(false, "Request not found.");
        }

        if (req.isTerminal()) {
            return new AssignmentResult(false, "Cannot reassign a closed or cancelled request.");
        }

        DepartmentBean dept = departmentDAO.findById(departmentId);
        if (dept == null || !dept.isActive()) {
            return new AssignmentResult(false, "Selected department does not exist or is inactive.");
        }

        UserBean staff = null;
        if (staffId != null && staffId > 0) {
            staff = userDAO.findById(staffId);
            if (staff == null || !staff.isStaff() || !staff.isActive()) {
                return new AssignmentResult(false, "Selected staff member is not an active staff account.");
            }
            if (staff.getDepartmentId() == null || !staff.getDepartmentId().equals(departmentId)) {
                return new AssignmentResult(false, "Assigned staff member does not belong to the selected department.");
            }
        }

        boolean isReassignment = req.getAssignedStaffId() != null || req.getDepartmentId() != null;
        String actionType = isReassignment ? "REASSIGNMENT" : "ASSIGNMENT";
        String newStatus = "SUBMITTED".equalsIgnoreCase(req.getStatus()) ? "ASSIGNED" : req.getStatus();

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean assigned = requestDAO.assign(requestId, departmentId, staff != null ? staff.getUserId() : null, newStatus, conn);
                if (!assigned) {
                    conn.rollback();
                    return new AssignmentResult(false, "Failed to update assignment in database.");
                }

                String staffName = staff != null ? staff.getName() : "Unassigned Staff";
                String historyRemarks = String.format("Assigned to %s (%s). %s",
                    dept.getDepartmentName(), staffName,
                    (remarks != null && !remarks.trim().isEmpty() ? "Note: " + remarks.trim() : ""));

                RequestHistoryBean history = new RequestHistoryBean();
                history.setRequestId(requestId);
                history.setActionType(actionType);
                history.setOldStatus(req.getStatus());
                history.setNewStatus(newStatus);
                history.setRemarks(historyRemarks);
                history.setActorUserId(adminUser.getUserId());
                historyDAO.create(history, conn);

                // Notify Student
                NotificationBean notifStudent = new NotificationBean();
                notifStudent.setRecipientUserId(req.getUserId());
                notifStudent.setRequestId(requestId);
                notifStudent.setNotificationType("ASSIGNMENT");
                notifStudent.setMessage(String.format("Your request [%s] has been assigned to %s (%s).",
                    req.getTrackingCode(), dept.getDepartmentName(), staffName));
                notificationDAO.create(notifStudent, conn);

                // Notify Assigned Staff (if assigned)
                if (staff != null) {
                    NotificationBean notifStaff = new NotificationBean();
                    notifStaff.setRecipientUserId(staff.getUserId());
                    notifStaff.setRequestId(requestId);
                    notifStaff.setNotificationType("NEW_ASSIGNMENT");
                    notifStaff.setMessage(String.format("You have been assigned new request [%s]: %s.",
                        req.getTrackingCode(), req.getTitle()));
                    notificationDAO.create(notifStaff, conn);
                }

                conn.commit();
                return new AssignmentResult(true, "Request assignment updated successfully.");
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Transaction error during request assignment: " + requestId, e);
                return new AssignmentResult(false, "Database transaction error: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error during assignment", e);
            return new AssignmentResult(false, "Database connection error.");
        }
    }
}
