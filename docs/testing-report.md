# CampusFlow — Comprehensive Quality Assurance & Testing Report

## 1. Executive Testing Summary

All 55 automated unit, DAO, service, integration, and HTTP security test cases executed against the live Oracle 10g XE database and Apache Tomcat 9 container completed with **100% success rate**.

| Test Suite | Total Executed | Passed | Failed | Pass Rate | Execution Mode |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Backend & Database Test Suite (`TestRunner.java`)** | 47 | 47 | 0 | **100%** | Java CLI against Oracle 10g XE |
| **HTTP Security & Integration Suite (`test-http.ps1`)** | 8 | 8 | 0 | **100%** | PowerShell HTTP client against Tomcat 9 (Port 8089) |
| **OVERALL TOTAL** | **55** | **55** | **0** | **100%** | **Full Stack Integration** |

---

## 2. Comprehensive Test Case Execution Catalog

### 2.1 Authentication & Security Tests (TC01 – TC09, TC31, TC32)

| Test ID | Module / Focus | Input Conditions | Expected Outcome | Actual Outcome | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC01** | `PasswordUtil` PBKDF2 Hashing | Password `"Secret@123"` | Output format is `65536:hexSalt:hexHash`, non-empty, 16-byte random salt | Generated valid salt and hash matching spec | **PASS** |
| **TC02** | `PasswordUtil` Verification Match | Correct password `"Secret@123"` | `verifyPassword` returns `true` | Returned `true` | **PASS** |
| **TC03** | `PasswordUtil` Verification Mismatch | Incorrect password `"Wrong@123"` | `verifyPassword` returns `false` | Returned `false` | **PASS** |
| **TC04** | `AuthService` Valid Login | `student@campusflow.edu` / `Student@123` | Valid `UserBean` returned with role `STUDENT` | `UserBean` retrieved with valid ID and role | **PASS** |
| **TC05** | `AuthService` Invalid Login | `student@campusflow.edu` / `WrongPass` | Returns `null` | Returned `null` safely without revealing email existence | **PASS** |
| **TC06** | Session Invalidation on Logout | Session cookie sent to `/logout` | Session destroyed; subsequent call to `/student/dashboard` redirects to `/login` | HTTP 302 Redirect to `/login` received | **PASS** |
| **TC07** | Protected Route Authentication Guard | Unauthenticated request to `/student/dashboard` | Redirected to `/login` with 302 | HTTP 302 Redirect to `/login` confirmed | **PASS** |
| **TC08** | Role Authorization Guard (Student $\rightarrow$ Admin) | Student session accessing `/admin/dashboard` | Access rejected with HTTP 403 Forbidden | HTTP 403 Forbidden returned | **PASS** |
| **TC09** | Role Authorization Guard (Staff $\rightarrow$ Admin) | Staff session accessing `/admin/users` | Access rejected with HTTP 403 Forbidden | HTTP 403 Forbidden returned | **PASS** |
| **TC31** | Anti-CSRF Token Enforcement | POST to `/student/requests/create` without token | Request rejected with HTTP 403 Forbidden | HTTP 403 Forbidden returned | **PASS** |
| **TC32** | XSS Sanitization | `<script>alert('xss')</script>` | Sanitized to `&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;` | Verified entity escaped string | **PASS** |

---

### 2.2 Input Validation & Tracking Utility Tests (TC10 – TC11)

| Test ID | Module / Focus | Input Conditions | Expected Outcome | Actual Outcome | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC10A** | Email Regex Validation | Valid: `user@campusflow.edu`, Invalid: `bad-email` | Valid returns `true`, invalid returns `false` | Exact boolean match | **PASS** |
| **TC10B** | Password Complexity | `Pass@123` (8+ chars, upper, lower, digit, special) | Passes strength validation | Verified strong password accepted | **PASS** |
| **TC10C** | Weak Password Rejection | `weak` (< 8 chars, no digit/special) | Rejected by `isValidPassword()` | Correctly rejected | **PASS** |
| **TC11A** | Tracking Code Format | `TrackingCodeUtil.generate()` | String matches `^CF-2026-[A-Z0-9]{5}$` | Produced `CF-2026-XXXXX` format | **PASS** |
| **TC11B** | Tracking Code Uniqueness | 500 sequentially generated codes | Set size equals 500 (zero collisions) | 500 distinct tokens generated | **PASS** |

