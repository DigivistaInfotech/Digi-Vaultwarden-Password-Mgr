# DigiVista Secure Vault — Phase 2 Templates and Privacy Standard

Status: Approved for implementation prototype  
Scope: DigiVista presentation and guidance layer; Vaultwarden encryption/core remains unchanged.

## Design rule

The DigiVista dashboard must guide the user into an existing encrypted Vaultwarden record type. It must not store passwords, journal text, banking details, recovery information, or encryption keys in a separate analytics or application database.

## Common fields

Every applicable record should support:

- Record title
- Category/folder
- Company or household
- Region, country and site/location (business records only)
- Owner and authorised collection/team (shared business records only)
- Username/account identifier
- Password or key (handled only by the Vaultwarden encrypted client)
- Website, source or support URL
- IP address/hostname where applicable
- Notes
- Tags/classification
- Review or expiry date
- Favourite and archive status

## Guided templates

### Website and application login

Use Vaultwarden type: Login.

- Service/application name
- Website/login URL
- Username/email
- Password
- TOTP secret only when the owner intentionally stores it
- Recovery/source URL
- Account owner
- Notes
- Review date

### Desktop, laptop and device

Use Vaultwarden type: Login or Secure Note.

- Device name and asset tag
- Device type
- Company/owner
- Country/site
- Hostname/IP address
- Operating system
- Username
- Password or recovery key
- Support/source URL
- Notes and review date

### Server and infrastructure

Use Vaultwarden type: Login or SSH Key.

- Server/service name
- Environment (production/test/development)
- Company, region, country and site
- Hostname/IP and protocol/port
- Username
- Password or SSH key
- Console/source URL
- Technical owner
- Expiry/rotation date
- Notes

### Network device and security appliance

Use Vaultwarden type: Login.

- Device/appliance name
- Vendor/model and serial or asset reference
- Site/country
- Management IP/hostname
- Management URL
- Username/password
- Support portal/source URL
- Responsible team
- Rotation/review date
- Notes

### Banking and payment references

Use Vaultwarden type: Login or Card.

- Institution/card name
- Official website URL
- Username/customer identifier
- Account nickname or masked last four digits
- Password/PIN only when the owner accepts the risk and policy permits it
- Card details in the dedicated Card record type only
- Support/contact reference
- Notes and review date

Do not display full account/card values on dashboard cards. Mask sensitive values and require vault unlock before viewing.

### Personal identity

Use Vaultwarden type: Identity.

- Name and contact details
- Address
- Organisation/title when applicable
- Only the minimum identity fields required by the user

### Private Journal and Goals

Use Vaultwarden type: Secure Note.

- Title
- Entry date
- Optional theme: Reflection, Goal, Milestone, Idea, Gratitude or Private Note
- Encrypted note body
- Optional target date and milestone list
- Optional tags

Private Journal and Goals is personal-only by default. It must never be placed in an organisation collection, indexed by analytics, used for advertising, scanned by AI, included in administrator reports, or exposed to a guardian/corporate administrator without the owner's explicit sharing action.

### Recovery kit

Use Vaultwarden Secure Note only when the user intentionally chooses this method; also provide an offline recovery-kit option.

- Recovery instructions
- Trusted contact reference
- Backup location reference (not the backup encryption key itself unless separately protected)
- Last backup date
- Last restore-test date

## Profile visibility

- Professional: business categories, authorised collections, audit/review information and private personal workspace.
- Home: websites, banking, devices, Wi-Fi/VPN, identity, Private Journal and Goals, and recovery.
- Teen: social/apps, school, gaming, devices, personal items and safe notes.
- Family/Child: only guardian-approved games/apps, school, family devices and safe notes.

Visibility must be enforced by account, organisation, collection and permission—not by CSS alone.

## Privacy and compliance controls

- Data minimisation: collect only fields the user needs.
- Purpose limitation: never reuse vault metadata for marketing or profiling.
- No master-password access for DigiVista or organisation administrators.
- Personal vault and Private Journal remain private from corporate administrators.
- Clear consent before sharing or moving a personal item into a business collection.
- Export and deletion controls must be available to the owner.
- Encrypted backup, recovery acknowledgement and periodic restore testing.
- Country/flag is user-selected presentation metadata; it does not claim data residency.
- Child profiles require guardian-managed onboarding and country-specific legal review.
- Accessibility: country names accompany flags; icons always include text and descriptions.

## Implementation sequence

1. Category-aware dashboard and country/profile selection.
2. Guided template panels mapped to Vaultwarden record types.
3. Organisation, collection and role-based permission integration.
4. Recovery, backup status and security-health guidance.
5. Accessibility, mobile and localisation testing.
6. Security and privacy acceptance testing before live release.
