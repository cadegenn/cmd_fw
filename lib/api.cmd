@echo off
rem
rem this script gather useful information from underlying Windows OS
rem it can be considered as a general include file for windows scripts
rem
rem 2014.08.26, DCA
rem /!\ DO NOT ENABLE THESE OPTIONS
rem these options hav to be enabled in the caller script
rem setlocal enabledelayedexpansion enableextensions
rem VERSION of file is of the form YYYYmmdd.## where
rem YYYY is the current year using 4 digits
rem mm is the current month using 2 digits
rem dd is the current day of month using 2 digits
rem ## is the revision number within the same day (starting at 0)
rem it HAVE TO be updated with each single modification
rem set VERSION=20160503.1650
rem 
rem Copyright (C) 2015-2016  Charles-Antoine Degennes <cadegenn@gmail.com>
rem 
rem This file is part of cmd_fw
rem 
rem     cmd_fw is free software: you can redistribute it and/or modify
rem     it under the terms of the GNU General Public License as published by
rem     the Free Software Foundation, either version 3 of the License, or
rem     (at your option) any later version.
rem 
rem     cmd_fw is distributed in the hope that it will be useful,
rem     but WITHOUT ANY WARRANTY; without even the implied warranty of
rem     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem     GNU General Public License for more details.
rem 
rem     You should have received a copy of the GNU General Public License
rem     along with cmd_fw.  If not, see <http://www.gnu.org/licenses/>.
rem 
rem HOW TO USE
rem ==========
rem 
rem call %DIRNAME%\windows.cmd
rem
rem Changelog
rem =========
rem 2016.05.03, DCA -   add MACADDRESS variable
rem 2015.05.04, DCA -	use wmic to detect some BIOS data. enter set BIOS to see them all
rem                     added WinPE compatibility (WinPE does not contain findstr)
rem 2015.04.10, DCA -	use efunctions.cmd to output everything
rem 2015.03.11, DCA -	ajout de la détection du numéro de version de windows et export dans Windows_CurrentVersion
rem						ajout de la détection du nom de windows et export dans WindowsName
rem 2014.12.18, DCA -	ajout de la variable SED
rem 2014.11.24, DCA -	ajout variable SOURCE_DIRNAME => chemin vers efunctions.cmd et les outils détecté automatiquement
rem 					de cette manière, possibilité d'installer en local les API avec install-efunctions.cmd
rem						escape d'éventuelles parenthèses dans le chemin de l'install.cmd appelant
rem 2014.11.06, DCA -	ajout de la variable ZIP
rem						ajout des variables HKLM_UNINSTALL(x86) et HKLM_UNINSTALL(x64). ce sont des raccourcis vers les clés Uninstall de la base de registre
rem						ajout de la variable WindowsState qui remonte grossièrement dans quelle état d'installation se trouve Windows plus d'infos @url http://technet.microsoft.com/en-us/library/cc721913(v=ws.10).aspx
rem 2013.06.28, AR -	détection du CommonDocuments
rem 2012.04.18, AR -	détection du CommonAppData
rem 2012.04.03, DCA -	détection du "manufacturer" et du "serialnumber". ça peut aider à différencier les VM des "vraies" machines
rem						ces valeurs sont trouvées via wmic et portent un préfix BIOS_ (et ne marche pas sous XP => désactivés)
rem 2011.05.26, DCA -	ajout détection du dossier "Démarrer/Programmes/Démarrage" pour pouvoir y insérer des scripts
rem 2011.03.29, DCA -	fix détection HKLM_SOFTWARE(x64)
rem 2011.01.19, DCA -	ajout des variables HKLM_SOFTWARE(x86) et HKLM_SOFTWARE(x64)
rem 2010.12.07, DCA -	ajout de la variable ARCH = {x86,x64}
rem 2010.11.23, DCA -	déplacé le test iconv après le calcul des progfiles
rem 2010.11.22, DCA -	ajout variable ICONV et suppression du chemin en dur tout le long du script
rem 2010.11.19, DCA -	ajout d'un variable UsersDir qui pointe vers le répertoire parent des profiles utilisateurs
rem 2010.10.21, DCA -	ajout détection du "CommonPrograms" pour XP, VISTA, 7
rem						ajout détection du "CommonDesktop" pour XP, VISTA, 7
rem						ajout détection du "ProgFiles(x86)" pour XP, VISTA, 7
rem						ajout détection du "ProgFiles(x64)" pour XP, VISTA, 7
rem

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem calcul de la variable SOURCE_DIRNAME
rem
set SOURCE_DIRNAME=%~dp0
IF %SOURCE_DIRNAME:~-1%==\ set SOURCE_DIRNAME=%SOURCE_DIRNAME:~0,-1%
set SOURCE_BASENAME=%~nx0

