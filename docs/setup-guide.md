# CampusFlow — Installation, Configuration & Setup Guide

## 1. System Requirements & Prerequisites

To build and run **CampusFlow**, verify that the following prerequisites are installed on the host machine:

| Component | Minimum Version | Recommended / Verified Version |
| :--- | :--- | :--- |
| **Java Development Kit (JDK)** | JDK 8+ | JDK 17.0.19 LTS (`C:\Program Files\Java\jdk-17.0.19`) |
| **Servlet Container** | Apache Tomcat 8.5 / 9.0 | Apache Tomcat 9.0.121 (`C:\Program Files\Apache Software Foundation\Tomcat 9.0`) |
| **Database** | Oracle 10g / 11g / 19c XE | Oracle Database 10g Express Edition (`C:\oraclexe`) |
| **JDBC Driver** | Oracle Thin Driver | `ojdbc14.jar` (or `ojdbc8.jar` for Oracle 12c+) |
| **Operating System** | Windows 10/11 or Linux | Windows 11 with PowerShell 5.1+ |

---

## 2. Oracle Database Setup & Configuration

### Step 2.1: Adjust Oracle Connection Processes (Crucial for Rapid JDBC)
By default, Oracle 10g XE has `PROCESSES = 40`, which can lead to `ORA-12519: TNS:no appropriate service handler found` during concurrent connection pooling.
Run the following commands in SQL*Plus:

```sql
sqlplus sys/manager as sysdba
ALTER SYSTEM SET PROCESSES=150 SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;
EXIT;
```

### Step 2.2: Create Dedicated Application User
In SQL*Plus as SYSDBA:

```sql
CREATE USER campusflow IDENTIFIED BY campusflow123;
GRANT CONNECT, RESOURCE TO campusflow;
GRANT CREATE VIEW, CREATE SEQUENCE, CREATE SYNONYM TO campusflow;
EXIT;
```

### Step 2.3: Execute Schema & Seed Scripts
Execute the SQL files located in `D:\fsd2-project\database\` in numerical sequence:

```powershell
sqlplus campusflow/campusflow123@localhost:1521/xe @D:\fsd2-project\database\01_create_schema.sql
sqlplus campusflow/campusflow123@localhost:1521/xe @D:\fsd2-project\database\02_seed_departments.sql
sqlplus campusflow/campusflow123@localhost:1521/xe @D:\fsd2-project\database\03_create_admin_instructions.sql
sqlplus campusflow/campusflow123@localhost:1521/xe @D:\fsd2-project\database\04_indexes.sql
```

> [!NOTE]
> All SQL scripts include `SET DEFINE OFF;` to avoid PowerShell/SQL*Plus substitution variable prompts on ampersand characters in department names.

---

## 3. Apache Tomcat Configuration

### Step 3.1: Resolve Port Conflict with Oracle XE
Oracle 10g XE embeds an HTTP listener on port `8080`. To avoid port collision, Tomcat should be configured to run on port `8089`.

In `C:\Program Files\Apache Software Foundation\Tomcat 9.0\conf\server.xml`:
```xml
<Connector port="8089" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

### Step 3.2: Verify Oracle JDBC Driver Availability
Ensure `ojdbc14.jar` (or `ojdbc8.jar`) is placed in either:
1. `C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\` (container-wide), OR
2. `src/main/webapp/WEB-INF/lib/` (web-app specific).

---

## 4. Application Build & Deployment

### Automated One-Click Build & Deployment (`build.ps1`)
Run the provided automated deployment script:

```powershell
powershell -ExecutionPolicy Bypass -File D:\fsd2-project\build.ps1
```

The script performs the following:
1. Scans and compiles all 50 Java source files to `src/main/webapp/WEB-INF/classes`.
2. Packages the full web application into `dist/campusflow.war`.
3. Directly deploys the exploded application to Tomcat's `webapps/campusflow` directory.

### Starting Tomcat
Open a terminal and launch the Tomcat server:

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17.0.19"
$env:CATALINA_HOME = "C:\Program Files\Apache Software Foundation\Tomcat 9.0"
& "$env:CATALINA_HOME\bin\catalina.bat" run
```

Access the application in your browser:
**`http://localhost:8089/campusflow/`**

---

## 5. Bootstrap Demo Accounts

The database seed scripts create the following pre-configured user accounts:

| Role | Email | Password | Department |
| :--- | :--- | :--- | :--- |
| **System Administrator** | `admin@campusflow.edu` | `Admin@123` | Campus Administration |
| **IT Staff Member** | `it.staff@campusflow.edu` | `Staff@123` | Information Technology |
| **Electrical Staff** | `elec.staff@campusflow.edu` | `Staff@123` | Electrical & Power |
| **Plumbing Staff** | `plumb.staff@campusflow.edu` | `Staff@123` | Plumbing & Water |
| **Primary Student** | `student@campusflow.edu` | `Student@123` | Student Body |
| **Secondary Student** | `rahul.verma@campusflow.edu` | `Student@123` | Student Body |

> [!TIP]
> On the `/login` page, click any of the "Demo Fill" buttons (Admin, Staff, Student) to populate credentials into the form with one click.

---

## 6. Running Test Suites

### 1. Run Complete Backend & DAO Test Suite (47 Tests):
```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17.0.19"
$CP = "D:\fsd2-project\src\main\webapp\WEB-INF\classes;C:\oraclexe\app\oracle\product\10.2.0\server\jdbc\lib\ojdbc14.jar;C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\servlet-api.jar"
& "$env:JAVA_HOME\bin\java.exe" -cp $CP com.campusflow.test.TestRunner
```

### 2. Run HTTP Security & Authorization Test Suite (8 Tests):
```powershell
powershell -ExecutionPolicy Bypass -File D:\fsd2-project\test-http.ps1
```
