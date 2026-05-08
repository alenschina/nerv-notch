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

## MVP Scope

- CPU telemetry
- Memory telemetry
- Network telemetry
- MAGI decision panels
- Central Dogma judgement
- Click-to-open and outside-click-to-close notch panel
- Hover for about 1 second to open

This project is a local fan-oriented prototype and does not bundle copyrighted image assets.
