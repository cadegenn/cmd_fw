rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem Network
rem
for /f "tokens=2 delims= " %%i in ('arp.exe -a ^| find "Interface"') do (set IP=%%i)
call edebug IP = %IP%
for /f "tokens=1,2 delims=." %%i in ('echo %IP%') do (set VLAN=%%i.%%j)
call edebug VLAN = %VLAN%
for /F "tokens=1,2,3,4,5,6 delims=- " %%i in ('getmac /nh ^| find /V "Support"') do (set MACADDRESS=%%i:%%j:%%k:%%l:%%m:%%n)
call edebug MACADDRESS = %MACADDRESS%
