package com.campusflow.dao;

import com.campusflow.config.DBConnection;
import com.campusflow.model.RequestHistoryBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for REQUEST_HISTORY entity in Oracle Database.
 */
public class RequestHistoryDAO {

    private static final Logger LOGGER = Logger.getLogger(RequestHistoryDAO.class.getName());

    public boolean create(RequestHistoryBean history, Connection conn) throws SQLException {
        String sql = "INSERT INTO REQUEST_HISTORY (" +
                     "HISTORY_ID, REQUEST_ID, ACTION_TYPE, OLD_STATUS, NEW_STATUS, REMARKS, ACTOR_USER_ID, CREATED_AT" +
                     ") VALUES (SEQ_REQUEST_HISTORY.NEXTVAL, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, history.getRequestId());
            ps.setString(2, history.getActionType());
            ps.setString(3, history.getOldStatus());
            ps.setString(4, history.getNewStatus());
            ps.setString(5, history.getRemarks());
            ps.setLong(6, history.getActorUserId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean create(RequestHistoryBean history) {
        try (Connection conn = DBConnection.getConnection()) {
            return create(history, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating history record for request: " + history.getRequestId(), e);
            return false;
        }
    }

    public List<RequestHistoryBean> findByRequestId(Long requestId) {
        List<RequestHistoryBean> list = new ArrayList<>();
        String sql = "SELECT h.HISTORY_ID, h.REQUEST_ID, h.ACTION_TYPE, h.OLD_STATUS, h.NEW_STATUS, " +
                     "h.REMARKS, h.ACTOR_USER_ID, u.NAME AS ACTOR_NAME, u.ROLE AS ACTOR_ROLE, h.CREATED_AT " +
                     "FROM REQUEST_HISTORY h " +
                     "JOIN USERS u ON h.ACTOR_USER_ID = u.USER_ID " +
                     "WHERE h.REQUEST_ID = ? " +
                     "ORDER BY h.CREATED_AT ASC, h.HISTORY_ID ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RequestHistoryBean h = new RequestHistoryBean();
                    h.setHistoryId(rs.getLong("HISTORY_ID"));
                    h.setRequestId(rs.getLong("REQUEST_ID"));
                    h.setActionType(rs.getString("ACTION_TYPE"));
                    h.setOldStatus(rs.getString("OLD_STATUS"));
                    h.setNewStatus(rs.getString("NEW_STATUS"));
                    h.setRemarks(rs.getString("REMARKS"));
                    h.setActorUserId(rs.getLong("ACTOR_USER_ID"));
                    h.setActorName(rs.getString("ACTOR_NAME"));
                    h.setActorRole(rs.getString("ACTOR_ROLE"));
                    h.setCreatedAt(rs.getTimestamp("CREATED_AT"));
                    list.add(h);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching history for request: " + requestId, e);
        }
        return list;
    }
}
