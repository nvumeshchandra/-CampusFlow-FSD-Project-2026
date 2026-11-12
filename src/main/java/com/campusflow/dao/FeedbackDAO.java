package com.campusflow.dao;

import com.campusflow.config.DBConnection;
import com.campusflow.model.FeedbackBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for FEEDBACK entity in Oracle Database.
 */
public class FeedbackDAO {

    private static final Logger LOGGER = Logger.getLogger(FeedbackDAO.class.getName());

    public boolean create(FeedbackBean fb) {
        String sql = "INSERT INTO FEEDBACK (FEEDBACK_ID, REQUEST_ID, STUDENT_USER_ID, RATING, COMMENTS, CREATED_AT) " +
                     "VALUES (SEQ_FEEDBACK.NEXTVAL, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, fb.getRequestId());
            ps.setLong(2, fb.getStudentUserId());
            ps.setInt(3, fb.getRating());
            ps.setString(4, fb.getComments());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating feedback for request: " + fb.getRequestId(), e);
            return false;
        }
    }

    public FeedbackBean findByRequestId(Long requestId) {
        String sql = "SELECT f.FEEDBACK_ID, f.REQUEST_ID, r.TRACKING_CODE, r.TITLE AS REQUEST_TITLE, " +
                     "f.STUDENT_USER_ID, u.NAME AS STUDENT_NAME, f.RATING, f.COMMENTS, f.CREATED_AT, f.UPDATED_AT " +
                     "FROM FEEDBACK f " +
                     "JOIN REQUESTS r ON f.REQUEST_ID = r.REQUEST_ID " +
                     "JOIN USERS u ON f.STUDENT_USER_ID = u.USER_ID " +
                     "WHERE f.REQUEST_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding feedback for request: " + requestId, e);
        }
        return null;
    }

    public List<FeedbackBean> findAll() {
        List<FeedbackBean> list = new ArrayList<>();
        String sql = "SELECT f.FEEDBACK_ID, f.REQUEST_ID, r.TRACKING_CODE, r.TITLE AS REQUEST_TITLE, " +
                     "f.STUDENT_USER_ID, u.NAME AS STUDENT_NAME, f.RATING, f.COMMENTS, f.CREATED_AT, f.UPDATED_AT " +
                     "FROM FEEDBACK f " +
                     "JOIN REQUESTS r ON f.REQUEST_ID = r.REQUEST_ID " +
                     "JOIN USERS u ON f.STUDENT_USER_ID = u.USER_ID " +
                     "ORDER BY f.CREATED_AT DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving all feedback", e);
        }
        return list;
    }

    public double getAverageRating() {
        String sql = "SELECT ROUND(AVG(RATING), 2) FROM FEEDBACK";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating average feedback rating", e);
        }
        return 0.0;
    }

    public Map<Integer, Integer> getRatingDistribution() {
        Map<Integer, Integer> dist = new HashMap<>();
        for (int i = 1; i <= 5; i++) {
            dist.put(i, 0);
        }
        String sql = "SELECT RATING, COUNT(*) FROM FEEDBACK GROUP BY RATING";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                dist.put(rs.getInt(1), rs.getInt(2));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching rating distribution", e);
        }
        return dist;
    }

    public int countTotalFeedback() {
        String sql = "SELECT COUNT(*) FROM FEEDBACK";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting feedback", e);
        }
        return 0;
    }

    private FeedbackBean mapRow(ResultSet rs) throws SQLException {
        FeedbackBean fb = new FeedbackBean();
        fb.setFeedbackId(rs.getLong("FEEDBACK_ID"));
        fb.setRequestId(rs.getLong("REQUEST_ID"));
        fb.setTrackingCode(rs.getString("TRACKING_CODE"));
        fb.setRequestTitle(rs.getString("REQUEST_TITLE"));
        fb.setStudentUserId(rs.getLong("STUDENT_USER_ID"));
        fb.setStudentName(rs.getString("STUDENT_NAME"));
        fb.setRating(rs.getInt("RATING"));
        fb.setComments(rs.getString("COMMENTS"));
        fb.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        fb.setUpdatedAt(rs.getTimestamp("UPDATED_AT"));
        return fb;
    }
}
