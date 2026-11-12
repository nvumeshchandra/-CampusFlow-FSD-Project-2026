package com.campusflow.service;

import com.campusflow.config.DBConnection;
import com.campusflow.dao.FeedbackDAO;
import com.campusflow.dao.UserDAO;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Enterprise Analytics Engine querying live Oracle Database metrics.
 * Computes status distributions, priority breakdowns, resolution performance, and satisfaction rates.
 */
public class AnalyticsService {

    private static final Logger LOGGER = Logger.getLogger(AnalyticsService.class.getName());

    private final UserDAO userDAO = new UserDAO();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    public static class DashboardMetrics {
        private int totalRequests;
        private int submittedCount;
        private int assignedCount;
        private int inProgressCount;
        private int resolvedCount;
        private int closedCount;
        private int cancelledCount;
        private int unassignedCount;

        private int activeStudentsCount;
        private int activeStaffCount;
        private int activeDepartmentsCount;

        private double averageRating;
        private int totalFeedbackCount;
        private double averageResolutionHours;

        private Map<String, Integer> statusDistribution = new LinkedHashMap<>();
        private Map<String, Integer> categoryDistribution = new LinkedHashMap<>();
        private Map<String, Integer> priorityDistribution = new LinkedHashMap<>();
        private Map<String, Integer> departmentDistribution = new LinkedHashMap<>();
        private Map<Integer, Integer> ratingDistribution = new LinkedHashMap<>();

        public int getTotalRequests() { return totalRequests; }
        public void setTotalRequests(int totalRequests) { this.totalRequests = totalRequests; }

        public int getSubmittedCount() { return submittedCount; }
        public void setSubmittedCount(int submittedCount) { this.submittedCount = submittedCount; }

        public int getAssignedCount() { return assignedCount; }
        public void setAssignedCount(int assignedCount) { this.assignedCount = assignedCount; }

        public int getInProgressCount() { return inProgressCount; }
        public void setInProgressCount(int inProgressCount) { this.inProgressCount = inProgressCount; }

        public int getResolvedCount() { return resolvedCount; }
        public void setResolvedCount(int resolvedCount) { this.resolvedCount = resolvedCount; }

        public int getClosedCount() { return closedCount; }
        public void setClosedCount(int closedCount) { this.closedCount = closedCount; }

        public int getCancelledCount() { return cancelledCount; }
        public void setCancelledCount(int cancelledCount) { this.cancelledCount = cancelledCount; }

        public int getUnassignedCount() { return unassignedCount; }
        public void setUnassignedCount(int unassignedCount) { this.unassignedCount = unassignedCount; }

        public int getActiveStudentsCount() { return activeStudentsCount; }
        public void setActiveStudentsCount(int activeStudentsCount) { this.activeStudentsCount = activeStudentsCount; }

        public int getActiveStaffCount() { return activeStaffCount; }
        public void setActiveStaffCount(int activeStaffCount) { this.activeStaffCount = activeStaffCount; }

        public int getActiveDepartmentsCount() { return activeDepartmentsCount; }
        public void setActiveDepartmentsCount(int activeDepartmentsCount) { this.activeDepartmentsCount = activeDepartmentsCount; }

        public double getAverageRating() { return averageRating; }
        public void setAverageRating(double averageRating) { this.averageRating = averageRating; }

        public int getTotalFeedbackCount() { return totalFeedbackCount; }
        public void setTotalFeedbackCount(int totalFeedbackCount) { this.totalFeedbackCount = totalFeedbackCount; }

        public double getAverageResolutionHours() { return averageResolutionHours; }
        public void setAverageResolutionHours(double averageResolutionHours) { this.averageResolutionHours = averageResolutionHours; }

        public Map<String, Integer> getStatusDistribution() { return statusDistribution; }
        public Map<String, Integer> getCategoryDistribution() { return categoryDistribution; }
        public Map<String, Integer> getPriorityDistribution() { return priorityDistribution; }
        public Map<String, Integer> getDepartmentDistribution() { return departmentDistribution; }
        public Map<Integer, Integer> getRatingDistribution() { return ratingDistribution; }
    }

