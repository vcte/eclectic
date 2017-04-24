REM TI Calculator Build Script - Ben Ryves 2005-2006

REM Jump to source directory
CD "%SOURCE_DIR%"

REM Add compiler directory to PATH
SET PATH=%PATH%;"%COMPILE_DIR%"

REM Set up debugger information
SET DEBUG_DEBUGGER="%DEBUG_DIR%/PindurTI/PindurTI Debugger.exe"
SET DEBUG_DEBUGGER_ARGS="%DEBUG_DIR%/PindurTI/ROMs/%PLATFORM%.rom" -d "%DEBUG_LOG%" -s "%PROJECT_DIR%/Build/%BUILD_FILE_NOEXT%.debug" -l

REM Run the assembler
BRASS "%SOURCE_FILE%" "%PROJECT_DIR%/Bin/%PROJECT_NAME% - %BUILD_FILE_NOEXT%.%EXTENSION%" -x -d -l "%PROJECT_DIR%/Bin/%PROJECT_NAME%.htm"
CD "%PROJECT_DIR%/Bin/"
DEL *.inc