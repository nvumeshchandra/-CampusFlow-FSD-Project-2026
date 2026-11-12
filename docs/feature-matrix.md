# CampusFlow — Feature Implementation & Verification Matrix

All features outlined in the Master Build Prompt have been implemented using the strict permitted technology stack (Java EE, Servlets, JSP, JDBC, Oracle 10g/11g/19c XE, modern CSS3, vanilla JavaScript). Every feature has been systematically verified via automated unit/integration tests and HTTP end-to-end integration tests.

---

## 1. Authentication & Security Module

| Ref # | Feature Description | Implementing Components | Status | Test Case Reference |
| :--- | :--- | :--- | :--- | :--- |
| **F01** | Student Self-Registration with client/server validation | `RegisterServlet.java`, `ValidationUtil.java`, `UserDAO.java` | **VERIFIED** | TC01, TC02, TC03 |
| **F02** | Secure PBKDF2 Password Hashing (65,536 iters, SHA-256, 16B salt) | `PasswordUtil.java`, `AuthService.java` | **VERIFIED** | TC01, TC04 |
| **F03** | Credential Authentication with constant-time equality compare | `LoginServlet.java`, `PasswordUtil.java`, `UserDAO.java` | **VERIFIED** | TC04, TC05 |
| **F04** | Role-Based Session Initialization & Session Fixation Renewal | `LoginServlet.java`, `AuthenticationFilter.java` | **VERIFIED** | TC04, TC06 |
| **F05** | Role-Based Authorization Guard (Student / Staff / Admin) | `AuthenticationFilter.java` | **VERIFIED** | TC07, TC08, TC09 |
| **F06** | Synchronizer CSRF Token Generation & Verification | `CsrfFilter.java`, `SecurityUtil.java` | **VERIFIED** | TC31 |
| **F07** | XSS Protection (HTML Entity Encoding) | `SecurityUtil.java`, `escapeHtml()` | **VERIFIED** | TC32 |
| **F08** | Account Deactivation Check on Login | `AuthService.java`, `LoginServlet.java` | **VERIFIED** | TC05 |
| **F09** | Session Expiration & Complete Invalidation on Logout | `LogoutServlet.java`, `web.xml` | **VERIFIED** | TC06 |
| **F10** | User Profile & Password Change with Current Password Verification | `ProfileServlet.java`, `AuthService.java` | **VERIFIED** | TC33 |

---

## 2. Student Service Request Module

| Ref # | Feature Description | Implementing Components | Status | Test Case Reference |
| :--- | :--- | :--- | :--- | :--- |
| **F11** | Request Submission Form with Dynamic Priority Score Preview | `RequestCreateServlet.java`, `create-request.jsp`, `app.js` | **VERIFIED** | TC10 |
| **F12** | Automatic Unique Tracking Code Generator (`CF-2026-xxxxx`) | `TrackingCodeUtil.java`, `RequestService.java` | **VERIFIED** | TC10, TC11 |
| **F13** | Rule-Based Priority Engine (Urgency, Impact, Location, Keywords) | `PriorityService.java` | **VERIFIED** | TC12, TC13, TC14 |
| **F14** | Personal Request Listing & Oracle `ROWNUM` Pagination | `RequestListServlet.java`, `my-requests.jsp`, `RequestDAO.java`| **VERIFIED** | TC15 |
| **F15** | Multi-attribute Filtering & Search (Category, Status, Priority) | `RequestDAO.java` (Dynamic SQL Builder) | **VERIFIED** | TC15 |
| **F16** | Request Details & Chronological Audit Timeline View | `RequestDetailsServlet.java`, `request-details.jsp` | **VERIFIED** | TC16, TC17 |
| **F17** | Request Modification (Restricted to `SUBMITTED` state) | `RequestEditServlet.java`, `WorkflowService.java` | **VERIFIED** | TC18 |
| **F18** | Request Cancellation (Restricted to `SUBMITTED` / `ASSIGNED`) | `RequestCancelServlet.java`, `WorkflowService.java` | **VERIFIED** | TC19 |
| **F19** | Post-Resolution 5-Star Feedback & Review Submission | `FeedbackServlet.java`, `FeedbackDAO.java`, `feedback.jsp` | **VERIFIED** | TC20 |

