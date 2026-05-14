# =============================================================
# install_sysmon.ps1 — Automated Sysmon Deployment
# =============================================================
# Author: Mordie Lawrence
# Run as: Administrator
#
# WHAT SYSMON IS AND WHY IT MATTERS:
#   Windows Event Logging out of the box is limited. By default,
#   process creation events don't include full command lines.
#   Network connections aren't logged. DLL loads aren't logged.
#   Sysmon (System Monitor) by Sysinternals/Microsoft fills these gaps.
#   It runs as a system service and writes enriched events to
#   Applications and Services Logs > Microsoft > Windows > Sysmon
#
#   For a SOC analyst, Sysmon is the difference between seeing
#   "powershell.exe ran" versus seeing the full command, parent
#   process, network connection, and file it created.
#
# THIS SCRIPT:
#   1. Downloads Sysmon from Microsoft Sysinternals
#   2. Downloads SwiftOnSecurity's community config (widely used baseline)
#   3. Installs Sysmon with that config
#   4. Verifies the service is running

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "[*] Starting Sysmon installation..." -ForegroundColor Cyan

# URLs
$SysmonUrl    = "https://download.sysinternals.com/files/Sysmon.zip"
$ConfigUrl    = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
$InstallPath  = "C:\Tools\Sysmon"

# Create install directory
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath | Out-Null
    Write-Host "[+] Created $InstallPath" -ForegroundColor Green
}

# Download Sysmon
Write-Host "[*] Downloading Sysmon..." -ForegroundColor Yellow
$ZipPath = "$InstallPath\Sysmon.zip"
Invoke-WebRequest -Uri $SysmonUrl -OutFile $ZipPath -UseBasicParsing
Expand-Archive -Path $ZipPath -DestinationPath $InstallPath -Force
Write-Host "[+] Sysmon downloaded and extracted" -ForegroundColor Green

# Download SwiftOnSecurity config
Write-Host "[*] Downloading Sysmon config (SwiftOnSecurity baseline)..." -ForegroundColor Yellow
$ConfigPath = "$InstallPath\sysmon-config.xml"
Invoke-WebRequest -Uri $ConfigUrl -OutFile $ConfigPath -UseBasicParsing
Write-Host "[+] Config downloaded" -ForegroundColor Green

# Install Sysmon
Write-Host "[*] Installing Sysmon service..." -ForegroundColor Yellow
$SysmonExe = "$InstallPath\Sysmon64.exe"
Start-Process -FilePath $SysmonExe -ArgumentList "-accepteula -i $ConfigPath" -Wait -NoNewWindow

# Verify service
$service = Get-Service -Name "Sysmon64" -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq "Running") {
    Write-Host "[+] Sysmon is installed and running" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "  Open Event Viewer > Applications and Services Logs"
    Write-Host "  > Microsoft > Windows > Sysmon > Operational"
    Write-Host "  You should see events appearing within seconds."
    Write-Host "  Event ID 1 = Process Create (most important to start with)"
} else {
    Write-Host "[!] Sysmon service not running. Check Event Viewer for errors." -ForegroundColor Red
}
