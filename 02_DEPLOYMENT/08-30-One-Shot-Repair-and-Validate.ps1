[CmdletBinding()]
param(
    [string]$PodmanPath,
    [string]$Container = 'vaultwarden'
)

$ErrorActionPreference = 'Stop'
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Split-Path -Parent $ScriptRoot
if (-not $PodmanPath) {
    $PodmanPath = (Get-Command podman.exe -ErrorAction SilentlyContinue).Source
    if (-not $PodmanPath) { $PodmanPath = Join-Path $env:LOCALAPPDATA 'Programs\Podman\podman.exe' }
}
$StartupScript = Join-Path $ScriptRoot '08-30-Start-DigiVista-Secure-Vault.ps1'
$BrandingSource = Join-Path $PackageRoot '04_ASSETS\08-30-digivista-phase2-branding.scss'
$ComplianceTest = Join-Path $ScriptRoot '08-30-Test-DigiVista-Compliance.ps1'
$LiveBranding = '/data/templates/scss/user.vaultwarden.scss.hbs'
$BackupRoot = Join-Path $PackageRoot ('06_REPAIR_BACKUP\' + (Get-Date -Format 'MM-dd-HHmmss'))

foreach ($required in @($PodmanPath, $StartupScript, $BrandingSource, $ComplianceTest)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required controlled file is missing: $required" }
}

New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

# Preserve only the external presentation file. Vault data, database, users,
# passwords, authentication logic, source code, and binaries remain untouched.
$brandingBackup = Join-Path $BackupRoot 'user.vaultwarden.scss.hbs.before'
& $PodmanPath cp "${Container}:$LiveBranding" $brandingBackup 2>$null
$hadBranding = $LASTEXITCODE -eq 0

& $StartupScript
if ($LASTEXITCODE -ne 0) { throw "Controlled startup failed with exit code $LASTEXITCODE." }

try {
    & $PodmanPath cp $BrandingSource "${Container}:$LiveBranding"
    if ($LASTEXITCODE -ne 0) { throw 'Could not deploy the approved external stylesheet.' }

    & $PodmanPath restart $Container | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Vaultwarden container restart failed.' }
    Start-Sleep -Seconds 6

    & $ComplianceTest -PodmanPath $PodmanPath
    if ($LASTEXITCODE -ne 0) { throw 'One or more compliance checks failed.' }
} catch {
    if ($hadBranding) {
        & $PodmanPath cp $brandingBackup "${Container}:$LiveBranding" 2>$null | Out-Null
    } else {
        & $PodmanPath exec $Container sh -c "if [ -f '$LiveBranding' ]; then mv '$LiveBranding' '$LiveBranding.failed'; fi" 2>$null | Out-Null
    }
    & $PodmanPath restart $Container 2>$null | Out-Null
    throw
}

$temporaryLiveCopy = Join-Path ([IO.Path]::GetTempPath()) ('digivista-live-css-' + [guid]::NewGuid().ToString('N') + '.scss')
try {
    & $PodmanPath cp "${Container}:$LiveBranding" $temporaryLiveCopy
    if ($LASTEXITCODE -ne 0) { throw 'Could not verify the deployed stylesheet.' }
    $sourceHash = (Get-FileHash -LiteralPath $BrandingSource -Algorithm SHA256).Hash
    $liveHash = (Get-FileHash -LiteralPath $temporaryLiveCopy -Algorithm SHA256).Hash
    if ($sourceHash -ne $liveHash) { throw 'Deployed stylesheet does not match the approved source.' }
} finally {
    if (Test-Path -LiteralPath $temporaryLiveCopy) { Remove-Item -LiteralPath $temporaryLiveCopy -Force }
}

[pscustomobject]@{
    Status = 'PASS'
    Url = 'https://localhost/#/login'
    BrandingSHA256 = $sourceHash
    RollbackBackup = $BackupRoot
    VaultwardenCodeModified = $false
    VaultDataModified = $false
} | Format-List
