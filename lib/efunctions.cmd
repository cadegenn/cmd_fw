@echo off
rem setlocal enableExtensions enableDelayedExpansion
rem VERSION of file is of the form YYYYmmdd.## where
rem YYYY is the current year using 4 digits
rem mm is the current month using 2 digits
rem dd is the current day of month using 2 digits
rem ## is the revision number within the same day (starting at 0)
rem it HAVE TO be updated with each single modification
rem set VERSION=20150505.00
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
rem in your scripts, use syntax like this
rem call path\to\api.cmd :apifunction argument list with %VARIABLE%
rem for example
rem call %DIRNAME%\api.cmd :edebug MYVAR = %MYVAR%
rem call %DIRNAME%\api.cmd :eexec "echo f | xcopy /hrky sourcefile.exe destfile.exe"
rem 
rem I recommend writing on top of your script following lines :
rem @echo off
rem setlocal enableExtensions enableDelayedExpansion
rem
rem and somewhere near the top of your script :
rem rem compute DIRNAME variable
rem for /f "tokens=*" %%i in ('echo %0') do set DIRNAME=%%~dpi
rem if %DIRNAME:~-1%==\ set DIRNAME=%DIRNAME:~0,-1%
rem for /f "tokens=*" %%i in ('echo %0') do set BASENAME=%%~nxi
rem
rem variable DIRNAME will then be the absolute pathname of your script. I recommand putting a copy
rem of the api.cmd in this same directory to later be able to call %DIRNAME%\api.cmd :myfunc
rem 
rem Changelog
rem =========
rem 2016.03.15, DCA -   do not echo anything if QUIET has been requested
rem 2015.04.10, DCA -	added serial() to generate a uniq serial number based on DATE-TIME
rem 2015.04.02, DCA -	renamed eexec() to eexec()
rem 2015.03.23, DCA -	add Question(), Question_YN() functions
rem 2015.03.24, DCA -	add edevel() function to print data if DEVEL env variable is set
rem 2014.03.20, DCA -	parse correctly arguments to get rid of function name in %*
rem 
rem ::::::::::::::::::::::::::::::::::::::::::::::
rem 
rem  @brief	common functions
rem  @param	(string)	label
rem  @return	(integer)	ERRORLEVEL
rem  
rem  e* functions shamelessly inspired from gentoo e* functions
rem  you have to pass the correct label as parameter
rem 
rem ::::::::::::::::::::::::::::::::::::::::::::::

set LABEL=%1
set ARGS=%*
rem  using 'call' here is important @url http://ss64.com/nt/syntax-replace.html
call set CMD=%%ARGS:%LABEL% =%%
rem  define valid labels
if "%LABEL%" == ":eexec" goto %LABEL%
if "%LABEL%" == ":ebegin" goto %LABEL%
if "%LABEL%" == ":einfo" goto %LABEL%
if "%LABEL%" == ":ewarn" goto %LABEL%
if "%LABEL%" == ":eerror" goto %LABEL%
if "%LABEL%" == ":edebug" goto %LABEL%
if "%LABEL%" == ":serial" goto %LABEL%
goto :EOF

rem execute command and log accordingly of 2 debug levels :
rem	DEBUG		simply log the command line to the console
rem	DEVEL	log output to the console
rem @param	full command line with arguments (enclose in double quote if you hav pipes)
rem @return	ERRORLEVEL
:eexec
rem set ARGS=%*
rem set CMD=%ARGS::eexec =%
if defined DEBUG echo  * DBG: %CMD%
if defined DEVEL %CMD%
if NOT defined DEVEL %CMD% >nul 2>nul
if %ERRORLEVEL% GTR 0 (
    call :eerror %CMD%
	exit /B %ERRORLEVEL%
)
goto :EOF

rem print a message on the console
rem @param	(string)	message without quotes
rem @TODO	try with this syntax : <nul: set /p %CMD%
:ebegin
rem set ARGS=%*
rem set CMD=%ARGS::ebegin =%
if NOT DEFINED QUIET echo  * %CMD%
goto :EOF

rem print an information message on the console
rem @param	(string)	message without quotes
:einfo
rem set ARGS=%*
rem set CMD=%ARGS::einfo =%
if NOT DEFINED QUIET echo  * INF: %CMD%
goto :EOF

