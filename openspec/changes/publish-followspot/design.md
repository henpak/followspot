# Design

## Context

So far the app has been a personal tool: bundle ID `local.presenter.app`, signed with a personal “Apple Development” certificate, installed only through `scripts/build-app.sh`. There is no Apple Developer membership, and therefore no notarization. The app needs no permissions (global mouse monitors, Carbon hotkeys).

## Goals / Non-Goals

**Goals:**
- Installation for others without Xcode: one-line installer or ZIP.
- Reproducible releases from GitHub Actions.
- No personal data or machine-specific settings in the public repository.

**Non-Goals:**
- Homebrew cask, notarization, auto-update, localization.

## Decisions

### 1. Name Followspot, bundle ID under `io.github.henpak`

A followspot is the theatre spotlight that follows the performer. Among Mac cursor tools the name is free, while Limelight, Glint and ClickLight are taken. The bundle ID uses the account's GitHub domain because there is no project domain.

The capability `presenter-controls` keeps its name; it describes how the app is operated, not the product.

### 2. Ad-hoc signature

Without a Developer ID, an ad-hoc signature (`codesign -s -`) is the best option and is sufficient on Apple Silicon. Because the app needs no TCC permissions, the signature changing with every build does no harm. `FOLLOWSPOT_SIGN_IDENTITY` still allows a custom certificate.

### 3. Installing with curl legitimately avoids the Gatekeeper prompt

Files downloaded with `curl` get no `com.apple.quarantine` attribute, so the app starts without a prompt. The installer still verifies the SHA-256 checksum from the release and removes any quarantine attribute. For a browser download, the README describes “Open Anyway” and `xattr -dr com.apple.quarantine`.

The release assets are always named `Followspot.zip` and `Followspot.zip.sha256`, so `releases/latest/download/…` works without an API call.

### 4. One-time takeover of settings

`SettingsMigration` in `FollowspotCore` is a pure function `migrate(legacy: [String: Any]?, into: UserDefaults)`:
- It copies the known keys that are missing in the target.
- It then sets `migratedFromLegacyDomain`.
- If that flag is already set, it does nothing.

The app reads the old domain with `UserDefaults.standard.persistentDomain(forName: "local.presenter.app")` and runs the migration in `main()`, before `AppDelegate` and `OverlayController` load the stores. The old domain is left untouched as a backup.

### 5. Universal binary in releases and CI

`swift build -c release --arch arm64 --arch x86_64` produces a universal binary under `.build/apple/Products/Release`. The path comes from `--show-bin-path` with the same arguments.

### 6. English only

The UI strings, specs and all change documents are in English, so the repository is consistent for an international audience. The archived changes are translated as well; their content and decisions are unchanged.

## Risks / Trade-offs

- **Gatekeeper on browser downloads:** users have to choose “Open Anyway” once. → The README recommends the one-line installer.
- **Intel Macs:** the ad-hoc signed x86_64 binary is built but not tested on real hardware. → Marked as untested in the README.
- **Renaming:** an old `Presenter.app` would stay installed next to the new app. → `build-app.sh` removes it locally; it was never published, so nobody else has it.

## Migration Plan

Rebuild with `scripts/build-app.sh --open`. Settings are taken over and `Presenter.app` is removed. Rollback: restore the old history from the git bundle.
