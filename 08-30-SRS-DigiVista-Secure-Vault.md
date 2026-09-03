# Software Requirements Specification — DigiVista Secure Vault

Status: Draft for owner review  
Date: 30 August 2026  
Product-facing name: DigiVista Secure Vault  
Underlying server: Unmodified Vaultwarden

## 1. Purpose

DigiVista Secure Vault provides an internally operated password and credential vault through an HTTPS browser interface. Vaultwarden remains the unchanged open-source server. DigiVista supplies deployment configuration, external visual branding, operational controls, documentation, monitoring, backup, and support.

## 2. Scope

### Included

- Existing Vaultwarden container under Podman on Windows/WSL2.
- Persistent `/data` storage owned by the existing deployment.
- Windows-to-Podman backend reachability on host port 8080.
- Caddy HTTPS at `https://localhost`.
- External DigiVista CSS branding through Vaultwarden's custom stylesheet location.
- Visible open-source and AGPL notice.
- Safe startup automation, diagnostics, reporting, backup, rollback, and monitoring guidance.

### Excluded

- Modification of Vaultwarden source, binaries, image, web-vault application code, authentication logic, cryptographic behavior, database schema, users, passwords, or vault records.
- Removal or concealment of required open-source attribution.
- Public internet exposure, multi-host production architecture, enterprise SSO, and customer-facing SaaS operation unless separately approved.
- Claims of affiliation with Bitwarden, Inc.

## 3. Stakeholders and ownership

Before production acceptance, the following roles must be named:

- Business owner: purpose, funding, and final acceptance.
- Product owner: scope and requirements.
- Technical owner: Podman, Vaultwarden, Caddy, releases, and recovery.
- Security/data owner: privileged access, secrets, retention, backup, and incident handling.

## 4. Operating environment

- Supported host: approved Windows 11 system.
- Virtualization path: current WSL2-backed Podman machine.
- Container: existing container named `vaultwarden`, unless an approved configuration changes the name.
- Backend: container port 80 published to Windows loopback/host port 8080.
- HTTPS endpoint: `localhost` on port 443 via Caddy.
- Browser: currently supported Chromium, Edge, or Firefox release approved by the owner.

## 5. Functional requirements

| ID | Requirement | Priority |
|---|---|---|
| FR-001 | The solution shall detect and use the existing Podman machine and Vaultwarden container. | Must |
| FR-002 | The solution shall refuse to create, remove, or recreate the Vaultwarden container automatically. | Must |
| FR-003 | The solution shall prove a persistent mount exists at `/data` before configuration changes. | Must |
| FR-004 | The solution shall back up inspected configuration, `.wslconfig`, Caddy configuration, and active custom SCSS where present. | Must |
| FR-005 | The solution shall diagnose container health, Podman-machine backend reachability, inspected port bindings, and Windows port 8080 reachability. | Must |
| FR-006 | WSL mirrored networking shall be enabled only when the failure is isolated to Windows forwarding and the installed WSL version supports it. | Must |
| FR-007 | Existing unrelated `.wslconfig` settings shall be preserved. | Must |
| FR-008 | HTTPS and branding shall not proceed until the Windows backend is reachable. | Must |
| FR-009 | The solution shall detect an unrelated owner of port 443 and stop without terminating that process. | Must |
| FR-010 | Caddy shall provide locally trusted HTTPS and reverse proxy only to the local backend. | Must |
| FR-011 | The product-facing interface shall use DigiVista navy/white visual branding through external CSS. | Should |
| FR-012 | Branding failure shall not prevent recovery of the stock Vaultwarden interface. | Must |
| FR-013 | An open-source notice shall identify Vaultwarden, AGPL-3.0, upstream source, and non-affiliation with Bitwarden. | Must |
| FR-014 | Startup automation shall be registered only after required automated checks pass. | Must |
| FR-015 | The deployment shall generate a PASS/FAIL report with changes, backups, root cause, and rollback guidance. | Must |
| FR-016 | An operator shall manually validate password-field input, login, dashboard appearance, and restart/sign-in persistence. | Must |

## 6. Security requirements

| ID | Requirement |
|---|---|
| SR-001 | No secret, password, token, private key, database, or customer vault record shall be written to source control or deployment logs. |
| SR-002 | The browser endpoint shall use HTTPS; normal use over plain HTTP is prohibited. |
| SR-003 | Administrative deployment shall require an elevated Windows session. |
| SR-004 | Caddy shall proxy only to the loopback backend unless separately reviewed. |
| SR-005 | The deployment shall not disable authentication, weaken cryptography, or change Vaultwarden security controls. |
| SR-006 | The script shall never run Podman reset, machine removal, container removal, volume removal, or `/data` deletion. |
| SR-007 | Backups shall be access-controlled, encrypted when stored outside the protected host, and restore-tested. |
| SR-008 | Security-relevant changes and failures shall be recorded without logging secrets. |
| SR-009 | Privileged access shall use named accounts, MFA where available, and least privilege. |
| SR-010 | Public exposure shall require a separate threat model, domain/TLS design, rate controls, patch plan, and approval. |

## 7. Availability and recovery requirements

- The existing `/data` source and destination must match before and after deployment.
- The owner must define production RPO, RTO, retention, backup destinations, and restore-test frequency.
- At least two approved backup copies are required for production, with one logically isolated or immutable.
- A failed branding verification must disable the new stylesheet and preserve the vault service.
- A failed backend check must prevent HTTPS, branding, and startup-task changes from continuing.

## 8. Compliance and representation

- DigiVista Secure Vault is deployment/operator branding.
- Vaultwarden remains the underlying unmodified open-source server.
- Vaultwarden and AGPL-3.0 attribution must remain available through the open-source notice.
- The service must not claim Bitwarden endorsement, authorization, or affiliation.
- Any future modification of AGPL-covered code requires a separate review of corresponding-source obligations.

## 9. Acceptance criteria

The release is accepted only when:

1. Static script parsing and prohibited-command scans pass.
2. Persistent `/data` evidence passes before and after the run.
3. Windows backend reachability passes.
4. Caddy validation and HTTPS reachability pass.
5. The external branding marker is served, or branding is intentionally skipped.
6. The open-source notice is reachable.
7. The startup task is verified, unless intentionally skipped.
8. The operator completes the manual login, password-input, dashboard, and persistence tests.
9. The generated report is reviewed and approved by the named owners.

## 10. Open owner decisions

- Name the four accountable owners and deputies.
- Approve target environment classification: development, pilot, or production.
- Define RPO, RTO, retention, and restore-test schedule.
- Decide whether account registration is enabled and who may create accounts.
- Decide patch cadence and acceptable maintenance window.
- Approve monitoring destinations and incident contacts.
