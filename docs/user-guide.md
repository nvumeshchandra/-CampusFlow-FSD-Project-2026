# CampusFlow — End-to-End User Manual & Operation Guide

## 1. Student User Guide

### 1.1 Account Registration & Authentication
1. Navigate to `/register`.
2. Complete the registration form with your Full Name, Email, Password, and Phone Number.
3. Passwords must be at least 8 characters and contain at least one uppercase letter, one digit, and one special character (`@#$%^&+=!`).
4. Upon successful submission, you are redirected to the Login page with a success message.
5. Log in at `/login` using your registered credentials.

### 1.2 Student Dashboard
The student dashboard (`/student/dashboard`) provides a centralized view of your service interactions:
- **Metrics Summary**: Active Requests, In-Progress Requests, Resolved Issues, and Total Requests Submitted.
- **Recent Requests**: Displays the 5 most recent requests submitted by your account.
- **Quick Actions**: One-click shortcuts to submit a new issue or view notification alerts.

### 1.3 Submitting a Campus Service Request
1. Click **Submit Request** in the sidebar or dashboard.
2. Select an issue category (e.g., *IT & Networking*, *Electrical & Power*, *Plumbing & Water*, *Classroom Infrastructure*).
3. Enter a clear Title and detailed problem Description.
4. Specify the exact Campus Location (e.g., *Engineering Block B, Room 204*).
5. Choose Urgency Level (*Low*, *Medium*, *High*, *Emergency*) and Impact Level (*Single User*, *Room/Lab*, *Floor*, *Building Wide*).
6. **Live Priority Preview**: As you adjust urgency and impact, observe the interactive priority badge dynamically recalculate between **LOW**, **MEDIUM**, **HIGH**, and **CRITICAL**.
7. Click **Submit Service Request**.
8. A unique tracking identifier (e.g., `CF-2026-A1B2C`) is generated and you are redirected to the ticket details view.

### 1.4 Tracking & Modifying Requests
- Navigate to **My Requests** (`/student/requests`) to view a paginated list of all your tickets.
- Filter by Status (Submitted, In Progress, Resolved) or Category.
- Click **View Details** on any ticket to inspect the full timeline history, assigned staff, and progress remarks.
- **Editing**: If a ticket is still in `SUBMITTED` state, an **Edit** button is available to revise details.
- **Cancelling**: If the issue is no longer relevant, click **Cancel Request** to withdraw it.

### 1.5 Submitting Post-Resolution Feedback
1. Once staff mark your ticket as `RESOLVED`, a **Submit Feedback** prompt appears on your dashboard and request details page.
2. Select a star rating from 1 to 5.
3. Enter optional comments regarding the timeliness and quality of service.
4. Click **Submit Feedback**. The ticket automatically transitions to `CLOSED`.

---

## 2. Staff User Guide

### 2.1 Staff Dashboard & Assigned Queue
1. Log in with your staff account (e.g., `it.staff@campusflow.edu`).
2. The Staff Dashboard (`/staff/dashboard`) displays your active assigned workload:
   - **Assigned Tasks**: Work waiting to be started.
   - **In Progress Tasks**: Issues currently being worked on.
   - **Resolved This Month**: Completed tasks.
3. The queue table shows ticket title, location, dynamic priority level, student name, and date assigned.

### 2.2 Updating Progress & Resolving Issues
1. Click **View / Update** on any assigned ticket to open the details view.
2. To begin working on an issue in `ASSIGNED` state:
   - Click **Start Work**.
   - Enter optional notes (e.g., *"Diagnosing network switch in room 204"*).
   - The ticket status transitions to `IN_PROGRESS`, and an automated notification is dispatched to the student.
3. To complete an issue:
   - Click **Mark as Resolved**.
   - Enter mandatory resolution remarks (e.g., *"Replaced faulty RJ45 patch cable; uplink connection restored and verified"*).
   - The ticket status updates to `RESOLVED`, the completion timestamp is recorded, and the student is invited to leave feedback.

---

## 3. Administrator User Guide

### 3.1 Central Administrative Dashboard
1. Log in with your administrator account (`admin@campusflow.edu`).
2. The Admin Dashboard (`/admin/dashboard`) displays enterprise-wide metrics:
   - **Total Requests**, **Open Issues**, **Critical Priority Escalations**, and **Global Resolution Rate %**.
   - Quick table of recent campus-wide submissions.

### 3.2 Master Request Management & Dispatch
1. Navigate to **All Requests** (`/admin/requests`).
2. Use the multi-attribute filter bar to filter by Department, Status, Priority, Category, or Date Range.
3. Open any request to view its complete audit trail.
4. **Assign / Reassign**:
   - Select the target Department from the dropdown.
   - The Staff dropdown dynamically refreshes via AJAX to show active staff members belonging to that department.
   - Select the staff member and click **Assign Staff**. An audit log and in-app notification are dispatched.
5. **Priority Override**:
   - Change the priority level (e.g., from `MEDIUM` to `CRITICAL`).
   - Enter a mandatory justification for the override (e.g., *"Dean requested immediate escalation due to upcoming exam"*).
   - Click **Update Priority**. The reason is permanently recorded in the audit history.

### 3.3 Department Management
1. Navigate to **Departments** (`/admin/departments`).
2. View existing departments, their short codes, contact emails, and active staff counts.
3. Click **Add Department** to create a new division (e.g., *Hostel Management* or *Campus Security*).
4. Toggle active/inactive status to disable departments during semester breaks.

### 3.4 User Directory & Access Governance
1. Navigate to **Users** (`/admin/users`).
2. Filter accounts by role (`STUDENT`, `STAFF`, `ADMIN`) or search by name and email.
3. Deactivate or reactivate user accounts with one click. Deactivated users are blocked from logging into the platform immediately.

### 3.5 Operational Analytics & SVG Visualizations
1. Navigate to **Analytics** (`/admin/analytics`).
2. **Status Distribution**: Interactive SVG Donut chart displaying proportions of active, in-progress, resolved, and cancelled tickets.
3. **Priority Distribution**: Visual breakdown of workload across Low, Medium, High, and Critical tickets.
4. **Departmental Workload & Turnaround**: Responsive SVG horizontal bar charts illustrating ticket volume and average resolution hours per department.
