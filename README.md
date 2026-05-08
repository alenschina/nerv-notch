[中文版本](README.zh-CN.md)

# NERV Notch

A macOS notch status island with a NERV/MAGI command-console aesthetic. Displays real-time CPU, memory, network, disk I/O, swap, and battery telemetry in a floating panel anchored to the MacBook notch. Written in Swift, zero third-party dependencies.

## Features

- **Real-time telemetry** — CPU, memory, network throughput, disk space & I/O, swap, battery
- **MAGI triad decision panel** — Melchior (CPU), Balthazar (memory/network), Casper (disk/swap) push raw metrics through a Central Dogma consensus engine producing synchronized colour-coded judgements: green (normal), orange (elevated), red (emergency)
- **Notch-resident island** — compact mode sits inside the physical notch area as a subtle status strip; hover for ~1 second or click to expand into the full MAGI console
- **Click-only mode** — optionally disable hover expansion so the island responds exclusively to clicks
- **Animated warning chrome** — diagonal stripe backgrounds scroll behind the triad during elevated and emergency states, with independent per-strip animation toggles
- **NERV launch intro** — first-run animated intro sequence with CRT scanlines and NERV branding; toggleable to replay on every launch
- **Background audio** — configurable ambient soundscape that plays when the console expands
- **Multi-screen aware** — follows the MacBook notch or simulates one on displays without a physical notch
- **Zero dependencies** — Apple system frameworks only (AppKit, SwiftUI, Combine, Darwin)

## Requirements

- macOS 13+
- Fonts are bundled inside the app — no user installation needed

## Quick Start

```bash
./scripts/run-dev.sh
```

## Development

```bash
# Build
swift build

# Run all tests
swift test

# Run a single test
swift test --filter NotchGeometryTests/testNotchScreenRect

# Parallel tests
swift test --parallel

# Code coverage
swift test --enable-code-coverage
```

### Packaging

```bash
# Ad-hoc signed (local use)
./scripts/package-app.sh
open dist/NervNotch.app

# Signed release
SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
  PRODUCT_BUNDLE_IDENTIFIER="com.example.NervNotch" \
  VERSION="0.1.0" BUILD_NUMBER="1" \
  ./scripts/package-app.sh
```

## Release

Push a version tag to trigger automated build, signing, notarization, and DMG upload via GitHub Actions:

```bash
git tag v0.1.0
git push origin v0.1.0
```

You can also trigger the workflow manually from the Actions tab. An unsigned DMG is produced when signing credentials are unavailable.

See [`.github/workflows/release.yml`](.github/workflows/release.yml) for the required repository secrets (`MACOS_CERTIFICATE`, `MACOS_CERTIFICATE_PASSWORD`, `MACOS_SIGNING_IDENTITY`, `MACOS_KEYCHAIN_PASSWORD`, `APPLE_NOTARY_KEY`, `APPLE_NOTARY_KEY_ID`, `APPLE_NOTARY_ISSUER`).

## Architecture

Swift 5.9, MVVM with a functional core. Domain types are `Sendable` + `Equatable` value types. SwiftUI views are hosted inside AppKit `NSPanel` / `NSWindow`. Combine is used for a single `@Published` ↔ `sink` binding.

Detailed architecture docs live in [`.planning/codebase/`](.planning/codebase/) — ARCHITECTURE.md, CONVENTIONS.md, TESTING.md, and more.

## License

Personal fan prototype. No copyrighted imagery or music included.
