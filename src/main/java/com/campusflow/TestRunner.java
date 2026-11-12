package com.campusflow;

import com.campusflow.config.DBConnection;
import com.campusflow.dao.*;
import com.campusflow.model.*;
import com.campusflow.service.*;
import com.campusflow.service.AuthService.AuthResult;
import com.campusflow.service.PriorityService.PriorityResult;
import com.campusflow.service.RequestService.RequestResult;
import com.campusflow.service.WorkflowService.WorkflowResult;
import com.campusflow.service.AssignmentService.AssignmentResult;
import com.campusflow.service.FeedbackService.FeedbackResult;
import com.campusflow.service.AnalyticsService.DashboardMetrics;
import com.campusflow.util.*;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

/**
 * Automated Verification & QA Test Suite for CampusFlow.
 * Executes live tests against Oracle Database XE and backend services.
 */
public class TestRunner {

    private static int passed = 0;
    private static int failed = 0;

    public static void main(String[] args) {
        System.out.println("====================================================================");
        System.out.println("   CAMPUSFLOW AUTOMATED QA VERIFICATION TEST SUITE (ORACLE 10g XE)   ");
        System.out.println("====================================================================");

        testDatabaseConnectivity();
        testPasswordHashingAndSecurity();
        testPriorityEngineRules();
        testStudentRegistrationAndDuplicateCheck();
        testAuthenticationAndRoles();
        testRequestCreationAndPersistence();
        testRequestStateTransitionsAndValidation();
        testDepartmentAndStaffAssignment();
        testStaffWorkAndRemarks();
        testStaffResolutionAndStudentFeedback();
        testInAppNotificationsPersistence();
        testAdminPriorityOverride();
        testRequestCancellationRules();
        testAnalyticsLiveQueryMatching();
        testSqlInjectionResistance();
        testXssEscaping();

        System.out.println("====================================================================");
        System.out.printf("TEST RESULTS: %d PASSED, %d FAILED (TOTAL %d)%n", passed, failed, (passed + failed));
        System.out.printf("PASS RATE: %.1f%%%n", (double) passed / (passed + failed) * 100);
        System.out.println("====================================================================");

        if (failed > 0) {
            System.exit(1);
        }
    }

    private static void check(String testId, String description, boolean condition, String details) {
        if (condition) {
            passed++;
            System.out.printf("[PASS] %s: %s%n", testId, description);
        } else {
            failed++;
            System.out.printf("[FAIL] %s: %s -- Details: %s%n", testId, description, details);
        }
    }

    private static void testDatabaseConnectivity() {
        boolean ok = DBConnection.testConnection();
        check("TC_DB_01", "Oracle Database Connection Established via JDBC thin driver", ok, "Failed to connect to Oracle XE");
    }

    private static void testPasswordHashingAndSecurity() {
        String raw = "StrongP@ssw0rd2026";
        String salt1 = PasswordUtil.generateSalt();
        String salt2 = PasswordUtil.generateSalt();
        String hash1 = PasswordUtil.hashPassword(raw, salt1);
        String hash2 = PasswordUtil.hashPassword(raw, salt2);

        check("TC_SEC_01", "PBKDF2 generates unique salt per account", !salt1.equals(salt2), "Salts were identical");
        check("TC_SEC_02", "PBKDF2 generates different hashes for same password with different salts", !hash1.equals(hash2), "Hashes were identical");
        check("TC_SEC_03", "Password verification matches correct password", PasswordUtil.verifyPassword(raw, salt1, hash1), "Verification failed");
        check("TC_SEC_04", "Password verification rejects incorrect password", !PasswordUtil.verifyPassword("WrongPassword", salt1, hash1), "Accepted wrong password");
    }

