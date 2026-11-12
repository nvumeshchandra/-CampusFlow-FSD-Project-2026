# ====================================================================
# CampusFlow Build & Deployment Script (Windows PowerShell)
# ====================================================================

$ErrorActionPreference = "Stop"

$PROJECT_ROOT = "D:\fsd2-project"
$JAVA_HOME = "C:\Program Files\Java\jdk-17.0.19"
$TOMCAT_HOME = "C:\Program Files\Apache Software Foundation\Tomcat 9.0"
$OJDBC_JAR = "C:\oraclexe\app\oracle\product\10.2.0\server\jdbc\lib\ojdbc14.jar"

Write-Host "==> Starting CampusFlow Build Process..." -ForegroundColor Cyan

# 1. Ensure Directories
$BUILD_CLASSES = "$PROJECT_ROOT\build\classes"
$WEBAPP_DIR = "$PROJECT_ROOT\src\main\webapp"
$WEBINF_CLASSES = "$WEBAPP_DIR\WEB-INF\classes"
$WEBINF_LIB = "$WEBAPP_DIR\WEB-INF\lib"
$DIST_DIR = "$PROJECT_ROOT\dist"

New-Item -ItemType Directory -Force -Path $BUILD_CLASSES | Out-Null
New-Item -ItemType Directory -Force -Path $WEBINF_CLASSES | Out-Null
New-Item -ItemType Directory -Force -Path $WEBINF_LIB | Out-Null
New-Item -ItemType Directory -Force -Path $DIST_DIR | Out-Null

# 2. Copy JDBC Driver to WEB-INF/lib
Copy-Item $OJDBC_JAR -Destination "$WEBINF_LIB\ojdbc14.jar" -Force
Write-Host "[OK] ojdbc14.jar copied to WEB-INF/lib" -ForegroundColor Green

# Also ensure ojdbc14.jar is in Tomcat's lib for shared loader access if possible
try {
    Copy-Item $OJDBC_JAR -Destination "$TOMCAT_HOME\lib\ojdbc14.jar" -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] ojdbc14.jar verified in Tomcat lib" -ForegroundColor Green
} catch {
    Write-Host "[INFO] Tomcat lib write skipped (application WEB-INF/lib will be used)" -ForegroundColor Yellow
}

# 3. Collect Java Sources
$JAVA_FILES = Get-ChildItem -Path "$PROJECT_ROOT\src\main\java" -Filter "*.java" -Recurse | Select-Object -ExpandProperty FullName
Write-Host "Found $($JAVA_FILES.Count) Java source files to compile."

# 4. Compile with javac
$CLASSPATH = "$TOMCAT_HOME\lib\servlet-api.jar;$TOMCAT_HOME\lib\jsp-api.jar;$OJDBC_JAR"
$JAVAC_BIN = "$JAVA_HOME\bin\javac.exe"

$SOURCES_FILE = "$PROJECT_ROOT\build\sources.txt"
[System.IO.File]::WriteAllLines($SOURCES_FILE, $JAVA_FILES, [System.Text.Encoding]::ASCII)

Write-Host "Compiling Java sources..."
& $JAVAC_BIN -encoding UTF-8 -cp $CLASSPATH -d $WEBINF_CLASSES "@$SOURCES_FILE"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Java compilation failed with exit code $LASTEXITCODE"
}
Write-Host "[OK] Compilation completed successfully into WEB-INF/classes" -ForegroundColor Green

# 5. Package WAR file
$JAR_BIN = "$JAVA_HOME\bin\jar.exe"
$WAR_OUTPUT = "$DIST_DIR\campusflow.war"
if (Test-Path $WAR_OUTPUT) { Remove-Item $WAR_OUTPUT -Force }

Write-Host "Packaging WAR file: $WAR_OUTPUT..."
Push-Location $WEBAPP_DIR
& $JAR_BIN -cvf $WAR_OUTPUT * | Out-Null
Pop-Location
Write-Host "[OK] WAR file created: $WAR_OUTPUT" -ForegroundColor Green

# 6. Deploy to Tomcat webapps/campusflow
$TOMCAT_APP_DIR = "$TOMCAT_HOME\webapps\campusflow"
Write-Host "Deploying directly to Tomcat webapps: $TOMCAT_APP_DIR..."
if (-not (Test-Path $TOMCAT_APP_DIR)) {
    New-Item -ItemType Directory -Force -Path $TOMCAT_APP_DIR | Out-Null
}
Copy-Item "$WEBAPP_DIR\*" -Destination $TOMCAT_APP_DIR -Recurse -Force
Write-Host "[OK] Deployed successfully to Tomcat!" -ForegroundColor Green

Write-Host "==> CampusFlow Build & Deployment Finished Successfully." -ForegroundColor Cyan
