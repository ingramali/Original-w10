@echo off

:: Clean up unnecessary shortcuts
echo Deleting Epic Games Launcher shortcut...
del /f "C:\Users\Public\Desktop\Epic Games Launcher.lnk" >> out.txt 2>&1

:: Modify server comment
echo Setting server comment to 'Windows Azure VM'...
net config server /srvcomment:"Windows Azure VM" >> out.txt 2>&1

:: Disable tray auto-hide
echo Disabling Auto Tray in Windows Explorer...
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /V EnableAutoTray /T REG_DWORD /D 0 /F >> out.txt 2>&1

:: Create new user and add to administrators group
echo Creating new Administrator user...
net user administrator @duiwel04 /add >nul
net localgroup administrators administrator /add >nul

:: Display RDP connection details
echo All done! Connect your VM using RDP. If the RDP session expires and the VM shuts down, re-run the job to get a new RDP.
echo ----------------------------------------------
echo User: Administrator
echo Pass: @duiwel04

:: Fetch Ngrok tunnel URL if running
echo Fetching Ngrok tunnel URL...
tasklist | find /i "ngrok.exe" >nul && (
    curl -s localhost:4040/api/tunnels | jq -r .tunnels[0].public_url
) || (
    echo "Can't get NGROK tunnel. Ensure NGROK_AUTH_TOKEN is correct in Settings > Secrets > Repository secret."
    echo "Maybe your previous VM is still running: https://dashboard.ngrok.com/status/tunnels"
)

:: Download various utilities
echo Downloading necessary utilities...
curl -O https://raw.githubusercontent.com/c9ffin/rdp/main/Files/DisablePasswordComplexity.ps1 >> out.txt 2>&1
curl -o "C:\Users\Public\Desktop\Fast Config VPS.exe" https://raw.githubusercontent.com/ingramali/W10_RDP/main/Files/FastConfigVPS_v5.1.exe >> out.txt 2>&1
curl -o "C:\Users\Public\Desktop\npp.7.9.4.Installer.x64.exe" https://raw.githubusercontent.com/ingramali/W10_RDP/main/Files/npp.7.9.4.Installer.x64.exe >> out.txt 2>&1
curl -o "C:\Users\Public\Desktop\Everything.exe" https://raw.githubusercontent.com/ingramali/W10_RDP/main/Files/Everything.exe >> out.txt 2>&1
curl -o "C:\Users\Public\Desktop\BANDIZIP-SETUP.exe" https://raw.githubusercontent.com/ingramali/W10_RDP/main/Files/BANDIZIP-SETUP.exe >> out.txt 2>&1

:: Disable password complexity
echo Disabling password complexity...
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './DisablePasswordComplexity.ps1'" >> out.txt 2>&1

:: Configure disk performance
echo Setting up disk performance monitoring...
diskperf -Y >nul

:: Start audio services and set to auto-start
echo Starting audio services...
sc start audiosrv >nul
sc config Audiosrv start= auto >nul

:: Grant administrator permissions to important directories
echo Granting Administrator permissions to necessary directories...
ICACLS C:\Windows\Temp /grant administrator:F >nul
ICACLS C:\Windows\installer /grant administrator:F >nul

:: Wait before finishing
ping -n 10 127.0.0.1 >nul

echo Setup complete! Please use the Ngrok URL to connect via RDP.
