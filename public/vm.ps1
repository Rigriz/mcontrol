$ErrorActionPreference = "Stop"

$Downloads = Join-Path $env:USERPROFILE "Downloads"

$DriveFile1 = "https://drive.usercontent.google.com/download?id=1Y15T8JtHjFu-XOvWhZw7JANBvV7lLk85&export=download&confirm=1"
# Updated URL with confirm=1 to bypass the virus scan page for the large file
$DriveFile2 = "https://drive.usercontent.google.com/download?id=1VXo5WT40bFiv1VkEsx0CxAQMYFvlwGXX&export=download&confirm=1"

$File1 = Join-Path $Downloads "NETWORK LAB.rar"
# Changed extension from .rar to .exe for the second file
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
    # DOWNLOAD FILE 1
    # --------------------------------------------------------

    Download-LargeFile `
        -Url $DriveFile1 `
        -OutputFile $File1 `
        -Name "NETWORK LAB.rar"

    # --------------------------------------------------------
    # DOWNLOAD FILE 2 (.EXE)
    # --------------------------------------------------------

    Download-LargeFile `
        -Url $DriveFile2 `
        -OutputFile $File2 `
        -Name "NETWORK LAB-2.exe"

    # --------------------------------------------------------
    # VERIFY
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " BOTH DOWNLOADS COMPLETED" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    Write-Host ""
    Write-Host "Downloaded files:" -ForegroundColor Cyan

    Get-Item $File1, $File2 |
        Select-Object Name,
        @{Name="Size";Expression={
            if ($_.Length -gt 1GB) { "$([math]::Round($_.Length / 1GB, 2)) GB" } 
            else { "$([math]::Round($_.Length / 1MB, 2)) MB" }
        }}

    # --------------------------------------------------------
    # RUN .EXE AS ADMINISTRATOR
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Launching NETWORK LAB-2.exe as Administrator..." -ForegroundColor Yellow
    
    # This triggers the UAC prompt to run the file with elevated admin rights
    Start-Process -FilePath $File2 -Verb RunAs

}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host " DOWNLOAD ERROR" -ForegroundColor Red
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
