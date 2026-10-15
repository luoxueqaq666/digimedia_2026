# Guanlan local launcher
# Single source of truth for the port: $env:PORT (default 4321), matching server/index.mjs
# and the same-origin relative API paths used by the frontend.
# When the port is taken we report it and exit. We never terminate other processes.
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$port = if ($env:PORT) { [int]$env:PORT } else { 4321 }
$url = "http://127.0.0.1:$port"
$logs = Join-Path $root 'logs'
New-Item -ItemType Directory -Path $logs -Force | Out-Null

function Test-GuanlanHealth {
    param([string]$Target)
    try {
        $response = Invoke-RestMethod -Uri "$Target/api/health" -TimeoutSec 2
        return ($null -ne $response.ok -and $response.ok -eq $true)
    } catch { return $false }
}

# 1) Already running: reuse it instead of starting a duplicate.
if (Test-GuanlanHealth $url) {
    Write-Output "Already running: $url"
    exit 0
}

# 2) Port taken by something else: report and exit. Terminate nothing.
$occupied = Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue
if ($occupied) {
    $owners = ($occupied | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object {
        $p = Get-Process -Id $_ -ErrorAction SilentlyContinue
        if ($p) { "$($p.ProcessName) (PID $($p.Id))" } else { "PID $_" }
    }) -join ', '
    Write-Error "Port $port is already in use by: $owners. Nothing was terminated. Set a different port, e.g. `$env:PORT=4322, then rerun this script."
    exit 1
}

# 3) Pick a Node runtime.
$runtime = 'C:\Users\zheye\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
if (-not (Test-Path -LiteralPath $runtime)) {
    $runtime = (Get-Command node -ErrorAction Stop).Source
}

$env:PORT = "$port"
$env:GUANLAN_FIXED_PORT = '1'
if (Test-Path -LiteralPath (Join-Path $root 'guanlan.sqlite')) {
    $env:DB_PATH = Join-Path $root 'guanlan.sqlite'
}

$outLog = Join-Path $logs 'server-out.log'
$errLog = Join-Path $logs 'server-error.log'
# Truncate old logs so a previous failure is not mistaken for the current one.
# A running server (or another project's process) may hold these files open; that must
# not abort startup, so failures here are ignored rather than fatal.
$canTruncate = $true
foreach ($logPath in @($outLog, $errLog)) {
    try { Set-Content -LiteralPath $logPath -Value '' -NoNewline -ErrorAction Stop }
    catch {
        $canTruncate = $false
        Write-Warning "Could not truncate $logPath (in use): $($_.Exception.Message)"
    }
}
# If the canonical logs are locked, redirect to per-run files instead of failing.
# Start-Process cannot write a stream into a file another process holds open.
if (-not $canTruncate) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $outLog = Join-Path $logs "server-out-$stamp.log"
    $errLog = Join-Path $logs "server-error-$stamp.log"
    Write-Output "Using per-run logs: $outLog"
}
# Record where this run's output lives, so a user can always find the current logs.
Set-Content -LiteralPath (Join-Path $logs 'server-logs.txt') -Value "$outLog`n$errLog" -ErrorAction SilentlyContinue

# 4) Start detached with hidden window and redirected logs, so the server is not
#    reaped when the launching shell or its job ends.
$process = Start-Process -FilePath $runtime -ArgumentList 'server/index.mjs' `
    -WorkingDirectory $root -WindowStyle Hidden -PassThru `
    -RedirectStandardOutput $outLog -RedirectStandardError $errLog

# 5) Poll the health endpoint for up to 30 seconds.
for ($attempt = 0; $attempt -lt 60; $attempt++) {
    Start-Sleep -Milliseconds 500
    if (Test-GuanlanHealth $url) {
        Write-Output "Running: $url (PID $($process.Id))"
        Write-Output "Health: $url/api/health"
        exit 0
    }
    $process.Refresh()
    if ($process.HasExited) {
        $detail = (Get-Content -LiteralPath $errLog -Raw -ErrorAction SilentlyContinue)
        Write-Error "Server exited immediately (exit code $($process.ExitCode)). Error log: $errLog . Detail: $detail"
        exit 1
    }
}
Write-Error "Server did not pass the health check within 30 seconds. See $errLog and $outLog"
exit 1
