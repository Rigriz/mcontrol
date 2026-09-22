$ErrorActionPreference = "Stop"

$Downloads = Join-Path $env:USERPROFILE "Downloads"

$DriveFile1 = "https://drive.usercontent.google.com/download?id=1tC7Enz5xmMk-pc8-mHV6GmbZQ0mEn_fy&export=download&authuser=0"
$DriveFile2 = "https://drive.usercontent.google.com/download?id=1RusP5GE4M__23dUxY9kgbT4P_SjHMCYg&export=download&authuser=0"
function Download-LargeFile {
    param(
        [string]$Url,
        [string]$OutputFile,
        [string]$Name
    )

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " DOWNLOADING $Name" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "File: $OutputFile"
    Write-Host ""
    Write-Host "DO NOT CLOSE THIS WINDOW." -ForegroundColor Yellow
    Write-Host "The file may take a long time to download."
    Write-Host ""

    & curl.exe `
        --location `
        --fail `
        --retry 10 `
        --retry-delay 5 `
        --continue-at - `
        --progress-bar `
        --output "$OutputFile" `
        "$Url"

    if ($LASTEXITCODE -ne 0) {
        throw "Download failed. curl exit code: $LASTEXITCODE"
    }

    if (-not (Test-Path $OutputFile)) {
        throw "Download did not create the expected file."
    }

    $File = Get-Item $OutputFile
    if ($File.Length -lt 10MB) {
        throw "The downloaded file is too small ($([math]::Round($File.Length / 1MB, 2)) MB). It appears Google Drive returned an HTML warning page instead of the actual file."
    }

    $SizeGB = [math]::Round($File.Length / 1GB, 2)

    Write-Host ""
    Write-Host "DOWNLOAD FINISHED!" -ForegroundColor Green
    Write-Host "$Name = $SizeGB GB" -ForegroundColor Green
}
try {
    Write-Host "============================================" -ForegroundColor Green
    if (-not (Test-Path $Downloads)) {
        New-Item -ItemType Directory -Path $Downloads -Force | Out-Null
    }
    
    # --------------------------------------------------------
    # DOWNLOAD FILE 1 
    # --------------------------------------------------------
     Download-LargeFile `
        -Url $DriveFile1 `
        -OutputFile $File1 `
        -Name "vcxsrv-64.1.20.14.0.installer.exe"
    # --------------------------------------------------------
    # DOWNLOAD FILE 2
    (.exe)
    # --------------------------------------------------------
     Download-LargeFile `
        -Url $DriveFile2 `
        -OutputFile $File2 `
        -Name "putty-64bit-0.85-installer.msi"
     Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " ORGANIZING FILES" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    }
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host " DOWNLOAD OR SETUP ERROR" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red

    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red

    Write-Host ""
    Write-Host "The PowerShell window will remain open." -ForegroundColor Yellow

    Read-Host "Press ENTER to close"
}
finally {
    Write-Host ""
    Write-Host "Script finished." -ForegroundColor Cyan

    Read-Host "Press ENTER to close PowerShell"
}
