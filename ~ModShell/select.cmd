@ECHO OFF
IF /I "%~1"=="none" (
    :: special case for deselect
    CALL deselect
    GOTO :EOF
)
ECHO.
IF "%~1"=="" (
    CALL cmds select
) ELSE (
    IF EXIST "%~1\build.gradle" (
        ꞈBG PRINT A "[i] " F "%~1" 7 " selected as current project \n"
        SET _modDir=%~1
        SET _modDirNoSpace=!_modDir: =!
        IF NOT !_modDir!==!_modDirNoSpace! (
            ꞈBG PRINT E "    [^!] " 7 "Mod project has a space in it's directory. This will *VERY* likely cause problems^! \n"
        )
        SET _modDir=
        SET _modDirNoSpace=
        SET current_project=%~1
        PROMPT $C Current$SProject:$S!current_project! $F$_$C$P$F$_$G$S
    ) ELSE (
        IF EXIST "%~1" (
            ꞈBG PRINT C "[X] " F "%~1" 7 " is not a valid Forge mod project. \n"
        ) ELSE (
            ꞈBG PRINT C "[X] " F "%~1" 7 " does not exist. \n"
            ꞈBG PRINT A "[i] " 7 "To create a new mod with this name, type: \n"
            ꞈBG PRINT F "create %~1" \n"
            echo.
        )
    )
)