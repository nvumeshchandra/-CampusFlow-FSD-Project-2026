# ====================================================================
# CampusFlow HTTP & Security QA Verification Test Suite
# ====================================================================

$BASE_URL = "http://localhost:8089/campusflow"
$passed = 0
$failed = 0

function Assert-Test($testId, $desc, $condition, $details) {
    if ($condition) {
        $script:passed++
        Write-Host "[PASS] $testId`: $desc" -ForegroundColor Green
    } else {
        $script:failed++
        Write-Host "[FAIL] $testId`: $desc -- Details: $details" -ForegroundColor Red
    }
}

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "   CAMPUSFLOW HTTP SECURITY & ROLE AUTHORIZATION TEST SUITE          " -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan

# 1. TC07: Unauthenticated access to protected route redirects to login
try {
    $req = [System.Net.HttpWebRequest]::Create("$BASE_URL/student/dashboard")
    $req.AllowAutoRedirect = $false
    $resp = $req.GetResponse()
    $status = [int]$resp.StatusCode
    $location = $resp.Headers["Location"]
    $resp.Close()
    Assert-Test "TC07" "Unauthenticated user accessing protected route is redirected to login" ($status -eq 302 -and $location -match "login") "Status: $status, Location: $location"
} catch [System.Net.WebException] {
    $resp = $_.Exception.Response
    $status = [int]$resp.StatusCode
    $location = $resp.Headers["Location"]
    $resp.Close()
    Assert-Test "TC07" "Unauthenticated user accessing protected route is redirected to login" ($status -eq 302 -and $location -match "login") "Status: $status, Location: $location"
}

# 2. TC04_STUDENT_HTTP: Login as student via HTTP POST and store session cookie
$studentSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginBody = @{
    email = "student@campusflow.edu"
    password = "Student@123"
}
try {
    $loginResp = Invoke-WebRequest -Uri "$BASE_URL/login" -Method POST -Body $loginBody -WebSession $studentSession -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
    $loginStatus = $loginResp.StatusCode
    $loginRedirect = $loginResp.Headers["Location"]
    Assert-Test "TC04_STUDENT_HTTP" "Student login establishes session and redirects to /student/dashboard" ($loginStatus -eq 302 -and $loginRedirect -match "student/dashboard") "Status: $loginStatus, Redirect: $loginRedirect"
} catch {
    $loginResp = $_.Exception.Response
    $loginStatus = [int]$loginResp.StatusCode
    $loginRedirect = $loginResp.Headers["Location"]
    Assert-Test "TC04_STUDENT_HTTP" "Student login establishes session and redirects to /student/dashboard" ($loginStatus -eq 302 -and $loginRedirect -match "student/dashboard") "Status: $loginStatus, Redirect: $loginRedirect"
}

# Verify student dashboard accessible with student session
try {
    $dashResp = Invoke-WebRequest -Uri "$BASE_URL/student/dashboard" -WebSession $studentSession -UseBasicParsing
    Assert-Test "TC_STUDENT_DASH" "Student dashboard renders 200 OK with session" ($dashResp.StatusCode -eq 200 -and $dashResp.Content -match "Student Dashboard") "Status: $($dashResp.StatusCode)"
} catch {
    Assert-Test "TC_STUDENT_DASH" "Student dashboard renders 200 OK with session" $false $_
}

# 3. TC08: Student attempting to access Admin route receives HTTP 403 Forbidden
try {
    $adminAccess = Invoke-WebRequest -Uri "$BASE_URL/admin/dashboard" -WebSession $studentSession -UseBasicParsing -ErrorAction Stop
    Assert-Test "TC08" "Student accessing /admin/dashboard directly is rejected with 403" $false "Returned HTTP 200 unexpectedly"
} catch {
    $resp = $_.Exception.Response
    $code = if ($resp) { [int]$resp.StatusCode } else { 0 }
    Assert-Test "TC08" "Student accessing /admin/dashboard directly is rejected with 403 Forbidden" ($code -eq 403) "Received status code: $code"
}

