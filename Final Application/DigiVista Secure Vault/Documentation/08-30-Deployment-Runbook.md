# DigiVista Secure Vault — Deployment Runbook

Status: Engineering-reviewed controlled runbook; production use requires owner approval

## Inputs

- Existing Vaultwarden container and persistent `/data` mount.
- Administrator access to the Windows host.
- Current verified backup.
- `02_DEPLOYMENT/08-30-Complete-DigiVista-Secure-Vault.ps1`.
- Approved DigiVista logo supplied in the package.

## Pre-deployment gate

1. Name the technical and security/data approvers.
2. Confirm the target environment and maintenance window.
3. Verify the latest backup and restore-test evidence.
4. Confirm no unrelated service is expected to own port 443.
5. Confirm the existing container name and `/data` mount.
6. Close applications that depend on WSL before any approved WSL shutdown.

## Safe execution

From Administrator PowerShell, review the script before execution. First use PowerShell's WhatIf mode to view intended mutations:

```powershell
& '.\02_DEPLOYMENT\08-30-Invoke-Project-Tests.ps1'
& '.\02_DEPLOYMENT\08-30-Complete-DigiVista-Secure-Vault.ps1' -WhatIf
```

After review and approval, run without `-WhatIf`. Branding or startup automation can be intentionally excluded with `-SkipBranding` or `-SkipStartupTask`.

## Execution sequence

1. Validate administrator privileges and required commands.
2. Start only the existing Podman machine/container.
3. Prove the `/data` mount and capture backups.
4. Diagnose container, Podman-machine, inspected mapping, and Windows backend paths.
5. Merge WSL mirrored networking only if supported and diagnostically justified.
6. Stop unless Windows port 8080 passes.
7. Detect port 443 conflicts.
8. Validate the existing Caddy executable and configure it; the workflow does not install software.
9. Verify HTTPS before branding.
10. Apply conservative external SCSS and verify its live marker.
11. Re-prove the `/data` mount.
12. Register startup automation only after required checks pass.
13. Generate the final report.

## Manual acceptance

- Open the HTTPS login page without a certificate warning.
- Confirm email and master-password fields accept input.
- Complete a valid login using an authorized test account.
- Confirm vault data is present and unchanged.
- Confirm DigiVista branding does not block navigation or controls.
- Open the open-source notice.
- Sign out/in to Windows or perform an approved restart-persistence test.
- Confirm the final report and backup location.

## Stop conditions

Stop and review if the persistent mount is missing, internal health fails, the failure is not isolated to Windows forwarding, WSL support cannot be proven, port 443 has another owner, HTTPS fails, the CSS marker is absent, or the mount identity changes.
