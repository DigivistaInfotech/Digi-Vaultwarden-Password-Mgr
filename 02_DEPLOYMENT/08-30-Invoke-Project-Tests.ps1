[CmdletBinding()]
param(
    [switch]$Live
)

$ErrorActionPreference = 'Stop'
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Split-Path -Parent $ScriptRoot
$Failures = [Collections.Generic.List[string]]::new()
$Results = [Collections.Generic.List[object]]::new()

function Add-TestResult {
    param([string]$Name, [bool]$Passed, [string]$Details)
    $Results.Add([pscustomobject]@{ Test = $Name; Passed = $Passed; Details = $Details })
    if (-not $Passed) { $Failures.Add("${Name}: $Details") }
}

$requiredFiles = @(
    '08-30-SRS-DigiVista-Secure-Vault.md',
    '08-30-System-Architecture.md',
    '08-30-Security-and-Compliance.md',
    '08-30-Deployment-Runbook.md',
    '08-30-Backup-and-Restore-Runbook.md',
    '08-30-Monitoring-and-Operations.md',
    '08-30-Test-and-Acceptance-Plan.md',
    '08-30-Requirements-Traceability-Matrix.md',
    '08-30-FINAL-DEPLOYMENT-REPORT.md',
    '09-03-FINAL-VERIFICATION-REPORT.md',
    '02_DEPLOYMENT\08-30-Complete-DigiVista-Secure-Vault.ps1',
    '02_DEPLOYMENT\08-30-Start-DigiVista-Secure-Vault.ps1',
    '02_DEPLOYMENT\08-30-One-Shot-Repair-and-Validate.ps1',
    '02_DEPLOYMENT\08-30-Test-DigiVista-Compliance.ps1',
    '02_DEPLOYMENT\08-30-Invoke-Project-Tests.ps1',
    '02_DEPLOYMENT\08-30-Caddyfile.template',
    '04_ASSETS\08-30-digivista-phase2-branding.scss',
    '04_ASSETS\08-30-open-source-notices.html',
    '04_ASSETS\11-05-digivista-help.html',
    '11-05-Product-Operating-Standard.md',
    '05_REFERENCE\08-30-Approved-Component-Baseline.json',
    '05_REFERENCE\08-30-Vaultwarden-AGPL-3.0-LICENSE.txt'
)
$missing = @($requiredFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $PackageRoot $_)) })
Add-TestResult 'Required files' ($missing.Count -eq 0) $(if ($missing.Count) { $missing -join ', ' } else { "$($requiredFiles.Count) files present" })

