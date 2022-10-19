@echo off
setlocal enabledelayedexpansion
goto :detect

:detect
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
set "disk=0"
for /f "tokens=1-2 delims= " %%A in (
   '^(echo list disk^)^|diskpart^|findstr /ic:"Online"'
) do (
   for /f "tokens=1-3 delims= " %%X in (
      '^(echo select disk %%B^&echo detail disk^)^|diskpart^|findstr /ic:"Removable"'
   ) do (
      set /a disk+=1
      set "vol!disk!=%%B_%%Z:"
   )
)

echo.
echo Detected %disk% Removable Drive(s):
echo.
if %disk% equ 0 echo    No drives found.
for /l %%X in (1,1,%disk%) do (
   echo     %%X. Drive !vol%%X:~2,2!
)
echo.

:choice
set /p "choice=Choose a number: "
if !choice! geq 1 if !choice! leq %disk% goto :main
goto :choice


:main
echo.
set "disknum=!vol%choice%:~0,1!"
for /f "tokens=1-2 delims=:" %%F in (
   '^(echo select disk %disknum%^&echo attribute disk^)^|diskpart^|findstr /bic:"Read-Only"'
) do (
   set "readonly_state=%%G"&set "readonly_state=!readonly_state: =!"
)
if /i "%readonly_state%" equ "No" (
   (echo select disk %disknum%&echo attribute disk set readonly)|diskpart >nul
   echo Drive !vol%choice%:~2,2! is now Read-Only - Locked.
) else (
   (echo select disk %disknum%&echo attribute disk clear readonly)|diskpart >nul
   echo Drive !vol%choice%:~2,2! is now Read/Write - Unlocked.
)
echo.
endlocal
pause
exit