    private static void testPriorityEngineRules() {
        // Low: 1 + 1 + 1 = 3 -> LOW
        PriorityResult r1 = PriorityService.calculate(1, 1, 1);
        check("TC_PRIO_01", "Priority Score 3 maps to LOW", r1.getScore() == 3 && "LOW".equals(r1.getPriority()), "Got " + r1.getPriority());

        // Medium: 2 + 2 + 2 = 6 -> MEDIUM
        PriorityResult r2 = PriorityService.calculate(2, 2, 2);
        check("TC_PRIO_02", "Priority Score 6 maps to MEDIUM", r2.getScore() == 6 && "MEDIUM".equals(r2.getPriority()), "Got " + r2.getPriority());

        // High: 3 + 3 + 2 = 8 -> HIGH
        PriorityResult r3 = PriorityService.calculate(3, 3, 2);
        check("TC_PRIO_03", "Priority Score 8 maps to HIGH", r3.getScore() == 8 && "HIGH".equals(r3.getPriority()), "Got " + r3.getPriority());

        // Critical: 4 + 4 + 3 = 11 -> CRITICAL
        PriorityResult r4 = PriorityService.calculate(4, 4, 3);
        check("TC_PRIO_04", "Priority Score 11 maps to CRITICAL", r4.getScore() == 11 && "CRITICAL".equals(r4.getPriority()), "Got " + r4.getPriority());
    }

    private static void testStudentRegistrationAndDuplicateCheck() {
        AuthService auth = new AuthService();
        String testEmail = "qa.test.student." + System.currentTimeMillis() + "@campusflow.edu";

        // TC01: Valid registration
        AuthResult r1 = auth.registerStudent("QA Tester Student", testEmail, "Student@123", "9876543299");
        check("TC01", "Valid student registration creates database record", r1.isSuccess(), r1.getMessage());

        // Verify in Oracle
        UserDAO userDAO = new UserDAO();
        UserBean persisted = userDAO.findByEmail(testEmail);
        check("TC01_ORACLE", "Registered student exists in Oracle USERS table", persisted != null && "STUDENT".equals(persisted.getRole()), "User not found in Oracle");

        // TC02: Duplicate email rejection
        AuthResult r2 = auth.registerStudent("Duplicate Person", testEmail, "Student@123", "9876543299");
        check("TC02", "Duplicate email registration is rejected", !r2.isSuccess(), "Duplicate was accepted");

        // TC03: Invalid registration (short password / invalid email)
        AuthResult r3 = auth.registerStudent("Bad", "invalid-email", "123", null);
        check("TC03", "Invalid registration input is rejected on server", !r3.isSuccess(), "Invalid input accepted");
    }

    private static void testAuthenticationAndRoles() {
        AuthService auth = new AuthService();

        // TC04: Valid login creates session
        AuthResult rAdmin = auth.login("admin@campusflow.edu", "Admin@123");
        check("TC04_ADMIN", "Administrator login authenticates successfully", rAdmin.isSuccess() && rAdmin.getUser().isAdmin(), rAdmin.getMessage());

        AuthResult rStaff = auth.login("it.staff@campusflow.edu", "Staff@123");
        check("TC04_STAFF", "Staff login authenticates successfully", rStaff.isSuccess() && rStaff.getUser().isStaff(), rStaff.getMessage());

        AuthResult rStudent = auth.login("student@campusflow.edu", "Student@123");
        check("TC04_STUDENT", "Student login authenticates successfully", rStudent.isSuccess() && rStudent.getUser().isStudent(), rStudent.getMessage());

        // TC05: Invalid login credentials rejected
        AuthResult rBadPass = auth.login("admin@campusflow.edu", "WrongPassword");
        check("TC05_BAD_PASS", "Incorrect password rejected", !rBadPass.isSuccess(), "Accepted wrong password");

        AuthResult rBadEmail = auth.login("nonexistent@campusflow.edu", "Admin@123");
        check("TC05_BAD_USER", "Nonexistent user rejected", !rBadEmail.isSuccess(), "Accepted nonexistent user");
    }

    private static RequestBean createdRequest;

