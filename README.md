# NERV Notch Pro

NERV Notch Pro is a native macOS notch status island inspired by the NERV/MAGI command-console aesthetic. It shows real CPU, memory, and network telemetry in a floating panel anchored to the MacBook notch area.

## Development

Run tests:

```bash
rtk swift test
```

Build:

```bash
rtk swift build
```

Run:

```bash
./scripts/run-dev.sh
```

Package a local macOS app bundle:

```bash
./scripts/package-app.sh
open dist/NervNotch.app
```

By default the package script creates `dist/NervNotch.app` and applies an ad-hoc signature for local use. For a signed build, pass your Developer ID identity:

```bash
SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
PRODUCT_BUNDLE_IDENTIFIER="com.example.NervNotch" \
VERSION="0.1.0" \
BUILD_NUMBER="1" \
./scripts/package-app.sh
```

For distribution outside your own machine, sign with a Developer ID certificate, then notarize and staple the app before shipping a zip or DMG.

## Release

Pushing a version tag triggers the GitHub Actions release workflow, which builds, signs, notarizes, packages a DMG, and uploads it as a draft GitHub Release.

```bash
git tag v0.1.0
git push origin v0.1.0
```

You can also trigger the workflow manually from the Actions tab.

### Required secrets for signed releases

For unsigned builds (local use only), no secrets are needed. The workflow will produce an unsigned DMG.

To distribute signed and notarized builds, configure these secrets in the repository:

| Secret | Description |
|--------|-------------|
| `MACOS_CERTIFICATE` | Base64-encoded Developer ID Application `.p12` certificate |
| `MACOS_CERTIFICATE_PASSWORD` | Password for the `.p12` certificate |
| `MACOS_SIGNING_IDENTITY` | Signing identity, e.g. `Developer ID Application: Your Name (TEAMID)` |
| `MACOS_KEYCHAIN_PASSWORD` | Arbitrary password for the temporary keychain |
| `APPLE_NOTARY_KEY` | Base64-encoded App Store Connect API `.p8` key |
| `APPLE_NOTARY_KEY_ID` | API Key ID |
| `APPLE_NOTARY_ISSUER` | Issuer ID (visible in App Store Connect → Keys) |

To base64-encode a file:

```bash
base64 < certificate.p12 | pbcopy
base64 < AuthKey.p8 | pbcopy
```

## MVP Scope

- CPU telemetry
- Memory telemetry
- Network telemetry
- MAGI decision panels
- Central Dogma judgement
- Click-to-open and outside-click-to-close notch panel
- Hover for about 1 second to open

This project is a local fan-oriented prototype and does not bundle copyrighted image assets.
