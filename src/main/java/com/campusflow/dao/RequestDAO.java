package com.campusflow.dao;

import com.campusflow.config.DBConnection;
import com.campusflow.model.RequestBean;
import com.campusflow.util.TrackingCodeUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for REQUESTS entity in Oracle Database.
 */
public class RequestDAO {

    private static final Logger LOGGER = Logger.getLogger(RequestDAO.class.getName());

    public long getNextSequenceId(Connection conn) throws SQLException {
        String sql = "SELECT SEQ_REQUESTS.NEXTVAL FROM DUAL";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        throw new SQLException("Could not retrieve nextval from SEQ_REQUESTS");
    }

    public RequestBean create(RequestBean req, Connection conn) throws SQLException {
        long nextId = getNextSequenceId(conn);
        String trackingCode = TrackingCodeUtil.generate(nextId);

        String sql = "INSERT INTO REQUESTS (" +
                     "REQUEST_ID, TRACKING_CODE, USER_ID, CATEGORY, TITLE, DESCRIPTION, " +
                     "LOCATION, URGENCY, IMPACT, LOCATION_WEIGHT, PRIORITY_SCORE, PRIORITY, " +
                     "STATUS, DEPARTMENT_ID, ASSIGNED_STAFF_ID, CREATED_AT, UPDATED_AT" +
                     ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, nextId);
            ps.setString(2, trackingCode);
            ps.setLong(3, req.getUserId());
            ps.setString(4, req.getCategory());
            ps.setString(5, req.getTitle());
            ps.setString(6, req.getDescription());
            ps.setString(7, req.getLocation());
            ps.setInt(8, req.getUrgency());
            ps.setInt(9, req.getImpact());
            ps.setInt(10, req.getLocationWeight());
            ps.setInt(11, req.getPriorityScore());
            ps.setString(12, req.getPriority());
            ps.setString(13, req.getStatus() != null ? req.getStatus() : "SUBMITTED");

            if (req.getDepartmentId() != null) {
                ps.setLong(14, req.getDepartmentId());
            } else {
                ps.setNull(14, Types.NUMERIC);
            }

            if (req.getAssignedStaffId() != null) {
                ps.setLong(15, req.getAssignedStaffId());
            } else {
                ps.setNull(15, Types.NUMERIC);
            }

            ps.executeUpdate();

