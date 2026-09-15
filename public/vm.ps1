# Run this PowerShell script as Administrator

$ErrorActionPreference = "Stop"

Write-Host "=== Uninstalling Oracle VirtualBox ===" -ForegroundColor Cyan

# Find installed VirtualBox entries
$virtualBox = Get-CimInstance Win32_Product |
    Where-Object { $_.Name -like "Oracle VM VirtualBox*" }

if ($virtualBox) {
    foreach ($app in $virtualBox) {
        Write-Host "Uninstalling: $($app.Name)"
        $result = Invoke-CimMethod -InputObject $app -MethodName Uninstall

        if ($result.ReturnValue -ne 0) {
            Write-Warning "Uninstall returned code $($result.ReturnValue)"
        }
    }
}
else {
    Write-Host "Oracle VirtualBox was not found."
}

Write-Host "`n=== Looking for VMware installer ===" -ForegroundColor Cyan

$installer = Join-Path $env:USERPROFILE "Downloads\VMware-player-full-17.0.0-20800274.exe"

if (-not (Test-Path $installer)) {
    Write-Error "VMware installer not found: $installer"
    exit 1
}

Write-Host "Found installer:"
Write-Host $installer

Write-Host "`n=== Starting VMware Player installer ===" -ForegroundColor Cyan

Start-Process -FilePath $installer -Verb RunAs -Wait

Write-Host "`nVMware Player installer has finished." -ForegroundColor Green
