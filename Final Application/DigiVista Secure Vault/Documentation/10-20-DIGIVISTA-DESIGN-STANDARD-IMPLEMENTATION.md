# DigiVista Design Standard Implementation

Date: 20 October 2026  
Application: DigiVista Secure Vault  
Local URL: `https://localhost/`  
Framework boundary: Vaultwarden with the upstream Bitwarden Web Vault  
Theme source: `04_ASSETS/08-30-digivista-phase2-branding.scss`

## Applied shared tokens

- Navigation `#102E49`
- Primary `#095B89`; hover `#07476B`
- Accent `#FF981A`
- Page `#F4F7FC`; surface `#FFFFFF`; panel `#EDF4FA`
- Text `#17374F`; secondary text `#526B80`
- Border `#D6E2EE`; active navigation `#1D506F`
- Information, success, warning, failure and inactive state token pairs
- Arial/Helvetica with Noto Sans Devanagari and Nirmala UI fallbacks
- 12px cards, 8px controls and the shared 4/8/12/16/24/32 spacing model

## Updated reusable surfaces

- Anonymous sign-in, unlock and account-creation layouts
- Authenticated navigation, logo treatment and active navigation state
- Page titles and headings
- Primary, secondary and destructive button presentation
- Inputs, labels, helper text and visible focus states
- Cards, dialogs, tables, menus and badges
- Vault onboarding accordion and task states
- Vault filters, table/list workspace and empty states
- Desktop navigation width and mobile touch targets
- Responsive vault columns and contained table overflow
- Open-source attribution footer

## Preserved controls

- Authentication and account unlocking
- Organization and collection permissions
- Validation and API behavior
- Vault data, attachments and persistent storage
- Audit-relevant upstream workflows
- Vaultwarden and Bitwarden ownership and AGPL notices

Vaultwarden source code was not modified. The design is delivered through the existing external theme and approved reverse-proxy asset path.

## Exceptions and non-applicable requirements

- Ticketing-specific badges, queues and SLA metrics are not applicable because the application has no ticketing module.
- KPI cards and charts were not added because the vault has no corresponding business metrics; invented figures are prohibited by the standard.
- Existing upstream language strings and route availability remain controlled by Web Vault. The theme supplies the specified Devanagari font fallback but does not rewrite translations.
- Multi-account switching continues to require per-account unlock. This security boundary is intentionally unchanged.

## Verification

- Project verification: 16/16 checks passed.
- Deployment/security controls: 11/11 checks passed.
- Backend, HTTPS, open-source notice and licence routes returned HTTP 200.
- Container remained non-privileged and on the approved image.
- Vaultwarden source modified: No.
- Vault data modified: No.

Manual acceptance remains appropriate for long names, each supported language, each demo role and narrow physical devices after the relevant test account has been securely unlocked.
