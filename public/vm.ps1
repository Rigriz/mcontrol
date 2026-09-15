# ============================================================
# NETWORK LAB + VMWARE INSTALLATION SCRIPT
# Run PowerShell as Administrator
# ============================================================

$ErrorActionPreference = "Stop"

$Downloads = Join-Path $env:USERPROFILE "Downloads"
$NetworkLab = "C:\NETWORKLAB"

$VMwareInstaller = Join-Path $Downloads "VMware-player-full-17.0.0-20800274.exe"

$DriveFile1 = "https://drive.usercontent.google.com/download?id=1Y15T8JtHjFu-XOvWhZw7JANBvV7lLk85&export=download"
$DriveFile2 = "https://drive.usercontent.google.com/download?id=1VXo5WT40bFiv1VkEsx0CxAQMYFvlwGXX&export=download"

$File1 = Join-Path $Downloads "NETWORK LAB.rar"
$File2 = Join-Path $Downloads "NETWORK LAB-2.rar"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " NETWORK LAB + VMWARE SETUP" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. Create required directories
# ------------------------------------------------------------

Write-Host "`n[1/6] Preparing directories..." -ForegroundColor Yellow

if (-not (Test-Path $Downloads)) {
    New-Item -ItemType Directory -Path $Downloads -Force | Out-Null
}

if (-not (Test-Path $NetworkLab)) {
    New-Item -ItemType Directory -Path $NetworkLab -Force | Out-Null
}

Write-Host "Directories ready." -ForegroundColor Green


# ------------------------------------------------------------
# 2. Download large Google Drive files
# ------------------------------------------------------------

Write-Host "`n[2/6] Downloading Network Lab files..." -ForegroundColor Yellow
Write-Host "These files are several GB. Downloads may take a long time."
Write-Host "DO NOT close this PowerShell window.`n"

function Download-LargeFile {

    param (
        [string]$Url,
        [string]$OutputFile,
        [string]$DisplayName
    )

    Write-Host "--------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Downloading: $DisplayName" -ForegroundColor Cyan
    Write-Host "Destination: $OutputFile" -ForegroundColor DarkGray
    Write-Host "--------------------------------------------"

    # Remove incomplete previous file
    if (Test-Path $OutputFile) {
        Write-Host "Removing previous/incomplete file..." -ForegroundColor Yellow
        Remove-Item $OutputFile -Force
    }

    # Use curl.exe instead of Invoke-WebRequest.
    # --location follows redirects.
    # --output writes directly to the destination.
    # --progress-bar displays download progress.
    # --fail makes curl return an error on HTTP failures.
    & curl.exe `
        --location `
        --fail `
        --progress-bar `
        --output "$OutputFile" `
        "$Url"

    if ($LASTEXITCODE -ne 0) {
        throw "Download failed for $DisplayName. curl exit code: $LASTEXITCODE"
    }

    if (-not (Test-Path $OutputFile)) {
        throw "Download failed: file was not created."
    }

    $FileInfo = Get-Item $OutputFile
    $SizeGB = [math]::Round($FileInfo.Length / 1GB, 2)

    Write-Host "`nDownload finished: $DisplayName" -ForegroundColor Green
    Write-Host "Downloaded size: $SizeGB GB" -ForegroundColor Green
}


# Download file 1
Download-LargeFile `
    -Url $DriveFile1 `
    -OutputFile $File1 `
    -DisplayName "NETWORK LAB.rar"


# Download file 2
Download-LargeFile `
    -Url $DriveFile2 `
    -OutputFile $File2 `
    -DisplayName "NETWORK LAB-2.rar"


Write-Host "`nBoth downloads have completed successfully." -ForegroundColor Green


# ------------------------------------------------------------
# 3. Verify downloaded files before moving
# ------------------------------------------------------------

Write-Host "`n[3/6] Verifying downloaded files..." -ForegroundColor Yellow

if (-not (Test-Path $File1)) {
    throw "NETWORK LAB.rar was not downloaded."
}

if (-not (Test-Path $File2)) {
    throw "NETWORK LAB-2.rar was not downloaded."
}

$Info1 = Get-Item $File1
$Info2 = Get-Item $File2

Write-Host "NETWORK LAB.rar   : $([math]::Round($Info1.Length / 1GB, 2)) GB"
Write-Host "NETWORK LAB-2.rar : $([math]::Round($Info2.Length / 1GB, 2)) GB"

Write-Host "File verification completed." -ForegroundColor Green


# ------------------------------------------------------------
# 4. Move files to C:\NETWORKLAB
# ------------------------------------------------------------

Write-Host "`n[4/6] Moving Network Lab files..." -ForegroundColor Yellow

Move-Item `
    -Path $File1 `
    -Destination $NetworkLab `
    -Force

Write-Host "NETWORK LAB.rar moved successfully." -ForegroundColor Green


Move-Item `
    -Path $File2 `
    -Destination $NetworkLab `
    -Force

Write-Host "NETWORK LAB-2.rar moved successfully." -ForegroundColor Green


# ------------------------------------------------------------
# 5. Uninstall Oracle VirtualBox
# ------------------------------------------------------------

Write-Host "`n[5/6] Checking for Oracle VirtualBox..." -ForegroundColor Yellow

$VirtualBoxApps = Get-ItemProperty `
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" ,
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.DisplayName -like "Oracle VM VirtualBox*"
    }

if ($VirtualBoxApps) {

    foreach ($App in $VirtualBoxApps) {

        Write-Host "Found: $($App.DisplayName)" -ForegroundColor Yellow

        if ($App.UninstallString) {

            Write-Host "Uninstalling VirtualBox..." -ForegroundColor Yellow

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

Write-Host "`n[6/6] Checking VMware installer..." -ForegroundColor Yellow

if (-not (Test-Path $VMwareInstaller)) {

    Write-Host ""
    Write-Host "VMware installer was not found:" -ForegroundColor Red
    Write-Host $VMwareInstaller -ForegroundColor Red
    Write-Host ""
    Write-Host "Place VMware-player-full-17.0.0-20800274.exe"
    Write-Host "in your Downloads folder and run the script again."

    exit 1
}

Write-Host "VMware installer found." -ForegroundColor Green

Write-Host "`nStarting VMware Player installation..." -ForegroundColor Yellow

Start-Process `
    -FilePath $VMwareInstaller `
    -Verb RunAs `
    -Wait

Write-Host "`n============================================" -ForegroundColor Green
Write-Host " SETUP COMPLETED" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

Write-Host "`nNetwork Lab files:" -ForegroundColor Cyan

Get-ChildItem $NetworkLab |
    Select-Object Name,
    @{Name="SizeGB";Expression={[math]::Round($_.Length / 1GB, 2)}}

Write-Host "`nVMware installation process has completed." -ForegroundColor Green
Write-Host "You may need to restart Windows before using VMware."
