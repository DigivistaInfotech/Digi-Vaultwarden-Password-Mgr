# DigiVista Secure Vault — Multi-user Permission/UAT Results

Date: 11-06-2026  
Status: **Automated policy tests passed; live customer UAT awaiting named test users and signatures**

## Verified automatically

| Test | Result |
|---|---|
| No role may view another user's personal vault | PASS |
| Organization management is Owner-only | PASS |
| Member management is limited to Owner and Admin | PASS |
| Manager/User access is limited to assigned collections | PASS — policy contract |
| Home and Teen profiles do not receive organization collection access | PASS |
| Teen, Home, and Family experiences map to restricted dashboards | PASS |
| Administration is hidden outside the professional experience | PASS |
| Dashboard-to-vault links remain on the trusted origin | PASS |

These tests validate the DigiVista policy and presentation layer. Vaultwarden organizations, groups, collections, and collection permissions remain the enforcement authority.

## Live UAT cases requiring real test identities

| ID | Persona | Test | Expected result | Customer result |
|---|---|---|---|---|
| UAT-01 | Owner | Invite members and assign groups/collections | Allowed; master passwords remain unknown | Pending |
| UAT-02 | Admin | Manage permitted members/collections | Allowed; owner-only functions denied | Pending |
| UAT-03 | Manager | View/edit assigned department collection | Allowed only for assigned collection | Pending |
| UAT-04 | User | View assigned collection; attempt restricted edit | View allowed; edit denied where read-only | Pending |
| UAT-05 | Unassigned user | Attempt another department collection | Denied | Pending |
| UAT-06 | Any organization role | Attempt another user's personal vault | Not available | Pending |
| UAT-07 | Leaver | Revoke organization access and sessions | Access removed; shared secrets queued for rotation | Pending |
| UAT-08 | Teen/Home/Family | Verify simplified categories and no administration | Only applicable experience is shown | Pending |

## Evidence rules

- Use dedicated demo users only; never share their master passwords in reports.
- Record role, group, and collection assignments without vault secrets.
- Redact email addresses in public evidence.
- Capture allow/deny results and audit evidence where available.
- Delete demo records after acceptance according to the approved retention process.

## Customer acceptance

Customer organisation: ____________________  
Customer representative: ____________________  
Technical tester: ____________________  
Decision: `ACCEPT / ACCEPT WITH CONDITIONS / REJECT`  
Conditions: ________________________________________________  
Acceptance date: ____________________  
Signature or recorded approval reference: ____________________

Until the fields above are completed, customer UAT is **not approved**.
