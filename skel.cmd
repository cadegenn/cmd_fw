@echo off
setlocal EnableDelayedExpansion

rem
rem @file skel.cmd
rem @brief skeleton of script to use with efunctions.cmd
rem @project cmd_fw
rem @author Charles-Antoine Degennes (cadegenn@gmail.com)
rem @date 2018.09.10
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
goto arg_help

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
if exist "%CMDFW_PATH%\includes\globals.cmd" (
    call edevel Loading globals variables 
    call "%CMDFW_PATH%\includes\globals.cmd"
)

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT GOES HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::



rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT END HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

:end
rem reset window title
title %COMSPEC%