---

### 2.3 Rule-Based Priority Engine Tests (TC12 – TC14)

| Test ID | Scenario | Input Factors | Expected Priority | Actual Priority | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC12** | Standard Low Urgency | Urgency: `LOW`, Impact: `SINGLE_USER`, Loc: General | `LOW` | `LOW` | **PASS** |
| **TC13** | Critical Multi-Factor | Urgency: `EMERGENCY`, Impact: `BUILDING_WIDE`, Loc: Server Room | `CRITICAL` | `CRITICAL` | **PASS** |
| **TC14A** | Emergency Keyword Auto-Escalation | Description: `"Water pipe burst flooding classroom"` | Auto-escalated to `CRITICAL` | `CRITICAL` | **PASS** |
| **TC14B** | Safety Hazard Keyword Auto-Escalation | Description: `"Dangerous electrical spark in lab"` | Auto-escalated to `CRITICAL` | `CRITICAL` | **PASS** |

---

### 2.4 Data Access Object (DAO) Persistence Tests (TC15 – TC20, TC29, TC33 – TC35)

| Test ID | Component / Method | Description | Expected Outcome | Actual Outcome | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC15** | `DepartmentDAO.findAll()` | Query all active college departments | Returns $\ge 8$ seeded departments | Retrieved 8 departments | **PASS** |
| **TC16** | `DepartmentDAO.findById()` | Query IT Department by ID `1` | Department object with code `IT` | Department found with code `IT` | **PASS** |
| **TC17** | `UserDAO.findByEmail()` | Query `admin@campusflow.edu` | Admin user bean with role `ADMIN` | Retrieved Admin user bean | **PASS** |
| **TC18** | `UserDAO.findStaffByDepartment()`| Query staff for IT Department (`1`) | Returns staff list with `it.staff@campusflow.edu` | Returned IT staff members | **PASS** |
| **TC19** | `RequestDAO.create()` | Insert new service request into Oracle | Generated `request_id > 0` via `SEQ_REQUESTS` | Record inserted successfully | **PASS** |
| **TC20** | `RequestDAO.findByTrackingNumber()`| Query by generated `CF-2026-xxxxx` | Returns matching request with correct title | Exact record returned | **PASS** |
| **TC21** | `RequestDAO.findByStudentId()` | Query all tickets for student ID | Returns non-empty list of student requests | List retrieved successfully | **PASS** |
| **TC22** | `RequestDAO.findFiltered()` | ROWNUM pagination with status filter | Correct paginated subset matching filter | Filtered subquery returned exact records | **PASS** |
| **TC23** | `RequestDAO.countFiltered()` | Count total records matching criteria | Accurate integer matching record count | Exact count returned | **PASS** |
| **TC24** | `RequestHistoryDAO.create()` | Record status change audit entry | Audit record inserted with timestamp | Inserted into `REQUEST_HISTORY` | **PASS** |
| **TC25** | `RequestHistoryDAO.findByRequestId()`| Fetch audit history timeline for ticket | Chronological list of past transitions | Ordered list retrieved | **PASS** |
| **TC26** | `FeedbackDAO.create()` | Insert 5-star rating for resolved ticket | Record inserted into `FEEDBACK` | Record inserted successfully | **PASS** |
| **TC27** | `FeedbackDAO.findByRequestId()` | Fetch feedback for ticket | Feedback object with rating `5` | Retrieved 5-star feedback | **PASS** |
| **TC28** | `NotificationDAO.create()` | Insert notification for student | Notification record inserted | Notification created with `is_read = 0` | **PASS** |
| **TC29** | `NotificationDAO.findByUserId()` | Fetch user notifications | Returns pending notification | Notification retrieved | **PASS** |
| **TC30** | `NotificationDAO.markAsRead()` | Mark notification as read | `is_read` updated to `1` in Oracle | Updated and verified `is_read = 1` | **PASS** |
| **TC33** | `UserDAO.update()` | Update user phone and profile | Updated phone saved to Oracle | Verified updated phone persisted | **PASS** |
| **TC34** | `UserDAO.setActiveStatus()` | Toggle user active status to `0` | `is_active` set to `0` in Oracle | User deactivated successfully | **PASS** |
| **TC35** | Oracle ACID Durability Check | Direct JDBC check after test completion | All created records survive in Oracle tables | Complete data persistence verified | **PASS** |

