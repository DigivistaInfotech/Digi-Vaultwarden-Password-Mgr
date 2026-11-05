# DigiVista Secure Vault — Monitoring and Operations

Status: Draft operational baseline

## Monitoring scope

| Signal | Expected state | Suggested response |
|---|---|---|
| Podman machine | Running during service window | Start existing machine; investigate repeated failures |
| Vaultwarden container | Running/healthy | Review logs without exposing secrets |
| Internal HTTP | Successful local response | Isolate container/application issue |
| Windows backend 8080 | Reachable locally | Diagnose Podman/WSL forwarding |
| HTTPS 443 | Reachable with trusted certificate | Review Caddy, certificate trust, and port conflicts |
| Open-source notice | HTTP 200 over HTTPS | Restore controlled Caddy content |
| Custom CSS marker | Present when branding enabled | Disable failed stylesheet and investigate selectors |
| Persistent `/data` | Same approved source and destination | Treat change as critical incident |
| Disk capacity | Above approved free-space threshold | Expand/clean through approved procedure |
| Backup job | Completed and verified | Escalate missed/failed backups |
| Certificate status | Valid and trusted | Renew/re-trust through approved process |

## Logging safeguards

- Do not capture master passwords, account credentials, vault items, session material, tokens, or private keys.
- Restrict logs to operational status, timestamps, component versions, non-secret configuration evidence, and error categories.
- Protect logs against unauthorized modification and define retention.

## Incident classes

- Critical: suspected data loss, unauthorized access, changed `/data` identity, exposed secrets, or unrecoverable login outage.
- High: HTTPS failure, repeated container failure, backup failure beyond RPO, or security patch emergency.
- Medium: branding failure with stock UI available, startup-task failure, or non-critical monitoring gap.

## Integration boundary

The portfolio Monitoring System remains a separate product. It may consume health signals or create tickets only through approved authenticated interfaces. Vault credentials and vault content must never be copied into monitoring or ticketing repositories.

