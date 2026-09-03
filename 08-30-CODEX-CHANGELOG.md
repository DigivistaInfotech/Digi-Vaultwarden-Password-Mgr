# Codex Changelog

## 3 September 2026 — Autonomous completion review

- Replaced the maintained completion workflow with an idempotent, secret-safe implementation that uses the approved external stylesheet and does not install software.
- Added a version/image baseline, deterministic project test runner, portable startup checks, baseline-driven compliance checks, and automatic branding rollback.
- Removed execution-policy bypass and elevated scheduled-task requirements from maintained scripts.
- Standardized the endpoint on `https://localhost` and added Caddy routes for the logo, notice, and AGPL licence.
- Preserved all legacy scripts and prior backups as evidence; they are excluded from the maintained release scope.
- Confirmed 15/15 repository checks pass. Live checks confirm the Vaultwarden container, image, mount, privilege boundary, backend, and task policy; HTTPS recovery remains approval-gated.
- Corrected inherited low-contrast anonymous-page label/link colours while retaining the external-stylesheet-only boundary.

## 30 August 2026 — Stable DigiVista login logo

- Added the responsive DigiVista polished login presentation: branded ambient background, translucent card, refined fields/buttons, and mobile layout while preserving authentication and compliance content.
- Synchronized the exact authenticated sidebar structure derived from the bundled Web Vault 2026.7 source template: `bit-nav-logo > div > a > bit-svg`.
- Verified the source stylesheet and live mounted stylesheet are identical and that all login/sidebar rules compile in `/css/vaultwarden.css`.
- Added the Web Vault 2026.7 authenticated `bit-nav-logo` sidebar selector so the logged-in vault uses the DigiVista logo presentation.
- Added and successfully ran `08-30-One-Shot-Repair-and-Validate.ps1`; all ten compliance checks passed.
- Corrected the external stylesheet for the Web Vault 2026.7 inline `bit-svg` login-header implementation.
- Applied the DigiVista logo to the stable landing-header link and hid only the replaced inline SVG presentation.
- Made no Vaultwarden source, binary, authentication, database, user, password, or vault-record change.
- Verified the DigiVista logo remained applied after 2.5 and 6 seconds, with zero browser console warnings/errors.
- Stored the pre-change stylesheet under the controlled Phase-4 backup directory; excluded that backup from release packaging.

## 30 August 2026

- Added `08-30-Complete-DigiVista-Secure-Vault.ps1` as the consolidated safe completion workflow.
- Kept Vaultwarden source code, binaries, authentication, database, users, passwords, and vault records outside the change scope.
- Added persistent `/data` mount proof before any configuration change and re-verification afterward.
- Added backups for container inspection, mount evidence, `.wslconfig`, Caddy configuration, and active custom SCSS.
- Added diagnostics for container health, Podman-machine reachability, Windows port 8080, and inspected port bindings.
- Added conservative `.wslconfig` merging rather than overwriting unrelated settings.
- Gated HTTPS and branding behind successful Windows backend reachability.
- Added port 443 ownership detection and refusal to stop unrelated services.
- Added Caddy internal HTTPS and a visible Vaultwarden/AGPL open-source notice.
- Added conservative external CSS branding with automatic disable-on-verification-failure behavior.
- Added startup-task creation only after required automated checks pass.
- Added a generated final deployment report with results, changes, backup location, failure details, and rollback guidance.
- Added a reusable Caddy template.

## Explicitly unchanged

- Vaultwarden source and web-vault application code
- Vaultwarden binaries and container image
- Authentication logic
- Users, passwords, vault records, and database content
- Existing container and persistent data volume ownership
