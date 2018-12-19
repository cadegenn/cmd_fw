@echo off
rem 
rem @file regread.cmd
rem @project cmd_fw
rem @author Charles-Antoine Degennes (cadegenn@gmail.com)
rem @date 2018.09.13
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

rem @note   regread puts the result into a REGDATA variable.
rem @note   to use this in a script, follow these guidelines
rem @note   call regread "HKLM\Path\to\my key" "theValue to read"
rem @note   set MyVar=%REGDATA%

set "KEY=%1"
set "VALUE=%2"
call edevel.cmd KEY = %KEY%
call edevel.cmd VALUE = %VALUE%

rem
rem check parameters
if not defined KEY (
    call eerror.cmd KEY not defined
    goto :EOF
)
if not defined VALUE (
    call eerror.cmd VALUE not defined
    goto :EOF
)

rem
rem check if KEY exist
call eexec reg query %KEY%
if %ERRORLEVEL% GTR 0 (
    call eerror.cmd KEY '%KEY%' does not exist or is not readable
    goto :EOF
)

rem
rem check if value exist
call eexec reg query %KEY% /v %VALUE%
if %ERRORLEVEL% GTR 0 (
    call eerror.cmd VALUE '%VALUE%' does not exist or is not readable
    goto :EOF
)

REM This simple code does not handle VALUE with white space
REM for /F "tokens=2*" %%u in ('reg query %KEY% /v %VALUE% ^| find "REG_"') do set "DATA=%%v"
REM echo %DATA%
REM REM set DATA=

REM This far more complicated code does handle correctly VALUE with white space
rem 1st pass, extract all values from registry, replace REG_* with an arbitratry one-char separator
set SEP=/
if exist "%TEMP%\regread.out" del /q "%TEMP%\regread.out"
for /f "tokens=*" %%i in ('reg query %KEY% /v %VALUE% ^| find "REG_"') do (
    set "line=%%i"
    echo !line:    REG_SZ    =%SEP%!
) >> "%TEMP%\regread.out"
rem second pass, use %SEP% to correctly separate fields
for /f "tokens=1* delims=%SEP%" %%i in ('type "%TEMP%\regread.out"') do (
    set REGDATA=%%j
)
if exist "%TEMP%\regread.out" del /q "%TEMP%\regread.out"

call edevel.cmd REGDATA = %REGDATA%
REM echo %REGDATA%