    private static void testRequestCreationAndPersistence() {
        UserDAO userDAO = new UserDAO();
        UserBean student = userDAO.findByEmail("student@campusflow.edu");
        RequestService reqService = new RequestService();

        RequestBean req = new RequestBean();
        req.setTitle("Projector Overheating in CS Lab 402");
        req.setCategory("Classroom");
        req.setLocation("Block C, Room 402, CS Department");
        req.setDescription("The main overhead projector shuts down with thermal warning lamp blinking after 10 minutes of lecture.");
        req.setUrgency(3);       // High
        req.setImpact(3);        // Department/Room
        req.setLocationWeight(2); // Classroom/Lab

        RequestResult result = reqService.createRequest(req, student);

        // TC10: Request created with tracking code
        check("TC10", "Student submits request and receives unique tracking ID",
            result.isSuccess() && result.getRequest().getTrackingCode() != null && result.getRequest().getTrackingCode().startsWith("CF-"),
            result.getMessage());

        createdRequest = result.getRequest();

        // TC11: Present in Oracle
        RequestDAO reqDAO = new RequestDAO();
        RequestBean fromDb = reqDAO.findById(createdRequest.getRequestId());
        check("TC11", "Request verified persisted in Oracle REQUESTS table",
            fromDb != null && "SUBMITTED".equals(fromDb.getStatus()) && "HIGH".equals(fromDb.getPriority()),
            "Request not in Oracle");

        // TC12: Missing required fields rejected
        RequestBean invalidReq = new RequestBean();
        RequestResult invResult = reqService.createRequest(invalidReq, student);
        check("TC12", "Missing required request fields are rejected", !invResult.isSuccess(), "Invalid request accepted");

        // TC13: Student can see their own request
        List<RequestBean> studentReqs = reqDAO.findRequests(student.getUserId(), null, null, null, null, null, null, null, 0, 10);
        check("TC13", "Student queries and views own submitted requests",
            studentReqs.stream().anyMatch(r -> r.getRequestId().equals(createdRequest.getRequestId())),
            "Created request not in student view");
    }

    private static void testRequestStateTransitionsAndValidation() {
        WorkflowService wf = new WorkflowService();
        UserDAO userDAO = new UserDAO();
        UserBean student = userDAO.findByEmail("student@campusflow.edu");
        UserBean admin = userDAO.findByEmail("admin@campusflow.edu");
        UserBean staff = userDAO.findByEmail("it.staff@campusflow.edu");

        // TC19: Illegal transition (SUBMITTED -> CLOSED directly by student)
        boolean canStudentClose = wf.canTransition("SUBMITTED", "CLOSED", student, createdRequest);
        check("TC19_ILLEGAL", "Illegal transition directly from SUBMITTED to CLOSED is blocked",
            !canStudentClose, "Student was permitted to illegally close SUBMITTED ticket");

        // Student cannot transition directly from SUBMITTED to IN_PROGRESS
        boolean canStudentStart = wf.canTransition("SUBMITTED", "IN_PROGRESS", student, createdRequest);
        check("TC19_ROLE_BLOCK", "Student cannot change status to IN_PROGRESS", !canStudentStart, "Student was permitted to start work");
    }

    private static void testDepartmentAndStaffAssignment() {
        AssignmentService assignService = new AssignmentService();
        UserDAO userDAO = new UserDAO();
        UserBean admin = userDAO.findByEmail("admin@campusflow.edu");
        UserBean itStaff = userDAO.findByEmail("it.staff@campusflow.edu");

        // TC15: Administrator assigns request to department (ID 1: IT) and staff
        AssignmentResult res = assignService.assignRequest(createdRequest.getRequestId(), 1L, itStaff.getUserId(), "Assigned to Alex Rivera for urgent thermal sensor inspection.", admin);
        check("TC15", "Administrator assigns request to department and eligible staff", res.isSuccess(), res.getMessage());

        // TC16: Assignment creates history record and notification
        RequestDAO reqDAO = new RequestDAO();
        RequestBean assignedReq = reqDAO.findById(createdRequest.getRequestId());
        check("TC16_STATUS", "Request status transitioned to ASSIGNED in Oracle", "ASSIGNED".equals(assignedReq.getStatus()), "Status: " + assignedReq.getStatus());

        RequestHistoryDAO histDAO = new RequestHistoryDAO();
        List<RequestHistoryBean> history = histDAO.findByRequestId(createdRequest.getRequestId());
        boolean hasAssignmentHistory = history.stream().anyMatch(h -> "ASSIGNMENT".equals(h.getActionType()) || "REASSIGNMENT".equals(h.getActionType()));
        check("TC16_HISTORY", "Assignment audit history record created in Oracle", hasAssignmentHistory, "No assignment record in history");

        NotificationDAO notifDAO = new NotificationDAO();
        List<NotificationBean> staffNotifs = notifDAO.findByRecipient(itStaff.getUserId(), false);
        boolean hasStaffNotif = staffNotifs.stream().anyMatch(n -> n.getRequestId() != null && n.getRequestId().equals(createdRequest.getRequestId()));
        check("TC16_NOTIFICATION", "In-app notification created for assigned staff member in Oracle", hasStaffNotif, "Staff did not receive notification");
    }