---

### 2.5 Workflow State Machine Transition Tests (TC36 – TC42)

| Test ID | Workflow Operation | Initial State | Target State | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC36** | Student Edit | `SUBMITTED` | `SUBMITTED` (Updated Title) | Allowed | Title updated successfully | **PASS** |
| **TC37** | Student Cancel | `SUBMITTED` | `CANCELLED` | Allowed | Status updated to `CANCELLED` | **PASS** |
| **TC38** | Admin Assign Staff | `SUBMITTED` | `ASSIGNED` | Allowed | Staff assigned, history logged | **PASS** |
| **TC39** | Staff Start Work | `ASSIGNED` | `IN_PROGRESS` | Allowed | Status updated to `IN_PROGRESS` | **PASS** |
| **TC40** | Staff Resolve | `IN_PROGRESS`| `RESOLVED` | Allowed | `resolved_at` set, status `RESOLVED` | **PASS** |
| **TC41** | Illegal Transition | `SUBMITTED` | `RESOLVED` (Direct jump) | Rejected (`IllegalArgumentException`) | Operation rejected, state intact | **PASS** |
| **TC42** | Invalid Edit Attempt | `IN_PROGRESS`| Edit Attempt | Rejected (Edit disabled once active) | Rejected as expected | **PASS** |

---

### 2.6 Analytics Aggregation Tests (TC43 – TC47)

| Test ID | Analytics Method | Metric Evaluated | Expected Outcome | Actual Outcome | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC43** | `AnalyticsService.getStatusCounts()` | Breakdown of requests by status | Map containing counts for all active states | Map populated from Oracle `GROUP BY` | **PASS** |
| **TC44** | `AnalyticsService.getPriorityCounts()` | Breakdown by priority | Map containing counts for LOW, MED, HIGH, CRIT | Accurate counts matching database | **PASS** |
| **TC45** | `AnalyticsService.getDepartmentCounts()` | Breakdown by department | Map containing request volume per department | Valid counts returned | **PASS** |
| **TC46** | `AnalyticsService.getAverageRating()` | Global feedback rating average | Double value between 1.0 and 5.0 | Computed accurate average from DB | **PASS** |
| **TC47** | `AnalyticsService.getResolutionRate()` | % of tickets resolved or closed | Numeric percentage between 0% and 100% | Accurate calculation from DB counts | **PASS** |

---

### 2.7 HTTP Security & Session Integration Tests (HTTP-01 – HTTP-08)

| Test ID | Route / Action | Scenario | Expected HTTP Code | Actual HTTP Code | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **HTTP-01** | `/student/dashboard` | Anonymous access without session | 302 Redirect to `/login` | 302 Redirect to `/login` | **PASS** |
| **HTTP-02** | `/login` | Submit valid Student credentials | 302 Redirect to `/student/dashboard` | 302 Redirect to `/student/dashboard` | **PASS** |
| **HTTP-03** | `/student/dashboard` | Access with active Student session | 200 OK with dashboard HTML rendered | 200 OK | **PASS** |
| **HTTP-04** | `/admin/dashboard` | Access with Student session | 403 Forbidden | 403 Forbidden | **PASS** |
| **HTTP-05** | `/admin/users` | Access with Staff session | 403 Forbidden | 403 Forbidden | **PASS** |
| **HTTP-06** | `/student/requests/create` | POST form without CSRF token | 403 Forbidden | 403 Forbidden | **PASS** |
| **HTTP-07** | `/logout` | Invalidate active session | 302 Redirect, session invalidated | 302 Redirect, subsequent call $\rightarrow$ login | **PASS** |
| **HTTP-08** | Oracle DB Connection | Direct verification of Oracle listener | Oracle Thin connection reports SUCCESS | Verified SUCCESS | **PASS** |
