# DigiVista Secure Vault — Compliance Validation Report

Date: 2026-08-30  
Environment: Controlled local Windows pilot  
Status: **Technically validated; production/legal gates remain open**

## Verified controls

| Control | Result |
|---|---|
| Vaultwarden application | Running, version 1.37.2 |
| Source/binary/auth modification | None performed |
| Persistent data | Named volume `vaultwarden-data` mounted read/write at `/data` |
| Container privilege | `Privileged=false`; no added capabilities |
| HTTPS | `https://localhost` returned HTTP 200 |
| Backend | `http://localhost:8080` returned HTTP 200 |
| Open-source notice | HTTP 200; identifies Vaultwarden and GNU AGPL |
| Local license | HTTP 200; 34,523 bytes |
| Public notice third-party branding | No Bitwarden name in the separate notice |
| Login UI | Rendered; DigiVista CSS marker `--dv-primary: #063b66` active |
| Login logo stability | DigiVista logo present after 2.5 and 6 seconds; upstream inline SVG presentation hidden externally |
| Authenticated sidebar branding | Exact Web Vault 2026.7 structure `bit-nav-logo > div > a > bit-svg` covered by the external stylesheet |
| Responsive login presentation | External CSS only; authentication fields, validation, flow, and compliance footer preserved |
| Browser console | No warning/error entries during fresh validation |
| Startup task | Limited privilege; last result 0 |
| Restart policy | `always` |

## Approved image baseline

- Running image ID: `d5b851abc3aa14b52feea09652bb467753f0ef12516cc9af9df254782eab15fb`
- Approved local tag: `localhost/digivista/vaultwarden-approved:1.37.2-2026-08-30`
- Recorded upstream digests:
  - `sha256:094b5689ed81549bd293418395c7cf495ae9d960fc2d4928cef2083ef913d912`
  - `sha256:5d326778c22f063d093d6b0c9c766a28249561632266776f2c93132ab0ad3a80`

The local approval tag was added without recreating the running container. The container remains bound to its existing immutable image ID. Future rebuilds must use an approved version/digest and must not pull `latest` implicitly.

## Logging control

The container uses the `journald` log driver. Notification request logs may contain bearer material in query strings. Accordingly:

1. Treat container logs as security-sensitive operational data.
2. Restrict log access to named technical/security administrators.
3. Do not export raw logs to release packages, tickets, governance records, chat, or email.
4. Redact query strings, authorization headers, cookies, tokens, email addresses, and vault metadata before sharing.
5. Define retention and incident-handling periods before production approval.

No credential, token, or vault content has been copied into this report.

## Branding and attribution boundary

The DigiVista stylesheet and separate open-source notice are active. The upstream web vault still supplies its own title/footer and legal disclaimer. Those upstream notices must not be removed through source modification. Any future presentation change must remain external, preserve required attribution, and receive legal/trademark review before customer distribution.

## Open gates

- Named business, product, technical, security, backup, and legal owners.
- Successful backup restoration exercise with dated evidence.
- Vulnerability review for the exact approved component versions.
- Production log-access and retention configuration.
- Interactive login and logout acceptance using an authorized test account.
- Legal approval for commercial/public distribution and product representation.

This document records engineering controls and is not legal advice or compliance certification.
