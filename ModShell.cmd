@ECHO OFF
IF "%1"=="START" GOTO :START
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
SET current_project=None
PROMPT $C Current$SProject:$S!current_project! $F$_$C$P$F$_$G$S
START "" /MAX CMD /E:ON /V:ON /K "%~0" START
EXIT 

:START
SET PATH=%PATH%;%CD%\~ModShell
:: TODO: Enforce that mod names do NOT have a ! character
COLOR 07
TITLE ModShell
::MODE 100,40
MODE CON:cols=100 lines=1000
CALL :INIT
BG PRINT F "-------------------------------\n"
BG PRINT F "--    ModShell v0.1 Alpha    --\n"
BG PRINT F "-------------------------------\n"
echo.
CALL :echoTask 0 "Scanning for Forge projects... \n"
FOR /D %%D IN (*.*) DO (
    IF EXIST %%D\build.gradle (
        BG PRINT A "    [i] " F "%%D " 7 "found \n"
    )
)
echo.
echo.
BG PRINT A "[i] " F "ModShell ready^! Type 'help' for global command list.\n"
::PROMPT $CCurrent$SProject:$S!current_project!$F$_$C$P$F$_$G$S
::pause
::CMD /E:ON /F:ON /V:ON /K

GOTO :EOF

:INIT
CALL :echoTask 0 "Checking environment sanity...\n"
::::::::::::::::::::::
:: Create empty config file if required
::::::::::::::::::::::
IF NOT EXIST "%~dp0\ModShell.ini" (
    BG PRINT "" > "%~dp0\ModShell.ini"
)
SET SETTINGS="%~dp0\ModShell.ini"
::::::::::::::::::::::
:: Check for 64-bit
::::::::::::::::::::::
IF DEFINED ProgramFiles(x86) (
    CALL :echoInfo 1 "64-bit detected"
) ELSE (
    CALL :echoInfo 1 "32-bit detected"
    CALL :echoError 1 "Sorry, 32-bit is not currently supported."
    CALL :echoBlank 1 "Press any key to quit."
    pause>nul
    exit
)
::::::::::::::::::::::
:: Check JDK versions
::::::::::::::::::::::
CALL :echoTask 1 "Searching for installed JDK's...\n"
FOR /F "skip=2 tokens=2*" %%A IN ('REG QUERY "HKLM\Software\JavaSoft\Java Development Kit\1.7" /v JavaHome') DO (
    SET JAVA_17_PATH=%%B
    CALL :echoInfo 2 "JDK 1.7 found at '!JAVA_17_PATH:\=\\!'"
)
FOR /F "skip=2 tokens=2*" %%A IN ('REG QUERY "HKLM\Software\JavaSoft\Java Development Kit\1.8" /v JavaHome') DO (
    SET JAVA_18_PATH=%%B
    CALL :echoInfo 2 "JDK 1.8 found at '!JAVA_18_PATH:\=\\!'"
)
IF NOT DEFINED JAVA_17_PATH (
    CALL :echoWarn 2 "JDK 1.7 not installed"
)
IF NOT DEFINED JAVA_18_PATH (
    CALL :echoWarn 2 "JDK 1.8 not installed"
)
IF NOT DEFINED JAVA_17_PATH (
    IF NOT DEFINED JAVA_18_PATH (
        CALL :echoError 2 "No JDK installation found"
        CALL :echoBlank 2 "Your PC has no JDK installed. Install either JDK 1.7 [if using Forge for 1.7.10]"
        CALL :echoBlank 2 "and/or JDK 1.8 [if using Forge for 1.8] and start ModShell again."
        echo.
        CALL :echoBlank 2 "Restarting your computer is *not* required."
        echo.
        CALL :echoBlank 2 "Press any key to quit."
        pause>nul
        exit
    )
)
GOTO :EOF
::::::::::::::::::::::
:: Check for Git installation
::::::::::::::::::::::
CALL :echoTask 1 "Searching for Git installation...\n"
FOR /F "delims=" %%A IN ('findexe git') DO (
    SET GIT_PATH=%%A
)
IF DEFINED GIT_PATH (
    CALL :echoInfo 2 "Git found at '!GIT_PATH:\=\\!' - Git integration enabled."
) ELSE (
    CALL :echoWarn 2 "Git installation not found - Git integration disabled."
)
::::::::::::::::::::::
:: Check for Eclipse installation
::::::::::::::::::::::
CALL :echoTask 1 "Checking for Eclipse installation...\n"
FOR /F "delims=" %%A IN ('Inifile !SETTINGS! [eclipse] eclipse_path') DO %%A
IF "!eclipse_path!"=="" (
    CALL :echoWarn 2 "Not set. Showing folder browser to set Eclipse directory..."
    FOR /F "delims=" %%A IN ('wfolder2 "set eclipse_path=" "C:\" "Please browse to your Eclipse IDE directory"') DO %%A
    SET eclipse_path=!eclipse_path:"=!
)
IF NOT EXIST "!eclipse_path!\eclipse.exe" (
    CALL :echoError 2 "Eclipse installation not found. Please install Eclipse and restart ModShell."
    CALL :echoBlank 2 "Press any key to quit."
    pause>nul
    exit
) ELSE (
    CALL :echoInfo 2 "Eclipse installation found at '!eclipse_path:\=\\!'"
    Inifile !SETTINGS! [eclipse] eclipse_path=!eclipse_path!
)
echo.
echo.
GOTO :EOF

:echoTask
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO BG PRINT "    "
BG PRINT B "[#] " 7 "%~2"
SET _num=
GOTO :EOF

:echoTaskOk
BG PRINT F " %~1 \n"
GOTO :EOF

:echoInfo
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO BG PRINT "    "
BG PRINT A "[i] " 7 "%~2 \n"
SET _num=
GOTO :EOF

:echoWarn
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO BG PRINT "    "
BG PRINT E "[^!] " 7 "%~2 \n"
SET _num=
GOTO :EOF

:echoError
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO BG PRINT "    "
BG PRINT C "[X] " 7 "%~2 \n"
SET _num=
GOTO :EOF

:echoBlank
SET /A _num=%1-1
FOR /L %%C IN (0,1,!_num!) DO BG PRINT "    "
BG PRINT 7 "    %~2\n"
SET _num=
GOTO :EOF