---

## 3. Staff Workflow Module

| Ref # | Feature Description | Implementing Components | Status | Test Case Reference |
| :--- | :--- | :--- | :--- | :--- |
| **F20** | Staff Assigned Queue Dashboard & Workload Counters | `StaffDashboardServlet.java`, `dashboard.jsp` | **VERIFIED** | TC21 |
| **F21** | Workflow State Transition: `ASSIGNED` $\rightarrow$ `IN_PROGRESS` | `StaffActionServlet.java`, `WorkflowService.java` | **VERIFIED** | TC22 |
| **F22** | Workflow State Transition: `IN_PROGRESS` $\rightarrow$ `RESOLVED` | `StaffActionServlet.java`, `WorkflowService.java` | **VERIFIED** | TC23 |
| **F23** | Action Remarks Logging in `REQUEST_HISTORY` Audit Trail | `WorkflowService.java`, `RequestHistoryDAO.java` | **VERIFIED** | TC22, TC23 |
| **F24** | Automated Status-Change Notification Dispatch to Student | `WorkflowService.java`, `NotificationDAO.java` | **VERIFIED** | TC22, TC23, TC30 |

---

## 4. Administrator Governance & Operations Module

| Ref # | Feature Description | Implementing Components | Status | Test Case Reference |
| :--- | :--- | :--- | :--- | :--- |
| **F25** | Executive KPI Dashboard (Active, High-Priority, Resolution Rate) | `AdminDashboardServlet.java`, `AnalyticsService.java` | **VERIFIED** | TC24 |
| **F26** | Universal Request Filter & Department Dispatch | `AdminRequestListServlet.java`, `all-requests.jsp` | **VERIFIED** | TC25 |
| **F27** | Staff Assignment & Reassignment with Notification Dispatch | `AdminAssignmentServlet.java`, `AssignmentService.java` | **VERIFIED** | TC26 |
| **F28** | Administrative Priority Override with Mandatory Reason Log | `AdminPriorityServlet.java`, `RequestHistoryDAO.java` | **VERIFIED** | TC27 |
| **F29** | Administrative Workflow Status Override | `AdminStatusServlet.java`, `WorkflowService.java` | **VERIFIED** | TC28 |
| **F30** | Department Management (Create, Edit, Toggle Active) | `DepartmentServlet.java`, `DepartmentDAO.java` | **VERIFIED** | TC29 |
| **F31** | User Management (Directory, Role Filter, Deactivate/Reactivate)| `UserManagementServlet.java`, `UserDAO.java` | **VERIFIED** | TC34 |
| **F32** | Interactive Operational Analytics (Native SVG Donut & Bar Charts)| `AnalyticsServlet.java`, `analytics.jsp`, `charts.js` | **VERIFIED** | TC24 |

---

## 5. Shared Infrastructure & Notifications

| Ref # | Feature Description | Implementing Components | Status | Test Case Reference |
| :--- | :--- | :--- | :--- | :--- |
| **F33** | In-App Notification Center & Unread Navbar Badge Count | `NotificationServlet.java`, `notifications.jsp`, `header.jsp`| **VERIFIED** | TC30 |
| **F34** | Transactional Atomicity (Rollback on Workflow Failure) | `WorkflowService.java`, `AssignmentService.java` | **VERIFIED** | TC10, TC26 |
| **F35** | Oracle Database Persistence & Foreign Key Integrity | Oracle XE Schema (`01_create_schema.sql` to `04_indexes.sql`)| **VERIFIED** | TC35 |
