$ErrorActionPreference = "Stop"

$Downloads = Join-Path $env:USERPROFILE "Downloads"

# Added &confirm=1 to bypass Google Drive's large file virus-scan warning page
$DriveFile1 = "https://drive.usercontent.google.com/download?id=1Y15T8JtHjFu-XOvWhZw7JANBvV7lLk85&export=download&confirm=1"
$DriveFile2 = "https://drive.usercontent.google.com/download?id=1VXo5WT40bFiv1VkEsx0CxAQMYFvlwGXX&export=download&confirm=1"

$File1 = Join-Path $Downloads "NETWORK LAB.rar"
$File2 = Join-Path $Downloads "NETWORK LAB-2.rar"

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

    # Verify if the file is actually an HTML error/warning page instead of a large archive
    $File = Get-Item $OutputFile
    if ($File.Length -lt 10MB) {
        throw "The downloaded file is too small ($([math]::Round($File.Length / 1MB, 2)) MB). It appears Google Drive returned an HTML warning page instead of the archive. Please check the file permissions."
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
    # DOWNLOAD FILE 2
    # --------------------------------------------------------

    Download-LargeFile `
        -Url $DriveFile2 `
        -OutputFile $File2 `
        -Name "NETWORK LAB-2.rar"

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
        @{Name="SizeGB";Expression={[math]::Round($_.Length / 1GB, 2)}}

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

    # This prevents the window from disappearing.
    Read-Host "Press ENTER to close PowerShell"
}
