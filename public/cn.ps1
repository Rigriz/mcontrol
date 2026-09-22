\$ErrorActionPreference = "Stop"

Downloads = Join-Path env:USERPROFILE "Downloads"

\$DriveFile1 = "https://drive.usercontent.google.com/download?id=1tC7Enz5xmMk-pc8-mHV6GmbZQ0mEn_fy&export=download&authuser=0"
\$DriveFile2 = "https://drive.usercontent.google.com/download?id=1RusP5GE4M__23dUxY9kgbT4P_SjHMCYg&export=download&authuser=0"

File1 = Join-Path Downloads "vcxsrv-64.1.20.14.0.installer.exe"
File2 = Join-Path Downloads "putty-64bit-0.85-installer.msi"

function Download-LargeFile {
    param(
        [string]\$Url,
        [string]\$OutputFile,
        [string]\$Name
    )

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " DOWNLOADING \$Name" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "File: \$OutputFile"
    Write-Host ""
    Write-Host "DO NOT CLOSE THIS WINDOW." -ForegroundColor Yellow
    Write-Host "The file may take a long time to download."
    Write-Host ""

    if (\$Url -match "id=([^&]+)") {
        \$FileId = \(Matches[1]\)CookieFile = New-TemporaryFile
        
        & curl.exe --silent --location --cookie-jar \(CookieFile "https://google.com\)FileId" | Out-Null
        
        \$ConfirmCode = ""
        if (Test-Path \$CookieFile) {
            CookieContent = Get-Content CookieFile | Out-String
            if (\$CookieContent -match "download_warning_([^`t]+)`t([^`r`n]+)") {
                ConfirmCode = Matches[2].Trim()
            }
            Remove-Item \$CookieFile -Force
        }

        if (\(ConfirmCode) {\)DownloadUrl = "https://google.com\(ConfirmCode&id=\)FileId"
        } else {
            \(DownloadUrl = "https://google.com\)FileId"
        }
    } else {
        DownloadUrl = Url
    }

    & curl.exe `
        --location `
        --fail `
        --retry 10 `
        --retry-delay 5 `
        --continue-at - `
        --progress-bar `
        --output "$OutputFile" `
        "\$DownloadUrl"

    if (\$LASTEXITCODE -ne 0) {
        throw "Download failed. curl exit code: \$LASTEXITCODE"
    }

    if (-not (Test-Path \$OutputFile)) {
        throw "Download did not create the expected file."
    }

    File = Get-Item OutputFile
    
    if (\$File.Length -lt 1MB) {
        throw "The downloaded file is too small (\(([math]::Round(\)File.Length / 1MB, 2)) MB). It appears Google Drive returned an HTML warning page instead of the actual file."
    }

    \(SizeMB = [math]::Round(\)File.Length / 1MB, 2)

    Write-Host ""
    Write-Host "DOWNLOAD FINISHED!" -ForegroundColor Green
    Write-Host "Name = SizeMB MB" -ForegroundColor Green
}

try {
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " NETWORK CONSOLE TOOLS DOWNLOAD" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    if (-not (Test-Path \$Downloads)) {
        New-Item -ItemType Directory -Path \$Downloads -Force | Out-Null
    }
    
    Download-LargeFile `
        -Url $DriveFile1 `
        -OutputFile \$File1 `
        -Name "vcxsrv-64.1.20.14.0.installer.exe"

    Download-LargeFile `
        -Url \$DriveFile2 `
        -OutputFile $File2 `
        -Name "putty-64bit-0.85-installer.msi"

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " ORGANIZING FILES" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "All files successfully downloaded to your Downloads folder!" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host " DOWNLOAD OR SETUP ERROR" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red

    Write-Host ""
    Write-Host \$_.Exception.Message -ForegroundColor Red

    Write-Host ""
    Write-Host "The PowerShell window will remain open." -ForegroundColor Yellow

    Read-Host "Press ENTER to close"
}
finally {
    Write-Host ""
    Write-Host "Script finished." -ForegroundColor Cyan

    Read-Host "Press ENTER to close PowerShell"
}
