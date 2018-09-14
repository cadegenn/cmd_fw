@echo off
setlocal EnableDelayedExpansion

rem
rem @file cmdfw_init.cmd
rem @project cmd_fw
rem @author Charles-Antoine Degennes (cadegenn@gmail.com)
rem @date 2018.09.11
rem @copyright (c) 2018 Charles-Antoine Degennes
rem 
rem @modified 
rem @modifiedby 
rem 
rem This file is part of Tiny %COMSPEC% Framework
rem 
rem        Tiny %COMSPEC% Framework is free software: you can redistribute it and/or modify
rem        it under the terms of the GNU General Public License as published by
rem        the Free Software Foundation, either version 3 of the License, or
rem        (at your option) any later version.
rem 
rem        Tiny %COMSPEC% Framework is distributed in the hope that it will be useful,
rem        but WITHOUT ANY WARRANTY; without even the implied warranty of
rem        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem        GNU General Public License for more details.
rem 
rem        You should have received a copy of the GNU General Public License
rem        along with Tiny %COMSPEC% Framework.  If not, see <http://www.gnu.org/licenses/>.
rem 
rem

rem @param  (string)    Path to cmd_fw installation ($INSDIR when called from installer)
set INSTDIR=%1
if not defined INSTDIR set INSTDIR=%TEMP%

rem initialize window title
title %0

rem compute DIRNAME
set DIRNAME=%~dp0
rem strip trailing bask-slash
if %DIRNAME:~-1%==\ set DIRNAME=%DIRNAME:~0,-1%
set BASENAME=%~nx0

set QUIET=
set DEBUG=
set DEVEL=
set YES=
set CMDFW_PATH=

rem check instal directory
for /F "tokens=2*" %%u in ('reg query HKLM\SOFTWARE\cmd_fw /v InstallDir ^| find "REG_"') do set CMDFW_PATH=%%v
REM echo %CMDFW_PATH%

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem 
rem BEGIN parsing command line
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::
:begin-args-loop
if x%1 == x goto end-args-loop
if %1 == -h goto arg_help
if %1 == -y goto arg_yes
if %1 == -q goto arg_quiet
if %1 == -d goto arg_debug
if %1 == -dev goto arg_devel
if %1 == -api goto arg_api
if %1 == -instdir goto arg_instdir
goto arg_help

:arg_instdir
shift
set INSTDIR=%~1
if not exist "%INSTDIR%" (
    echo  * ERR: Installation directory "%INSTDIR%" not found. Aborting.
    goto :end
)
goto arg_end

:arg_yes
set YES=true
goto arg_end

:arg_quiet
set DEBUG=
set DEVEL=
set QUIET=true
goto arg_end

:arg_debug
set DEBUG=true
goto arg_end

:arg_devel
set DEBUG=true
set DEVEL=true
goto arg_end

:arg_api
shift
set CMDFW_PATH=%1
if not exist "%CMDFW_PATH%\lib\api.cmd" set CMDFW_PATH=
goto arg_end

:arg_help
echo DESCRIPTION: %BASENAME% do some things
echo USAGE: %BASENAME% [-q] [-d] [-dev] [-h] [-y]
echo    -q          quiet: do not print anything
echo    -d          debug mode: print VARIABLE=value pairs
echo    -dev        devel mode: print additional development data
echo    -h          help screen (this screen^)
echo    -y          assume 'yes' to all questions
goto :EOF

:arg_unknown
echo  * ERR: Unknown argument : %1
goto arg_help

:arg_end
shift
goto begin-args-loop
:end-args-loop
rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem END parsing command line
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

rem CMDFW_PATH : if not found, assume we are running bundled script (script + framework)
if not defined CMDFW_PATH set CMDFW_PATH=%DIRNAME%
if not exist "%CMDFW_PATH%\lib\api.cmd" (
	echo Tiny %%COMSPEC%% Framework not found. Aborting.
	goto :end
)
path "%CMDFW_PATH%\cmd";%PATH%

rem load windows variables
call "%CMDFW_PATH%\lib\api.cmd"
call edevel Using COMSPEC Framework from "%CMDFW_PATH%"

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT GOES HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

if not defined INSTDIR (
    eerror INSTDIR not defined. Please review help with %BASENAME% -h
    goto :end
)


rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem OS Architecture
rem
set ARCH=x86
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" set ARCH=x64
call edevel ARCH = %ARCH%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Folders
rem
rem ProgramFiles 32bits
rem arch x86 : ProgFiles(x86) = c:\Program Files
rem arch x64 : ProgFiles(x86) = C:\Program Files(x86)
set ProgFiles(x86)=%ProgramFiles%
if exist "%ProgramFiles(x86)%" set ProgFiles(x86)=%ProgramFiles(x86)%
rem ProgramFiles 64bits
rem arch x86 : ProgFiles(x64) = c:\Program Files
rem arch x64 : ProgFiles(x64) = C:\Program Files
set ProgFiles(x64)=%ProgramFiles%
rem if exist "%ProgramFiles(x86)%" set ProgFiles_x64=%ProgramFiles(x86)%
call edevel ProgFiles^(x86^) = %ProgFiles(x86)%
call edevel ProgFiles^(x64^) = %ProgFiles(x64)%

REM for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Programs"') do set CommonPrograms=%%j
REM for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Desktop"') do set CommonDesktop=%%j
REM for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Startup"') do set CommonStartup=%%j
REM for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common AppData"') do set CommonAppData=%%j
REM for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Documents"') do set CommonDocuments=%%j
REM for /f "tokens=1,2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State" ^| find "REG_SZ"') do set Windows_%%i=%%k
rem we will try to use a more generic version
rem 1st pass, extract all values from registry, replace REG_* with an arbitratry one-char separator
set SEP=/
del /q "%TEMP%\shellfolders.txt"
for /f "tokens=*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" ^| find "REG_SZ"') do (
    set "line=%%i"
    echo !line:    REG_SZ    =%SEP%!
) >> "%TEMP%\shellfolders.txt"
for /f "tokens=*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" ^| find "REG_DWORD"') do (
    set "line=%%i"
    echo !line:    REG_DWORD    =%SEP%!
) >> "%TEMP%\shellfolders.txt"
type "%TEMP%\shellfolders.txt"
rem second pass, use %SEP% to correctly separate fields
for /f "tokens=1* delims=%SEP%" %%i in ('type "%TEMP%\shellfolders.txt"') do (
    rem remove spaces from key name
    set keytmp=%%i
    set key=!keytmp: =!
    REM call edevel !key! - %%j
    call set !key!=%%j
)

set UsersDir=%SystemDrive%\Documents and settings
if exist "%SystemDrive%\Users" set UsersDir=%SystemDrive%\Users
call edevel UsersDir = %UsersDir%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Registry
rem
rem HKLM_SOFTWARE
set HKLM_SOFTWARE(x86)=HKLM\Software
if "%ARCH%" == "x64" set HKLM_SOFTWARE(x86)=%HKLM_SOFTWARE(x86)%\Wow6432Node
set HKLM_SOFTWARE(x64)=HKLM\Software
call edevel HKLM_SOFTWARE^(x86^) = %HKLM_SOFTWARE(x86)%
call edevel HKLM_SOFTWARE^(x64^) = %HKLM_SOFTWARE(x64)%
rem HKLM_UNINSTALL
set HKLM_UNINSTALL(x86)=%HKLM_SOFTWARE(x86)%\Microsoft\Windows\CurrentVersion\Uninstall
set HKLM_UNINSTALL(x64)=%HKLM_SOFTWARE(x64)%\Microsoft\Windows\CurrentVersion\Uninstall
call edevel HKLM_UNINSTALL^(x86^) = %HKLM_UNINSTALL(x86)%
call edevel HKLM_UNINSTALL^(x64^) = %HKLM_UNINSTALL(x64)%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Windows version
rem
for /f "tokens=1,2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" ^| find "REG_SZ"') do set Windows_%%i=%%k
for /f "tokens=1,2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" ^| find "REG_DWORD"') do set /a Windows_%%i=%%k
if "%Windows_InstallationType%" == "Server" goto :getWindowsServerOsVer
if "%Windows_InstallationType%" == "Client" goto :getWindowsClientOsVer
if "%Windows_InstallationType%" == "WindowsPE" goto :getWindowsPEOsVer
:getWindowsServerOsVer
if "%Windows_CurrentVersion%"=="5.0" set Windows_OsVer=2000
if "%Windows_CurrentVersion%"=="5.2" set Windows_OsVer=2003
if "%Windows_CurrentVersion%"=="6.0" set Windows_OsVer=2008
if "%Windows_CurrentVersion%"=="6.1" set Windows_OsVer=2008r2
if "%Windows_CurrentVersion%"=="6.2" set Windows_OsVer=2012
if "%Windows_CurrentVersion%"=="6.3" set Windows_OsVer=2012r2
goto :continue

