package com.campusflow.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * JavaBean representing a campus service department.
 */
public class DepartmentBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long departmentId;
    private String departmentName;
    private String description;
    private String activeStatus; // ACTIVE, INACTIVE
    private Timestamp createdAt;
    private int staffCount;
    private int activeRequestsCount;

    public DepartmentBean() {}

    public Long getDepartmentId() { return departmentId; }
    public void setDepartmentId(Long departmentId) { this.departmentId = departmentId; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getActiveStatus() { return activeStatus; }
    public void setActiveStatus(String activeStatus) { this.activeStatus = activeStatus; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getStaffCount() { return staffCount; }
    public void setStaffCount(int staffCount) { this.staffCount = staffCount; }

    public int getActiveRequestsCount() { return activeRequestsCount; }
    public void setActiveRequestsCount(int activeRequestsCount) { this.activeRequestsCount = activeRequestsCount; }

    public boolean isActive() { return "ACTIVE".equalsIgnoreCase(activeStatus); }
}
