# DigiVista Secure Vault — Customer-Use Status

Date: 2026-10-20  
Current decision: **READY FOR CONTROLLED CUSTOMER DEMONSTRATION AND EVALUATION**  
Production decision: **NOT YET APPROVED**

## Applied customer presentation

- Product presentation uses the DigiVista Secure Vault name and DigiVista logo.
- Login, navigation, vault list, filters, tables, forms, dialogs, and responsive layouts use the approved DigiVista navy/white theme.
- A filter-panel contrast defect was corrected by limiting dark styling to the actual navigation sidebar.
- Vaultwarden attribution, the AGPL-3.0 licence, and the open-source notice remain available.
- The customer-facing branding does not claim ownership of Vaultwarden or affiliation with Bitwarden, Inc.

## Verified on 2026-10-20

| Area | Result |
|---|---|
| Maintained project checks | PASS — 16/16 |
| Live compliance controls | PASS — 11/11 |
| HTTPS application | PASS — HTTP 200 |
| Branding stylesheet | PASS — HTTP 200 |
| DigiVista logo | PASS — HTTP 200 |
| Open-source notice | PASS — HTTP 200 |
| AGPL-3.0 licence copy | PASS — HTTP 200 |
| Persistent vault data mount | PASS |
| Container privilege boundary | PASS — not privileged |
| Startup task | PASS — limited privilege, last result 0 |

## Demonstration access model

- Admin: organization owner.
- Manager: organization administrator.
- Supervisor: user restricted to the Supervisor collection.
- User: user restricted to the User collection.
- Each account's personal vault remains private to that account.
- Shared customer records must be placed only in the intended organization collection.

## Ownership and open-source conditions

- Vaultwarden and its original code remain owned by their respective copyright holders.
- DigiVista owns its independent branding, configuration, deployment automation, and documentation, subject to any applicable third-party licences.
- Any distributed or network-operated modified Vaultwarden version must retain applicable copyright and licence notices and make the complete corresponding modified source available under AGPL-3.0.
- The source reference and local licence copy must remain reachable from the customer deployment.

## Production gates still required

1. Customer-specific hostname and trusted public TLS certificate.
2. Backup-and-restore exercise using an isolated copy, without touching live vault data.
3. Approved RPO, RTO, retention, incident-response owner, and support owner.
4. Vulnerability review of the pinned Vaultwarden image and all deployment dependencies.
5. Final business, security/data-owner, and legal/licensing approval.
6. Removal or reset of temporary demo identities and dummy secrets before production use.

The current build may be shown to customers in a controlled demo environment. It must not be represented as production-approved until every production gate above is recorded as complete.
