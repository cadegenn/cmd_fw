rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Network
rem
for /f "tokens=2 delims= " %%i in ('arp.exe -a ^| find "Interface"') do (set IP=%%i)
call edevel IP = %IP%
rem 
for /f "tokens=1,2 delims=." %%i in ('echo %IP%') do (set VLAN=%%i.%%j)
call edebug VLAN = %VLAN%
for /F "tokens=1,2,3,4,5,6 delims=- " %%i in ('getmac /nh ^| find /V "Support"') do (set MACADDRESS=%%i:%%j:%%k:%%l:%%m:%%n)
call edevel MACADDRESS = %MACADDRESS%

rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Applications
rem
rem 7ZIP
call regread HKLM\Software\7-Zip Path
set "7ZIP=%REGDATA%\7z.exe"
call edevel 7ZIP = %7ZIP%

