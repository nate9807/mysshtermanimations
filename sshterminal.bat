@echo off
echo Setting up SSH directory and checking for sshconnector.py...

REM Set target directory and server details
set DEST_DIR=C:\ProgramData\ssh
set SERVER=root@68.45.208.166
set SOURCE_PATH=/root/
set FILE=sshconnector.py

REM Check if sshconnector.py exists in C:\ProgramData\ssh
if not exist "%DEST_DIR%\%FILE%" (
    echo sshconnector.py not found. Admin privileges required for directory creation or download...
    REM Check if running as Administrator
    net session >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Requesting Administrator privileges...
        REM Create a temporary VBScript to relaunch as Admin
        echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\elevate.vbs"
        echo UAC.ShellExecute "cmd.exe", "/c ""%~f0""", "", "runas", 1 >> "%TEMP%\elevate.vbs"
        cscript //nologo "%TEMP%\elevate.vbs"
        del "%TEMP%\elevate.vbs"
        exit /b
    )
    REM If we reach here, we're running as Admin
    echo Running with Admin privileges...

    REM Create the ssh directory if it doesn't exist
    if not exist "%DEST_DIR%" (
        echo Creating directory %DEST_DIR%...
        mkdir "%DEST_DIR%"
        if %ERRORLEVEL% NEQ 0 (
            echo Failed to create directory. Check permissions.
            goto :error
        )
    )

    echo Downloading sshconnector.py from server...
    scp %SERVER%:%SOURCE_PATH%%FILE% %DEST_DIR%\
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to download sshconnector.py. Check server connection or credentials.
        goto :error
    )
    REM Brief delay to ensure file write completes, then verify
    timeout /t 2 /nobreak >nul
    if not exist "%DEST_DIR%\%FILE%" (
        echo Download command ran, but sshconnector.py is still missing.
        goto :error
    )
) else (
    echo sshconnector.py already exists. No Admin privileges needed.
)

REM Change to the directory and run the Python script (no Admin required here)
echo File present. Running Python script...
cd /d "%DEST_DIR%"
python "%FILE%"

if %ERRORLEVEL% EQU 0 (
    echo Script executed successfully!
) else (
    echo Error running Python script.
    goto :error
)

goto :end

:error
echo Process failed. Check error messages above.
pause
exit /b 1

:end
echo Process completed.
pause
exit /b 0