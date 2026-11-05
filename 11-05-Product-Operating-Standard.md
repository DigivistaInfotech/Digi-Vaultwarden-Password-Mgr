# DigiVista Secure Vault — Product Operating Standard

Status: Phase 1 implementation baseline  
Date: 5 November 2026

## Product profiles

- **Home / Individual:** private categories, guided recovery, encrypted backup and optional emergency access.
- **Family:** private vaults plus explicitly shared family collections.
- **Business:** organization groups, department collections, least-privilege roles and lifecycle controls.
- **Customer-managed / on-premises:** customer-controlled server, storage, backup destination and encryption material.

## Credential taxonomy

Use folders for personal organization and organization collections for approved sharing:

1. Website & Application
2. Personal Accounts
3. Desktop & Laptop
4. Server & Infrastructure
5. Network Devices
6. Security Appliances
7. Wi-Fi & VPN
8. Banking & Finance (restricted)
9. Shared Team Credentials
10. Archive

Every applicable record should contain the service/asset name, username, website or IP address, system owner, business purpose, review/expiry date and non-secret operational notes.

## Identity and access

- Administrators invite users; they do not create or retain users' permanent master passwords.
- Users create their own master passwords and enroll approved recovery controls.
- Personal vault items remain private. Company credentials belong in authorized organization collections.
- Groups map to departments such as Export, Import, Custom Sales, IT and Accounts.
- Collection permissions follow least privilege and are reviewed periodically.
- Super administrators manage policy and access; the role must not become a decryption backdoor into private vaults.

## Mandatory onboarding controls

1. Master-password guidance and private hint.
2. Two-step login plus offline recovery code.
3. Offline recovery kit acknowledgement.
4. Trusted device, passkey, emergency access or approved organization recovery where supported.
5. Backup-policy acknowledgement and latest-backup visibility.
6. Test record create/view/edit/delete exercise.
7. Privacy notice and open-source notice acknowledgement.

## Recovery boundary

Email does not reveal the old master password. It may carry a hint or initiate a preconfigured recovery workflow. If no recovery method exists and no trusted unlocked device remains, zero-knowledge encryption means the personal vault cannot be recovered.

## Backup standard

- Back up the complete persistent data directory, database, attachments, sends, cryptographic keys and deployment configuration.
- Keep at least one encrypted copy on separate customer-controlled infrastructure.
- Keep backup-encryption keys separate from the backup media.
- Define RPO, RTO and retention per customer.
- Test restoration on a schedule and record evidence without exposing vault contents.
- Restoration of server data does not bypass a user's master password.

## User lifecycle

- Joiner: invite, group assignment, recovery enrollment and training.
- Mover: remove old access before granting new department access.
- Leaver: revoke sessions/access, rotate shared credentials and retain required audit evidence.
- Never request or record a user's master password during support or offboarding.

## Compliance position

Controls are designed for alignment with ISO/IEC 27001 and GDPR principles including least privilege, data minimization, purpose limitation, security, retention and user rights. Alignment does not constitute certification or legal advice; formal certification and privacy compliance require organizational evidence and independent review.

## Implementation boundary

Vaultwarden source, authentication, cryptography and database schema remain unmodified. DigiVista supplies external branding, deployment, operational policy, help, monitoring, backup and support while preserving Vaultwarden/AGPL attribution.
