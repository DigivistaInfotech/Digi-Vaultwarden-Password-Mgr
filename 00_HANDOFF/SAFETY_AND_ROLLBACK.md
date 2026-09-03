# Safety / Rollback Rules

1. Preserve Vaultwarden data first.
2. No destructive Podman reset/machine deletion.
3. Back up `.wslconfig` before network edits.
4. Back up active Vaultwarden SCSS before branding.
5. Back up Caddy config before replacing it.
6. If branding causes login/template problems, use `Restore-Vaultwarden-Login-Safely.ps1`.
7. If HTTPS fails, keep backend diagnosis separate from UI changes.
8. Record every mutation in the final report.
