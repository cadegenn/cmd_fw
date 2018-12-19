@echo off
rem
rem this script gather useful information from an offline OFFLINE_Windows OS
rem
rem 2014.08.26, DCA
rem /!\ DO NOT ENABLE THESE OPTIONS
rem these options hav to be enabled in the caller script
rem setlocal enabledelayedexpansion enableextensions
rem VERSION of file is of the form YYYYmmdd.## where
rem YYYY is the current year using 4 digits
rem mm is the current month using 2 digits
rem dd is the current day of month using 2 digits
rem ## is the revision number within the same day (starting at 0)
rem it HAVE TO be updated with each single modification
set VERSION=20150505.01
rem 
rem Copyright (C) 2015  Charles-Antoine Degennes <cadegenn@gmail.com>
rem 
rem This file is part of api.cmd
rem 
rem     api.cmd is free software: you can redistribute it and/or modify
rem     it under the terms of the GNU General Public License as published by
rem     the Free Software Foundation, either version 3 of the License, or
rem     (at your option) any later version.
rem 
rem     api.cmd is distributed in the hope that it will be useful,
rem     but WITHOUT ANY WARRANTY; without even the implied warranty of
rem     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem     GNU General Public License for more details.
rem 
rem     You should have received a copy of the GNU General Public License
rem     along with api.cmd.  If not, see <http://www.gnu.org/licenses/>.
rem 
rem HOW TO USE
rem ==========
rem 
rem call %DIRNAME%\windows.cmd X:\Path\To\Windows\Folder
rem
rem Changelog
rem =========
rem 2015.05.05, DCA -	1st version from windows.cmd
rem

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem calcul de la variable API_PATH
rem
set API_PATH=%~dp0
IF %API_PATH:~-1%==\ set API_PATH=%API_PATH:~0,-1%

call "%API_PATH%\api.cmd" :ebegin #include %0 - BEGIN

if "%1" == "" (
    call "%API_PATH%\api.cmd" :eerror Missing argument. Give full path to windows folder:
	call "%API_PATH%\api.cmd" :eerror e.g. call %0 x:\windows
	goto :end
)
set TARGET=%1
call "%API_PATH%\api.cmd" :edebug TARGET = %TARGET%
if NOT exist %TARGET% (
    call "%API_PATH%\api.cmd" :eerror '%TARGET%' not found. aborting
    goto :end
)
if NOT exist %TARGET%\system32 (
    call "%API_PATH%\api.cmd" :eerror '%TARGET%' does not contains system32 folder. Give full path to windows folder: e.g. call %0 x:\windows
    goto :end
)

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem load registry hives
set KEY=%TARGET:\=_%
set KEY=%KEY::=%
call "%API_PATH%\api.cmd" :edebug KEY = %KEY%
call "%API_PATH%\api.cmd" :eexec reg load HKLM\%KEY%_SOFTWARE "%TARGET%\system32\config\SOFTWARE"
call "%API_PATH%\api.cmd" :eexec reg load HKLM\%KEY%_SYSTEM "%TARGET%\system32\config\SYSTEM"

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem d‚tection du CurrentControlSet
rem
for /f "tokens=1,2*" %%a in ('reg query "HKLM\%KEY%_SYSTEM\Select" /v "Current"') do set OFFLINE_CONTROLSET=%%c
rem call "%API_PATH%\api.cmd" :edebug OFFLINE_CONTROLSET = %OFFLINE_CONTROLSET%
set OFFLINE_CONTROLSET=%OFFLINE_CONTROLSET:~2,1%
rem call "%API_PATH%\api.cmd" :edebug OFFLINE_CONTROLSET = %OFFLINE_CONTROLSET%
set OFFLINE_CurrentControlSet=ControlSet00%OFFLINE_CONTROLSET%
rem call "%API_PATH%\api.cmd" :edebug OFFLINE_CurrentControlSet = %OFFLINE_CurrentControlSet%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem d‚tection de l'architecture de l'OS
rem
set OFFLINE_ARCH=x86
for /f "tokens=1,2*" %%a in ('reg query "HKLM\%KEY%_SYSTEM\%OFFLINE_CurrentControlSet%\Control\Session Manager\Environment" /v "PROCESSOR_ARCHITECTURE"') do set OFFLINE_PROCESSOR_ARCHITECTURE=%%c
call "%API_PATH%\api.cmd" :edebug OFFLINE_PROCESSOR_ARCHITECTURE = %OFFLINE_PROCESSOR_ARCHITECTURE%
if "%OFFLINE_PROCESSOR_ARCHITECTURE%" == "AMD64" set OFFLINE_ARCH=x64
rem call "%API_PATH%\api.cmd" :edebug OFFLINE_ARCH = %OFFLINE_ARCH%