$maintainedScripts = @(Get-ChildItem -LiteralPath $ScriptRoot -Filter '08-30-*.ps1' -File)
$parseErrors = [Collections.Generic.List[object]]::new()
foreach ($script in $maintainedScripts) {
    $tokens = $null
    $errors = $null
    [Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    foreach ($error in @($errors)) { $parseErrors.Add($error) }
}
Add-TestResult 'PowerShell parse' ($parseErrors.Count -eq 0) "$($maintainedScripts.Count) maintained scripts; $($parseErrors.Count) errors"

$maintainedTextFiles = @(
    $maintainedScripts.FullName
    (Join-Path $ScriptRoot '08-30-Caddyfile.template')
    (Join-Path $PackageRoot '04_ASSETS\08-30-digivista-phase2-branding.scss')
    (Join-Path $PackageRoot '04_ASSETS\08-30-open-source-notices.html')
    (Join-Path $PackageRoot '04_ASSETS\11-05-digivista-help.html')
) | Where-Object { $_ }
$allMaintainedText = ($maintainedTextFiles | ForEach-Object { Get-Content -LiteralPath $_ -Raw }) -join "`n"
$prohibitedPatterns = [ordered]@{
    'Podman destructive reset/removal' = '(?i)podman\s+(system\s+reset|machine\s+rm|volume\s+rm)'
    'Vault data deletion' = '(?im)^\s*(?:&\s+)?(?:rm\s+-rf\s+[^\r\n]*/data|Remove-Item[^\r\n]+/data)'
    'Execution-policy bypass' = '(?i)ExecutionPolicy\s+Bypass'
    'Elevated startup task' = '(?i)RunLevel\s+Highest'
    'Automatic package installation' = '(?i)winget\s+install|choco\s+install|scoop\s+install'
}
foreach ($entry in $prohibitedPatterns.GetEnumerator()) {
    Add-TestResult $entry.Key ($allMaintainedText -notmatch $entry.Value) 'Maintained delivery files scanned'
}

$secretPattern = '(?i)(password\s*[=:]\s*[^<\s]|token\s*[=:]\s*[A-Za-z0-9_-]{12,}|api[_-]?key\s*[=:]|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY)'
Add-TestResult 'Secret-pattern scan' ($allMaintainedText -notmatch $secretPattern) 'Maintained delivery files scanned'

$baselinePath = Join-Path $PackageRoot '05_REFERENCE\08-30-Approved-Component-Baseline.json'
try {
    $baseline = Get-Content -LiteralPath $baselinePath -Raw | ConvertFrom-Json
    $baselineValid = $baseline.schemaVersion -eq 1 -and $baseline.vaultwarden.imageId -match '^[a-f0-9]{64}$' -and $baseline.httpsHost -eq 'localhost'
    Add-TestResult 'Component baseline JSON' $baselineValid 'Schema, image ID, and localhost host checked'
} catch { Add-TestResult 'Component baseline JSON' $false $_.Exception.Message }

$branding = Get-Content -LiteralPath (Join-Path $PackageRoot '04_ASSETS\08-30-digivista-phase2-branding.scss') -Raw
$brandingRequirements = @('--dv-primary', 'DigiVista_Logo.png', 'bit-landing-header', 'bit-nav-logo > div > a > bit-svg', '@media (max-width: 639px)')
$missingBranding = @($brandingRequirements | Where-Object { $branding -notmatch [regex]::Escape($_) })
Add-TestResult 'Branding contract' ($missingBranding.Count -eq 0) $(if ($missingBranding.Count) { 'Missing: ' + ($missingBranding -join ', ') } else { 'Login, sidebar, responsive, logo, and colour rules present' })
$openBraces = ([regex]::Matches($branding, '\{')).Count
$closeBraces = ([regex]::Matches($branding, '\}')).Count
Add-TestResult 'Branding brace balance' ($openBraces -eq $closeBraces) "Open=$openBraces Close=$closeBraces"

$notice = Get-Content -LiteralPath (Join-Path $PackageRoot '04_ASSETS\08-30-open-source-notices.html') -Raw
$noticeValid = $notice -match 'Vaultwarden' -and $notice -match 'AGPL' -and $notice -match 'unmodified' -and $notice -notmatch 'Bitwarden'
Add-TestResult 'Open-source notice contract' $noticeValid 'Vaultwarden, AGPL, unmodified statement, and public branding boundary checked'

$help = Get-Content -LiteralPath (Join-Path $PackageRoot '04_ASSETS\11-05-digivista-help.html') -Raw
$helpRequirements = @('Home and family use', 'Business access model', 'If you forget the master password', 'Backup and restore', 'Employee change or exit', '/open-source-notices')
$missingHelp = @($helpRequirements | Where-Object { $help -notmatch [regex]::Escape($_) })
Add-TestResult 'Help and onboarding contract' ($missingHelp.Count -eq 0) $(if ($missingHelp.Count) { 'Missing: ' + ($missingHelp -join ', ') } else { 'Home, business, recovery, backup, lifecycle, and attribution guidance present' })

$licensePath = Join-Path $PackageRoot '05_REFERENCE\08-30-Vaultwarden-AGPL-3.0-LICENSE.txt'
$license = Get-Content -LiteralPath $licensePath -Raw
Add-TestResult 'AGPL licence file' ($license -match 'GNU AFFERO GENERAL PUBLIC LICENSE' -and (Get-Item -LiteralPath $licensePath).Length -eq 34523) "Bytes=$((Get-Item -LiteralPath $licensePath).Length)"

$maintainedDocs = @(Get-ChildItem -LiteralPath $PackageRoot -Filter '08-30-*.md' -File)
$legacyHostDocs = @($maintainedDocs | Select-String -Pattern 'vaultwarden\.localhost')
Add-TestResult 'Maintained endpoint consistency' ($legacyHostDocs.Count -eq 0) $(if ($legacyHostDocs.Count) { ($legacyHostDocs.Path | Sort-Object -Unique) -join ', ' } else { 'All maintained documents use localhost' })

$srs = Get-Content -LiteralPath (Join-Path $PackageRoot '08-30-SRS-DigiVista-Secure-Vault.md') -Raw
$traceability = Get-Content -LiteralPath (Join-Path $PackageRoot '08-30-Requirements-Traceability-Matrix.md') -Raw
$testPlan = Get-Content -LiteralPath (Join-Path $PackageRoot '08-30-Test-and-Acceptance-Plan.md') -Raw
$missingTrace = [Collections.Generic.List[string]]::new()
foreach ($prefix in @('FR','SR')) {
    $max = if ($prefix -eq 'FR') { 16 } else { 10 }
    foreach ($number in 1..$max) {
        $id = '{0}-{1:D3}' -f $prefix, $number
        if ($srs -notmatch [regex]::Escape($id) -or $traceability -notmatch [regex]::Escape($id)) { $missingTrace.Add($id) }
    }
}
foreach ($number in 1..30) {
    $id = 'T-{0:D3}' -f $number
    if ($testPlan -notmatch [regex]::Escape($id)) { $missingTrace.Add($id) }
}
Add-TestResult 'Requirements and test traceability' ($missingTrace.Count -eq 0) $(if ($missingTrace.Count) { 'Missing: ' + ($missingTrace -join ', ') } else { 'FR-001..016, SR-001..010, and T-001..030 present' })

$caddyPath = 'C:\ProgramData\DigiVista\SecureVault\Caddy\caddy.exe'
if (Test-Path -LiteralPath $caddyPath) {
    & $caddyPath validate --adapter caddyfile --config (Join-Path $ScriptRoot '08-30-Caddyfile.template') 2>$null | Out-Null
    Add-TestResult 'Caddy template validation' ($LASTEXITCODE -eq 0) "ExitCode=$LASTEXITCODE"
} else {
    Add-TestResult 'Caddy template validation' $false 'Caddy executable is unavailable'
}

if ($Live) {
    & (Join-Path $ScriptRoot '08-30-Test-DigiVista-Compliance.ps1')
    Add-TestResult 'Live compliance' ($LASTEXITCODE -eq 0) "ExitCode=$LASTEXITCODE"
}

$Results | Format-Table -AutoSize
if ($Failures.Count) {
    Write-Host "`nFAILED ($($Failures.Count))"
    $Failures | ForEach-Object { Write-Host "- $_" }
    exit 1
}
Write-Host "`nPASS ($($Results.Count) checks)"
exit 0
