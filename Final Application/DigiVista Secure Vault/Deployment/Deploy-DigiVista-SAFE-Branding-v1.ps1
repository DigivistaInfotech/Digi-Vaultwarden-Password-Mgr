#requires -RunAsAdministrator
<#
DigiVista Secure Vault - SAFE BRANDING v1
Reviewed against current Vaultwarden custom-CSS behavior.

GOAL
----
Apply DigiVista branding without touching login form structure, password inputs,
authentication flow, users, database, HTTPS, Caddy, or the vw-data volume.

IMPORTANT DESIGN RULE
---------------------
This script deliberately DOES NOT:
  - rewrite H1/H2 text with pseudo-elements
  - resize/reposition forms or password fields
  - style generic bit-card/tw-rounded-* containers
  - hide generic SVG/bit-icon elements
  - append to old CSS

Those earlier techniques can conflict with Vaultwarden's changing Angular DOM.

WHAT IT DOES
------------
  - creates ONE clean custom SCSS file
  - uses DigiVista navy/white colors
  - changes primary button colors only
  - replaces the post-render login/lock logo via img.new-logo-themed
  - applies a constrained sidebar logo override only inside bit-nav-logo
  - colors the sidebar/top navigation conservatively
  - backs up everything it changes
  - verifies the custom CSS marker is served over HTTPS

ROLLBACK
--------
A rollback command is printed at the end. It only disables this custom SCSS.
#>

$ErrorActionPreference = "Stop"

$Container = "vaultwarden"
$BrandDir  = "C:\vault-branding"
$LogoPath  = Join-Path $BrandDir "DigiVista_Logo.png"
$HostCss   = Join-Path $BrandDir "digivista-vault-SAFE-v1.css"
$ActiveScss = "/data/templates/scss/user.vaultwarden.scss.hbs"
$VaultUrl = "https://vaultwarden.localhost"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupDir = Join-Path $BrandDir ("safe-branding-backup-" + $Stamp)
$Marker = "DIGIVISTA_SAFE_BRANDING_V1_20260818"

function Step([string]$Text) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
}

function Stop-Safely([string]$Text) {
    Write-Host ""
    Write-Host "STOPPED SAFELY: $Text" -ForegroundColor Red
    Write-Host "No vault data was deleted." -ForegroundColor Yellow
    exit 1
}

Step "1. Validate the healthy baseline"

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Stop-Safely "Podman is not available."
}
if (-not (Test-Path $LogoPath)) {
    Stop-Safely "DigiVista logo was not found at $LogoPath"
}

$Names = @(podman ps -a --format "{{.Names}}")
if ($Names -notcontains $Container) {
    Stop-Safely "Container '$Container' was not found."
}

try { podman start $Container 2>$null | Out-Null } catch {}

podman exec $Container sh -c "test -d /data"
if ($LASTEXITCODE -ne 0) {
    Stop-Safely "Persistent /data is not available."
}

# Confirm HTTPS is healthy before changing branding
try {
    $baseline = Invoke-WebRequest "$VaultUrl/#/login?baseline=$Stamp" -UseBasicParsing -TimeoutSec 20
    if ($baseline.StatusCode -ne 200) {
        Stop-Safely "Baseline HTTPS login did not return HTTP 200."
    }
} catch {
    Stop-Safely "Baseline HTTPS login check failed: $($_.Exception.Message)"
}

Write-Host "Healthy baseline confirmed." -ForegroundColor Green

Step "2. Back up current state"

New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
podman inspect $Container | Set-Content (Join-Path $BackupDir "vaultwarden-inspect.json") -Encoding UTF8

if (Test-Path $HostCss) {
    Copy-Item $HostCss (Join-Path $BackupDir "previous-safe-css.css") -Force
}

podman exec $Container sh -c "mkdir -p /data/templates/scss; if [ -f '$ActiveScss' ]; then cp '$ActiveScss' '/data/templates/scss/user.vaultwarden.scss.hbs.pre-safe-$Stamp'; fi"

Write-Host "Backup folder: $BackupDir" -ForegroundColor Green

Step "3. Build ONE clean, low-risk stylesheet"

$Logo64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($LogoPath))

$Css = @"
/* $Marker
   DigiVista Secure Vault - conservative visual branding only.
   No form/input/layout restructuring.
*/

:root {
  --dv-primary: #063B66;
  --dv-deep: #042B4A;
  --dv-active: #0A4F82;
  --dv-surface: #FFFFFF;
  --dv-page: #F6F9FC;
  --dv-border: #DCE6EF;
  --dv-text: #102A43;
  --dv-logo: url("data:image/png;base64,$Logo64");
}

/* Keep page surfaces subtle; no layout changes */
html, body {
  background-color: var(--dv-page) !important;
}

/* Primary actions only - do not change dimensions or form structure */
button[type="submit"],
button[buttontype="primary"],
[bitbutton][buttontype="primary"],
.btn-primary,
.bwi-btn-primary {
  background-color: var(--dv-primary) !important;
  border-color: var(--dv-primary) !important;
  color: #FFFFFF !important;
}

button[type="submit"] *,
button[buttontype="primary"] *,
[bitbutton][buttontype="primary"] *,
.btn-primary *,
.bwi-btn-primary * {
  color: #FFFFFF !important;
  fill: #FFFFFF !important;
}

button[type="submit"]:hover,
button[buttontype="primary"]:hover,
[bitbutton][buttontype="primary"]:hover,
.btn-primary:hover,
.bwi-btn-primary:hover {
  background-color: var(--dv-active) !important;
  border-color: var(--dv-active) !important;
}

