#requires -RunAsAdministrator
<#
DigiVista Secure Vault - ONE GO Branding + HTTPS Deployment
Target: Windows + Podman + Vaultwarden + Caddy

What this script does:
  - Uses the existing Vaultwarden container/data
  - DOES NOT delete the vw-data volume
  - Applies DigiVista logo + colors through Vaultwarden custom SCSS
  - Keeps HTTPS at https://vaultwarden.localhost
  - Adds an Open Source / Trademark notice page
  - Disables caching for Vaultwarden custom CSS through Caddy
  - Restarts Vaultwarden and reloads Caddy
  - Verifies that the custom CSS is being served

Required files already on the PC:
  C:\vault-branding\DigiVista_Logo.png
  C:\vault-branding\digivista-vault.css

Safe design:
  DigiVista branding is front-end/operator branding.
  Vaultwarden attribution + AGPL notice remains separate.
  No Bitwarden branding/affiliation is claimed.
#>

$ErrorActionPreference = "Stop"

# ---------------- SETTINGS ----------------
$Container      = "vaultwarden"
$BrandDir       = "C:\vault-branding"
$LogoPath       = Join-Path $BrandDir "DigiVista_Logo.png"
$CssPath        = Join-Path $BrandDir "digivista-vault.css"
$ComplianceDir  = Join-Path $BrandDir "compliance"
$CaddyFile      = "C:\Caddyfile"
$VaultUrl       = "https://vaultwarden.localhost"
$BackendUrl     = "http://127.0.0.1:8080"
$Marker         = "DIGIVISTA_CUSTOM_BRANDING_20260818"

function Step([string]$m) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host $m -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
}

function Fail([string]$m) {
    Write-Host ""
    Write-Host "FAILED: $m" -ForegroundColor Red
    exit 1
}

# ---------------- 1. PRECHECKS ----------------
Step "1. Pre-check Podman, Caddy and branding files"

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Fail "Podman is not installed or is not in PATH."
}

if (-not (Get-Command caddy -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Fail "Caddy is missing and winget is unavailable."
    }
    Write-Host "Installing Caddy..." -ForegroundColor Yellow
    winget install --id CaddyServer.Caddy -e --accept-package-agreements --accept-source-agreements
}

if (-not (Test-Path $BrandDir)) {
    New-Item -ItemType Directory -Path $BrandDir -Force | Out-Null
    Fail "Created $BrandDir. Copy DigiVista_Logo.png and digivista-vault.css into it, then run again."
}

if (-not (Test-Path $LogoPath)) {
    Fail "Missing: $LogoPath"
}

# Fix accidental .cs filename
if (-not (Test-Path $CssPath)) {
    $WrongCss = Join-Path $BrandDir "digivista-vault.cs"
    if (Test-Path $WrongCss) {
        Rename-Item $WrongCss "digivista-vault.css" -Force
    }
}
if (-not (Test-Path $CssPath)) {
    Fail "Missing: $CssPath"
}

Write-Host "Found logo : $LogoPath" -ForegroundColor Green
Write-Host "Found CSS  : $CssPath" -ForegroundColor Green

# ---------------- 2. PODMAN ----------------
Step "2. Ensure Podman machine and Vaultwarden are running"

try { podman machine start 2>$null | Out-Null } catch {}

$names = @(podman ps -a --format "{{.Names}}")
if ($names -notcontains $Container) {
    Fail "Existing container '$Container' was not found. This safe script will not create a new vault automatically."
}

try { podman start $Container 2>$null | Out-Null } catch {}

# Confirm /data exists and is persistent
podman exec $Container sh -c "test -d /data"
if ($LASTEXITCODE -ne 0) {
    Fail "Vaultwarden /data was not found. Stopping to avoid data risk."
}

Write-Host "Vaultwarden container found and /data is available." -ForegroundColor Green

# ---------------- 3. BACKUP ----------------
Step "3. Back up current deployment configuration"

