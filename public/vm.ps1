# ============================================================
# NETWORK LAB + VMWARE INSTALLATION SCRIPT
# Run PowerShell as Administrator
# ============================================================

$ErrorActionPreference = "Stop"

$Downloads = Join-Path $env:USERPROFILE "Downloads"
$NetworkLab = "C:\NETWORKLAB"

$VMwareInstaller = Join-Path $Downloads "VMware-player-full-17.0.0-20800274.exe"
$NetworkLabRAR = Join-Path $Downloads "NETWORK LAB.rar"

$DriveFile1 = "https://drive.usercontent.google.com/download?id=1Y15T8JtHjFu-XOvWhZw7JANBvV7lLk85&export=download"
$DriveFile2 = "https://drive.usercontent.google.com/download?id=1VXo5WT40bFiv1VkEsx0CxAQMYFvlwGXX&export=download"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " NETWORK LAB + VMWARE SETUP" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. Create Downloads directory if necessary
# ------------------------------------------------------------

if (-not (Test-Path $Downloads)) {
    New-Item -ItemType Directory -Path $Downloads -Force | Out-Null
}

# ------------------------------------------------------------
# 2. Download the two Google Drive files
# ------------------------------------------------------------

Write-Host "`n[1/6] Downloading Network Lab files..." -ForegroundColor Yellow

# First file
Write-Host "Downloading file 1..."
Invoke-WebRequest `
    -Uri $DriveFile1 `
    -OutFile (Join-Path $Downloads "NETWORK LAB.rar") `
    -UseBasicParsing

# Second file
Write-Host "Downloading file 2..."
Invoke-WebRequest `
    -Uri $DriveFile2 `
    -OutFile (Join-Path $Downloads "NETWORK LAB-2.rar") `
    -UseBasicParsing

Write-Host "Downloads completed." -ForegroundColor Green

# ------------------------------------------------------------
# 3. Create C:\NETWORKLAB
# ------------------------------------------------------------

Write-Host "`n[2/6] Creating C:\NETWORKLAB..." -ForegroundColor Yellow

if (-not (Test-Path $NetworkLab)) {
    New-Item -ItemType Directory -Path $NetworkLab -Force | Out-Null
}

# ------------------------------------------------------------
# 4. Move NETWORK LAB.rar into C:\NETWORKLAB
# ------------------------------------------------------------

Write-Host "`n[3/6] Moving Network Lab archive..." -ForegroundColor Yellow

if (Test-Path $NetworkLabRAR) {
    Move-Item `
        -Path $NetworkLabRAR `
        -Destination $NetworkLab `
        -Force

    Write-Host "NETWORK LAB.rar moved to C:\NETWORKLAB" -ForegroundColor Green
}
else {
    Write-Warning "NETWORK LAB.rar was not found in Downloads."
}

# Move second archive as well
$SecondRAR = Join-Path $Downloads "NETWORK LAB-2.rar"

if (Test-Path $SecondRAR) {
    Move-Item `
        -Path $SecondRAR `
        -Destination $NetworkLab `
        -Force

    Write-Host "NETWORK LAB-2.rar moved to C:\NETWORKLAB" -ForegroundColor Green
}

# ------------------------------------------------------------
# 5. Uninstall Oracle VirtualBox
# ------------------------------------------------------------

Write-Host "`n[4/6] Checking for Oracle VirtualBox..." -ForegroundColor Yellow

$VirtualBoxApps = Get-ItemProperty `
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" ,
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.DisplayName -like "Oracle VM VirtualBox*"
    }

if ($VirtualBoxApps) {

    foreach ($App in $VirtualBoxApps) {

        Write-Host "Found: $($App.DisplayName)"

        if ($App.UninstallString) {

            Write-Host "Uninstalling VirtualBox..."

            $UninstallCommand = $App.UninstallString

            if ($UninstallCommand -match '^"([^"]+)"\s*(.*)$') {
                $Uninstaller = $matches[1]
                $Arguments = $matches[2]

                Start-Process `
                    -FilePath $Uninstaller `
                    -ArgumentList $Arguments `
                    -Verb RunAs `
                    -Wait
            }
            else {
                Start-Process `
                    -FilePath "cmd.exe" `
                    -ArgumentList "/c `"$UninstallCommand`"" `
                    -Verb RunAs `
                    -Wait
            }
        }
    }

    Write-Host "VirtualBox uninstall completed." -ForegroundColor Green
}
else {
    Write-Host "Oracle VirtualBox is not installed." -ForegroundColor Green
}

# ------------------------------------------------------------
# 6. Install VMware Player
# ------------------------------------------------------------

Write-Host "`n[5/6] Checking VMware installer..." -ForegroundColor Yellow

if (-not (Test-Path $VMwareInstaller)) {

    Write-Error @"
VMware installer was not found:

$VMwareInstaller

Place VMware-player-full-17.0.0-20800274.exe in your Downloads folder
and run this script again.
"@

    exit 1
}

Write-Host "VMware installer found." -ForegroundColor Green

Write-Host "`n[6/6] Starting VMware Player installation..." -ForegroundColor Yellow

Start-Process `
    -FilePath $VMwareInstaller `
    -Verb RunAs `
    -Wait

Write-Host "`n============================================" -ForegroundColor Green
Write-Host " SETUP COMPLETED" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

Write-Host "`nNetwork Lab files:"
Get-ChildItem $NetworkLab | Select-Object Name, Length

Write-Host "`nVMware installation process has completed."
Write-Host "You may need to restart Windows before using VMware."
