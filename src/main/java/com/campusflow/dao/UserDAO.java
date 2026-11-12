package com.campusflow.dao;

import com.campusflow.config.DBConnection;
import com.campusflow.model.UserBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for USERS entity in Oracle Database.
 */
public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public UserBean findById(Long userId) {
        String sql = "SELECT u.USER_ID, u.NAME, u.EMAIL, u.PASSWORD_HASH, u.PASSWORD_SALT, " +
                     "u.ROLE, u.DEPARTMENT_ID, d.DEPARTMENT_NAME, u.PHONE, u.ACCOUNT_STATUS, " +
                     "u.CREATED_AT, u.UPDATED_AT " +
                     "FROM USERS u LEFT JOIN DEPARTMENTS d ON u.DEPARTMENT_ID = d.DEPARTMENT_ID " +
                     "WHERE u.USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by ID: " + userId, e);
        }
        return null;
    }

    public UserBean findByEmail(String email) {
        if (email == null) return null;
        String sql = "SELECT u.USER_ID, u.NAME, u.EMAIL, u.PASSWORD_HASH, u.PASSWORD_SALT, " +
                     "u.ROLE, u.DEPARTMENT_ID, d.DEPARTMENT_NAME, u.PHONE, u.ACCOUNT_STATUS, " +
                     "u.CREATED_AT, u.UPDATED_AT " +
                     "FROM USERS u LEFT JOIN DEPARTMENTS d ON u.DEPARTMENT_ID = d.DEPARTMENT_ID " +
                     "WHERE LOWER(u.EMAIL) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by email: " + email, e);
        }
        return null;
    }

    public boolean create(UserBean user) {
        String sql = "INSERT INTO USERS (USER_ID, NAME, EMAIL, PASSWORD_HASH, PASSWORD_SALT, " +
                     "ROLE, DEPARTMENT_ID, PHONE, ACCOUNT_STATUS, CREATED_AT, UPDATED_AT) " +
                     "VALUES (SEQ_USERS.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail().trim().toLowerCase());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getPasswordSalt());
            ps.setString(5, user.getRole());
            if (user.getDepartmentId() != null) {
                ps.setLong(6, user.getDepartmentId());
            } else {
                ps.setNull(6, Types.NUMERIC);
            }
            ps.setString(7, user.getPhone());
            ps.setString(8, user.getAccountStatus() != null ? user.getAccountStatus() : "ACTIVE");

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating user: " + user.getEmail(), e);
            return false;
        }
    }

    public boolean updateProfile(UserBean user) {
        String sql = "UPDATE USERS SET NAME = ?, PHONE = ?, UPDATED_AT = CURRENT_TIMESTAMP WHERE USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getPhone());
            ps.setLong(3, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating profile for user: " + user.getUserId(), e);
            return false;
        }
    }

    public boolean updatePassword(Long userId, String newHash, String newSalt) {
        String sql = "UPDATE USERS SET PASSWORD_HASH = ?, PASSWORD_SALT = ?, UPDATED_AT = CURRENT_TIMESTAMP WHERE USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setString(2, newSalt);
            ps.setLong(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating password for user: " + userId, e);
            return false;
        }
    }

    public boolean updateAccountStatus(Long userId, String status) {
        String sql = "UPDATE USERS SET ACCOUNT_STATUS = ?, UPDATED_AT = CURRENT_TIMESTAMP WHERE USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating account status for user: " + userId, e);
            return false;
        }
    }

    public boolean updateStaffDepartment(Long userId, Long departmentId) {
        String sql = "UPDATE USERS SET DEPARTMENT_ID = ?, UPDATED_AT = CURRENT_TIMESTAMP WHERE USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (departmentId != null) {
                ps.setLong(1, departmentId);
            } else {
                ps.setNull(1, Types.NUMERIC);
            }
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating staff department: " + userId, e);
            return false;
        }
    }

    public List<UserBean> findAll(String roleFilter, String statusFilter, String search) {
        List<UserBean> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.USER_ID, u.NAME, u.EMAIL, u.PASSWORD_HASH, u.PASSWORD_SALT, " +
            "u.ROLE, u.DEPARTMENT_ID, d.DEPARTMENT_NAME, u.PHONE, u.ACCOUNT_STATUS, " +
            "u.CREATED_AT, u.UPDATED_AT " +
            "FROM USERS u LEFT JOIN DEPARTMENTS d ON u.DEPARTMENT_ID = d.DEPARTMENT_ID WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (roleFilter != null && !roleFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(roleFilter)) {
            sql.append("AND u.ROLE = ? ");
            params.add(roleFilter.trim().toUpperCase());
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND u.ACCOUNT_STATUS = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.NAME) LIKE ? OR LOWER(u.EMAIL) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
        }
        sql.append("ORDER BY u.USER_ID ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error listing users", e);
        }
        return list;
    }

    public List<UserBean> findStaffByDepartment(Long departmentId) {
        List<UserBean> list = new ArrayList<>();
        String sql = "SELECT u.USER_ID, u.NAME, u.EMAIL, u.PASSWORD_HASH, u.PASSWORD_SALT, " +
                     "u.ROLE, u.DEPARTMENT_ID, d.DEPARTMENT_NAME, u.PHONE, u.ACCOUNT_STATUS, " +
                     "u.CREATED_AT, u.UPDATED_AT " +
                     "FROM USERS u LEFT JOIN DEPARTMENTS d ON u.DEPARTMENT_ID = d.DEPARTMENT_ID " +
                     "WHERE u.ROLE = 'STAFF' AND u.ACCOUNT_STATUS = 'ACTIVE' " +
                     (departmentId != null ? "AND u.DEPARTMENT_ID = ? " : "") +
                     "ORDER BY u.NAME ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (departmentId != null) {
                ps.setLong(1, departmentId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding staff for department: " + departmentId, e);
        }
        return list;
    }

    public int countActiveUsers(String role) {
        String sql = "SELECT COUNT(*) FROM USERS WHERE ACCOUNT_STATUS = 'ACTIVE'" +
                     (role != null ? " AND ROLE = ?" : "");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (role != null) {
                ps.setString(1, role);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting active users for role: " + role, e);
        }
        return 0;
    }

    private UserBean mapRow(ResultSet rs) throws SQLException {
        UserBean user = new UserBean();
        user.setUserId(rs.getLong("USER_ID"));
        user.setName(rs.getString("NAME"));
        user.setEmail(rs.getString("EMAIL"));
        user.setPasswordHash(rs.getString("PASSWORD_HASH"));
        user.setPasswordSalt(rs.getString("PASSWORD_SALT"));
        user.setRole(rs.getString("ROLE"));
        long deptId = rs.getLong("DEPARTMENT_ID");
        if (!rs.wasNull()) {
            user.setDepartmentId(deptId);
        }
        user.setDepartmentName(rs.getString("DEPARTMENT_NAME"));
        user.setPhone(rs.getString("PHONE"));
        user.setAccountStatus(rs.getString("ACCOUNT_STATUS"));
        user.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        user.setUpdatedAt(rs.getTimestamp("UPDATED_AT"));
        return user;
    }
}
