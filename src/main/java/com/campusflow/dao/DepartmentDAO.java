package com.campusflow.dao;

import com.campusflow.config.DBConnection;
import com.campusflow.model.DepartmentBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for DEPARTMENTS entity in Oracle Database.
 */
public class DepartmentDAO {

    private static final Logger LOGGER = Logger.getLogger(DepartmentDAO.class.getName());

    public DepartmentBean findById(Long deptId) {
        String sql = "SELECT d.DEPARTMENT_ID, d.DEPARTMENT_NAME, d.DESCRIPTION, d.ACTIVE_STATUS, d.CREATED_AT, " +
                     "(SELECT COUNT(*) FROM USERS u WHERE u.DEPARTMENT_ID = d.DEPARTMENT_ID AND u.ROLE = 'STAFF' AND u.ACCOUNT_STATUS = 'ACTIVE') AS STAFF_COUNT, " +
                     "(SELECT COUNT(*) FROM REQUESTS r WHERE r.DEPARTMENT_ID = d.DEPARTMENT_ID AND r.STATUS IN ('ASSIGNED', 'IN_PROGRESS')) AS ACTIVE_REQ_COUNT " +
                     "FROM DEPARTMENTS d WHERE d.DEPARTMENT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding department by ID: " + deptId, e);
        }
        return null;
    }

    public DepartmentBean findByName(String name) {
        if (name == null) return null;
        String sql = "SELECT d.DEPARTMENT_ID, d.DEPARTMENT_NAME, d.DESCRIPTION, d.ACTIVE_STATUS, d.CREATED_AT, " +
                     "(SELECT COUNT(*) FROM USERS u WHERE u.DEPARTMENT_ID = d.DEPARTMENT_ID AND u.ROLE = 'STAFF' AND u.ACCOUNT_STATUS = 'ACTIVE') AS STAFF_COUNT, " +
                     "(SELECT COUNT(*) FROM REQUESTS r WHERE r.DEPARTMENT_ID = d.DEPARTMENT_ID AND r.STATUS IN ('ASSIGNED', 'IN_PROGRESS')) AS ACTIVE_REQ_COUNT " +
                     "FROM DEPARTMENTS d WHERE LOWER(d.DEPARTMENT_NAME) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding department by name: " + name, e);
        }
        return null;
    }

    public List<DepartmentBean> findAll(boolean activeOnly) {
        List<DepartmentBean> list = new ArrayList<>();
        String sql = "SELECT d.DEPARTMENT_ID, d.DEPARTMENT_NAME, d.DESCRIPTION, d.ACTIVE_STATUS, d.CREATED_AT, " +
                     "(SELECT COUNT(*) FROM USERS u WHERE u.DEPARTMENT_ID = d.DEPARTMENT_ID AND u.ROLE = 'STAFF' AND u.ACCOUNT_STATUS = 'ACTIVE') AS STAFF_COUNT, " +
                     "(SELECT COUNT(*) FROM REQUESTS r WHERE r.DEPARTMENT_ID = d.DEPARTMENT_ID AND r.STATUS IN ('ASSIGNED', 'IN_PROGRESS')) AS ACTIVE_REQ_COUNT " +
                     "FROM DEPARTMENTS d " +
                     (activeOnly ? "WHERE d.ACTIVE_STATUS = 'ACTIVE' " : "") +
                     "ORDER BY d.DEPARTMENT_NAME ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error listing departments", e);
        }
        return list;
    }

    public boolean create(DepartmentBean dept) {
        String sql = "INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, DESCRIPTION, ACTIVE_STATUS, CREATED_AT) " +
                     "VALUES (SEQ_DEPARTMENTS.NEXTVAL, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dept.getDepartmentName().trim());
            ps.setString(2, dept.getDescription());
            ps.setString(3, dept.getActiveStatus() != null ? dept.getActiveStatus() : "ACTIVE");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating department: " + dept.getDepartmentName(), e);
            return false;
        }
    }

    public boolean update(DepartmentBean dept) {
        String sql = "UPDATE DEPARTMENTS SET DEPARTMENT_NAME = ?, DESCRIPTION = ?, ACTIVE_STATUS = ? " +
                     "WHERE DEPARTMENT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dept.getDepartmentName().trim());
            ps.setString(2, dept.getDescription());
            ps.setString(3, dept.getActiveStatus());
            ps.setLong(4, dept.getDepartmentId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating department: " + dept.getDepartmentId(), e);
            return false;
        }
    }

    private DepartmentBean mapRow(ResultSet rs) throws SQLException {
        DepartmentBean dept = new DepartmentBean();
        dept.setDepartmentId(rs.getLong("DEPARTMENT_ID"));
        dept.setDepartmentName(rs.getString("DEPARTMENT_NAME"));
        dept.setDescription(rs.getString("DESCRIPTION"));
        dept.setActiveStatus(rs.getString("ACTIVE_STATUS"));
        dept.setCreatedAt(rs.getTimestamp("CREATED_AT"));
        dept.setStaffCount(rs.getInt("STAFF_COUNT"));
        dept.setActiveRequestsCount(rs.getInt("ACTIVE_REQ_COUNT"));
        return dept;
    }
}
