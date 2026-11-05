#requires -Version 5.1
<#
DigiVista - Vaultwarden Local HTTPS Deployment / Repair Script
Target: Windows 11 + WSL2 + Podman Machine + Vaultwarden + Caddy
Run from Windows PowerShell as Administrator.

What it does:
1. Verifies Administrator privileges.
2. Verifies Podman, Winget and Caddy; installs Caddy if missing.
3. Starts the Podman machine and the existing 'vaultwarden' container.
4. Confirms the container is published on host port 8080.
5. Writes a Caddyfile for https://vaultwarden.localhost -> http://127.0.0.1:8080.
6. Validates and starts/reloads Caddy.
7. Trusts Caddy's local CA where possible.
8. Tests TCP 443.
9. Creates a logon task so the stack is started again after Windows sign-in.

This script does NOT delete or recreate the Vaultwarden container or its data.
#>

$ErrorActionPreference = 'Stop'
$ContainerName = 'vaultwarden'
$HttpsHost = 'vaultwarden.localhost'
$Backend = '127.0.0.1:8080'
$BaseDir = 'C:\ProgramData\DigiVista\Vaultwarden'
$CaddyFile = Join-Path $BaseDir 'Caddyfile'
$StartupScript = Join-Path $BaseDir 'Start-Vaultwarden-Stack.ps1'
$TaskName = 'DigiVista-Vaultwarden-Stack'

function Write-Step($Text) {
    Write-Host "`n=== $Text ===" -ForegroundColor Cyan
}

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run Windows PowerShell as Administrator and launch the script again.'
    }
}

function Require-Command($Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found."
    }
}

Assert-Admin
New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null

Write-Step 'Checking required tools'
Require-Command 'podman'
Require-Command 'winget'

if (-not (Get-Command 'caddy' -ErrorAction SilentlyContinue)) {
    Write-Host 'Caddy is not installed. Installing Caddy with winget...'
    winget install --id CaddyServer.Caddy -e --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
}
Require-Command 'caddy'
Write-Host "Caddy: $((caddy version | Select-Object -First 1))"

Write-Step 'Starting Podman machine'
$machine = podman machine inspect 2>$null | ConvertFrom-Json
if (-not $machine) { throw 'No Podman machine was found.' }
if ($machine[0].State -ne 'running') {
    podman machine start
} else {
    Write-Host 'Podman machine is already running.'
}

Write-Step "Starting container '$ContainerName'"
$exists = podman ps -a --format '{{.Names}}' | Where-Object { $_ -eq $ContainerName }
if (-not $exists) {
    throw "Container '$ContainerName' does not exist. This repair script intentionally will not recreate it automatically."
}
podman start $ContainerName | Out-Null

Write-Step 'Checking Vaultwarden container and port mapping'
$port = podman port $ContainerName 80/tcp 2>$null
Write-Host "Podman mapping: $port"
if ($port -notmatch ':8080$') {
    throw "Expected container port 80 to be published on host port 8080, but found: '$port'."
}

# Optional application health test inside the container.
try {
    $health = podman exec $ContainerName curl -sS -I http://127.0.0.1:80 2>$null | Select-Object -First 1
    if ($health -match '200') { Write-Host "Vaultwarden internal health: $health" }
    else { Write-Warning "Vaultwarden internal response was: $health" }
} catch {
    Write-Warning 'Could not run curl inside the container; continuing because this check is optional.'
}

Write-Step 'Creating Caddy HTTPS reverse-proxy configuration'
$cfg = @"
$HttpsHost {
    tls internal
    reverse_proxy $Backend
}
"@
Set-Content -Path $CaddyFile -Value $cfg -Encoding UTF8
Write-Host "Caddyfile written to: $CaddyFile"

Write-Step 'Validating Caddy configuration'
caddy validate --config $CaddyFile

Write-Step 'Starting or reloading Caddy'
# If a Caddy admin endpoint is already active, reload it; otherwise start Caddy in the background.
$adminUp = Test-NetConnection -ComputerName 127.0.0.1 -Port 2019 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($adminUp) {
    caddy reload --config $CaddyFile
    Write-Host 'Caddy configuration reloaded.'
} else {
    caddy start --config $CaddyFile
    Start-Sleep -Seconds 3
    Write-Host 'Caddy started in the background.'
}

Write-Step 'Trusting Caddy local certificate authority'
try {
    caddy trust
    Write-Host 'Caddy local CA trusted.'
} catch {
    Write-Warning 'Automatic trust did not complete. If the browser shows a certificate warning, run: caddy trust'
}

Write-Step 'Creating automatic logon startup script'
$startup = @'
$ErrorActionPreference = 'SilentlyContinue'
$ContainerName = 'vaultwarden'
$CaddyFile = 'C:\ProgramData\DigiVista\Vaultwarden\Caddyfile'

# Start Podman machine if needed.
$mi = podman machine inspect 2>$null | ConvertFrom-Json
if ($mi -and $mi[0].State -ne 'running') { podman machine start | Out-Null }
Start-Sleep -Seconds 3

# Start Vaultwarden if it exists.
if (podman ps -a --format '{{.Names}}' | Where-Object { $_ -eq $ContainerName }) {
    podman start $ContainerName | Out-Null
}
Start-Sleep -Seconds 2

# Start Caddy if the local admin endpoint is not already listening; otherwise reload config.
$adminUp = Test-NetConnection -ComputerName 127.0.0.1 -Port 2019 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($adminUp) {
    caddy reload --config $CaddyFile | Out-Null
} else {
    caddy start --config $CaddyFile | Out-Null
}
'@
Set-Content -Path $StartupScript -Value $startup -Encoding UTF8

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$StartupScript`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
Write-Host "Scheduled task created: $TaskName"

Write-Step 'Final connectivity test'
$ok = Test-NetConnection -ComputerName $HttpsHost -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($ok) {
    Write-Host "SUCCESS: HTTPS is reachable at https://$HttpsHost" -ForegroundColor Green
    Start-Process "https://$HttpsHost"
} else {
    Write-Warning "Port 443 is not reachable yet. Run these diagnostics:`n  podman ps`n  podman port $ContainerName`n  caddy validate --config $CaddyFile`n  netstat -ano | findstr :443"
}

Write-Host "`nNo Vaultwarden data was deleted or recreated." -ForegroundColor Yellow
