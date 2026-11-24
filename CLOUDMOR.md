# CloudMor Remote

CloudMor-branded build of [RustDesk](https://github.com/rustdesk/rustdesk) (AGPL-3.0) for CloudMor RMM.

- Branch `cloudmor` = RustDesk release tag + CloudMor branding (icons, name "CloudMor Remote").
- `res/cloudmor-brand.sh` runs in CI before the build: sets the app name and builds in the
  CloudMor RustDesk server (rmm.cloudmor.com) and its public key.
- Build: Actions → "CloudMor Remote release" → Run workflow. Output goes to the GitHub release.
- Upgrading RustDesk: rebase `cloudmor` onto the new release tag and bump `VERSION` in
  `.github/workflows/cloudmor-flutter-build.yml`.

Source is published here as required by the AGPL.
