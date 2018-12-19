@echo off
setlocal enableExtensions enableDelayedExpansion
rem
rem skeleton of script to use with api.cmd
rem

rem VERSION of file is of the form YYYYmmdd.## where
rem YYYY is the current year using 4 digits
rem mm is the current month using 2 digits
rem dd is the current day of month using 2 digits
rem ## is the revision number within the same day (starting at 0)
rem it HAVE TO be updated with each single modification
set VERSION=20160314.1530
rem 
rem Copyright (C) 2015-2016 Charles-Antoine Degennes <cadegenn@gmail.com>
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
rem
rem Changelog
rem =========
rem 2016.03.13, DCA -   add optional parameter -var to specify alternate VARIABLE instead of default PATH
rem 2015.03.23, DCA - 	initial version of script

rem initialise window title
title %0

rem compute DIRNAME
set DIRNAME=%~dp0
if %DIRNAME:~-1%==\ set DIRNAME=%DIRNAME:~0,-1%
set BASENAME=%~nx0

rem on ajoute vite-fait le chemin de ce script au PATH
set PATH=%PATH%;%DIRNAME%

set DEBUG=
set DEVEL=
set YES=
set VARIABLE=

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem 
rem BEGIN parsing command line
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::
:begin-args-loop
if x%1 == x goto end-args-loop
if %1 == -h goto arg_help
if %1 == -y goto arg_yes
if %1 == -d goto arg_debug
if %1 == -dev goto arg_devel
if %1 == -var goto arg_var
goto arg_unknown
goto arg_help

:arg_yes
set YES=true
goto arg_end

:arg_debug
set DEBUG=true
goto arg_end

:arg_devel
set DEBUG=true
set DEVEL=true
goto arg_end

:arg_var
shift
set VARIABLE=%1
goto arg_end

:arg_help
echo DESCRIPTION: %BASENAME% add a path to the PATH environment variable
echo USAGE: %BASENAME% [-d] [-dev] [-h] [-y] [-var VARIABLE] path\to\add\
echo    -d          debug mode: print VARIABLE=value pairs
echo    -dev        devel mode: print additional development data
echo    -h          help screen (this screen^)
echo    -y          assume 'yes' to all questions
echo    -var        specify alternate VARIABLE name instead of default PATH
goto :EOF

:arg_unknown
set "PATH_TO_ADD=%~1"
goto arg_end

:arg_end
shift
goto begin-args-loop
:end-args-loop
rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem END parsing command line
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

rem load windows variables
rem rem call %DIRNAME%\lib\windows.cmd

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT GOES HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

if NOT DEFINED VARIABLE set VARIABLE=PATH
set VALUE=
rem trick for double expansion
set VALUE=!%VARIABLE%!
call "%DIRNAME%\lib\api.cmd" :edebug %VARIABLE% = !VALUE!
call "%DIRNAME%\lib\api.cmd" :edebug PATH_TO_ADD = '%PATH_TO_ADD%'

rem
rem check if path exist
rem use delayed expansion because PATH_TO_ADD may contain parenthesis and thus end the IF block prematurly
if not exist "!PATH_TO_ADD!" (
    call "%DIRNAME%\lib\api.cmd" :eerror Path '!PATH_TO_ADD!' does not exist on current system. Path not added to %VARIABLE% environment variable
    goto :EOF
)

call "%DIRNAME%\lib\api.cmd" :edebug exec regread.cmd "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" %VARIABLE%
for /f "tokens=*" %%p in ('regread.cmd -q "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" %VARIABLE%') do (
    set CURRENT_PATH=%%p
)
call "%DIRNAME%\lib\api.cmd" :edebug CURRENT_PATH = '%CURRENT_PATH%'

rem
rem check if VARIABLE is empty
rem if VARIABLE is empty, the test %CURRENT_PATH% == %PATH_TEST% says true while obviously it is not
if "x!CURRENT_PATH!" == "x" goto :do_add_path
rem
rem check if path is already present
set PATH_TEST=!CURRENT_PATH:%PATH_TO_ADD%=!
call "%DIRNAME%\lib\api.cmd" :edebug PATH_TEST    = '%PATH_TEST%'
if "!CURRENT_PATH!" EQU "!PATH_TEST!" call "%DIRNAME%\lib\api.cmd" :edebug CURRENT_PATH == PATH_TEST
if "!CURRENT_PATH!" NEQ "!PATH_TEST!" call "%DIRNAME%\lib\api.cmd" :edebug CURRENT_PATH =/= PATH_TEST
if not "!CURRENT_PATH!" == "!PATH_TEST!" call "%DIRNAME%\lib\api.cmd" :ewarn Path '%PATH_TO_ADD%' is already present in %VARIABLE% variable
if not "!CURRENT_PATH!" == "!PATH_TEST!" goto :end

:do_add_path
rem add path
set CURRENT_PATH=%CURRENT_PATH%;%PATH_TO_ADD%
rem trim leading and trailing ";"
if "%CURRENT_PATH:~0,1%" == ";" set CURRENT_PATH=%CURRENT_PATH:~1%
if "%CURRENT_PATH:~-1%" == ";" set CURRENT_PATH=%CURRENT_PATH:~0,-1%
rem do not do anything if anything goes wrong
if "x!CURRENT_PATH!" == "x" goto :EOF
call "%DIRNAME%\lib\api.cmd" :eexec reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v %VARIABLE% /d "%CURRENT_PATH%" /f

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT END HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

:end
rem reset window title
title %COMSPEC%

