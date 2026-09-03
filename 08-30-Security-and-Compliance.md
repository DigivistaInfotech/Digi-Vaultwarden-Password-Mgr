# DigiVista Secure Vault — Security and Compliance Standard

Status: Draft control baseline; not legal certification

## Non-modification commitment

The deployment does not modify Vaultwarden source code, web-vault application code, binaries, authentication logic, cryptographic behavior, database schema, users, passwords, or vault records. DigiVista branding is an external configuration and stylesheet layer.

## Open-source obligations

- Keep a visible notice identifying Vaultwarden as the underlying open-source server.
- Identify GNU AGPL-3.0 and provide upstream source and license references.
- Do not use third-party product names, logos, or trade dress in public DigiVista branding unless separately reviewed and authorized.
- Public compliance material should identify Vaultwarden and its AGPL license without introducing unrelated third-party branding.
- If AGPL-covered code is modified in the future and users interact with it over a network, perform a separate corresponding-source review before release.

## Security controls

- HTTPS is mandatory for normal browser use.
- Backend exposure is limited to the local host architecture unless separately approved.
- Deployment requires Administrator PowerShell and records non-secret evidence.
- No credentials or vault content are collected in logs or reports.
- Persistent data is verified before and after deployment.
- Unrelated port owners are not stopped automatically.
- Destructive Podman reset/removal and `/data` deletion are prohibited.
- Production access, backup access, and restore rights must be least-privilege and attributable.
- Pin every approved release to an immutable container image ID or digest. A floating `latest` reference must not be used for a future rebuild or promotion.
- Treat container journals as security-sensitive because request URLs can contain bearer material. Restrict access, define retention, and redact before export.
- Never place raw container logs or inspection exports in release archives or governance records.

## Branding controls

- Product-facing name: DigiVista Secure Vault.
- Approved palette: navy, white, restrained supporting colors; orange remains primarily within logo artwork.
- CSS must not restructure authentication forms, hide password inputs, replace authentication text through brittle pseudo-elements, or suppress compliance notices.
- Branding must fail safely to the stock interface.

## Evidence required before production

- Named business, product, technical, and security/data owners.
- Approved SRS and architecture.
- Static safety scan and deployment report.
- Current backup and successful restore-test evidence.
- HTTPS, login, persistence, and rollback acceptance evidence.
- Vulnerability/patch review for the selected Vaultwarden, Podman, WSL, Caddy, Windows, and browser versions.
- Exact image ID/digest approval and verification evidence.
- Log-access, redaction, retention, and incident-handling acceptance.
