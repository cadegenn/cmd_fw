@echo off
rem 
rem @file elog.cmd
rem @project cmd_fw
rem @author Charles-Antoine Degennes (cadegenn@gmail.com)
rem @date 2018.09.14
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

rem @brief  log a message on a file
rem @param	(string)	message without quotes
if not defined LOGFILE goto :EOF

>> "%LOGFILE%" (
    echo %DATE% %TIME% %BASENAME% - %*
)


