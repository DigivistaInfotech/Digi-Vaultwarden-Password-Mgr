# DigiVista Secure Vault - Final Deployment Report

Date: 2026-08-30  
Environment: Controlled local Windows host  
Status: **DEPLOYED AND TECHNICALLY VERIFIED**

> Historical record: this report describes the verified state on 30 August 2026. The 3 September review found the backend healthy but Caddy/HTTPS stopped. See `09-03-FINAL-VERIFICATION-REPORT.md` for current status.

## Delivered outcome

DigiVista Secure Vault is running locally at `https://localhost/#/login` through Caddy HTTPS. Vaultwarden remains the unmodified password-vault engine. DigiVista presentation is supplied through Vaultwarden's external custom stylesheet mechanism and Caddy-served static assets; no Vaultwarden source, binary, authentication logic, database schema, user record, password, or vault item was edited.

## Verified software and service state

| Control | Verified result |
|---|---|
| Vaultwarden | 1.37.2 |
| Web Vault | 2026.7.0 |
| Podman | 6.0.2 |
| Caddy | 2.11.4 |
| Vaultwarden container | Running |
| Persistent data | Named volume `vaultwarden-data` mounted at `/data` |
| Backend health | `http://localhost:8080` reachable |
| HTTPS endpoint | `https://localhost` reachable |
| Login route | HTTP 200 |
| DigiVista branding | Compiled CSS marker `--dv-primary` confirmed |
| DigiVista logo | Served by the local HTTPS proxy |
| Open-source notice | `https://localhost/open-source-notices`, HTTP 200 |
| Local AGPL license | HTTP 200; 34,523 bytes |
| Startup task | Ready, Limited privilege, last result 0 |
| Unsafe policy bypass | Not present in the startup task action |

Evidence was rechecked on 2026-08-30 at 16:01:38 +05:30.

## Controlled changes

1. Repaired the already-installed Podman CLI from the locally bundled official installer.
2. Enabled WSL mirrored networking so the existing Podman-published ports are reachable from Windows.
3. Restored every container that was running before the controlled WSL restart.
4. Installed the official Caddy Windows binary after SHA-512 verification.
5. Configured local HTTPS and trusted the local Caddy certificate authority for the current Windows user.
6. Added external DigiVista branding, logo delivery, and open-source notice routes.
7. Added a limited-privilege startup task for the local stack.
8. Added SRS, architecture, security, deployment, backup, monitoring, testing, traceability, and operational records.
9. Recorded the controlled environment and OEM/open-source policy in the master governance workspace.

## Open-source and branding position

The customer-facing product name is **DigiVista Secure Vault**. The public open-source notice identifies Vaultwarden and the GNU Affero General Public License v3.0. It does not present third-party product branding as DigiVista branding. A complete local copy of Vaultwarden's AGPL license is included in `05_REFERENCE/08-30-Vaultwarden-AGPL-3.0-LICENSE.txt`.

License file SHA-256: `8486A10C4393CEE1C25392769DDD3B2D6C242D6EC7928E1414EFFF7DFB2F07EF`

This is an engineering compliance record, not a legal opinion. Any public or commercial distribution should receive final legal and trademark review.

## Recovery and rollback

The persistent vault volume was retained. Phase-specific configuration backups remain only in the controlled working folder and are excluded from the release ZIP because inspection exports may contain operational metadata. Rollback and restoration procedures are documented in `08-30-Backup-and-Restore-Runbook.md`.

## Remaining owner acceptance

Technical checks are complete. The owner should still perform an interactive login with an authorized test account, confirm the approved DigiVista appearance at normal and mobile widths, and approve the acceptance record. No credentials were requested, created, viewed, or stored during deployment.
