# DigiVista Secure Vault — Project Index

Status: Controlled implementation complete; production acceptance remains gated

| Field | Current record |
|---|---|
| Product | DigiVista Secure Vault |
| Purpose | Internally operated secure password and credential vault |
| Underlying server | Unmodified Vaultwarden |
| Branding | External DigiVista stylesheet and deployment configuration |
| Priority | Separate product track; does not change ticketing-first portfolio priority |
| Source package | `DigiVista-Secure-Vault-Codex-Handoff-2026-08-30` |
| Authoritative repository | Pending owner declaration |
| Environment | Controlled local Windows host; backend and HTTPS healthy |
| Business owner | Pending |
| Product owner | Pending |
| Technical owner | Pending |
| Security/data owner | Pending |
| Data store | Existing Vaultwarden persistent `/data`; exact mount recorded at deployment |
| HTTPS | Caddy local TLS at `localhost` |
| Backup/RPO/RTO | Pending owner approval; see backup runbook |
| Current release | Release candidate prepared; production acceptance not granted |

## Governing documents

- `08-30-SRS-DigiVista-Secure-Vault.md`
- `08-30-System-Architecture.md`
- `08-30-Security-and-Compliance.md`
- `08-30-Deployment-Runbook.md`
- `08-30-Backup-and-Restore-Runbook.md`
- `08-30-Monitoring-and-Operations.md`
- `08-30-Test-and-Acceptance-Plan.md`
- `08-30-Requirements-Traceability-Matrix.md`
- `09-03-FINAL-VERIFICATION-REPORT.md`
- `02_DEPLOYMENT/08-30-Invoke-Project-Tests.ps1`
- `05_REFERENCE/08-30-Approved-Component-Baseline.json`

## Current risks

- Full Windows restart-persistence and isolated restore exercises remain pending.
- Owner roles, RPO/RTO, retention, and release authority are not yet assigned.
- Component versions are recorded; vulnerability disposition still requires the security owner.
- Browser-level acceptance remains manual.

## Next gate

Complete owner visual review, restart/restore exercises, ownership assignments, and production acceptance.
