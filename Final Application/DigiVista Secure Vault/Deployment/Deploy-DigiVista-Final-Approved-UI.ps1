#requires -RunAsAdministrator
<#
DigiVista Secure Vault - FINAL APPROVED UI (CSS-safe deployment)

Purpose
-------
Apply the approved DigiVista navy/white login + dashboard visual treatment
without deleting/recreating the Vaultwarden data volume and without changing
authentication logic.

Important
---------
This script performs CSS/SCSS theming only. It cannot safely rewrite the
Vaultwarden Angular component structure into an exact custom split-page/dashboard
layout. That requires a maintained custom web-vault build.

Expected paths:
  C:\vault-branding\DigiVista_Logo.png
  C:\vault-branding\digivista-vault.css

Target container:
  vaultwarden
#>

$ErrorActionPreference = "Stop"

$BrandDir  = "C:\vault-branding"
$LogoPath  = Join-Path $BrandDir "DigiVista_Logo.png"
$CssPath   = Join-Path $BrandDir "digivista-vault.css"
$Container = "vaultwarden"
$VaultUrl  = "https://vaultwarden.localhost"
$StartMark = "/* DIGIVISTA_FINAL_APPROVED_UI_START */"
$EndMark   = "/* DIGIVISTA_FINAL_APPROVED_UI_END */"

function Step($text) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host $text -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
}

Step "1. Validate current installation"

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "Podman is not available."
}
if (-not (Test-Path $LogoPath)) {
    throw "Logo not found: $LogoPath"
}
if (-not (Test-Path $CssPath)) {
    New-Item -ItemType File -Path $CssPath -Force | Out-Null
}

$containers = @(podman ps -a --format "{{.Names}}")
if ($containers -notcontains $Container) {
    throw "Existing Vaultwarden container '$Container' was not found."
}

try { podman start $Container 2>$null | Out-Null } catch {}

Step "2. Back up current branding CSS"

$BackupDir = Join-Path $BrandDir ("backup-ui-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
Copy-Item $CssPath (Join-Path $BackupDir "digivista-vault.css.before-final-ui") -Force
podman inspect $Container | Set-Content (Join-Path $BackupDir "vaultwarden-inspect.json") -Encoding UTF8
Write-Host "Backup created: $BackupDir" -ForegroundColor Green

Step "3. Build approved navy/white UI layer"

$LogoBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($LogoPath))
$Existing = Get-Content $CssPath -Raw -ErrorAction SilentlyContinue
if ($null -eq $Existing) { $Existing = "" }

$pattern = [regex]::Escape($StartMark) + ".*?" + [regex]::Escape($EndMark)
$Existing = [regex]::Replace(
    $Existing,
    $pattern,
    "",
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)

$Approved = @"

/* DIGIVISTA_FINAL_APPROVED_UI_START */

/* ============================================================
   DigiVista Secure Vault — Approved Enterprise UI
   Navy + White / minimal orange
   ============================================================ */

:root {
    --dv-navy: #063B66;
    --dv-deep: #042B4A;
    --dv-active: #0A4F82;
    --dv-surface: #FFFFFF;
    --dv-bg: #F6F9FC;
    --dv-border: #DCE6EF;
    --dv-text: #102A43;
    --dv-muted: #5E7388;
    --dv-success: #198754;
    --dv-logo: url("data:image/png;base64,$LogoBase64");
}

/* ---------------- GLOBAL ---------------- */

html, body {
    background: var(--dv-bg) !important;
}

body {
    color: var(--dv-text) !important;
}

button[buttontype="primary"],
[bitbutton][buttontype="primary"],
.btn-primary,
.bwi-btn-primary,
button[type="submit"] {
    background: var(--dv-navy) !important;
    border-color: var(--dv-navy) !important;
    color: #fff !important;
    border-radius: 9px !important;
    box-shadow: 0 4px 12px rgba(6,59,102,.14) !important;
}

button[buttontype="primary"] *,
[bitbutton][buttontype="primary"] *,
.btn-primary *,
.bwi-btn-primary *,
button[type="submit"] * {
    color: #fff !important;
    fill: #fff !important;
}

