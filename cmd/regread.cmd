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
set VERSION=20150401.00
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
rem 2016.03.14, DC1 -   add optional parameter -q to silence everything
rem 2015.03.23, DCA - 	initial version of script

rem initialise window title
title %0

rem compute DIRNAME
set DIRNAME=%~dp0
rem strip trailing bask-slash
if %DIRNAME:~-1%==\ set DIRNAME=%DIRNAME:~0,-1%
set BASENAME=%~nx0

rem ** DEBUG only **
rem echo . DIRNAME = %DIRNAME%
rem echo . BASENAME = %BASENAME%

set QUIET=
set DEBUG=
set DEVEL=
set YES=

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
if %1 == -q goto arg_quiet
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

:arg_quiet
set DEBUG=
set DEVEL=
set QUIET=true
goto arg_end

:arg_help
echo DESCRIPTION: %BASENAME% read value from windows registry and display its data
echo USAGE: %BASENAME% [-q] [-d] [-dev] [-h] [-y] HIVE\Path\to\key value
echo    -q          quiet: do not print anything
echo    -d          debug mode: print VARIABLE=value pairs
echo    -dev        devel mode: print additional development data
echo    -h          help screen (this screen^)
echo    -y          assume 'yes' to all questions
goto :EOF

:arg_unknown
if defined KEY set VALUE=%1
if not defined KEY set KEY=%1
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
rem call %DIRNAME%\lib\windows.cmd

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT GOES HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

call "%DIRNAME%\lib\api.cmd" :edebug KEY = %KEY%
call "%DIRNAME%\lib\api.cmd" :edebug VALUE = %VALUE%

rem
rem check parameters
if not defined KEY (
    call "%DIRNAME%\lib\api.cmd" :eerror KEY not defined
    goto :EOF
)
if not defined VALUE (
    call "%DIRNAME%\lib\api.cmd" :eerror VALUE not defined
    goto :EOF
)

rem
rem check if KEY exist
call "%DIRNAME%\lib\api.cmd" :eexec reg query %KEY%
if %ERRORLEVEL% GTR 0 (
    call "%DIRNAME%\lib\api.cmd" :eerror KEY '%KEY%' does not exist or is not readable
    goto :EOF
)

rem
rem check if value exist
call "%DIRNAME%\lib\api.cmd" :eexec reg query %KEY% /v %VALUE%
if %ERRORLEVEL% GTR 0 (
    call "%DIRNAME%\lib\api.cmd" :eerror VALUE '%VALUE%' does not exist or is not readable
    goto :EOF
)



for /F "tokens=2*" %%u in ('reg query %KEY% /v %VALUE% ^| find "REG_"') do set DATA=%%v
echo %DATA%

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT END HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

:end
rem reset window title
title %COMSPEC%

