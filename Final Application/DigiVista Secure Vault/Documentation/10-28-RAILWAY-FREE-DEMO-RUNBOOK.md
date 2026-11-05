# DigiVista Secure Vault — Railway Free Demo Runbook

Status: deployment-ready configuration; external Railway account setup pending

## Purpose

This configuration runs the approved, unmodified Vaultwarden 1.37.2 image on Railway for a controlled demonstration of up to 15 dummy users. It is not a production approval.

## Mandatory storage control

Before the first start, attach a Railway persistent volume to the service at exactly:

`/data`

Do not create demo accounts or vault records until the volume is attached and a restart proves persistence.

## Deployment sequence

1. Create a Railway project from the DigiVista GitHub repository.
2. Confirm Railway detects the root `Dockerfile`.
3. Add a persistent volume mounted at `/data`.
4. Set `SIGNUPS_ALLOWED=true` only for the controlled account-enrolment window.
5. Deploy and use the temporary Railway HTTPS domain for initial validation.
6. Create the owner account and the approved dummy accounts.
7. Immediately set `SIGNUPS_ALLOWED=false` and redeploy/restart.
8. Validate `/alive`, login, logout, branding, open-source notice, and persistence after restart.
9. Add `vault.digivistainfotech.in` as a Railway custom domain.
10. Add Railway's exact CNAME and TXT verification records to Hostinger DNS without changing existing MX, SPF, DKIM, Microsoft verification, website, CRM, API, or Academy records.

## Required Railway variables

Set these in Railway; never commit secret values:

- `DOMAIN=https://<temporary Railway hostname>` initially; change it to `https://vault.digivistainfotech.in` after domain verification.
- `SIGNUPS_ALLOWED=false` except during the controlled enrolment window.
- `INVITATIONS_ALLOWED=true`.
- `SHOW_PASSWORD_HINT=false`.
- `LOG_LEVEL=warn`.
- `EXTENDED_LOGGING=false`.

Do not configure an `ADMIN_TOKEN` unless the approved test procedure requires the admin page. If required, generate a high-entropy Argon2 PHC value and store it only as a masked Railway variable.

## Demo restrictions

- Dummy data only; never enter customer or production credentials.
- Maximum 15 demo users.
- No file attachments on the free storage tier.
- No shared password for all users.
- Each test user receives a unique temporary password through a controlled channel and changes it at first login.
- Free-tier uptime, retention, support and capacity are not production guarantees.

## Acceptance checks

- `/alive` returns a successful response.
- `/open-source-notices/` loads and links to the bundled AGPL-3.0 licence.
- DigiVista logo and approved stylesheet load.
- Account registration is closed after enrolment.
- A test record survives a service restart.
- Existing `digivistainfotech.in` website and Microsoft 365 mail records remain unchanged.
