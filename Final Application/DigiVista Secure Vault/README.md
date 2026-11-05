# DigiVista Secure Vault — Final Application

This is the controlled source and documentation package for DigiVista Secure Vault.

Start with:

- `11-05-CLOSURE-STATUS.md` — current position and closure path.
- `Documentation/08-30-SRS-DigiVista-Secure-Vault.md` — requirements.
- `Documentation/11-05-Phase2-Templates-and-Privacy-Standard.md` — Phase 2 data and privacy model.
- `Application/phase2-dashboard/` — React + TypeScript dashboard source.
- `Deployment/` — safe build, test, proxy, and deployment assets.
- `Compliance/` — licensing, security, and open-source notices.

## Security boundary

Vaultwarden remains the secure vault engine. DigiVista presentation and guidance do not move encrypted vault contents into a separate application database. Never commit runtime databases, vault exports, credentials, secrets, private keys, `.env` files, or customer backups.

## Local verification

From `Application/phase2-dashboard`:

```powershell
npm ci
npm test
npm run build
```

Run the maintained project verification script from `Deployment` as documented in the deployment runbook.
