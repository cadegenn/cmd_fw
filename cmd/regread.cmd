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

call edebug.cmd KEY = %KEY%
call edebug.cmd VALUE = %VALUE%

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



for /F "tokens=2*" %%u in ('reg query %KEY% /v %VALUE% ^| find "REG_"') do set DATA=%%v
echo %DATA%


