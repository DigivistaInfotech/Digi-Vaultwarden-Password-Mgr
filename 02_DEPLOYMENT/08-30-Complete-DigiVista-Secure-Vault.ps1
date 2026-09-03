#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
Safely completes the existing DigiVista Secure Vault deployment.

.DESCRIPTION
Validates the existing Podman/Vaultwarden data boundary, repairs WSL host
networking only when the fault is isolated to that layer, configures the
already-installed Caddy executable, deploys approved external branding and
open-source materials, and creates a limited current-user startup task.

This script does not install software, recreate the Vaultwarden container,
remove Podman resources, modify Vaultwarden source/authentication/database
logic, or inspect vault records.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [string]$ContainerName = 'vaultwarden',
    [string]$HttpsHost = 'localhost',
    [ValidateRange(1, 65535)][int]$BackendPort = 8080,
    [string]$PodmanPath = 'C:\Users\TOOLS\AppData\Local\Programs\Podman\podman.exe',
    [string]$CaddyPath = 'C:\ProgramData\DigiVista\SecureVault\Caddy\caddy.exe',
    [switch]$SkipBranding,
    [switch]$SkipStartupTask,
    [switch]$SkipWslRepair
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Split-Path -Parent $ScriptRoot
$ProgramRoot = Join-Path $env:ProgramData 'DigiVista\SecureVault'
$CaddyFile = Join-Path $ProgramRoot 'Caddyfile'
$StartupSource = Join-Path $ScriptRoot '08-30-Start-DigiVista-Secure-Vault.ps1'
$StartupTarget = Join-Path $ProgramRoot '08-30-Start-DigiVista-Secure-Vault.ps1'
$BrandingSource = Join-Path $PackageRoot '04_ASSETS\08-30-digivista-phase2-branding.scss'
$NoticeSource = Join-Path $PackageRoot '04_ASSETS\08-30-open-source-notices.html'
$LogoSource = Join-Path $PackageRoot '04_ASSETS\DigiVista_Logo.png'
$LicenseSource = Join-Path $PackageRoot '05_REFERENCE\08-30-Vaultwarden-AGPL-3.0-LICENSE.txt'
$ReportPath = Join-Path $PackageRoot '08-30-FINAL-DEPLOYMENT-REPORT.md'
$RunStamp = Get-Date -Format 'MM-dd-yyyyMMdd-HHmmss'
$RunBackup = Join-Path $PackageRoot "06_DEPLOYMENT_BACKUP\$RunStamp"
$LogPath = Join-Path $RunBackup 'deployment.log'
$TaskName = 'DigiVista-Secure-Vault-Stack'
$ActiveScss = '/data/templates/scss/user.vaultwarden.scss.hbs'
$BrandProof = '--dv-primary'
$BackendUrl = "http://localhost:$BackendPort/"
$VaultUrl = "https://$HttpsHost"
$Result = [ordered]@{
    Preflight = 'FAIL'
    Backup = 'FAIL'
    DataMount = 'FAIL'
    Backend = 'FAIL'
    Https = 'FAIL'
    Branding = if ($SkipBranding) { 'SKIPPED' } else { 'FAIL' }
    Compliance = 'FAIL'
    StartupTask = if ($SkipStartupTask) { 'SKIPPED' } else { 'FAIL' }
}
$Changes = [Collections.Generic.List[string]]::new()
$RootCause = 'No active failure was isolated.'

function Write-DeploymentLog {
    param([string]$Message, [ValidateSet('INFO', 'PASS', 'WARN', 'FAIL')][string]$Level = 'INFO')
    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    Write-Host $line
    if (Test-Path -LiteralPath $RunBackup) {
        Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
    }
}

function Invoke-PodmanText {
    param([Parameter(Mandatory)][string[]]$Arguments, [switch]$AllowFailure)
    $output = & $PodmanPath @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $text = (($output | ForEach-Object { "$_" }) -join "`n").Trim()
    if ($exitCode -ne 0 -and -not $AllowFailure) {
        throw "Podman command failed (exit $exitCode): $($Arguments -join ' ')"
    }
    [pscustomobject]@{ ExitCode = $exitCode; Text = $text }
}

