@echo off
rem 
rem @file eexec.cmd
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

set CMD=%*

rem execute command within a %COMSPEC% environment and log accordingly of 2 debug levels :
rem	DEBUG		simply log the command line to the console
rem	DEVEL	log output to the console
rem @param	full command line with arguments (enclose in double quote if you hav pipes)
rem @return	ERRORLEVEL
call edebug.cmd %CMD%
if defined DEVEL %COMSPEC% /c "%CMD%"
if NOT defined DEVEL %COMSPEC% /c "%CMD%" >nul 2>nul
REM echo RC = %ERRORLEVEL%
if /I %ERRORLEVEL% GTR 0 (
    call eerror.cmd %CMD%
    set CMD=
	exit /B %ERRORLEVEL%
)
set CMD=
goto :EOF
