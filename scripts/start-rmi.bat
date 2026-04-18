@echo off
setlocal EnableDelayedExpansion

set "ROOT=%~dp0.."
set "BUILD_DIR=%ROOT%\build"
set "CLASSES_DIR=%BUILD_DIR%\classes"
set "SOURCES_FILE=%BUILD_DIR%\sources.txt"
set "JAVA_EXE="
set "JAVAC_EXE="

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%CLASSES_DIR%" mkdir "%CLASSES_DIR%"

if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" (
	set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"
	set "JAVAC_EXE=%JAVA_HOME%\bin\javac.exe"
)

if not defined JAVA_EXE (
	for %%i in (java.exe) do set "JAVA_EXE=%%~$PATH:i"
)

if not defined JAVA_EXE (
	echo ERROR: Java runtime not found in PATH and JAVA_HOME is not set.
	exit /b 1
)

if not defined JAVAC_EXE (
	for %%i in (javac.exe) do set "JAVAC_EXE=%%~$PATH:i"
)

if not defined JAVAC_EXE (
	echo ERROR: Java compiler not found in PATH and JAVA_HOME is not set.
	exit /b 1
)

for %%p in ("%JAVA_EXE%") do set "JAVA_BIN=%%~dpp"
if exist "%JAVA_BIN%javac.exe" set "JAVAC_EXE=%JAVA_BIN%javac.exe"

echo Using Java runtime: %JAVA_EXE%
echo Using Java compiler: %JAVAC_EXE%
"%JAVA_EXE%" -version

echo Cleaning previous compiled classes...
if exist "%CLASSES_DIR%" rmdir /s /q "%CLASSES_DIR%"
mkdir "%CLASSES_DIR%"

echo Collecting Java sources...
type nul > "%SOURCES_FILE%"
for /r "%ROOT%\src" %%f in (*.java) do (
	set "JAVA_FILE=%%f"
	set "JAVA_FILE=!JAVA_FILE:\=/!"
	echo "!JAVA_FILE!" >> "%SOURCES_FILE%"
)

echo Compiling project classes...
"%JAVAC_EXE%" -source 1.8 -target 1.8 -cp "%ROOT%\WebContent\WEB-INF\lib\*" -d "%CLASSES_DIR%" @"%SOURCES_FILE%"
if errorlevel 1 (
	echo Compilation failed. Please fix compile errors and retry.
	exit /b 1
)

echo Starting RMI server...
"%JAVA_EXE%" -cp "%CLASSES_DIR%;%ROOT%\WebContent\WEB-INF\lib\*" com.college.rmi.RMIServer