    private static void testStaffWorkAndRemarks() {
        WorkflowService wf = new WorkflowService();
        UserDAO userDAO = new UserDAO();
        UserBean itStaff = userDAO.findByEmail("it.staff@campusflow.edu");
        RequestDAO reqDAO = new RequestDAO();

        // TC17: Staff starts work (ASSIGNED -> IN_PROGRESS)
        WorkflowResult res = wf.transitionStatus(createdRequest.getRequestId(), "IN_PROGRESS", "Started teardown of projector housing to inspect cooling fan and thermal paste.", itStaff);
        check("TC17", "Staff technician accepts work and transitions to IN_PROGRESS", res.isSuccess(), res.getMessage());

        RequestBean inProgReq = reqDAO.findById(createdRequest.getRequestId());
        check("TC18", "Request updated to IN_PROGRESS in Oracle", "IN_PROGRESS".equals(inProgReq.getStatus()), "Status: " + inProgReq.getStatus());
    }

    private static void testStaffResolutionAndStudentFeedback() {
        WorkflowService wf = new WorkflowService();
        FeedbackService fbService = new FeedbackService();
        UserDAO userDAO = new UserDAO();
        UserBean itStaff = userDAO.findByEmail("it.staff@campusflow.edu");
        UserBean student = userDAO.findByEmail("student@campusflow.edu");
        RequestDAO reqDAO = new RequestDAO();

        // Resolve request (IN_PROGRESS -> RESOLVED)
        WorkflowResult res = wf.transitionStatus(createdRequest.getRequestId(), "RESOLVED", "Cleared dust buildup from exhaust fan and replaced heatsink compound. Ran continuous 60-min test with zero overheating.", itStaff);
        check("TC_RESOLVE", "Staff marks request as RESOLVED in Oracle", res.isSuccess(), res.getMessage());

        RequestBean resolvedReq = reqDAO.findById(createdRequest.getRequestId());
        check("TC_RESOLVE_STATUS", "Request status verified as RESOLVED with RESOLVED_AT timestamp in Oracle",
            "RESOLVED".equals(resolvedReq.getStatus()) && resolvedReq.getResolvedAt() != null, "Timestamp missing or status wrong");

        // TC25: Student submits feedback (rating 1-5)
        FeedbackResult fbRes = fbService.submitFeedback(createdRequest.getRequestId(), 5, "Excellent same-day turnaround! Projector ran perfectly for our afternoon lecture.", student);
        check("TC25", "Student submits 5-star service feedback for resolved request", fbRes.isSuccess(), fbRes.getMessage());

        // TC26: Duplicate feedback rejected
        FeedbackResult fbDup = fbService.submitFeedback(createdRequest.getRequestId(), 4, "Second feedback attempt", student);
        check("TC26", "Duplicate feedback submission for same request is rejected", !fbDup.isSuccess(), "Duplicate feedback was accepted");
    }

    private static void testInAppNotificationsPersistence() {
        NotificationDAO notifDAO = new NotificationDAO();
        UserDAO userDAO = new UserDAO();
        UserBean student = userDAO.findByEmail("student@campusflow.edu");

        List<NotificationBean> notifs = notifDAO.findByRecipient(student.getUserId(), false);
        check("TC24_LIST", "Student has notifications stored in Oracle", !notifs.isEmpty(), "No notifications found");

        int initialUnread = notifDAO.countUnread(student.getUserId());
        check("TC24_COUNT", "Unread notification count calculated", initialUnread >= 0, "Count failed");

        // Mark all as read
        notifDAO.markAllAsRead(student.getUserId());
        int afterMark = notifDAO.countUnread(student.getUserId());
        check("TC24_READ_STATE", "Marking notifications as read updates database state to 0 unread", afterMark == 0, "Unread remaining: " + afterMark);
    }

    private static void testAdminPriorityOverride() {
        RequestService reqService = new RequestService();
        UserDAO userDAO = new UserDAO();
        UserBean admin = userDAO.findByEmail("admin@campusflow.edu");
        RequestDAO reqDAO = new RequestDAO();

        // TC21_OVERRIDE: Override priority with recorded reason
        RequestResult res = reqService.overridePriority(createdRequest.getRequestId(), "CRITICAL", "Exam hall session relocated to Room 402 tomorrow.", admin);
        check("TC21_OVERRIDE", "Administrator overrides priority with recorded justification", res.isSuccess(), res.getMessage());

        RequestBean overridden = reqDAO.findById(createdRequest.getRequestId());
        check("TC21_DB_PRIO", "Priority updated to CRITICAL in Oracle", "CRITICAL".equals(overridden.getPriority()), "Priority: " + overridden.getPriority());
    }

