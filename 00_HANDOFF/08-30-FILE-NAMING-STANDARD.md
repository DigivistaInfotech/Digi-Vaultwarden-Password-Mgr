# DigiVista Secure Vault File-Naming Standard

Status: Active

## Required pattern

`MM-DD-Descriptive-Filename.ext`

Use the actual creation date. The original controlled baseline begins with `08-30-`; later review artifacts use their own date, such as `09-03-`.

Examples:

- `08-30-SRS-DigiVista-Secure-Vault.md`
- `08-30-System-Architecture.md`
- `08-30-Deployment-Runbook.md`
- `08-30-Complete-DigiVista-Secure-Vault.ps1`
- `08-30-DigiVista-Secure-Vault-Release.zip`

## Rules

- Use two-digit month and day.
- Use hyphens between words.
- Keep product and purpose clear.
- Do not use ambiguous suffixes such as `final2`, `latest`, `new`, or `copy`.
- Preserve filenames of received source evidence. Apply this standard to newly created or formally released deliverables.
- If multiple approved revisions are produced on the same day, record the version in document metadata and Git history rather than creating ambiguous filenames.

## Scope note

The original handoff files remain unchanged as received evidence. New SRS, architecture, runbook, security, monitoring, testing, traceability, deployment, report, and release-package files use this standard.
