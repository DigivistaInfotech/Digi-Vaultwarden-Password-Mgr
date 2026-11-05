# DigiVista Secure Vault

DigiVista Secure Vault is a controlled Windows deployment and external-branding package for an **unmodified Vaultwarden** server. It provides local Caddy HTTPS, DigiVista styling/assets, startup automation, compliance checks, test automation, and governance documentation without changing Vaultwarden source, authentication logic, database schema, or vault records.

## Verified baseline

- Vaultwarden 1.37.2 / Web Vault 2026.7.0
- Podman 6.0.2
- Caddy 2.11.4
- Local endpoint: `https://localhost`
- Repository gate: 16/16 checks passed on 3 September 2026
- Live compliance: 11/11 controls passed on 3 September 2026

## Start here

1. Read [`08-30-Project-Index.md`](08-30-Project-Index.md).
2. Review [`08-30-Deployment-Runbook.md`](08-30-Deployment-Runbook.md).
3. Run `02_DEPLOYMENT/08-30-Invoke-Project-Tests.ps1`.
4. Review the maintained completion script with `-WhatIf` before any approved host change.

The dated release ZIP and its hash manifest are under `07_RELEASE/`. Operational backups and received legacy scripts are intentionally excluded from version control.

## Open-source notice

Vaultwarden remains identified as the underlying open-source component under GNU AGPL v3. This repository includes the applicable notice and licence copy. DigiVista branding does not imply that Vaultwarden or Bitwarden is a DigiVista-authored product.