rem title %0
call "%SOURCE_DIRNAME%\efunctions.cmd" :ebegin #include %SOURCE_BASENAME% - BEGIN

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Détection du réseau
rem
rem On détect le réseau sur lequel on se trouve actuellement pour ajuster l'installation
for /f "tokens=2 delims= " %%i in ('arp.exe -a ^| find "Interface"') do (set IP=%%i)
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug IP = %IP%
for /f "tokens=1,2 delims=." %%i in ('echo %IP%') do (set VLAN=%%i.%%j)
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug VLAN = %VLAN%
for /F "tokens=1,2,3,4,5,6 delims=- " %%i in ('getmac /nh ^| find /V "Support"') do (set MACADDRESS=%%i:%%j:%%k:%%l:%%m:%%n)
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug MACADDRESS = %MACADDRESS%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem détection de l'architecture de l'OS
rem
set ARCH=x86
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" set ARCH=x64
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug ARCH = %ARCH%

rem détection du ProgramFiles 32bits
rem arch x86 : ProgFiles(x86) = c:\Program Files
rem arch x64 : ProgFiles(x86) = C:\Program Files(x86)
set ProgFiles(x86)=%ProgramFiles%
if exist "%ProgramFiles(x86)%" set ProgFiles(x86)=%ProgramFiles(x86)%
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug ProgFiles(x86) = %ProgFiles(x86)%
rem détection du ProgramFiles 64bits
rem arch x86 : ProgFiles(x64) = c:\Program Files
rem arch x64 : ProgFiles(x64) = C:\Program Files
set ProgFiles(x64)=%ProgramFiles%
rem if exist "%ProgramFiles(x86)%" set ProgFiles_x64=%ProgramFiles(x86)%
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug ProgFiles(x64) = %ProgFiles(x64)%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Détection des clés de registre
rem
rem détection des HKLM_SOFTWARE
set HKLM_SOFTWARE(x86)=HKLM\Software
if "%ARCH%" == "x64" set HKLM_SOFTWARE(x86)=%HKLM_SOFTWARE(x86)%\Wow6432Node
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug HKLM_SOFTWARE(x86) = %HKLM_SOFTWARE(x86)%
set HKLM_SOFTWARE(x64)=HKLM\Software
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug HKLM_SOFTWARE(x64) = %HKLM_SOFTWARE(x64)%

rem déclaration des HKLM_UNINSTALL
set HKLM_UNINSTALL(x86)=%HKLM_SOFTWARE(x86)%\Microsoft\Windows\CurrentVersion\Uninstall
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug HKLM_UNINSTALL(x86) = %HKLM_UNINSTALL(x86)%
set HKLM_UNINSTALL(x64)=%HKLM_SOFTWARE(x64)%\Microsoft\Windows\CurrentVersion\Uninstall
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug HKLM_UNINSTALL(x64) = %HKLM_UNINSTALL(x64)%

REM rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM rem Déclaration de binaires
REM rem
REM rem 7-zip au cas ou
REM set ZIP="%SOURCE_DIRNAME%\7-Zip\%ARCH%\7z.exe"
REM call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug ZIP = %ZIP%

REM rem SED
REM set SED=%SOURCE_DIRNAME%\GnuWin32\bin\sed.exe
REM call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug SED = %SED%

REM rem pour la suite, on a besoin de iconv
REM rem set ICONV="%SOFTWARE%\_Utils\GnuWin32\bin\iconv.exe"
REM set ICONV="%SOURCE_DIRNAME%\GnuWin32\bin\iconv.exe"
REM call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug ICONV = %ICONV%
REM if NOT exist %ICONV% (
	REM echo %0 - %ICONV% n'existe pas.
	REM goto _end
REM )

REM rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM rem Détection des chemins systèmes
REM rem
REM rem détection du menu "Tous les programmes" (CommonPrograms)
REM rem
REM for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Programs" ^| %ICONV% -t CP850') do set CommonPrograms=%%j
REM call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug CommonPrograms = %CommonPrograms%

REM rem détection du Bureau de AllUsers (CommonDesktop)
for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Desktop" ^| %ICONV% -t CP850') do set CommonDesktop=%%j
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug CommonDesktop = %CommonDesktop%

REM rem détection du "Démarrage" de AllUsers (CommonStartup)
for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Startup" ^| %ICONV% -t CP850') do set CommonStartup=%%j
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug CommonStartup = %CommonStartup%

REM rem detection du chemin CommonAppData
for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common AppData" ^| %ICONV% -t CP850') do set CommonAppData=%%j
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug CommonAppData = %CommonAppData%

REM rem detection du chemin CommonDocuments
for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Documents" ^| %ICONV% -t CP850') do set CommonDocuments=%%j
call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug CommonDocuments = %CommonDocuments%