button[buttontype="primary"]:hover,
[bitbutton][buttontype="primary"]:hover,
.btn-primary:hover,
.bwi-btn-primary:hover,
button[type="submit"]:hover {
    background: var(--dv-active) !important;
    border-color: var(--dv-active) !important;
}

a {
    color: var(--dv-navy) !important;
}

a:hover {
    color: var(--dv-active) !important;
}

/* ---------------- LOGIN / AUTH ---------------- */

auth-anon-layout {
    background: var(--dv-bg) !important;
}

/* compact brand header */
auth-anon-layout header,
auth-anon-layout .navbar,
auth-anon-layout .app-header {
    min-height: 88px !important;
    height: 88px !important;
    background-color: var(--dv-deep) !important;
    background-image: var(--dv-logo) !important;
    background-repeat: no-repeat !important;
    background-position: 30px center !important;
    background-size: 290px auto !important;
    border: 0 !important;
    box-shadow: 0 2px 12px rgba(4,43,74,.14) !important;
}

/* suppress default header logo without removing the header itself */
auth-anon-layout header img,
auth-anon-layout header svg,
auth-anon-layout header bit-icon,
auth-anon-layout header .bwi-shield {
    visibility: hidden !important;
}

/* page */
auth-anon-layout main {
    background:
        radial-gradient(circle at 15% 45%, rgba(6,59,102,.045), transparent 27%),
        radial-gradient(circle at 86% 44%, rgba(6,59,102,.035), transparent 24%),
        linear-gradient(135deg,#FBFCFE 0%,#F3F7FB 100%) !important;
    min-height: calc(100vh - 88px) !important;
}

/* reduce default illustration dominance */
auth-anon-layout main > div > bit-icon,
auth-anon-layout main bit-icon.tw-text-illustration-outline,
auth-anon-layout main img.new-logo-themed {
    max-height: 54px !important;
    opacity: .15 !important;
}

/* change visible login heading without altering app logic */
auth-anon-layout h1 {
    font-size: 0 !important;
    margin-top: 14px !important;
    margin-bottom: 8px !important;
    color: var(--dv-text) !important;
}
auth-anon-layout h1::after {
    content: "Welcome to DigiVista Secure Vault";
    display: block;
    font-size: 30px !important;
    line-height: 1.2 !important;
    font-weight: 700 !important;
    color: var(--dv-text) !important;
    letter-spacing: -.35px !important;
}

/* subtle helper line */
auth-anon-layout h1 + *::before {
    content: "Secure access to your passwords and digital credentials.";
    display: block;
    text-align: center;
    color: var(--dv-muted);
    font-size: 14px;
    margin: 0 auto 18px auto;
}

/* auth cards */
auth-anon-layout form,
auth-anon-layout bit-card,
auth-anon-layout bit-simple-card,
auth-anon-layout .card,
auth-anon-layout .tw-rounded-xl,
auth-anon-layout .tw-rounded-2xl {
    background: var(--dv-surface) !important;
    border: 1px solid var(--dv-border) !important;
    border-radius: 16px !important;
    box-shadow: 0 16px 38px rgba(6,59,102,.09) !important;
}

auth-anon-layout input,
auth-anon-layout .form-control {
    min-height: 48px !important;
    border-radius: 9px !important;
    border-color: #BACADA !important;
    background: #fff !important;
}

auth-anon-layout input:focus,
auth-anon-layout .form-control:focus {
    border-color: var(--dv-active) !important;
    box-shadow: 0 0 0 3px rgba(10,79,130,.10) !important;
}

auth-anon-layout main::after {
    content: "Secure • Private • Trusted";
    display: block;
    text-align: center;
    color: var(--dv-muted);
    font-size: 13px;
    font-weight: 600;
    padding: 18px 12px 10px 12px;
}

/* ---------------- LOGGED-IN APP ---------------- */

/* sidebar */
aside,
.tw-bg-sidebar,
.bit-sidebar,
nav[aria-label="Main"] {
    background: linear-gradient(180deg,var(--dv-deep) 0%,#052F50 100%) !important;
}

/* sidebar brand block */
bit-nav-logo {
    display: block !important;
    position: relative !important;
    min-height: 94px !important;
    padding: 10px 8px 4px 8px !important;
}

bit-nav-logo * {
    opacity: 0 !important;
}

bit-nav-logo::before {
    content: "" !important;
    display: block !important;
    width: 285px !important;
    max-width: calc(100% - 16px) !important;
    height: 72px !important;
    margin: 4px auto 8px auto !important;
    background-image: var(--dv-logo) !important;
    background-repeat: no-repeat !important;
    background-position: center !important;
    background-size: contain !important;
    opacity: 1 !important;
}

/* sidebar nav items */
aside a,
aside button,
.tw-bg-sidebar a,
.tw-bg-sidebar button {
    border-radius: 10px !important;
}

aside a[aria-current="page"],
aside .active,
.tw-bg-sidebar a[aria-current="page"],
.tw-bg-sidebar .active {
    background: rgba(10,79,130,.78) !important;
    box-shadow: inset 0 0 0 1px rgba(255,255,255,.05) !important;
}

/* top app bar / primary header */
app-user-layout header,
app-vault header,
.tw-bg-primary-600,
.tw-bg-primary {
    background: var(--dv-navy) !important;
}

/* main page surface */
app-user-layout main,
app-vault,
app-vault > div {
    background: var(--dv-bg) !important;
}

/* cards / checklist / filters */
app-vault bit-card,
app-vault .card,
app-vault .tw-rounded-xl,
app-vault .tw-rounded-2xl,
app-user-layout bit-card {
    background: #fff !important;
    border: 1px solid var(--dv-border) !important;
    border-radius: 14px !important;
    box-shadow: 0 5px 18px rgba(6,59,102,.055) !important;
}

/* headings */
app-user-layout h1,
app-user-layout h2,
app-user-layout h3,
app-vault h1,
app-vault h2,
app-vault h3 {
    color: var(--dv-text) !important;
}

/* tables */
table {
    background: #fff !important;
}

table th {
    color: var(--dv-muted) !important;
    font-weight: 600 !important;
}

table td,
table th {
    border-color: #E5EDF4 !important;
}

/* search / filter inputs */
app-vault input,
app-user-layout input {
    border-radius: 9px !important;
}

/* success remains green */
.tw-text-success-600,
.text-success,
.badge-success {
    color: var(--dv-success) !important;
}

/* keep orange out of controls; logo artwork retains its own brand orange */

/* DIGIVISTA_FINAL_APPROVED_UI_END */
"@

$FinalCss = ($Existing.TrimEnd() + "`r`n`r`n" + $Approved)
Set-Content -Path $CssPath -Value $FinalCss -Encoding UTF8

Step "4. Deploy custom SCSS into persistent Vaultwarden /data"

podman exec $Container sh -c "mkdir -p /data/templates/scss"
podman cp $CssPath "${Container}:/data/templates/scss/user.vaultwarden.scss.hbs"

$verifyLocal = podman exec $Container sh -c "grep -c 'DIGIVISTA_FINAL_APPROVED_UI_START' /data/templates/scss/user.vaultwarden.scss.hbs"
if ([int]$verifyLocal -lt 1) {
    throw "The final UI marker was not copied into Vaultwarden."
}

Step "5. Restart Vaultwarden"

podman restart $Container | Out-Null
Start-Sleep -Seconds 10

Step "6. Verify the live custom CSS"

$verifyUrl = "$VaultUrl/css/vaultwarden.css?dv=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
try {
    $response = Invoke-WebRequest $verifyUrl -UseBasicParsing -TimeoutSec 20
    if ($response.Content -match "DIGIVISTA_FINAL_APPROVED_UI_START") {
        Write-Host "LIVE CSS: FINAL DIGIVISTA UI LOADED" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Vaultwarden is reachable, but the final UI marker was not found in live CSS." -ForegroundColor Yellow
    }
} catch {
    Write-Host "WARNING: Could not verify live HTTPS CSS: $($_.Exception.Message)" -ForegroundColor Yellow
}

Step "7. Open login page"

Write-Host "Backup: $BackupDir" -ForegroundColor Green
Write-Host "Login : $VaultUrl/#/login" -ForegroundColor Green
Write-Host "Vault : $VaultUrl/#/vault" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+Shift+R once after the page opens." -ForegroundColor Yellow
Write-Host ""
Write-Host "No user data or Vaultwarden data volume was deleted." -ForegroundColor Green

Start-Process "$VaultUrl/#/login"
