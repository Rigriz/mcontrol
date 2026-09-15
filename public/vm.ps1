$ErrorActionPreference = "Stop"

$Downloads = Join-Path $env:USERPROFILE "Downloads"
$DestinationFolder = "C:\NETWORKLAB"

$DriveFile1 = "https://drive.usercontent.google.com/download?id=1Y15T8JtHjFu-XOvWhZw7JANBvV7lLk85&export=download&confirm=1"
$DriveFile2 = "https://drive.usercontent.google.com/download?id=1VXo5WT40bFiv1VkEsx0CxAQMYFvlwGXX&export=download&confirm=1"

$File1 = Join-Path $Downloads "NETWORK LAB.rar"
$File2 = Join-Path $Downloads "NETWORK LAB-2.exe"

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
    Write-Host " NETWORK LAB DOWNLOAD" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    if (-not (Test-Path $Downloads)) {
        New-Item -ItemType Directory -Path $Downloads -Force | Out-Null
    }

    # --------------------------------------------------------
    # DOWNLOAD FILE 1 (.rar)
    # --------------------------------------------------------

    Download-LargeFile `
        -Url $DriveFile1 `
        -OutputFile $File1 `
        -Name "NETWORK LAB.rar"

    # --------------------------------------------------------
    # DOWNLOAD FILE 2 (.exe)
    # --------------------------------------------------------

    Download-LargeFile `
        -Url $DriveFile2 `
        -OutputFile $File2 `
        -Name "NETWORK LAB-2.exe"

    # --------------------------------------------------------
    # CREATE FOLDER AND MOVE FILE 1
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " ORGANIZING FILES" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    if (-not (Test-Path $DestinationFolder)) {
        New-Item -ItemType Directory -Path $DestinationFolder -Force | Out-Null
        Write-Host "Created folder: $DestinationFolder" -ForegroundColor Cyan
    }

    $DestinationFile1 = Join-Path $DestinationFolder "NETWORK LAB.rar"
    Move-Item -Path $File1 -Destination $DestinationFile1 -Force
    
    # Verification: Check if file was moved successfully
    if (Test-Path $DestinationFile1) {
        Write-Host "Successfully moved NETWORK LAB.rar to $DestinationFolder" -ForegroundColor Green
    } else {
        throw "Failed to move NETWORK LAB.rar to the destination folder."
    }

    # --------------------------------------------------------
    # RUN .EXE AS ADMINISTRATOR
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Launching NETWORK LAB-2.exe as Administrator..." -ForegroundColor Yellow
    
    # Verification: Launch executable with elevated permissions
    Start-Process -FilePath $File2 -Verb RunAs

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