rem détection de la phase d'installation de windows
for /f "tokens=1,2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State" ^| find "REG_SZ"') do set Windows_%%i=%%k
rem call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug Windows_ImageState = %Windows_ImageState%

REM rem détection du répertoire parent des profiles utilisateurs UsersDir
REM set UsersDir=%SystemDrive%\Documents and settings
REM if exist "%SystemDrive%\Users" set UsersDir=%SystemDrive%\Users
REM call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug UsersDir = %UsersDir%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Détection de la version de Windows
rem
for /f "tokens=1,2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" ^| find "REG_SZ"') do set Windows_%%i=%%k
for /f "tokens=1,2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" ^| find "REG_DWORD"') do set /a Windows_%%i=%%k
if "%Windows_InstallationType%" == "Server" goto :getWindowsServerOsVer
if "%Windows_InstallationType%" == "Client" goto :getWindowsClientOsVer
if "%Windows_InstallationType%" == "WindowsPE" goto :getWindowsPEOsVer
:getWindowsServerOsVer
if "%Windows_CurrentVersion%"=="5.2" set Windows_OsVer=2003
if "%Windows_CurrentVersion%"=="6.0" set Windows_OsVer=2008
if "%Windows_CurrentVersion%"=="6.1" set Windows_OsVer=2008r2
if "%Windows_CurrentVersion%"=="6.2" set Windows_OsVer=2012
if "%Windows_CurrentVersion%"=="6.3" set Windows_OsVer=2012r2
goto :continue

:getWindowsClientOsVer
if "%Windows_CurrentVersion%"=="5.1" set Windows_OsVer=xp
if "%Windows_CurrentVersion%"=="5.2" set Windows_OsVer=2003
if "%Windows_CurrentVersion%"=="6.0" set Windows_OsVer=vista
if "%Windows_CurrentVersion%"=="6.1" set Windows_OsVer=7
if "%Windows_CurrentVersion%"=="6.2" set Windows_OsVer=8
if "%Windows_CurrentVersion%"=="6.3" set Windows_OsVer=8.1
goto :continue

:getWindowsPEOsVer
if "%Windows_CurrentVersion%"=="5.1" set Windows_OsVer=2
if "%Windows_CurrentVersion%"=="5.2" set Windows_OsVer=2
if "%Windows_CurrentVersion%"=="6.0" set Windows_OsVer=3
if "%Windows_CurrentVersion%"=="6.1" set Windows_OsVer=4
if "%Windows_CurrentVersion%"=="6.2" set Windows_OsVer=5
if "%Windows_CurrentVersion%"=="6.3" set Windows_OsVer=5.1
goto :continue

:continue
rem windows 10 have another versionning system : CurrentVersion is still 6.3, but 2 new registry values appears : CurrentMajorVersionNumber and CurrentMinorVersionNumber. Let's use it
if DEFINED Windows_CurrentMajorVersionNumber (
    if DEFINED Windows_CurrentMinorVersionNumber (
        set Windows_OsVer=%Windows_CurrentMajorVersionNumber%.%Windows_CurrentMinorVersionNumber%
    ) else (
        set Windows_OsVer=%Windows_CurrentMajorVersionNumber%
    )
)
set Windows_ShortProductName=%Windows_ProductName%
set Windows_ShortProductName=%Windows_ShortProductName: =%
set Windows_ShortProductName=%Windows_ShortProductName:.=%
if "%Windows_InstallationType%" == "WindowsPE" (
    set Windows_ShortProductName=WinPE%Windows_OsVer%
    for /f "tokens=1,2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE" /v Version') do set WinPE_Version=%%k
)
for /f "tokens=1,2* delims==" %%i in ('set Win') do call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug %%i = %%j

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Détection de la version de Computer
rem
for /f "tokens=1*" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine" /v "Distinguished-Name" ^| findstr REG_SZ') do set ComputerDN=%%w
rem détection de l'OU
set ComputerOU=%ComputerDN:*,OU=OU%
for /f "tokens=1,2* delims==" %%i in ('set Computer') do call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug %%i = %%j


rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Detect some WMI data
rem found some simple solution here @url http://www.robvanderwoude.com/wmic.php (thank you guy !!)
rem
for /f "tokens=*" %%i in ('wmic bios get manufacturer^,serialnumber /value ^| find "="') do set BIOS_%%i
for /f "tokens=*" %%i in ('wmic computersystem get model /value ^| find "="') do set BIOS_%%i
for /f "tokens=1,2* delims==" %%i in ('set BIOS') do call "%SOURCE_DIRNAME%\efunctions.cmd" :edebug %%i = %%j

rem :_end
call "%SOURCE_DIRNAME%\efunctions.cmd" :ebegin #include %SOURCE_BASENAME% - END

goto :EOF
