# CampusFlow — Known Environmental Boundaries & Technical Considerations

## 1. Oracle Database Considerations

### 1.1 Oracle 10g Synthetic Key Generation
- **Boundary**: Modern SQL standards (and Oracle 12c+) support `GENERATED ALWAYS AS IDENTITY`. Oracle 10g XE does not support this syntax.
- **Architectural Handling**: Synthetic primary keys are implemented using dedicated Oracle Sequences (`SEQ_USERS`, `SEQ_DEPARTMENTS`, `SEQ_REQUESTS`, etc.). During record insertion, sequences are queried either explicitly or within `INSERT INTO ... VALUES (SEQ_*.NEXTVAL, ...)` and retrieved deterministically using `SEQ_*.CURRVAL`.

### 1.2 Oracle 10g XE Default Process Limits
- **Boundary**: Out-of-the-box installations of Oracle Database 10g Express Edition set `PROCESSES = 40`. Rapid concurrent JDBC calls from the Tomcat connection pool or automated test suites can exhaust available background processes, triggering `ORA-12519: TNS:no appropriate service handler found`.
- **Architectural Handling**: The database SPFILE parameter was updated to `PROCESSES = 150` via `ALTER SYSTEM SET PROCESSES=150 SCOPE=SPFILE;` followed by an instance bounce.

### 1.3 Oracle XE Embedded HTTP Listener Port (Port 8080)
- **Boundary**: Oracle XE launches an embedded HTTP server (for Oracle Application Express) listening on TCP port 8080 by default. This causes a port collision if Apache Tomcat attempts to bind to its default HTTP port 8080.
- **Architectural Handling**: Tomcat's HTTP connector was explicitly mapped to port **`8089`** in `conf/server.xml`.

---

## 2. Technology Stack Boundaries (Zero External Libraries)

### 2.1 Native SVG Data Visualizations vs. External Libraries
- **Boundary**: In accordance with the strict technology restrictions, external JavaScript libraries (such as Chart.js, D3.js, Highcharts) were strictly prohibited.
- **Architectural Handling**: Visual analytics are rendered using an in-house native SVG graphing engine (`assets/js/charts.js`). This provides clean, responsive Donut and Horizontal Progress Bar visualizations directly in the browser DOM with zero network overhead and zero third-party dependencies.

### 2.2 In-App Notification System vs. External Email Relays
- **Boundary**: To ensure complete offline functionality and eliminate reliance on external third-party mail relays (SendGrid, Mailgun) or configured SMTP credentials, notifications are delivered via an in-app notification center.
- **Architectural Handling**: Notifications are persisted in the `NOTIFICATIONS` table with real-time unread badge counts in the navigation header. The architecture provides clean service abstractions (`NotificationService`) should production SMTP delivery be enabled in the future.

---

## 3. Production Enhancement Roadmap

For enterprise-scale production rollouts exceeding 10,000 active concurrent campus users, the following enhancements are recommended:
1. **Managed Connection Pooling**: Transition from direct JDBC driver connections to Tomcat container-managed JNDI connection pooling (`javax.sql.DataSource` via Apache Commons DBCP or HikariCP).
2. **Oracle 19c Enterprise Migration**: Upgrade to Oracle 19c Long Term Support (LTS) to take advantage of JSON relational duality views, partitioned tables, and automated index management.
3. **Containerization & CI/CD**: Package the application into lightweight Docker containers orchestrated via Kubernetes, with automated migration pipelines using Flyway or Liquibase.