# 4. TC09: Staff attempting to access Admin route receives HTTP 403 Forbidden
$staffSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$staffLogin = @{
    email = "it.staff@campusflow.edu"
    password = "Staff@123"
}
try {
    Invoke-WebRequest -Uri "$BASE_URL/login" -Method POST -Body $staffLogin -WebSession $staffSession -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
    $staffAdminAccess = Invoke-WebRequest -Uri "$BASE_URL/admin/users" -WebSession $staffSession -UseBasicParsing -ErrorAction Stop
    Assert-Test "TC09" "Staff accessing /admin/users directly is rejected with 403" $false "Returned HTTP 200 unexpectedly"
} catch {
    $resp = $_.Exception.Response
    $code = if ($resp) { [int]$resp.StatusCode } else { 0 }
    Assert-Test "TC09" "Staff accessing /admin/users directly is rejected with 403 Forbidden" ($code -eq 403) "Received status code: $code"
}

# 5. TC31: CSRF Protection - State-changing POST without CSRF token is rejected with 403 Forbidden
$adminSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$adminLogin = @{
    email = "admin@campusflow.edu"
    password = "Admin@123"
}
try {
    Invoke-WebRequest -Uri "$BASE_URL/login" -Method POST -Body $adminLogin -WebSession $adminSession -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
    
    # Attempt POST to /admin/departments without csrfToken parameter
    $badPost = @{
        action = "CREATE"
        departmentName = "Unauthorized CSRF Dept"
    }
    Invoke-WebRequest -Uri "$BASE_URL/admin/departments" -Method POST -Body $badPost -WebSession $adminSession -UseBasicParsing -ErrorAction Stop
    Assert-Test "TC31" "State-changing POST without CSRF token is rejected" $false "Request was permitted without CSRF token"
} catch {
    $resp = $_.Exception.Response
    $code = if ($resp) { [int]$resp.StatusCode } else { 0 }
    Assert-Test "TC31" "State-changing POST without CSRF token is rejected with 403 Forbidden" ($code -eq 403) "Received code: $code"
}

# 6. TC06: Logout invalidates session
try {
    Invoke-WebRequest -Uri "$BASE_URL/logout" -WebSession $studentSession -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
    # Try accessing student dashboard again with invalidated session
    $postLogout = Invoke-WebRequest -Uri "$BASE_URL/student/dashboard" -WebSession $studentSession -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
    $postStatus = $postLogout.StatusCode
    $postLoc = $postLogout.Headers["Location"]
    Assert-Test "TC06" "Logout invalidates session and subsequent access redirects to login" ($postStatus -eq 302 -and $postLoc -match "login") "Status: $postStatus, Location: $postLoc"
} catch {
    $resp = $_.Exception.Response
    $postStatus = [int]$resp.StatusCode
    $postLoc = $resp.Headers["Location"]
    Assert-Test "TC06" "Logout invalidates session and subsequent access redirects to login" ($postStatus -eq 302 -and $postLoc -match "login") "Status: $postStatus, Location: $postLoc"
}

if (-not $env:JAVA_HOME) { $env:JAVA_HOME = "C:\Program Files\Java\jdk-17.0.19" }
$dbCheck = & "$env:JAVA_HOME\bin\java.exe" -cp "D:\fsd2-project\src\main\webapp\WEB-INF\classes;C:\oraclexe\app\oracle\product\10.2.0\server\jdbc\lib\ojdbc14.jar;C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\servlet-api.jar" com.campusflow.config.DBConnection
Assert-Test "TC35" "Persistent records remain intact in Oracle Database" ($dbCheck -match "SUCCESS") "DB Check Output: $dbCheck"

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "HTTP SECURITY TEST RESULTS: $passed PASSED, $failed FAILED (TOTAL $($passed + $failed))" -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 }
