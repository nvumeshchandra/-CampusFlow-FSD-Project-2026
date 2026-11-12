package com.campusflow.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * JavaBean representing a campus service request/issue ticket.
 */
public class RequestBean implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long requestId;
    private String trackingCode;
    private Long userId;
    private String requesterName;
    private String requesterEmail;
    private String category;
    private String title;
    private String description;
    private String location;
    private int urgency;         // 1 to 4
    private int impact;          // 1 to 4
    private int locationWeight;  // 1 to 3
    private int priorityScore;   // 3 to 11
    private String priority;     // LOW, MEDIUM, HIGH, CRITICAL
    private String status;       // SUBMITTED, ASSIGNED, IN_PROGRESS, RESOLVED, CLOSED, CANCELLED
    private Long departmentId;
    private String departmentName;
    private Long assignedStaffId;
    private String assignedStaffName;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp resolvedAt;
    private Timestamp closedAt;
    private Timestamp cancelledAt;
    private String cancellationReason;
    private boolean hasFeedback;
    private Integer feedbackRating;

    public RequestBean() {}

    public Long getRequestId() { return requestId; }
    public void setRequestId(Long requestId) { this.requestId = requestId; }

    public String getTrackingCode() { return trackingCode; }
    public void setTrackingCode(String trackingCode) { this.trackingCode = trackingCode; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getRequesterEmail() { return requesterEmail; }
    public void setRequesterEmail(String requesterEmail) { this.requesterEmail = requesterEmail; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public int getUrgency() { return urgency; }
    public void setUrgency(int urgency) { this.urgency = urgency; }

    public int getImpact() { return impact; }
    public void setImpact(int impact) { this.impact = impact; }

    public int getLocationWeight() { return locationWeight; }
    public void setLocationWeight(int locationWeight) { this.locationWeight = locationWeight; }

    public int getPriorityScore() { return priorityScore; }
    public void setPriorityScore(int priorityScore) { this.priorityScore = priorityScore; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getDepartmentId() { return departmentId; }
    public void setDepartmentId(Long departmentId) { this.departmentId = departmentId; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public Long getAssignedStaffId() { return assignedStaffId; }
    public void setAssignedStaffId(Long assignedStaffId) { this.assignedStaffId = assignedStaffId; }

    public String getAssignedStaffName() { return assignedStaffName; }
    public void setAssignedStaffName(String assignedStaffName) { this.assignedStaffName = assignedStaffName; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }

    public Timestamp getClosedAt() { return closedAt; }
    public void setClosedAt(Timestamp closedAt) { this.closedAt = closedAt; }

    public Timestamp getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(Timestamp cancelledAt) { this.cancelledAt = cancelledAt; }

    public String getCancellationReason() { return cancellationReason; }
    public void setCancellationReason(String cancellationReason) { this.cancellationReason = cancellationReason; }

    public boolean isHasFeedback() { return hasFeedback; }
    public void setHasFeedback(boolean hasFeedback) { this.hasFeedback = hasFeedback; }

    public Integer getFeedbackRating() { return feedbackRating; }
    public void setFeedbackRating(Integer feedbackRating) { this.feedbackRating = feedbackRating; }

    // Helper methods for workflow rules
    public boolean isEditableByStudent() {
        return "SUBMITTED".equalsIgnoreCase(status);
    }

    public boolean isCancellableByStudent() {
        return "SUBMITTED".equalsIgnoreCase(status) || "ASSIGNED".equalsIgnoreCase(status);
    }

    public boolean isTerminal() {
        return "CLOSED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status);
    }

    public boolean isFeedbackEligible() {
        return ("RESOLVED".equalsIgnoreCase(status) || "CLOSED".equalsIgnoreCase(status)) && !hasFeedback;
    }
}