/*
 Login/locked-page branding.
 Current Vaultwarden/Bitwarden web-vault replaces the initial logo during Angular
 rendering. This selector targets the post-render image only and does NOT touch
 the form, password field, safe illustration, headings, or surrounding layout.
*/
app-root img.new-logo-themed {
  content: var(--dv-logo) !important;
  width: min(360px, 78vw) !important;
  max-height: 92px !important;
  height: auto !important;
  object-fit: contain !important;
}

/* Conservative top/application bar color only */
.navbar,
.app-header {
  background-color: var(--dv-deep) !important;
}

/*
 Logged-in sidebar branding.
 This is intentionally scoped ONLY to bit-nav-logo so navigation/forms are not
 affected. If the current web-vault changes this component, the worst expected
 result is the stock Vaultwarden logo remaining visible.
*/
bit-nav-logo bit-nav-item .bwi-shield {
  display: none !important;
}

bit-nav-logo bit-nav-item a::before {
  content: "" !important;
  display: block !important;
  width: 265px !important;
  max-width: calc(100% - 18px) !important;
  height: 58px !important;
  margin: 6px auto !important;
  background-image: var(--dv-logo) !important;
  background-repeat: no-repeat !important;
  background-position: center !important;
  background-size: contain !important;
}

/* Restrict wordmark suppression to the brand component itself */
bit-nav-logo bit-nav-item a > span {
  display: none !important;
}

/* Sidebar color only */
.tw-bg-sidebar,
.bit-sidebar,
aside {
  background-color: #20252B !important;
}

/* Active sidebar item - visual only */
.tw-bg-sidebar a[aria-current="page"],
aside a[aria-current="page"] {
  background-color: var(--dv-active) !important;
}

/* No orange controls. Orange remains only in the DigiVista logo artwork. */
"@

# IMPORTANT: Set-Content replaces this SAFE file; never Add-Content.
Set-Content -Path $HostCss -Value $Css -Encoding UTF8

Write-Host "Created clean stylesheet: $HostCss" -ForegroundColor Green

Step "4. Deploy the clean stylesheet"

podman cp $HostCss "${Container}:$ActiveScss"

$inside = podman exec $Container sh -c "grep -c '$Marker' '$ActiveScss'"
if ([int]$inside -ne 1) {
    Stop-Safely "The expected marker was not found exactly once inside the container."
}

Write-Host "Custom SCSS installed exactly once." -ForegroundColor Green

Step "5. Restart Vaultwarden"

podman restart $Container | Out-Null
Start-Sleep -Seconds 10

$Status = podman ps --filter "name=$Container" --format "{{.Status}}"
if (-not $Status) {
    Stop-Safely "Vaultwarden did not return to running state."
}

Write-Host "Vaultwarden: $Status" -ForegroundColor Green

Step "6. Check recent startup logs"

$Bad = podman logs --tail 100 $Container 2>&1 |
       Select-String -Pattern "panic|fatal|template.*error|scss.*error" -CaseSensitive:$false

if ($Bad) {
    Write-Host "Potential template/SCSS errors detected. Rolling branding back automatically." -ForegroundColor Yellow
    podman exec $Container sh -c "mv '$ActiveScss' '$ActiveScss.failed-$Stamp'"
    podman restart $Container | Out-Null
    Start-Sleep -Seconds 8
    Stop-Safely "Branding was rolled back because startup/template errors were detected."
}

Write-Host "No obvious template/SCSS errors." -ForegroundColor Green

Step "7. Verify live HTTPS CSS"

$LiveOk = $false
try {
    $r = Invoke-WebRequest "$VaultUrl/css/vaultwarden.css?v=$Stamp" -UseBasicParsing -TimeoutSec 20
    if ($r.Content -match $Marker) {
        $LiveOk = $true
        Write-Host "LIVE CSS: DigiVista SAFE branding is being served." -ForegroundColor Green
    }
} catch {
    Write-Host "Live CSS verification request failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

if (-not $LiveOk) {
    Write-Host "Branding marker was not seen in live CSS. Rolling back automatically." -ForegroundColor Yellow
    podman exec $Container sh -c "if [ -f '$ActiveScss' ]; then mv '$ActiveScss' '$ActiveScss.not-live-$Stamp'; fi"
    podman restart $Container | Out-Null
    Start-Sleep -Seconds 8
    Stop-Safely "Custom CSS was not confirmed live, so it was disabled."
}

Step "8. Final status"

Write-Host "SAFE BRANDING DEPLOYED." -ForegroundColor Green
Write-Host "Login: $VaultUrl/#/login" -ForegroundColor Green
Write-Host "Vault: $VaultUrl/#/vault" -ForegroundColor Green
Write-Host "Backup: $BackupDir" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT TEST ORDER:" -ForegroundColor Yellow
Write-Host "  1) Press Ctrl+Shift+R once." -ForegroundColor White
Write-Host "  2) Enter email and Continue." -ForegroundColor White
Write-Host "  3) Confirm Master password field accepts typing." -ForegroundColor White
Write-Host "  4) Login and check sidebar." -ForegroundColor White
Write-Host ""
Write-Host "ROLLBACK (only if needed):" -ForegroundColor Yellow
Write-Host "podman exec vaultwarden sh -c `"mv /data/templates/scss/user.vaultwarden.scss.hbs /data/templates/scss/user.vaultwarden.scss.hbs.disabled-manual`"; podman restart vaultwarden" -ForegroundColor White
Write-Host ""
Write-Host "No vault data, account data, HTTPS, or Caddy configuration was changed." -ForegroundColor Green

Start-Process "$VaultUrl/#/login"
