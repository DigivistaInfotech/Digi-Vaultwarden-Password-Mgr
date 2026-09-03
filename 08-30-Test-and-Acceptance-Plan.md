# DigiVista Secure Vault — Test and Acceptance Plan

Status: Controlled pilot acceptance in progress

| Test ID | Test | Expected result | Evidence | Codex result | Owner/User result |
|---|---|---|---|---|---|
| T-001 | Parse completion script | No PowerShell syntax errors | Static test output | PASS | Pending / ____ |
| T-002 | Scan prohibited commands | No reset/removal/volume or `/data` deletion commands | Static scan output | PASS | Pending / ____ |
| T-003 | Inspect existing container | Named existing container found | Deployment log | PASS | Pending / ____ |
| T-004 | Prove `/data` before changes | Persistent mount source recorded | Backup evidence | PASS | Pending / ____ |
| T-005 | Internal HTTP probe | Vaultwarden responds internally | Deployment log | PASS | Pending / ____ |
| T-006 | Podman-machine backend probe | Result recorded | Diagnostic evidence | PASS | Pending / ____ |
| T-007 | Windows backend probe | Port 8080 reachable before HTTPS | PASS report | PASS | Pending / ____ |
| T-008 | `.wslconfig` merge | Unrelated settings preserved | Before/after review | PASS | Pending / ____ |
| T-009 | Port 443 conflict | Unrelated owner causes safe stop | Negative test | NOT RUN — no conflict present | Pending / ____ |
| T-010 | Caddy validation | Configuration valid | Caddy output | PASS | Pending / ____ |
| T-011 | HTTPS login page | HTTP 200 via trusted HTTPS | PASS report | PASS — reverified 09-03 | Pending / ____ |
| T-012 | Open-source notice | Notice reachable and complete | Manual/HTTP evidence | PASS | Pending / ____ |
| T-013 | CSS marker | Marker present when branding enabled | PASS report | PASS | Pending / ____ |
| T-014 | Branding rollback | Failed CSS is disabled without vault-data changes | Controlled negative test | PASS | Pending / ____ |
| T-015 | Password input | Field accepts typing | Manual acceptance | PASS — local demo identities | Pending / ____ |
| T-016 | Authorized login | Test user logs in successfully | Manual acceptance | PASS — four local demo roles | Pending / ____ |
| T-017 | Vault-data presence | Representative authorized data remains available | Manual acceptance | Mount verified; content not accessed | Pending / ____ |
| T-018 | `/data` after changes | Same mount source/destination | PASS report | PASS | Pending / ____ |
| T-019 | Startup task | Created only after prior checks pass | Task/report evidence | PASS — last result 0 | Pending / ____ |
| T-020 | Restart/sign-in persistence | Stack returns and HTTPS works | Manual acceptance | Container restart PASS; Windows restart pending | Pending / ____ |
| T-021 | Backup readability | Release and backup archives open and hashes match | Manifest evidence | PASS | Pending / ____ |
| T-022 | Mobile login layout | 375×812 renders without horizontal overflow | Browser evidence | PASS | Pending / ____ |
| T-023 | Desktop login layout | 1440×900 renders without horizontal overflow | Browser evidence | PASS | Pending / ____ |
| T-024 | Signup responsive layout | Mobile and desktop render expected form, branding and footer | Browser evidence | PASS | Pending / ____ |
| T-025 | Password-hint responsive layout | Mobile and desktop render expected form, branding and footer | Browser evidence | PASS | Pending / ____ |
| T-026 | Login accessibility readiness | Heading, labelled email, checkbox, button and signup link visible/enabled | Browser evidence | PASS | Pending / ____ |
| T-027 | Deployment script parsing | All five controlled PowerShell scripts parse without errors | Static test output | PASS | Pending / ____ |
| T-028 | Release manifest integrity | Every recorded file hash matches | Manifest evidence | PASS — 26/26 | Pending / ____ |
| T-029 | Release security scan | No secret patterns or prohibited destructive commands | Static scan output | PASS — 0 findings | Pending / ____ |
| T-030 | Project build gate | Required files, policy controls, branding, licence, endpoint and Caddy checks pass | Test-runner output | PASS — 15/15 | Pending / ____ |

## Phase acceptance tracker

| Phase | Acceptance scope | Codex result | Owner/User result |
|---|---|---|---|
| 1 | Podman, Vaultwarden and persistent volume | PASS | Pending / ____ |
| 2 | Caddy HTTPS and localhost connectivity | PASS — restored and live-verified | Pending / ____ |
| 3 | DigiVista login branding and responsive design | PASS in controlled browser | Pending visual approval / ____ |
| 4 | Logged-in dashboard/sidebar branding | PASS with four authenticated demo roles | Pending dashboard approval / ____ |
| 5 | Open-source notice and AGPL controls | PASS | Pending legal/owner approval / ____ |
| 6 | Login/logout and role access | PASS for Owner/Admin/collection-limited users; item CRUD not performed | Pending / ____ |
| 7 | Restart and persistence | Container restart PASS; full Windows restart pending | Pending / ____ |
| 8 | Backup and isolated restore | Release readability PASS; restore exercise pending | Pending / ____ |
| 9 | Vulnerability, logging and production security | Baseline and static security controls recorded; owner disposition pending | Pending / ____ |
| 10 | Governance and production release | Controlled pilot only | Pending signatures / ____ |

Owner/User name: ____________________  
Acceptance date: ____________________  
Final decision: `ACCEPT / ACCEPT WITH CONDITIONS / REJECT`  
Signature or recorded approval reference: ____________________

## Release rule

No document or script may claim production success until automated tests pass on the target host and the manual acceptance tests are signed off by the technical and security/data owners.
