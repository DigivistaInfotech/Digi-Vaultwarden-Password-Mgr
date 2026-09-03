# DigiVista Secure Vault — Codex Handoff Package

Date: 30 Aug 2026
Repository: `DigivistaInfotech/DigiVistaSmartPCGuardian`
Tracked issue: GitHub Issue #1 — Fix Vaultwarden Windows host access and complete Secure Vault deployment

## Last development
The latest integrated development is `02_DEPLOYMENT/DigiVista-Vaultwarden-OneGo-Deploy.ps1`. It combines the existing Vaultwarden deployment with DigiVista branding, Caddy HTTPS, an open-source notice page, CSS cache control, backups, service restart, and live CSS verification. It is intentionally non-destructive to Vaultwarden data.

A later conservative branding path is also included: `Deploy-DigiVista-SAFE-Branding-v1.ps1`. Use it as the safer UI reference because it avoids aggressive Angular DOM overrides and includes rollback behavior.

## Current blocker
Vaultwarden itself is healthy inside Podman, and container inspect reports `80/tcp -> 0.0.0.0:8080`. However Windows host access to `127.0.0.1:8080` has been the unresolved blocker. Earlier diagnostics proved HTTP 200 inside the Podman machine, pointing to the Windows/WSL/Podman forwarding path rather than Vaultwarden.

The historical recovery guide records that WSL2 mirrored networking plus a full WSL/Podman restart fixed this exact pattern on a prior working recovery. Codex should validate the current machine state before changing anything.

## Goal for Codex
Produce one safe, idempotent Administrator PowerShell repair/deployment script that:
1. Detects the existing Podman machine/container and preserves all vault data.
2. Diagnoses Windows port 8080, Podman publish state, WSL mode, and listener state.
3. Repairs WSL/Podman host networking only when required, preferring mirrored networking on supported Windows/WSL.
4. Restarts WSL/Podman safely when required.
5. Verifies `localhost:8080` from Windows before proceeding.
6. Installs/configures Caddy only if needed and serves `https://vaultwarden.localhost`.
7. Applies the approved DigiVista UI/branding conservatively.
8. Keeps Vaultwarden/AGPL attribution and open-source notices.
9. Verifies login, CSS marker, HTTPS, restart persistence, and data persistence.
10. Prints a clear PASS/FAIL summary and rollback guidance.

Start with `00_HANDOFF/CODEX_TASK.md`.
