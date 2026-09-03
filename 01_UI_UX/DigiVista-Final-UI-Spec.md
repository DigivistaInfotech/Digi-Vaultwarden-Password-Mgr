# DigiVista Secure Vault — Final UI Specification

## Approved visual direction
Use the two approved concepts as the design reference:
- Login: premium split/enterprise look with DigiVista branding, navy/white palette, subtle security imagery, and a focused sign-in card.
- Main dashboard: navy sidebar + navy top bar, white content surface, clean cards/table, restrained shadows, compact spacing.

## Brand system
- Primary navy: #063B66
- Deep navy: #042B4A
- Active navy: #0A4F82
- Surface: #FFFFFF
- Page background: #F6F9FC
- Border: #DCE6EF
- Primary text: #102A43
- Secondary text: #5E7388
- Success: #198754
- Orange: reserved for the logo only; do not use as a dominant UI control color.

## Login page
CSS-safe target:
- Compact navy header with DigiVista logo.
- “Welcome to DigiVista Secure Vault” heading.
- Subheading: “Secure access to your passwords and digital credentials.”
- White centered authentication card with 14–16px radius and subtle shadow.
- Navy primary buttons with white text.
- Remove/hide the large default Vaultwarden safe illustration where selectors permit.
- Small trust statement: “Secure • Private • Trusted”.
- Footer attribution: “Powered by Vaultwarden • Open Source Notices”.

A true two-column split page with custom explanatory content requires a maintained custom web-vault build because CSS cannot reliably restructure the Angular component tree across Vaultwarden upgrades.

## Main dashboard
CSS-safe target:
- DigiVista logo in the left sidebar.
- Dark navy sidebar, compact active navigation state.
- Navy top bar with clean white controls.
- White cards with subtle borders/shadows.
- Reduced oversized spacing.
- Polished checklist/filter/table surfaces.
- Navy buttons with white text.
- Minimal orange only through the logo artwork.
- Small footer/open-source disclosure.

## Compliance / representation
- Product-facing name: DigiVista Secure Vault.
- Do not present the service as “Bitwarden”.
- Keep a visible/open-source notice page that identifies Vaultwarden and AGPL-3.0.
- Do not remove upstream license obligations.
- If the deployed Vaultwarden/web-vault code itself is modified and made available to users over a network, keep the corresponding source for that deployed modified version available as required by AGPLv3.

## Implementation boundary
This deployment script intentionally uses CSS/SCSS only. It does not modify user data, database contents, authentication logic, or Vaultwarden binaries.
