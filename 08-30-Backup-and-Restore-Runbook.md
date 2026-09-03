# DigiVista Secure Vault — Backup and Restore Runbook

Status: Draft; production RPO/RTO requires owner approval

## Protected material

- Vaultwarden persistent `/data` content.
- Container and Podman-machine inspection evidence.
- Caddy configuration and local operational scripts.
- `.wslconfig` when present.
- Active DigiVista SCSS and logo source.
- Deployment reports, release manifests, decisions, and approved documentation.

## Backup rules

- Use at least two approved destinations for production-critical data.
- Keep one copy logically isolated, offline, or immutable.
- Encrypt backups and restrict restore rights.
- Never place passwords, tokens, private certificates, or production vault data in Git.
- Record date, environment, owner, source version, file count, hash, and verification result.
- A copied archive is not accepted until it can be opened and its manifest/hash verified.

## Application-consistent backup

The technical owner must select a Vaultwarden-supported backup procedure appropriate to the active database type. Do not copy a live database blindly. Record whether the procedure uses an approved database backup command, a controlled service stop, or another tested consistency method.

## Restore procedure

1. Declare the incident and obtain restore approval.
2. Preserve the failed/current state for investigation where safe.
3. Select the approved backup by date, environment, hash, and compatibility.
4. Restore into an isolated test environment first whenever possible.
5. Verify database integrity, attachments, configuration, login, and representative records.
6. Restore production only through the approved procedure.
7. Verify HTTPS, users, vault access, audit evidence, and startup behavior.
8. Record actual recovery time and data-loss window against RTO/RPO.

## Required owner values

- RPO: Pending owner decision.
- RTO: Pending owner decision.
- Backup frequency: Pending owner decision.
- Retention: Pending owner decision.
- Backup owner and deputy: Pending owner decision.
- Restore-test frequency: Pending owner decision.