    private static void testRequestCancellationRules() {
        UserDAO userDAO = new UserDAO();
        UserBean student = userDAO.findByEmail("student@campusflow.edu");
        RequestService reqService = new RequestService();

        // Create a new request to test cancellation
        RequestBean reqToCancel = new RequestBean();
        reqToCancel.setTitle("Water Cooler Filter Replacement");
        reqToCancel.setCategory("Water / Plumbing");
        reqToCancel.setLocation("Hostel Block 1 Ground Floor");
        reqToCancel.setDescription("Filter needs quarterly replacement.");
        reqToCancel.setUrgency(1);
        reqToCancel.setImpact(2);
        reqToCancel.setLocationWeight(1);

        RequestResult created = reqService.createRequest(reqToCancel, student);
        check("TC23_SUBMIT", "Test ticket created for cancellation workflow", created.isSuccess(), created.getMessage());

        // TC23: Eligible student cancels request while in SUBMITTED
        WorkflowResult cancelRes = reqService.cancelRequest(created.getRequest().getRequestId(), "Maintenance already serviced it earlier this morning.", student);
        check("TC23", "Student cancels eligible SUBMITTED request with reason", cancelRes.isSuccess(), cancelRes.getMessage());

        RequestDAO reqDAO = new RequestDAO();
        RequestBean cancelled = reqDAO.findById(created.getRequest().getRequestId());
        check("TC23_VERIFY", "Cancelled request has CANCELLED status and timestamp in Oracle",
            "CANCELLED".equals(cancelled.getStatus()) && cancelled.getCancelledAt() != null, "Not cancelled in Oracle");

        // TC22: Ineligible cancellation: Cannot transition or cancel already cancelled or closed request
        WorkflowResult invalidCancel = reqService.cancelRequest(created.getRequest().getRequestId(), "Cancelling again", student);
        check("TC22", "Cannot cancel an already cancelled terminal request", !invalidCancel.isSuccess(), "Permitted second cancellation");
    }

    private static void testAnalyticsLiveQueryMatching() {
        AnalyticsService analytics = new AnalyticsService();
        DashboardMetrics m = analytics.getMetrics();

        // TC27: Verify metrics match direct Oracle query results
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            int directTotal = 0;
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM REQUESTS")) {
                if (rs.next()) directTotal = rs.getInt(1);
            }

            int directFeedback = 0;
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM FEEDBACK")) {
                if (rs.next()) directFeedback = rs.getInt(1);
            }

            check("TC27_TOTAL", "Analytics total requests match direct Oracle query result", m.getTotalRequests() == directTotal, "Analytics: " + m.getTotalRequests() + ", DB: " + directTotal);
            check("TC27_FEEDBACK", "Analytics feedback count matches direct Oracle query result", m.getTotalFeedbackCount() == directFeedback, "Analytics: " + m.getTotalFeedbackCount() + ", DB: " + directFeedback);
        } catch (Exception e) {
            check("TC27", "Analytics query matching failed", false, e.getMessage());
        }
    }

    private static void testSqlInjectionResistance() {
        RequestDAO reqDAO = new RequestDAO();
        // TC29: Search with SQL injection payload: "' OR 1=1 -- "
        String sqlInjectionPayload = "' OR 1=1 -- ' UNION SELECT * FROM USERS";
        int count = reqDAO.countRequests(null, null, null, null, null, null, null, sqlInjectionPayload);
        // Should safely execute as literal search string and return 0 (or exact matches), NOT all rows
        check("TC29", "SQL Injection payload treated as literal search string via PreparedStatement", count == 0, "SQL injection returned unexpected match: " + count);
    }

    private static void testXssEscaping() {
        String xssPayload = "<script>alert('XSS')</script> & \"hello\" 'world'";
        String escaped = SecurityUtil.escapeHtml(xssPayload);
        boolean isSafe = !escaped.contains("<script>") && escaped.contains("&lt;script&gt;") && escaped.contains("&amp;") && escaped.contains("&quot;");
        check("TC30", "XSS payloads safely escaped by SecurityUtil for HTML rendering", isSafe, "Output: " + escaped);
    }
}
