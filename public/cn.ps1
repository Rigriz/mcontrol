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

    # Extract the ID from the Google Drive URL
    if (\$Url -match "id=([^&]+)") {
        FileId = Matches[1]
        
        # Step 1: Get the confirmation cookie/token from Google Drive
        \$CookieFile = New-TemporaryFile
        & curl.exe --silent --cookie-jar \(CookieFile "https://google.com\)FileId" | Out-Null
        
        # Extract confirmation code from cookie file
        \$ConfirmCode = ""
        if (Test-Path \$CookieFile) {
            CookieContent = Get-Content CookieFile | Out-String
            if (\$CookieContent -match "download_warning_([^`t]+)`t([^`r`n]+)") {
                ConfirmCode = CookieContent.Split()[-1]
            }
            Remove-Item \$CookieFile -Force
        }

        # Step 2: Build the final download URL
        if (\(ConfirmCode) {\)DownloadUrl = "https://google.com\(ConfirmCode&id=\)FileId"
        } else {
            \(DownloadUrl = "https://google.com\)FileId"
        }
    } else {
        # Fallback to the provided URL if it doesn't match standard Drive ID structure
        DownloadUrl = Url
    }

    # Step 3: Run the actual curl download
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
    if (\$File.Length -lt 10MB) {
        throw "The downloaded file is too small (\(([math]::Round(\)File.Length / 1MB, 2)) MB). It appears Google Drive returned an HTML warning page instead of the actual file."
    }

    \(SizeGB = [math]::Round(\)File.Length / 1GB, 2)

    Write-Host ""
    Write-Host "DOWNLOAD FINISHED!" -ForegroundColor Green
    Write-Host "Name = SizeGB GB" -ForegroundColor Green
}
