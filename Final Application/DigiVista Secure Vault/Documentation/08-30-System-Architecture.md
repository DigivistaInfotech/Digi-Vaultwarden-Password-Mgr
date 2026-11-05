# DigiVista Secure Vault — System Architecture

Status: Draft for technical and security review

## Architecture boundary

```text
Browser
  -> HTTPS 443: localhost
     -> Caddy on Windows
        -> HTTP loopback 127.0.0.1:8080
           -> Podman/WSL2 published port
              -> Unmodified Vaultwarden container:80
                 -> Existing persistent /data mount
```

External DigiVista branding is loaded from `/data/templates/scss/user.vaultwarden.scss.hbs`, a deployment customization boundary. It does not alter Vaultwarden source, binaries, authentication, cryptography, database schema, users, passwords, or vault records.

## Components

| Component | Responsibility | Change policy |
|---|---|---|
| Browser | Secure user interaction | Supported version; no plain-HTTP normal use |
| Caddy | Local TLS termination, reverse proxy, notice page, CSS cache control | Managed DigiVista configuration |
| Windows host | Caddy, startup task, operator controls | Controlled and logged |
| WSL2/Podman machine | Container runtime and port-forwarding path | Repair only when diagnostics justify it |
| Vaultwarden container | Password-vault server | Application code remains unchanged |
| Persistent `/data` | Vault database and server state | Never delete; backup and verify |
| External SCSS | DigiVista visual layer | Conservative selectors; reversible |

## Trust boundaries

- Browser to Caddy: encrypted TLS boundary.
- Caddy to backend: loopback-only local path.
- Windows to WSL/Podman: runtime forwarding boundary.
- Container to `/data`: critical persistence boundary.
- Operator/admin: privileged change boundary requiring controlled access.

## Failure containment

- If container health fails, stop before networking changes.
- If Podman-machine reachability fails, do not assume Windows forwarding is the cause.
- If Windows backend fails, do not configure HTTPS or branding.
- If port 443 belongs to another process, stop without terminating it.
- If CSS verification fails, disable the new stylesheet automatically.
- If data-mount identity changes, report failure and stop acceptance.

## Upgrade model

Vaultwarden upgrades remain an independent controlled operation. Before an upgrade, record the deployed image version, back up `/data`, preserve Caddy and SCSS, review upstream release notes, test in a non-production environment, validate selectors, and retain rollback evidence.
