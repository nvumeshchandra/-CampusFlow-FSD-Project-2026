package com.campusflow.dao;

import com.campusflow.config.DBConnection;
import com.campusflow.model.NotificationBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for NOTIFICATIONS entity in Oracle Database.
 */
public class NotificationDAO {

    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    public boolean create(NotificationBean notif, Connection conn) throws SQLException {
        String sql = "INSERT INTO NOTIFICATIONS (" +
                     "NOTIFICATION_ID, RECIPIENT_USER_ID, REQUEST_ID, NOTIFICATION_TYPE, MESSAGE, IS_READ, CREATED_AT" +
                     ") VALUES (SEQ_NOTIFICATIONS.NEXTVAL, ?, ?, ?, ?, 0, CURRENT_TIMESTAMP)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, notif.getRecipientUserId());
            if (notif.getRequestId() != null) {
                ps.setLong(2, notif.getRequestId());
            } else {
                ps.setNull(2, Types.NUMERIC);
            }
            ps.setString(3, notif.getNotificationType());
            ps.setString(4, notif.getMessage());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean create(NotificationBean notif) {
        try (Connection conn = DBConnection.getConnection()) {
            return create(notif, conn);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating notification for user: " + notif.getRecipientUserId(), e);
            return false;
        }
    }

    public List<NotificationBean> findByRecipient(Long userId, boolean unreadOnly) {
        List<NotificationBean> list = new ArrayList<>();
        String sql = "SELECT n.NOTIFICATION_ID, n.RECIPIENT_USER_ID, n.REQUEST_ID, r.TRACKING_CODE, " +
                     "n.NOTIFICATION_TYPE, n.MESSAGE, n.IS_READ, n.CREATED_AT, n.READ_AT " +
                     "FROM NOTIFICATIONS n " +
                     "LEFT JOIN REQUESTS r ON n.REQUEST_ID = r.REQUEST_ID " +
                     "WHERE n.RECIPIENT_USER_ID = ? " +
                     (unreadOnly ? "AND n.IS_READ = 0 " : "") +
                     "ORDER BY n.CREATED_AT DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NotificationBean n = new NotificationBean();
                    n.setNotificationId(rs.getLong("NOTIFICATION_ID"));
                    n.setRecipientUserId(rs.getLong("RECIPIENT_USER_ID"));
                    long reqId = rs.getLong("REQUEST_ID");
                    if (!rs.wasNull()) {
                        n.setRequestId(reqId);
                    }
                    n.setTrackingCode(rs.getString("TRACKING_CODE"));
                    n.setNotificationType(rs.getString("NOTIFICATION_TYPE"));
                    n.setMessage(rs.getString("MESSAGE"));
                    n.setRead(rs.getInt("IS_READ") == 1);
                    n.setCreatedAt(rs.getTimestamp("CREATED_AT"));
                    n.setReadAt(rs.getTimestamp("READ_AT"));
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching notifications for user: " + userId, e);
        }
        return list;
    }

    public int countUnread(Long userId) {
        String sql = "SELECT COUNT(*) FROM NOTIFICATIONS WHERE RECIPIENT_USER_ID = ? AND IS_READ = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting unread notifications for user: " + userId, e);
        }
        return 0;
    }

    public boolean markAsRead(Long notificationId, Long userId) {
        String sql = "UPDATE NOTIFICATIONS SET IS_READ = 1, READ_AT = CURRENT_TIMESTAMP " +
                     "WHERE NOTIFICATION_ID = ? AND RECIPIENT_USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, notificationId);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking notification as read: " + notificationId, e);
            return false;
        }
    }

    public boolean markAllAsRead(Long userId) {
        String sql = "UPDATE NOTIFICATIONS SET IS_READ = 1, READ_AT = CURRENT_TIMESTAMP " +
                     "WHERE RECIPIENT_USER_ID = ? AND IS_READ = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking all notifications as read for user: " + userId, e);
            return false;
        }
    }
}