rem d‚tection de la phase d'installation de windows
for /f "tokens=1,2*" %%a in ('reg query "HKLM\%KEY%_SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State" /v "ImageState"') do set OFFLINE_WindowsState=%%c
rem call "%API_PATH%\api.cmd" :edebug OFFLINE_WindowsState = %OFFLINE_WindowsState%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem D‚tection de la version de Windows
rem
for /f "tokens=1,2*" %%i in ('reg query "HKLM\%KEY%_SOFTWARE\Microsoft\Windows NT\CurrentVersion" ^| find "REG_SZ"') do set OFFLINE_Windows_%%i=%%k
for /f "tokens=1,2*" %%i in ('reg query "HKLM\%KEY%_SOFTWARE\Microsoft\Windows NT\CurrentVersion" ^| find "REG_DWORD"') do set /a OFFLINE_Windows_%%i=%%k
if "%OFFLINE_Windows_CurrentVersion%"=="5.1" set OFFLINE_Windows_OsVer=xp
if "%OFFLINE_Windows_CurrentVersion%"=="5.2" set OFFLINE_Windows_OsVer=2003
if "%OFFLINE_Windows_CurrentVersion%"=="6.0" set OFFLINE_Windows_OsVer=vista
if "%OFFLINE_Windows_CurrentVersion%"=="6.1" set OFFLINE_Windows_OsVer=7
if "%OFFLINE_Windows_CurrentVersion%"=="6.2" set OFFLINE_Windows_OsVer=8
if "%OFFLINE_Windows_CurrentVersion%"=="6.3" set OFFLINE_Windows_OsVer=8.1
rem windows 10 have another versionning system : CurrentVersion is still 6.3, but 2 new registry values appears : CurrentMajorVersionNumber and CurrentMinorVersionNumber. Let's use it
if DEFINED OFFLINE_Windows_CurrentMajorVersionNumber (
    if %OFFLINE_Windows_CurrentMinorVersionNumber% GTR 0 (
        set OFFLINE_Windows_OsVer=%OFFLINE_Windows_CurrentMajorVersionNumber%.%OFFLINE_Windows_CurrentMinorVersionNumber%
    ) else (
        set OFFLINE_Windows_OsVer=%OFFLINE_Windows_CurrentMajorVersionNumber%
    )
)
set OFFLINE_Windows_ShortProductName=%OFFLINE_Windows_ProductName%
set OFFLINE_Windows_ShortProductName=%OFFLINE_Windows_ShortProductName: =%
set OFFLINE_Windows_ShortProductName=%OFFLINE_Windows_ShortProductName:.=%
if "%OFFLINE_Windows_InstallationType%" == "WindowsPE" (
    set OFFLINE_Windows_ShortProductName=WinPE%OFFLINE_Windows_OsVer%
    for /f "tokens=1,2*" %%i in ('reg query "HKLM\%KEY%_SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE" /v Version') do set OFFLINE_WinPE_Version=%%k
)
for /f "tokens=1,2* delims==" %%i in ('set OFFLINE') do call "%API_PATH%\api.cmd" :edebug %%i = %%j

:end
call "%API_PATH%\api.cmd" :eexec reg unload HKLM\%KEY%_SOFTWARE
call "%API_PATH%\api.cmd" :eexec reg unload HKLM\%KEY%_SYSTEM
call %API_PATH%\api.cmd :ebegin #include %0 - END

