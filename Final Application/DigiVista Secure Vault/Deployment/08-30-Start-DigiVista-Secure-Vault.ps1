$ErrorActionPreference = 'Stop'

$Podman = (Get-Command podman.exe -ErrorAction SilentlyContinue).Source
if (-not $Podman) {
    $Podman = Join-Path $env:LOCALAPPDATA 'Programs\Podman\podman.exe'
}
$Caddy = 'C:\ProgramData\DigiVista\SecureVault\Caddy\caddy.exe'
$CaddyFile = 'C:\ProgramData\DigiVista\SecureVault\Caddyfile'
$RuntimeCaddyFile = Join-Path $PSScriptRoot '08-30-Caddyfile.runtime'
$Container = 'vaultwarden'

if (-not (Test-Path -LiteralPath $Podman)) { exit 10 }
if (-not (Test-Path -LiteralPath $Caddy)) { exit 11 }
if (-not (Test-Path -LiteralPath $CaddyFile)) { exit 12 }
if (-not (Test-Path -LiteralPath $RuntimeCaddyFile)) { exit 12 }

try {
    $machine = & $Podman machine inspect 2>$null | ConvertFrom-Json
    $machineState = @($machine)[0].State
    if ($machineState -ne 'running') {
        & $Podman machine start | Out-Null
        if ($LASTEXITCODE -ne 0) { exit 15 }
        Start-Sleep -Seconds 8
    }
} catch { exit 15 }

$exists = & $Podman ps -a --format '{{.Names}}' | Where-Object { $_ -eq $Container }
if (-not $exists) { exit 13 }

& $Podman start $Container 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { exit 16 }
Start-Sleep -Seconds 5

$backendStatus = & curl.exe --silent --show-error --output NUL --write-out '%{http_code}' --max-time 20 'http://localhost:8080/'
if ($LASTEXITCODE -ne 0 -or $backendStatus -ne '200') { exit 17 }

# The runtime configuration disables Caddy's optional port-80 redirect because
# Windows may reserve that port through HTTP.sys. The HTTPS vault remains on 443.
$adminReady = Test-NetConnection -ComputerName 127.0.0.1 -Port 2019 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($adminReady) {
    & $Caddy reload --config $RuntimeCaddyFile --adapter caddyfile | Out-Null
} else {
    & $Caddy start --config $RuntimeCaddyFile --adapter caddyfile | Out-Null
}
if ($LASTEXITCODE -ne 0) { exit 18 }

$httpsStatus = & curl.exe --insecure --silent --show-error --output NUL --write-out '%{http_code}' --max-time 20 'https://localhost/'
if ($LASTEXITCODE -ne 0 -or $httpsStatus -ne '200') { exit 14 }
exit 0
