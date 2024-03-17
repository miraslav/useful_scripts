@echo off
setlocal enabledelayedexpansion

rem Hello, everyone! I'm happy to share my micro-script for bypassing AnyConnect VPN tunnel and passing traffic through the Internet.
rem So, for this example, I used hard-coded method.
rem Also, I'd like to say thank you my friends

rem Getting default gateway from Powershell
for /f "delims=" %%a in ('powershell -command "Get-NetRoute | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' } | Select-Object -ExpandProperty NextHop"') do (
    set "gateway=%%a"
)

rem Please, enter default gateway If Powershell doesn't exist
if not defined gateway (
    set /p gateway="Enter default gateway (for example, 192.168.1.1): "
)

rem Add routes
for %%A in (your_ip1 your_ip2) do (
    route -p add %%A mask 255.255.255.255 %gateway% metric 1
)

rem Add records to hosts file
echo. >> C:\Windows\System32\drivers\etc\hosts
echo your_ip1   your_site1 >> C:\Windows\System32\drivers\etc\hosts
echo your_ip2  your_site2 >> C:\Windows\System32\drivers\etc\hosts

endlocal