function Get-ContainerInspect {
    $response = Invoke-PodmanText -Arguments @('inspect', $ContainerName)
    $parsed = $response.Text | ConvertFrom-Json
    if ($parsed -is [array]) { return $parsed[0] }
    return $parsed
}

function Get-DataMount {
    param([Parameter(Mandatory)]$Inspect)
    $mount = @($Inspect.Mounts | Where-Object { $_.Destination -eq '/data' }) | Select-Object -First 1
    if (-not $mount) { throw "Container '$ContainerName' has no persistent mount at /data." }
    $source = if ($mount.Name) { [string]$mount.Name } else { [string]$mount.Source }
    if ([string]::IsNullOrWhiteSpace($source)) { throw 'The /data mount source could not be proven.' }
    [pscustomobject]@{ Type = [string]$mount.Type; Name = [string]$mount.Name; Source = $source; Destination = [string]$mount.Destination; RW = [bool]$mount.RW }
}

function Test-TcpPort {
    param([string]$ComputerName, [int]$Port)
    try {
        [bool](Test-NetConnection -ComputerName $ComputerName -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue)
    } catch { $false }
}

function Test-Http200 {
    param([Parameter(Mandatory)][string]$Uri)
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
        $arguments = @('--silent', '--show-error', '--output', 'NUL', '--write-out', '%{http_code}', '--max-time', '20')
        if ($Uri.StartsWith('https://', [StringComparison]::OrdinalIgnoreCase)) { $arguments += '--insecure' }
        $status = & $curl.Source @arguments $Uri
        return $LASTEXITCODE -eq 0 -and $status -eq '200'
    }
    try { return (Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 20).StatusCode -eq 200 } catch { return $false }
}

function Test-ContainerHttp {
    $probe = Invoke-PodmanText -Arguments @('exec', $ContainerName, 'sh', '-c', 'if command -v curl >/dev/null 2>&1; then curl -fsS -o /dev/null http://127.0.0.1:80; else wget -q -O /dev/null http://127.0.0.1:80; fi') -AllowFailure
    $probe.ExitCode -eq 0
}

function Test-MachineBackend {
    $command = "if command -v curl >/dev/null 2>&1; then curl -fsS -o /dev/null http://127.0.0.1:$BackendPort; else wget -q -O /dev/null http://127.0.0.1:$BackendPort; fi"
    (Invoke-PodmanText -Arguments @('machine', 'ssh', $command) -AllowFailure).ExitCode -eq 0
}

function Set-WslMirroredNetworking {
    $wslConfig = Join-Path $env:USERPROFILE '.wslconfig'
    $lines = [Collections.Generic.List[string]]::new()
    if (Test-Path -LiteralPath $wslConfig) { Get-Content -LiteralPath $wslConfig | ForEach-Object { $lines.Add($_) } }
    $sectionStart = -1
    $sectionEnd = $lines.Count
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index].Trim() -match '^\[wsl2\]$') { $sectionStart = $index; continue }
        if ($sectionStart -ge 0 -and $index -gt $sectionStart -and $lines[$index].Trim() -match '^\[.+\]$') { $sectionEnd = $index; break }
    }
    if ($sectionStart -lt 0) {
        if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim()) { $lines.Add('') }
        $lines.Add('[wsl2]')
        $lines.Add('networkingMode=mirrored')
    } else {
        $keyIndex = -1
        for ($index = $sectionStart + 1; $index -lt $sectionEnd; $index++) {
            if ($lines[$index].Trim() -match '^networkingMode\s*=') { $keyIndex = $index; break }
        }
        if ($keyIndex -ge 0) { $lines[$keyIndex] = 'networkingMode=mirrored' } else { $lines.Insert($sectionStart + 1, 'networkingMode=mirrored') }
    }
    Set-Content -LiteralPath $wslConfig -Value $lines -Encoding UTF8
}