rem print a warning on the console
rem @param	(string)	message without quotes
:ewarn
rem set ARGS=%*
rem set CMD=%ARGS::ewarn =%
if NOT DEFINED QUIET echo  * WRN: %CMD%
goto :EOF

rem print an error on the console
rem @param	(string)	message without quotes
:eerror
rem set ARGS=%*
rem set CMD=%ARGS::eerror =%
if NOT DEFINED QUIET echo  * ERR: %CMD%
goto :EOF

rem print a debug on the console (only if DEBUG is set)
rem @param	(string)	message without quotes
:edebug
rem set ARGS=%*
rem set CMD=%ARGS::edebug =%
if defined DEBUG echo  * DBG: %CMD%
goto :EOF

rem print a debug on the console (only if DEBUG is set)
rem @param	(string)	message without quotes
:edevel
rem set ARGS=%*
rem set CMD=%ARGS::edebug =%
if defined DEVEL echo  * DEV: %CMD%
goto :EOF

rem
rem @brief        Question()      ask a question and wait for a response
rem @param        (string)        question to ask
rem @param        (string)        default response
rem @return       (string)        anwser of the user
:Question
    set FUNCNAME=%1
    call %DIRNAME%\api.cmd :edevel %FUNCNAME%(^)
    if %2 == -h (
        call %DIRNAME%\%0 :ewarn usage: %FUNCNAME% 'question' [default_answer]
        goto :EOF
    )
    set QUESTION=%2
    set QUESTION=%QUESTION:"=%
    set DEFAULT_ANSWER=%3
    rem call :ebegin %QUESTION% ^[%DEFAULT_ANSWER%^] ? 
    rem set /p ANSWER=
    set /p ANSWER= * %QUESTION% ? [%DEFAULT_ANSWER%] 
    if NOT DEFINED ANSWER set ANSWER=%DEFAULT_ANSWER%
    rem call %DIRNAME%\api.cmd :edebug ANSWER = %ANSWER%
goto :EOF

rem
rem @brief        Question_YN()   ask a YES/No question and wait for a response
rem @param        (string)        question to ask
rem @param        (string)        default response
rem @return       (string)        'y' if user agree | nothing if user do not agree
:Question_YN
    set FUNCNAME=%1
    call %DIRNAME%\api.cmd :edevel %FUNCNAME%(^)
    if %2 == -h (
        call %0 :ewarn usage: %FUNCNAME% 'question' [y^|n]
        goto :EOF
    )
    set QUESTION=%2
    set QUESTION=%QUESTION:"=%
    set DEFAULT_ANSWER=%3
    call %0 :Question %QUESTION% %DEFAULT_ANSWER%
    set SHORT_REPONSE=%ANSWER:~0,1%
    rem clear ANSWER variable
    set ANSWER=
    rem ... and fill it only if response is valid and is 'y'
    if %SHORT_REPONSE% == y set ANSWER=%SHORT_REPONSE%
    rem call %DIRNAME%\api.cmd :edebug ANSWER = %ANSWER%
goto :EOF

rem
rem @brief	serial()	export a serial number based on current date-time
rem @return	(string)	SERIAL variable
:serial
    for /f "tokens=3 delims=/ " %%i in ('date /t') do set YEAR=%%i
    for /f "tokens=2 delims=/" %%i in ('date /t') do set MONTH=%%i
    for /f "tokens=1 delims=/" %%i in ('date /t') do set DAY=%%i
rem    for /f "tokens=1 delims=:" %%i in ('time /t') do set HOUR=%%i
rem    for /f "tokens=2 delims=: " %%i in ('time /t') do set MINUTE=%%i
    for /f "tokens=1 delims=: " %%i in ('echo %TIME%') do set HOUR=%%i
    if %HOUR% LSS 10 set HOUR=0%HOUR%
    for /f "tokens=2 delims=: " %%i in ('echo %TIME%') do set MINUTE=%%i
    for /f "tokens=3 delims=: " %%i in ('echo %TIME%') do set SECONDS=%%i
    for /f "tokens=2 delims=, " %%i in ('echo %TIME%') do set MILLI=%%i
    set SERIAL=%YEAR%%MONTH%%DAY%-%HOUR%%MINUTE%%SECONDS%.%MILLI%
	call %0 :edebug SERIAL = %SERIAL%
goto :EOF

