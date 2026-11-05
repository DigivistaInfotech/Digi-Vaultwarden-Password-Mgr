# DigiVista Secure Vault — Role and Permission Acceptance

Date: 11-05-2026

## Enforcement boundary

The React dashboard is a presentation and guidance layer. It does not grant access. Vaultwarden organizations, groups, collections, membership roles, and collection permissions remain the authoritative enforcement layer. Personal vault items remain private and are never made visible through the dashboard.

## Role model

| Persona | Supported Vaultwarden mapping | Expected access |
|---|---|---|
| Super Admin / Owner | Organization Owner | Organization policy, members, groups, collections, audit/administration functions; no access to users' personal vaults |
| Admin | Organization Admin | Member and collection administration permitted by Vaultwarden; no ownership-only actions; no access to personal vaults |
| Manager / Supervisor | User with group and collection permissions | Access only to assigned department collections; create/edit based on collection permission |
| Business User | User with assigned collection access | Personal vault plus explicitly assigned business collections |
| Home / Individual | Personal account | Personal vault only unless the user explicitly joins or shares through an organization |
| Teen | Personal account with applicable consent flow | Personal vault and simplified dashboard; no administration surface |
| Family / Child | Personal account plus guardian-managed family organization where appropriate | Only approved family collections and simplified categories; private records are not automatically exposed |

## Acceptance tests

1. Owner can invite and assign members without learning their master passwords.
2. Admin cannot perform owner-only actions.
3. Manager can access only assigned department collections.
4. Business User cannot access unassigned collections.
5. No organization role can view a user's personal vault items.
6. Removing a member revokes organization collection access.
7. Moving a member removes old group access before new group access is granted.
8. Family/Child and Teen dashboard modes do not show Administration.
9. Dashboard links remain on the trusted origin and delegate encryption and authorization to Vaultwarden.
10. Recovery, backup, and restore tests do not expose master passwords or vault contents.

## Evidence required for final acceptance

- Test account identifiers without passwords.
- Role/group/collection assignments.
- Pass/fail result for each test above.
- Screenshot or audit evidence with secrets redacted.
- Tester and customer acceptance date.
