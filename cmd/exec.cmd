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
set CMDLINE=%*
if x%CMDLINE% == x goto :EOF

:end-args-loop
rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem END parsing command line
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

rem load windows variables
rem call %DIRNAME%\lib\windows.cmd
if exist "%DIRNAME%\exec-conf.cmd" call "%DIRNAME%\exec-conf.cmd"
rem wpkg'api.cmd defines LOGNAME as default log filename
if DEFINED LOGNAME set LOG_FILE=%LOGNAME%

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT GOES HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

rem for each stage, display it on console AND log into logfile if defined
echo --------------------------------
if DEFINED LOG_FILE echo -------------------------------- >> "%LOG_FILE%"
echo CMDLINE = %CMDLINE%
if DEFINED LOG_FILE echo CMDLINE = %CMDLINE% >> "%LOG_FILE%"
rem run command
if DEFINED LOG_FILE (
    %COMSPEC% /c %CMDLINE% >> "%LOG_FILE%"
) else (
    %COMSPEC% /c %CMDLINE%
)
set RC=%ERRORLEVEL%
echo RC ^(ERRORLEVEL^) = %RC%
if DEFINED LOG_FILE echo RC ^(ERRORLEVEL^) = %RC% >> "%LOG_FILE%"
LOG_FILE echo --------------------------------
if DEFINED LOG_FILE echo -------------------------------- >> "%LOG_FILE%"

rem ::::::::::::::::::::::::::::::::::::::::::::::::
rem
rem YOUR SCRIPT END HERE !
rem
rem ::::::::::::::::::::::::::::::::::::::::::::::::

:end