            req.setRequestId(nextId);
            req.setTrackingCode(trackingCode);
            return req;
        }
    }

    public RequestBean create(RequestBean req) {
        try (Connection conn = DBConnection.getConnection()) {
            return create(req, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating request", e);
            return null;
        }
    }

    public RequestBean findById(Long requestId) {
        String sql = baseSelect() + "WHERE r.REQUEST_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding request by ID: " + requestId, e);
        }
        return null;
    }

    public RequestBean findByTrackingCode(String trackingCode) {
        if (trackingCode == null) return null;
        String sql = baseSelect() + "WHERE UPPER(r.TRACKING_CODE) = UPPER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trackingCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding request by tracking code: " + trackingCode, e);
        }
        return null;
    }

    public boolean updateDetails(RequestBean req, Connection conn) throws SQLException {
        String sql = "UPDATE REQUESTS SET " +
                     "CATEGORY = ?, TITLE = ?, DESCRIPTION = ?, LOCATION = ?, " +
                     "URGENCY = ?, IMPACT = ?, LOCATION_WEIGHT = ?, " +
                     "PRIORITY_SCORE = ?, PRIORITY = ?, UPDATED_AT = CURRENT_TIMESTAMP " +
                     "WHERE REQUEST_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, req.getCategory());
            ps.setString(2, req.getTitle());
            ps.setString(3, req.getDescription());
            ps.setString(4, req.getLocation());
            ps.setInt(5, req.getUrgency());
            ps.setInt(6, req.getImpact());
            ps.setInt(7, req.getLocationWeight());
            ps.setInt(8, req.getPriorityScore());
            ps.setString(9, req.getPriority());
            ps.setLong(10, req.getRequestId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(Long requestId, String newStatus, Timestamp resolvedAt,
                                Timestamp closedAt, Timestamp cancelledAt, String reason,
                                Connection conn) throws SQLException {
        String sql = "UPDATE REQUESTS SET " +
                     "STATUS = ?, " +
                     "RESOLVED_AT = COALESCE(?, RESOLVED_AT), " +
                     "CLOSED_AT = COALESCE(?, CLOSED_AT), " +
                     "CANCELLED_AT = COALESCE(?, CANCELLED_AT), " +
                     "CANCELLATION_REASON = COALESCE(?, CANCELLATION_REASON), " +
                     "UPDATED_AT = CURRENT_TIMESTAMP " +
                     "WHERE REQUEST_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            if (resolvedAt != null) ps.setTimestamp(2, resolvedAt); else ps.setNull(2, Types.TIMESTAMP);
            if (closedAt != null) ps.setTimestamp(3, closedAt); else ps.setNull(3, Types.TIMESTAMP);
            if (cancelledAt != null) ps.setTimestamp(4, cancelledAt); else ps.setNull(4, Types.TIMESTAMP);
            if (reason != null) ps.setString(5, reason); else ps.setNull(5, Types.VARCHAR);
            ps.setLong(6, requestId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean assign(Long requestId, Long departmentId, Long staffId, String newStatus,
                          Connection conn) throws SQLException {
        String sql = "UPDATE REQUESTS SET " +
                     "DEPARTMENT_ID = ?, " +
                     "ASSIGNED_STAFF_ID = ?, " +
                     "STATUS = ?, " +
                     "UPDATED_AT = CURRENT_TIMESTAMP " +
                     "WHERE REQUEST_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (departmentId != null) ps.setLong(1, departmentId); else ps.setNull(1, Types.NUMERIC);
            if (staffId != null) ps.setLong(2, staffId); else ps.setNull(2, Types.NUMERIC);
            ps.setString(3, newStatus != null ? newStatus : "ASSIGNED");
            ps.setLong(4, requestId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean overridePriority(Long requestId, int urgency, int impact, int locWeight,
                                    int score, String priority, Connection conn) throws SQLException {
        String sql = "UPDATE REQUESTS SET " +
                     "URGENCY = ?, IMPACT = ?, LOCATION_WEIGHT = ?, " +
                     "PRIORITY_SCORE = ?, PRIORITY = ?, UPDATED_AT = CURRENT_TIMESTAMP " +
                     "WHERE REQUEST_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, urgency);
            ps.setInt(2, impact);
            ps.setInt(3, locWeight);
            ps.setInt(4, score);
            ps.setString(5, priority);
            ps.setLong(6, requestId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<RequestBean> findRequests(Long studentUserId, Long staffUserId, Boolean unassignedOnly,
                                         String status, String category, String priority,
                                         Long deptId, String search, int offset, int limit) {
        List<RequestBean> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseSelect());
        sql.append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (studentUserId != null) {
            sql.append("AND r.USER_ID = ? ");
            params.add(studentUserId);
        }
        if (staffUserId != null) {
            sql.append("AND r.ASSIGNED_STAFF_ID = ? ");
            params.add(staffUserId);
        }
        if (Boolean.TRUE.equals(unassignedOnly)) {
            sql.append("AND r.ASSIGNED_STAFF_ID IS NULL AND r.STATUS = 'SUBMITTED' ");
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append("AND r.STATUS = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
            sql.append("AND r.CATEGORY = ? ");
            params.add(category.trim());
        }
        if (priority != null && !priority.trim().isEmpty() && !"ALL".equalsIgnoreCase(priority)) {
            sql.append("AND r.PRIORITY = ? ");
            params.add(priority.trim().toUpperCase());
        }
        if (deptId != null && deptId > 0) {
            sql.append("AND r.DEPARTMENT_ID = ? ");
            params.add(deptId);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (UPPER(r.TRACKING_CODE) LIKE ? OR UPPER(r.TITLE) LIKE ? OR UPPER(r.LOCATION) LIKE ?) ");
            String term = "%" + search.trim().toUpperCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        sql.append("ORDER BY r.CREATED_AT DESC ");

        // Oracle 10g pagination using ROWNUM subquery
        String pagedSql = "SELECT * FROM ( " +
                          "  SELECT a.*, ROWNUM rnum FROM (" + sql.toString() + ") a " +
                          "  WHERE ROWNUM <= ? " +
                          ") WHERE rnum > ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(pagedSql)) {
            int idx = 1;
            for (Object param : params) {
                ps.setObject(idx++, param);
            }
            ps.setInt(idx++, offset + limit);
            ps.setInt(idx, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error querying requests", e);
        }
        return list;
    }

    public int countRequests(Long studentUserId, Long staffUserId, Boolean unassignedOnly,
                             String status, String category, String priority,
                             Long deptId, String search) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM REQUESTS r WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (studentUserId != null) {
            sql.append("AND r.USER_ID = ? ");
            params.add(studentUserId);
        }
        if (staffUserId != null) {
            sql.append("AND r.ASSIGNED_STAFF_ID = ? ");
            params.add(staffUserId);
        }
        if (Boolean.TRUE.equals(unassignedOnly)) {
            sql.append("AND r.ASSIGNED_STAFF_ID IS NULL AND r.STATUS = 'SUBMITTED' ");
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append("AND r.STATUS = ? ");
            params.add(status.trim().toUpperCase());
        }
        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
            sql.append("AND r.CATEGORY = ? ");
            params.add(category.trim());
        }
        if (priority != null && !priority.trim().isEmpty() && !"ALL".equalsIgnoreCase(priority)) {
            sql.append("AND r.PRIORITY = ? ");
            params.add(priority.trim().toUpperCase());
        }
        if (deptId != null && deptId > 0) {
            sql.append("AND r.DEPARTMENT_ID = ? ");
            params.add(deptId);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (UPPER(r.TRACKING_CODE) LIKE ? OR UPPER(r.TITLE) LIKE ? OR UPPER(r.LOCATION) LIKE ?) ");
            String term = "%" + search.trim().toUpperCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting requests", e);
        }
        return 0;
    }

    private String baseSelect() {
        return "SELECT r.REQUEST_ID, r.TRACKING_CODE, r.USER_ID, u.NAME AS REQUESTER_NAME, u.EMAIL AS REQUESTER_EMAIL, " +
               "r.CATEGORY, r.TITLE, r.DESCRIPTION, r.LOCATION, r.URGENCY, r.IMPACT, r.LOCATION_WEIGHT, " +
               "r.PRIORITY_SCORE, r.PRIORITY, r.STATUS, r.DEPARTMENT_ID, d.DEPARTMENT_NAME, " +
               "r.ASSIGNED_STAFF_ID, s.NAME AS ASSIGNED_STAFF_NAME, " +
               "r.CREATED_AT, r.UPDATED_AT, r.RESOLVED_AT, r.CLOSED_AT, r.CANCELLED_AT, r.CANCELLATION_REASON, " +
               "(SELECT COUNT(*) FROM FEEDBACK f WHERE f.REQUEST_ID = r.REQUEST_ID) AS HAS_FEEDBACK, " +
               "(SELECT f.RATING FROM FEEDBACK f WHERE f.REQUEST_ID = r.REQUEST_ID) AS FB_RATING " +
               "FROM REQUESTS r " +
               "JOIN USERS u ON r.USER_ID = u.USER_ID " +
               "LEFT JOIN DEPARTMENTS d ON r.DEPARTMENT_ID = d.DEPARTMENT_ID " +
               "LEFT JOIN USERS s ON r.ASSIGNED_STAFF_ID = s.USER_ID ";
    }

    private RequestBean mapRow(ResultSet rs) throws SQLException {
        RequestBean req = new RequestBean();
        req.setRequestId(rs.getLong("REQUEST_ID"));
        req.setTrackingCode(rs.getString("TRACKING_CODE"));
        req.setUserId(rs.getLong("USER_ID"));
        req.setRequesterName(rs.getString("REQUESTER_NAME"));
        req.setRequesterEmail(rs.getString("REQUESTER_EMAIL"));
        req.setCategory(rs.getString("CATEGORY"));
        req.setTitle(rs.getString("TITLE"));
        req.setDescription(rs.getString("DESCRIPTION"));
        req.setLocation(rs.getString("LOCATION"));
        req.setUrgency(rs.getInt("URGENCY"));
        req.setImpact(rs.getInt("IMPACT"));
        req.setLocationWeight(rs.getInt("LOCATION_WEIGHT"));
        req.setPriorityScore(rs.getInt("PRIORITY_SCORE"));
        req.setPriority(rs.getString("PRIORITY"));
        req.setStatus(rs.getString("STATUS"));

        long deptId = rs.getLong("DEPARTMENT_ID");
        if (!rs.wasNull()) req.setDepartmentId(deptId);
        req.setDepartmentName(rs.getString("DEPARTMENT_NAME"));

        long staffId = rs.getLong("ASSIGNED_STAFF_ID");
        if (!rs.wasNull()) req.setAssignedStaffId(staffId);
        req.setAssignedStaffName(rs.getString("ASSIGNED_STAFF_NAME"));

        req.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        req.setUpdatedAt(rs.getTimestamp("UPDATED_AT"));
        req.setResolvedAt(rs.getTimestamp("RESOLVED_AT"));
        req.setClosedAt(rs.getTimestamp("CLOSED_AT"));
        req.setCancelledAt(rs.getTimestamp("CANCELLED_AT"));
        req.setCancellationReason(rs.getString("CANCELLATION_REASON"));

        req.setHasFeedback(rs.getInt("HAS_FEEDBACK") > 0);
        int fbRating = rs.getInt("FB_RATING");
        if (!rs.wasNull()) req.setFeedbackRating(fbRating);

        return req;
    }
}