    public DashboardMetrics getMetrics() {
        DashboardMetrics m = new DashboardMetrics();

        // 1. User and Department Counts
        m.setActiveStudentsCount(userDAO.countActiveUsers("STUDENT"));
        m.setActiveStaffCount(userDAO.countActiveUsers("STAFF"));

        // 2. Feedback Metrics
        m.setAverageRating(feedbackDAO.getAverageRating());
        m.setTotalFeedbackCount(feedbackDAO.countTotalFeedback());
        m.getRatingDistribution().putAll(feedbackDAO.getRatingDistribution());

        // 3. Oracle Request Queries
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            // Active Departments count
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM DEPARTMENTS WHERE ACTIVE_STATUS = 'ACTIVE'")) {
                if (rs.next()) m.setActiveDepartmentsCount(rs.getInt(1));
            }

            // Status Distribution
            String statusSql = "SELECT STATUS, COUNT(*) FROM REQUESTS GROUP BY STATUS";
            try (ResultSet rs = stmt.executeQuery(statusSql)) {
                int total = 0;
                while (rs.next()) {
                    String status = rs.getString(1);
                    int count = rs.getInt(2);
                    total += count;
                    m.getStatusDistribution().put(status, count);

                    if ("SUBMITTED".equalsIgnoreCase(status)) m.setSubmittedCount(count);
                    else if ("ASSIGNED".equalsIgnoreCase(status)) m.setAssignedCount(count);
                    else if ("IN_PROGRESS".equalsIgnoreCase(status)) m.setInProgressCount(count);
                    else if ("RESOLVED".equalsIgnoreCase(status)) m.setResolvedCount(count);
                    else if ("CLOSED".equalsIgnoreCase(status)) m.setClosedCount(count);
                    else if ("CANCELLED".equalsIgnoreCase(status)) m.setCancelledCount(count);
                }
                m.setTotalRequests(total);
            }

            // Unassigned Count
            String unassignedSql = "SELECT COUNT(*) FROM REQUESTS WHERE ASSIGNED_STAFF_ID IS NULL AND STATUS = 'SUBMITTED'";
            try (ResultSet rs = stmt.executeQuery(unassignedSql)) {
                if (rs.next()) m.setUnassignedCount(rs.getInt(1));
            }

            // Category Distribution
            String catSql = "SELECT CATEGORY, COUNT(*) FROM REQUESTS GROUP BY CATEGORY ORDER BY COUNT(*) DESC";
            try (ResultSet rs = stmt.executeQuery(catSql)) {
                while (rs.next()) {
                    m.getCategoryDistribution().put(rs.getString(1), rs.getInt(2));
                }
            }

            // Priority Distribution
            String prioSql = "SELECT PRIORITY, COUNT(*) FROM REQUESTS GROUP BY PRIORITY";
            try (ResultSet rs = stmt.executeQuery(prioSql)) {
                while (rs.next()) {
                    m.getPriorityDistribution().put(rs.getString(1), rs.getInt(2));
                }
            }

            // Department Distribution
            String deptSql = "SELECT NVL(d.DEPARTMENT_NAME, 'Unassigned'), COUNT(*) " +
                             "FROM REQUESTS r LEFT JOIN DEPARTMENTS d ON r.DEPARTMENT_ID = d.DEPARTMENT_ID " +
                             "GROUP BY d.DEPARTMENT_NAME ORDER BY COUNT(*) DESC";
            try (ResultSet rs = stmt.executeQuery(deptSql)) {
                while (rs.next()) {
                    m.getDepartmentDistribution().put(rs.getString(1), rs.getInt(2));
                }
            }

            // Average Resolution Hours: (CAST(RESOLVED_AT AS DATE) - CAST(CREATED_AT AS DATE)) * 24
            String resTimeSql = "SELECT ROUND(AVG((CAST(RESOLVED_AT AS DATE) - CAST(CREATED_AT AS DATE)) * 24), 1) " +
                                "FROM REQUESTS WHERE RESOLVED_AT IS NOT NULL";
            try (ResultSet rs = stmt.executeQuery(resTimeSql)) {
                if (rs.next()) {
                    m.setAverageResolutionHours(rs.getDouble(1));
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error aggregating dashboard analytics", e);
        }

        return m;
    }
}
