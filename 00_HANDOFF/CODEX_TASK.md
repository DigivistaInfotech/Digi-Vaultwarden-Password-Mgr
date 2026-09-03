# CODEX TASK — Complete DigiVista Secure Vault in One Safe Run

You are taking over a partially completed Windows + Podman + Vaultwarden deployment. Review every file in this ZIP before editing.

## Primary objective
Deliver a single robust PowerShell script named `Complete-DigiVista-Secure-Vault.ps1` plus concise documentation. The script must diagnose and repair the current networking issue and then complete HTTPS + DigiVista UI deployment.

## Non-negotiable safety constraints
- NEVER run `podman system reset`.
- NEVER run `podman machine rm` automatically.
- NEVER delete Vaultwarden `/data`.
- NEVER delete a named volume such as `vw-data` or `vaultwarden-data`.
- Do not recreate the `vaultwarden` container unless absolutely unavoidable and only after explicitly proving the persistent data mount/volume and taking a backup. Prefer fixing networking without container recreation.
- Do not modify passwords, users, database content, or authentication logic.
- Do not hide/remove required Vaultwarden/AGPL notices.
- Avoid brittle Angular DOM rewrites. Prefer the conservative SAFE branding approach.

## Current evidence
- `podman inspect vaultwarden --format "{{json .HostConfig.PortBindings}}"` => `{"80/tcp":[{"HostIp":"0.0.0.0","HostPort":"8080"}]}`
- `podman inspect vaultwarden --format "{{json .NetworkSettings.Ports}}"` => same mapping.
- `podman port vaultwarden` returned blank in the current session.
- Prior VM-side request to `http://127.0.0.1:8080` returned HTTP 200.
- Windows-side reachability was the blocker.

## Required implementation plan
1. Preflight: Administrator, Windows version, WSL version, Podman version, Caddy state, container state, volume/mount state.
2. Backup: container inspect, current Caddyfile, active custom SCSS, current `.wslconfig`, and relevant Podman machine inspect.
3. Diagnose 8080: `podman port`, HostConfig, NetworkSettings, `netstat`/Get-NetTCPConnection, Windows Test-NetConnection, VM-side curl, container-side curl.
4. If VM/container works but Windows 8080 does not, repair WSL networking safely. Read the troubleshooting guide; use `networkingMode=mirrored` only if supported. Preserve unrelated existing `.wslconfig` settings rather than overwriting the file blindly.
5. Restart only the minimum required components (`podman machine stop`, `wsl --shutdown`, `podman machine start`, `podman start vaultwarden`) and re-test.
6. Do not continue to Caddy/branding until Windows can reach backend port 8080.
7. Configure Caddy using a stable ProgramData path, trust the local CA, detect port-443 conflicts, and verify HTTPS.
8. Apply branding using the SAFE branding logic and approved UI spec. If selectors are incompatible, fall back gracefully rather than breaking login.
9. Validate that master-password input and login remain functional.
10. Create/reconcile a logon startup task only after the full stack passes tests.
11. Print a final structured result: Backend PASS/FAIL, HTTPS PASS/FAIL, UI CSS PASS/FAIL, Data mount PASS/FAIL, Startup task PASS/FAIL.
12. Generate `FINAL-DEPLOYMENT-REPORT.md` with root cause, exact changes, backup locations, rollback steps, and any remaining manual action.

## UI target
Follow `01_UI_UX/DigiVista-Final-UI-Spec.md` and the included reference PNGs. Use navy/white enterprise styling. Orange is primarily logo artwork, not a dominant control color.

## Deliverables
- `Complete-DigiVista-Secure-Vault.ps1`
- `FINAL-DEPLOYMENT-REPORT.md` template populated by the script when run
- `CODEX-CHANGELOG.md`
- Any corrected Caddy template / helper scripts if needed
- Suggested Git commit message and Issue #1 closing comment

Do not claim success until all tests actually pass on the Windows host.
