[CmdletBinding()]
param(
    [string]$PodmanPath,
    [string]$BaselinePath,
    [switch]$SkipStartupTaskCheck
)

$ErrorActionPreference = 'Stop'
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Split-Path -Parent $ScriptRoot

if (-not $PodmanPath) {
    $PodmanPath = (Get-Command podman.exe -ErrorAction SilentlyContinue).Source
    if (-not $PodmanPath) { $PodmanPath = Join-Path $env:LOCALAPPDATA 'Programs\Podman\podman.exe' }
}
if (-not $BaselinePath) { $BaselinePath = Join-Path $PackageRoot '05_REFERENCE\08-30-Approved-Component-Baseline.json' }
if (-not (Test-Path -LiteralPath $BaselinePath)) { throw "Approved component baseline is unavailable: $BaselinePath" }
$baseline = Get-Content -LiteralPath $BaselinePath -Raw | ConvertFrom-Json
$ExpectedImageId = [string]$baseline.vaultwarden.imageId
$ExpectedMount = [string]$baseline.dataVolumeName
$ContainerName = [string]$baseline.containerName
$TaskName = [string]$baseline.startupTaskName
$BackendPort = [int]$baseline.backendPort
$HttpsHost = [string]$baseline.httpsHost

function Test-Http200 {
    param([Parameter(Mandatory)][string]$Uri)
    $status = & curl.exe --insecure --silent --show-error --output NUL --write-out '%{http_code}' --max-time 20 $Uri
    return $LASTEXITCODE -eq 0 -and $status -eq '200'
}

if (-not (Test-Path -LiteralPath $PodmanPath)) { throw 'Podman executable is unavailable.' }

$container = & $PodmanPath inspect $ContainerName | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Vaultwarden container inspection failed.' }
if (-not $container) { throw 'Vaultwarden container was not found.' }

$dataMount = $container[0].Mounts | Where-Object { $_.Destination -eq '/data' }
$task = if ($SkipStartupTaskCheck) { $null } else { Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop }
$taskInfo = if ($SkipStartupTaskCheck) { $null } else { Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction Stop }

$checks = [ordered]@{
    ContainerRunning = $container[0].State.Status -eq 'running'
    ApprovedImageId = $container[0].Image -eq $ExpectedImageId
    PersistentDataMount = $dataMount.Name -eq $ExpectedMount
    ContainerNotPrivileged = -not $container[0].HostConfig.Privileged
    BackendHttp200 = Test-Http200 -Uri "http://localhost:$BackendPort/"
    HttpsHttp200 = Test-Http200 -Uri "https://$HttpsHost/"
    NoticeHttp200 = Test-Http200 -Uri "https://$HttpsHost/open-source-notices"
    LicenseHttp200 = Test-Http200 -Uri "https://$HttpsHost/licenses/08-30-Vaultwarden-AGPL-3.0-LICENSE.txt"
    StartupTaskLimited = $SkipStartupTaskCheck -or $task.Principal.RunLevel -eq 'Limited'
    StartupTaskNoPolicyBypass = $SkipStartupTaskCheck -or $task.Actions.Arguments -notmatch 'ExecutionPolicy\s+Bypass'
    StartupTaskLastResult = $SkipStartupTaskCheck -or $taskInfo.LastTaskResult -eq 0
}

$checks.GetEnumerator() | ForEach-Object {
    [pscustomobject]@{ Control = $_.Key; Passed = [bool]$_.Value }
} | Format-Table -AutoSize

if ($checks.Values -contains $false) { exit 1 }
exit 0
