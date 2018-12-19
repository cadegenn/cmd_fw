@echo off
setlocal enableExtensions enableDelayedExpansion

rem
rem @file skel.cmd
rem @brief skeleton of script to use with efunctions.cmd
rem @author Charles-Antoine Degennes <cadegenn]gmail.com>
rem @copyright  Copyright (C) 2015-2016  Charles-Antoine Degennes <cadegenn@gmail.com>
rem
rem This file is part of TinyCmdFramework
rem 
rem     TinyCmdFramework is free software: you can redistribute it and/or modify
rem     it under the terms of the GNU General Public License as published by
rem     the Free Software Foundation, either version 3 of the License, or
rem     (at your option) any later version.
rem 
rem     TinyCmdFramework is distributed in the hope that it will be useful,
rem     but WITHOUT ANY WARRANTY; without even the implied warranty of
rem     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem     GNU General Public License for more details.
rem 
rem     You should have received a copy of the GNU General Public License
rem     along with TinyCmdFramework.  If not, see <http://www.gnu.org/licenses/>.
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
if %1 == -q goto arg_quiet
if %1 == -d goto arg_debug
if %1 == -dev goto arg_devel
goto arg_help

:arg_yes
set YES=true
goto arg_end

:arg_quiet
set DEBUG=
set DEVEL=
set QUIET=
goto arg_end

:arg_debug
set DEBUG=true
goto arg_end

:arg_devel
set DEBUG=true
set DEVEL=true
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
call "%DIRNAME%\lib\efunctions.cmd" :eerror Unknown argument : %1
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

rem load windows variables
call "%DIRNAME%\lib\api.cmd"

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