function Write-FinalReport {
    param([string]$Failure = '')
    $rows = ($Result.GetEnumerator() | ForEach-Object { "| $($_.Key) | $($_.Value) |" }) -join "`n"
    $changeRows = if ($Changes.Count) { ($Changes | ForEach-Object { "- $_" }) -join "`n" } else { '- No mutations completed.' }
    $failureText = if ($Failure) { $Failure.Replace('|', '\|') } else { 'None.' }
    $report = @"
# DigiVista Secure Vault — Final Deployment Report

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')

## Scope boundary

No Vaultwarden source, binary, authentication logic, database schema, user, password, or vault record was modified or inspected.

## Automated result

| Check | Result |
|---|---|
$rows

## Root cause

$RootCause

## Controlled changes

$changeRows

## Backup

`$RunBackup`

## Failure

$failureText

## Remaining manual acceptance

Authorized login/logout, authenticated dashboard appearance, representative vault operations, full Windows restart persistence, isolated restore exercise, and owner/legal approval.
"@
    Set-Content -LiteralPath $ReportPath -Value $report -Encoding UTF8
}

try {
    New-Item -ItemType Directory -Path $RunBackup -Force | Out-Null
    Write-DeploymentLog 'Starting controlled completion workflow.'

    foreach ($required in @($PodmanPath, $CaddyPath, $StartupSource, $NoticeSource, $LogoSource, $LicenseSource)) {
        if (-not (Test-Path -LiteralPath $required)) { throw "Required controlled dependency is missing: $required" }
    }
    if (-not $SkipBranding -and -not (Test-Path -LiteralPath $BrandingSource)) { throw "Approved branding source is missing: $BrandingSource" }
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) { throw 'WSL is unavailable.' }
    $Result.Preflight = 'PASS'

    $machine = (Invoke-PodmanText -Arguments @('machine', 'inspect')).Text | ConvertFrom-Json
    if (@($machine).Count -eq 0) { throw 'No existing Podman machine was found.' }
    if (@($machine)[0].State -ne 'running' -and $PSCmdlet.ShouldProcess('Existing Podman machine', 'Start')) {
        Invoke-PodmanText -Arguments @('machine', 'start') | Out-Null
        $Changes.Add('Started the existing Podman machine.')
    }

    $names = (Invoke-PodmanText -Arguments @('ps', '-a', '--format', '{{.Names}}')).Text -split "`r?`n"
    if ($names -notcontains $ContainerName) { throw "Existing container '$ContainerName' was not found." }
    if ($PSCmdlet.ShouldProcess($ContainerName, 'Start existing container')) { Invoke-PodmanText -Arguments @('start', $ContainerName) -AllowFailure | Out-Null }

    $inspectBefore = Get-ContainerInspect
    $mountBefore = Get-DataMount -Inspect $inspectBefore
    [pscustomobject]@{
        Name = $inspectBefore.Name
        ImageId = $inspectBefore.Image
        ImageName = $inspectBefore.ImageName
        Status = $inspectBefore.State.Status
        Privileged = [bool]$inspectBefore.HostConfig.Privileged
        RestartPolicy = $inspectBefore.HostConfig.RestartPolicy.Name
        DataMount = $mountBefore
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $RunBackup 'vaultwarden-safe-evidence.json') -Encoding UTF8
    $mountBefore | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $RunBackup 'data-mount-evidence.json') -Encoding UTF8
    $Result.DataMount = 'PASS'

    $wslConfig = Join-Path $env:USERPROFILE '.wslconfig'
    if (Test-Path -LiteralPath $wslConfig) { Copy-Item -LiteralPath $wslConfig -Destination (Join-Path $RunBackup 'wslconfig.before') }
    if (Test-Path -LiteralPath $CaddyFile) { Copy-Item -LiteralPath $CaddyFile -Destination (Join-Path $RunBackup 'Caddyfile.before') }
    $brandingBackup = Join-Path $RunBackup 'user.vaultwarden.scss.hbs.before'
    $brandingBackupResult = Invoke-PodmanText -Arguments @('cp', "${ContainerName}:$ActiveScss", $brandingBackup) -AllowFailure
    $hadBranding = $brandingBackupResult.ExitCode -eq 0
    $Result.Backup = 'PASS'

    if (-not (Test-ContainerHttp)) { throw 'Vaultwarden failed its internal HTTP probe.' }
    $machineBackend = Test-MachineBackend
    $windowsBackend = Test-TcpPort -ComputerName '127.0.0.1' -Port $BackendPort
    if (-not $windowsBackend -and $machineBackend) {
        $RootCause = 'Container and Podman-machine HTTP were healthy, but Windows could not reach the published backend; the fault was isolated to WSL host forwarding.'
        if ($SkipWslRepair) { throw 'WSL repair was required but explicitly skipped.' }
        $wslVersionText = (& wsl.exe --version 2>&1 | Out-String)
        if ($wslVersionText -notmatch 'WSL version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)') { throw 'WSL version could not be proven.' }
        if ([version]::new([int]$Matches[1], [int]$Matches[2], [int]$Matches[3]) -lt [version]'2.0.0') { throw 'Installed WSL does not support the approved mirrored-networking repair.' }
        if ($PSCmdlet.ShouldProcess($wslConfig, 'Merge networkingMode=mirrored and restart WSL/Podman')) {
            Set-WslMirroredNetworking
            Invoke-PodmanText -Arguments @('machine', 'stop') -AllowFailure | Out-Null
            & wsl.exe --shutdown
            Start-Sleep -Seconds 3
            Invoke-PodmanText -Arguments @('machine', 'start') | Out-Null
            Invoke-PodmanText -Arguments @('start', $ContainerName) -AllowFailure | Out-Null
            Start-Sleep -Seconds 8
            $Changes.Add('Merged WSL mirrored networking and restarted the minimum required components.')
        }
        $windowsBackend = Test-TcpPort -ComputerName '127.0.0.1' -Port $BackendPort
    }
    if (-not $windowsBackend) { throw "Windows cannot reach the backend on port $BackendPort." }
    $Result.Backend = 'PASS'

    $foreign443 = @(Get-NetTCPConnection -LocalPort 443 -State Listen -ErrorAction SilentlyContinue | Where-Object {
        $process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        $process -and $process.ProcessName -ne 'caddy'
    })
    if ($foreign443.Count) { throw 'Port 443 is owned by a non-Caddy process; nothing was stopped.' }

    if ($PSCmdlet.ShouldProcess($ProgramRoot, 'Install controlled proxy configuration and public assets')) {
        $assetsDir = Join-Path $ProgramRoot 'assets'
        $noticeDir = Join-Path $ProgramRoot 'open-source-notices'
        $licenseDir = Join-Path $ProgramRoot 'licenses'
        New-Item -ItemType Directory -Path $assetsDir, $noticeDir, $licenseDir -Force | Out-Null
        Copy-Item -LiteralPath $LogoSource -Destination (Join-Path $assetsDir 'DigiVista_Logo.png') -Force
        Copy-Item -LiteralPath $NoticeSource -Destination (Join-Path $noticeDir 'index.html') -Force
        Copy-Item -LiteralPath $LicenseSource -Destination (Join-Path $licenseDir '08-30-Vaultwarden-AGPL-3.0-LICENSE.txt') -Force
        Copy-Item -LiteralPath $StartupSource -Destination $StartupTarget -Force
        $caddyConfig = @"
$HttpsHost {
    tls internal
    handle /digivista-assets/* {
        uri strip_prefix /digivista-assets
        root * $($assetsDir.Replace('\', '/'))
        file_server
    }
    handle /open-source-notices* {
        root * $($noticeDir.Replace('\', '/'))
        rewrite * /index.html
        file_server
    }
    handle /licenses/* {
        uri strip_prefix /licenses
        root * $($licenseDir.Replace('\', '/'))
        file_server
    }
    @customcss path /css/vaultwarden.css
    header @customcss Cache-Control "no-store, no-cache, must-revalidate"
    reverse_proxy 127.0.0.1:$BackendPort
}
"@
        Set-Content -LiteralPath $CaddyFile -Value $caddyConfig -Encoding UTF8
        $Changes.Add('Installed controlled Caddy configuration, DigiVista logo, notice, licence, and startup helper.')
    }

    & $CaddyPath validate --config $CaddyFile
    if ($LASTEXITCODE -ne 0) { throw 'Caddy configuration validation failed.' }
    if ($PSCmdlet.ShouldProcess($HttpsHost, 'Trust local CA and start or reload Caddy')) {
        & $CaddyPath trust
        if ($LASTEXITCODE -ne 0) { throw 'Caddy local CA trust failed.' }
        if (Test-TcpPort -ComputerName '127.0.0.1' -Port 2019) { & $CaddyPath reload --config $CaddyFile } else { & $CaddyPath start --config $CaddyFile }
        if ($LASTEXITCODE -ne 0) { throw 'Caddy start/reload failed.' }
    }
    Start-Sleep -Seconds 3
    if (-not (Test-Http200 -Uri "$VaultUrl/")) { throw 'HTTPS login endpoint did not return HTTP 200.' }
    $Result.Https = 'PASS'

    if (-not $SkipBranding -and $PSCmdlet.ShouldProcess($ActiveScss, 'Install approved external DigiVista stylesheet')) {
        Invoke-PodmanText -Arguments @('exec', $ContainerName, 'sh', '-c', 'mkdir -p /data/templates/scss') | Out-Null
        Invoke-PodmanText -Arguments @('cp', $BrandingSource, "${ContainerName}:$ActiveScss") | Out-Null
        Invoke-PodmanText -Arguments @('restart', $ContainerName) | Out-Null
        Start-Sleep -Seconds 8
        $Changes.Add('Installed approved external DigiVista stylesheet and restarted only Vaultwarden.')
    }
    if (-not $SkipBranding) {
        $temporaryCss = Join-Path $RunBackup 'live-branding.scss'
        try {
            Invoke-PodmanText -Arguments @('cp', "${ContainerName}:$ActiveScss", $temporaryCss) | Out-Null
            if ((Get-FileHash -LiteralPath $temporaryCss -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $BrandingSource -Algorithm SHA256).Hash) { throw 'Live stylesheet does not match the approved source.' }
            $cssStatus = & curl.exe --insecure --silent --show-error --max-time 20 "$VaultUrl/css/vaultwarden.css?dv=$RunStamp"
            if ($LASTEXITCODE -ne 0 -or $cssStatus -notmatch [regex]::Escape($BrandProof)) { throw 'Compiled branding proof was not served.' }
            $Result.Branding = 'PASS'
        } catch {
            if ($hadBranding) { Invoke-PodmanText -Arguments @('cp', $brandingBackup, "${ContainerName}:$ActiveScss") -AllowFailure | Out-Null }
            else { Invoke-PodmanText -Arguments @('exec', $ContainerName, 'sh', '-c', "if [ -f '$ActiveScss' ]; then mv '$ActiveScss' '$ActiveScss.failed-$RunStamp'; fi") -AllowFailure | Out-Null }
            Invoke-PodmanText -Arguments @('restart', $ContainerName) -AllowFailure | Out-Null
            throw
        }
    }

    if (-not (Test-Http200 -Uri "$VaultUrl/open-source-notices")) { throw 'Open-source notice did not return HTTP 200.' }
    if (-not (Test-Http200 -Uri "$VaultUrl/licenses/08-30-Vaultwarden-AGPL-3.0-LICENSE.txt")) { throw 'Local AGPL licence did not return HTTP 200.' }
    if (-not (Test-Http200 -Uri "$VaultUrl/digivista-assets/DigiVista_Logo.png")) { throw 'DigiVista logo did not return HTTP 200.' }
    $Result.Compliance = 'PASS'

    $mountAfter = Get-DataMount -Inspect (Get-ContainerInspect)
    if ($mountAfter.Source -ne $mountBefore.Source -or $mountAfter.Destination -ne '/data') { throw 'The persistent /data mount changed unexpectedly.' }
    $Result.DataMount = 'PASS'

    if (-not $SkipStartupTask -and $PSCmdlet.ShouldProcess($TaskName, 'Register limited current-user startup task')) {
        $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -File `"$StartupTarget`""
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        $Changes.Add('Registered a limited current-user startup task without execution-policy bypass.')
    }
    if (-not $SkipStartupTask) {
        $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
        if ($task.Principal.RunLevel -ne 'Limited' -or $task.Actions.Arguments -match 'ExecutionPolicy\s+Bypass') { throw 'Startup task does not meet the limited/no-bypass policy.' }
        $Result.StartupTask = 'PASS'
    }

    Write-FinalReport
    Write-DeploymentLog 'All automated completion checks passed.' 'PASS'
    $Result.GetEnumerator() | ForEach-Object { Write-Host ('{0,-16} {1}' -f $_.Key, $_.Value) }
    Write-Host "Report: $ReportPath"
    Write-Host 'Manual owner acceptance remains required for authenticated workflows and restore testing.'
} catch {
    Write-DeploymentLog $_.Exception.Message 'FAIL'
    Write-FinalReport -Failure $_.Exception.Message
    throw
}