$BackupDir = Join-Path $BrandDir ("backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

podman inspect $Container | Set-Content (Join-Path $BackupDir "vaultwarden-inspect.json") -Encoding UTF8

if (Test-Path $CaddyFile) {
    Copy-Item $CaddyFile (Join-Path $BackupDir "Caddyfile.backup") -Force
}

try {
    podman cp "${Container}:/data/config.json" (Join-Path $BackupDir "config.json") 2>$null
} catch {}

Write-Host "Backup: $BackupDir" -ForegroundColor Green

# ---------------- 4. BUILD CUSTOM SCSS ----------------
Step "4. Build DigiVista custom Vaultwarden SCSS"

$LogoBytes = [System.IO.File]::ReadAllBytes($LogoPath)
$LogoBase64 = [Convert]::ToBase64String($LogoBytes)
$ExistingCss = Get-Content $CssPath -Raw

$Scss = @"
/* $Marker
   DigiVista Secure Vault branding layer
   Operator branding: DigiVista Infotech
   Underlying software: Vaultwarden
   No affiliation with Bitwarden, Inc. is claimed.
*/

:root {
  --dv-primary: #064679;
  --dv-accent: #FF9915;
  --dv-secondary: #8BA9C0;
  --dv-logo: url("data:image/png;base64,$LogoBase64");
}

/* Login / unlock logo after the web app renders */
app-root img.new-logo-themed {
  content: var(--dv-logo) !important;
  width: min(430px, 82vw) !important;
  height: auto !important;
  max-height: 115px !important;
  object-fit: contain !important;
}

/* Initial anonymous-layout logo */
auth-anon-layout > main > div > a > bit-icon > svg {
  display: none !important;
}
auth-anon-layout > main > div > a > bit-icon::before {
  content: "" !important;
  display: block !important;
  width: min(430px, 82vw) !important;
  height: 105px !important;
  background-image: var(--dv-logo) !important;
  background-repeat: no-repeat !important;
  background-position: center !important;
  background-size: contain !important;
}

/* Logged-in navigation logo */
bit-nav-logo bit-nav-item .bwi-shield,
bit-nav-logo bit-nav-item > a > bit-icon,
bit-nav-logo bit-nav-item > a > img {
  display: none !important;
}

bit-nav-logo bit-nav-item > a::before {
  content: "" !important;
  display: block !important;
  width: 285px !important;
  max-width: calc(100% - 20px) !important;
  height: 64px !important;
  margin: 8px auto 10px auto !important;
  background-image: var(--dv-logo) !important;
  background-repeat: no-repeat !important;
  background-position: center !important;
  background-size: contain !important;
}

/* DigiVista colours */
button[buttontype="primary"],
[bitbutton][buttontype="primary"],
.btn-primary,
.bwi-btn-primary {
  background-color: var(--dv-primary) !important;
  border-color: var(--dv-primary) !important;
}

button[buttontype="primary"]:hover,
[bitbutton][buttontype="primary"]:hover,
.btn-primary:hover,
.bwi-btn-primary:hover {
  background-color: var(--dv-accent) !important;
  border-color: var(--dv-accent) !important;
}

/* Preserve the user's existing branding rules below */
$ExistingCss
"@

# Write temporary SCSS and copy into Vaultwarden's persistent /data templates
$TempScss = Join-Path $env:TEMP "user.vaultwarden.scss.hbs"
Set-Content -Path $TempScss -Value $Scss -Encoding UTF8

podman exec $Container sh -c "mkdir -p /data/templates/scss"
podman cp $TempScss "${Container}:/data/templates/scss/user.vaultwarden.scss.hbs"

podman exec $Container sh -c "grep -q '$Marker' /data/templates/scss/user.vaultwarden.scss.hbs"
if ($LASTEXITCODE -ne 0) {
    Fail "Custom SCSS was not copied correctly."
}
Write-Host "Custom SCSS installed in persistent /data/templates/scss." -ForegroundColor Green

# ---------------- 5. COMPLIANCE NOTICE ----------------
Step "5. Create separate Open Source / Trademark notice"

New-Item -ItemType Directory -Path $ComplianceDir -Force | Out-Null

$Notice = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>DigiVista Secure Vault - Open Source Notices</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;max-width:900px;margin:40px auto;padding:0 20px;line-height:1.55;color:#17212b}
h1,h2{color:#064679}.box{border:1px solid #d9e1e7;border-radius:10px;padding:18px;margin:18px 0}
a{color:#064679}
</style>
</head>
<body>
<h1>DigiVista Secure Vault</h1>

<div class="box">
<h2>Branding</h2>
<p>DigiVista Secure Vault and the DigiVista Infotech logo identify the operator/deployment branding.</p>
</div>

<div class="box">
<h2>Underlying open-source software</h2>
<p>This deployment uses Vaultwarden, an open-source and unofficial Bitwarden-compatible server.</p>
<p>Vaultwarden is licensed under GNU AGPL-3.0.</p>
<p>Vaultwarden is not associated with Bitwarden or Bitwarden, Inc.</p>
<p><a href="https://github.com/dani-garcia/vaultwarden">Vaultwarden source project</a></p>
<p><a href="https://github.com/dani-garcia/vaultwarden/blob/main/LICENSE.txt">AGPL-3.0 license</a></p>
</div>

<div class="box">
<h2>Commercial / trademark representation</h2>
<p>This service is branded and operated by DigiVista Infotech. It is not presented as Bitwarden and does not imply endorsement, authorization, or affiliation with Bitwarden, Inc.</p>
</div>

<div class="box">
<h2>Source availability</h2>
<p>If DigiVista deploys a modified AGPL-covered version for users over a network, the corresponding source for that deployed version, including applicable modifications, must be made available to those users as required by AGPLv3.</p>
</div>
</body>
</html>
"@

Set-Content -Path (Join-Path $ComplianceDir "index.html") -Value $Notice -Encoding UTF8
Write-Host "Compliance page created." -ForegroundColor Green

# ---------------- 6. CADDY ----------------
Step "6. Configure HTTPS and disable custom-CSS caching"

$CaddyConfig = @"
https://vaultwarden.localhost {

    handle /open-source-notices* {
        root * C:/vault-branding/compliance
        rewrite * /index.html
        file_server
    }

    @customcss path /css/vaultwarden.css
    header @customcss Cache-Control "no-store, no-cache, must-revalidate"

    reverse_proxy 127.0.0.1:8080
}
"@

Set-Content -Path $CaddyFile -Value $CaddyConfig -Encoding UTF8

caddy validate --config $CaddyFile
if ($LASTEXITCODE -ne 0) {
    Fail "Caddy configuration validation failed."
}

try { caddy trust | Out-Null } catch {}

# ---------------- 7. RESTART SERVICES ----------------
Step "7. Restart Vaultwarden and Caddy"

podman restart $Container | Out-Null
Start-Sleep -Seconds 8

# Caddy reload if already running; otherwise start it
$CaddyRunning = Get-Process caddy -ErrorAction SilentlyContinue
if ($CaddyRunning) {
    try {
        caddy reload --config $CaddyFile
    } catch {
        Get-Process caddy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Process -FilePath (Get-Command caddy).Source -ArgumentList @("run","--config",$CaddyFile) -WindowStyle Hidden
    }
} else {
    Start-Process -FilePath (Get-Command caddy).Source -ArgumentList @("run","--config",$CaddyFile) -WindowStyle Hidden
}

Start-Sleep -Seconds 5

# ---------------- 8. VERIFY ----------------
Step "8. Verify Vaultwarden, HTTPS and custom CSS"

$BackendOk = $false
try {
    $r = Invoke-WebRequest -Uri $BackendUrl -UseBasicParsing -TimeoutSec 10
    if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { $BackendOk = $true }
} catch {}

if ($BackendOk) {
    Write-Host "Backend: OK" -ForegroundColor Green
} else {
    Write-Host "Backend: NOT REACHABLE" -ForegroundColor Red
}

$HttpsOk = $false
try {
    $tnc = Test-NetConnection vaultwarden.localhost -Port 443 -WarningAction SilentlyContinue
    $HttpsOk = [bool]$tnc.TcpTestSucceeded
} catch {}

if ($HttpsOk) {
    Write-Host "HTTPS: OK" -ForegroundColor Green
} else {
    Write-Host "HTTPS: NOT REACHABLE" -ForegroundColor Red
}

$CssOk = $false
$CssUrl = "$VaultUrl/css/vaultwarden.css?dv=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"

try {
    $cssResponse = Invoke-WebRequest -Uri $CssUrl -UseBasicParsing -TimeoutSec 15
    if ($cssResponse.Content -match $Marker) {
        $CssOk = $true
    }
} catch {}

if ($CssOk) {
    Write-Host "CUSTOM CSS: LOADED" -ForegroundColor Green
} else {
    Write-Host "CUSTOM CSS: marker was not found in the generated CSS." -ForegroundColor Yellow
    Write-Host "Check Vaultwarden logs with: podman logs --tail 100 vaultwarden" -ForegroundColor Yellow
}

# ---------------- 9. FINAL ----------------
Step "9. Deployment finished"

Write-Host "Vault URL:              $VaultUrl" -ForegroundColor Green
Write-Host "Open-source notices:    $VaultUrl/open-source-notices" -ForegroundColor Green
Write-Host "Backup folder:          $BackupDir"
Write-Host ""
Write-Host "Browser action: Press Ctrl+Shift+R once after the page opens." -ForegroundColor Yellow
Write-Host ""
Write-Host "The script did NOT delete the Vaultwarden data volume." -ForegroundColor Green

Start-Process $VaultUrl