:getWindowsClientOsVer
if "%Windows_CurrentVersion%"=="5.0" set Windows_OsVer=2000
if "%Windows_CurrentVersion%"=="5.1" set Windows_OsVer=XP
if "%Windows_CurrentVersion%"=="5.2" set Windows_OsVer=XP64
if "%Windows_CurrentVersion%"=="6.0" set Windows_OsVer=Vista
if "%Windows_CurrentVersion%"=="6.1" set Windows_OsVer=7
if "%Windows_CurrentVersion%"=="6.2" set Windows_OsVer=8
if "%Windows_CurrentVersion%"=="6.3" set Windows_OsVer=8.1
goto :continue

:getWindowsPEOsVer
if "%Windows_CurrentVersion%"=="5.1" set Windows_OsVer=2
if "%Windows_CurrentVersion%"=="5.2" set Windows_OsVer=2
if "%Windows_CurrentVersion%"=="6.0" set Windows_OsVer=3
if "%Windows_CurrentVersion%"=="6.1" set Windows_OsVer=4
if "%Windows_CurrentVersion%"=="6.2" set Windows_OsVer=5
if "%Windows_CurrentVersion%"=="6.3" set Windows_OsVer=5.1
goto :continue

:continue
rem windows 10 have another versionning system : CurrentVersion is still 6.3, but 2 new registry values appears : CurrentMajorVersionNumber and CurrentMinorVersionNumber. Let's use it
if DEFINED Windows_CurrentMajorVersionNumber (
rem Nobody use Windows_CurrentMinorVersionNumber, even Microsoft
rem    if DEFINED Windows_CurrentMinorVersionNumber (
rem        set Windows_OsVer=%Windows_CurrentMajorVersionNumber%.%Windows_CurrentMinorVersionNumber%
rem    ) else (
        set Windows_OsVer=%Windows_CurrentMajorVersionNumber%
    )
)
set Windows_ShortProductName=%Windows_ProductName%
set Windows_ShortProductName=%Windows_ShortProductName: =%
set Windows_ShortProductName=%Windows_ShortProductName:.=%
if "%Windows_InstallationType%" == "WindowsPE" (
    set Windows_ShortProductName=WinPE%Windows_OsVer%
    for /f "tokens=1,2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE" /v Version') do set WinPE_Version=%%k
)
for /f "tokens=1,2* delims==" %%i in ('set Windows_') do call edebug %%i = %%j

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Computer
rem
for /f "tokens=1*" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine" /v "Distinguished-Name" ^| findstr REG_SZ') do set ComputerDN=%%w
set ComputerOU=%ComputerDN:*,OU=OU%

rem found some simple solution here @url http://www.robvanderwoude.com/wmic.php (thank you guy !!)
rem
for /f "tokens=*" %%i in ('wmic bios get manufacturer^,serialnumber /value ^| find "="') do set BIOS_%%i
REM for /f "tokens=*" %%i in ('wmic bios get manufacturer^,serialnumber /value ^| find "="') do (
REM     REM set "value=BIOS_%%i"
REM     REM set !value:~0,-1%!
REM )
for /f "tokens=*" %%i in ('wmic computersystem get model /value ^| find "="') do set BIOS_%%i
for /f "tokens=1,2* delims==" %%i in ('set BIOS') do (
    set key=%%i
    set value=%%j
    REM remove extra CR
    set !key!=!value:~0,-1!
    REM call edebug %%i = %%j
    call edevel !key! = !value:~0,-1!
)

rem finally write down everything to an include file.
mkdir "%INSTDIR%\includes"
> "%INSTDIR%\includes\globals.cmd" (
    @echo @echo off
    for /f "tokens=1,2* delims==" %%i in ('set ARCH') do @echo set %%i=%%j
    for /f "tokens=1,2* delims==" %%i in ('set Common') do @echo set %%i=%%j
    for /f "tokens=1,2* delims==" %%i in ('set UsersDir') do @echo set %%i=%%j
    for /f "tokens=1,2* delims==" %%i in ('set ProgFiles') do @echo set %%i=%%j
    for /f "tokens=1,2* delims==" %%i in ('set HKLM') do @echo set %%i=%%j
    for /f "tokens=1,2* delims==" %%i in ('set Windows_') do @echo set %%i=%%j
    for /f "tokens=1,2* delims==" %%i in ('set WinPE') do @echo set %%i=%%j
    for /f "tokens=1,2* delims==" %%i in ('set BIOS') do @echo set %%i=%%j
)

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT END HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

:end
rem reset window title
title %COMSPEC%

