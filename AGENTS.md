# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project

NERV Notch Pro — a macOS notch status island with a NERV/MAGI command-console aesthetic. Displays real-time CPU, memory, network, disk, swap, and battery telemetry in a floating panel anchored to the MacBook notch area. Written in Swift (5.9), targets macOS 13+, uses SwiftUI hosted inside AppKit panels.

## Commands

```bash
# Build
rtk swift build

# Run all tests
rtk swift test

# Run a single test suite
rtk swift test --filter <TestSuite>
# Run a single test method
rtk swift test --filter <TestSuite>/<testMethod>
# e.g.: rtk swift test --filter NotchGeometryTests/testNotchScreenRect

# Run tests in parallel
rtk swift test --parallel

# Run tests with code coverage
rtk swift test --enable-code-coverage

# Dev run
./scripts/run-dev.sh

# Package as .app bundle (ad-hoc signed, for local use)
./scripts/package-app.sh
open dist/NervNotch.app

# Signed release build
SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
  PRODUCT_BUNDLE_IDENTIFIER="com.example.NervNotchPro" \
  VERSION="0.1.0" BUILD_NUMBER="1" \
  ./scripts/package-app.sh
```

## Architecture

**Pattern:** MVVM with a functional core. Domain types are `Sendable` + `Equatable` value types. `@MainActor` is explicit on all UI-facing classes. Combine is used minimally — a single `@Published` ↔ `sink` binding for `interactionState`.

**Key layers and their files:**

| Layer | Key Files | Role |
|-------|-----------|------|
| App bootstrap | `main.swift`, `App/NervNotchApplication.swift`, `App/AppDelegate.swift` | NSApplication setup, object graph wiring, timer-driven telemetry polling |
| Notch system | `Notch/NotchWindowController.swift`, `Notch/NotchPanel.swift`, `Notch/NotchEventMonitor.swift`, `Notch/NotchGeometry.swift` | Borderless floating NSPanel, global+local NSEvent monitoring, hit-test geometry |
| Interaction FSM | `Notch/NotchInteractionStateMachine.swift` | Pure state machine: `closed → hoverArming → opened → closing → closed` |
| ViewModel | `ViewModels/NotchViewModel.swift` | `@MainActor ObservableObject`, bridges `SystemSnapshot` to `MagiDecisionState`, delegates interaction to FSM |
| UI (SwiftUI) | `UI/NervConsoleView.swift`, `UI/MagiTriadConsoleView.swift`, `UI/NotchIslandChrome.swift`, `UI/NervStyle.swift` | Compact island + expanded MAGI console with triad layout, custom shapes, warning chrome |
| Decision engine | `Magi/MagiDecisionEngine.swift` | Pure function: `SystemSnapshot → MagiDecisionState` with threshold-based CPU/memory/network triage and Central Dogma consensus |
| Telemetry | `Telemetry/TelemetrySampler.swift`, `Telemetry/CPUUsageSampler.swift`, `Telemetry/MemoryUsageSampler.swift`, `Telemetry/NetworkUsageSampler.swift`, `Telemetry/DiskSpaceSampler.swift`, `Telemetry/DiskIOSampler.swift`, `Telemetry/SwapUsageSampler.swift`, `Telemetry/BatterySampler.swift`, `Telemetry/TelemetryCalculations.swift` | Low-level Darwin API sampling (Mach, sysctl, getifaddrs, IOKit); rate calculations use delta-over-time |
| Settings | `Settings/AppSettings.swift`, `Settings/SettingsWindowController.swift` | Simple struct with defaults; SwiftUI settings window raised above the island |
| Data types | `Telemetry/SystemSnapshot.swift` | All telemetry sample types + `SystemSnapshot` aggregate — value types only |

**Data flow:** `Timer (1s) → TelemetrySampler.sample() → SystemSnapshot → NotchViewModel.apply() → MagiDecisionEngine.evaluate() → MagiDecisionState → SwiftUI views render`

**Interaction flow:** `NSEvent → NotchEventMonitor → NotchInteractionStateMachine.Event → ViewModel.handleInteraction() → @Published interactionState → NotchPanel.ignoresMouseEvents toggle + SwiftUI re-render`

## Testing approach

- **No mocking.** Tests call real production code directly. No mock libraries, no protocols defined solely for testing. Value types are constructed inline at the call site with test data
- `@testable import NervNotchProApp` grants test access to `internal` types
- No shared fixtures or `setUp()`/`tearDown()` — each test method creates fresh instances
- ViewModel tests use `async`/`await` to call `@MainActor` methods and read `@Published` properties
- Layout verification tests assert computed pixel positions, corner radii, and frame rects without rendering
- State machine tests sequence events through the production `handle(_:at:)` method and assert resulting state
- Smoke tests verify system samplers return non-nil, positive values — no system API mocking

## Known issues

- `CPUUsageSampler` assumes precise timer intervals for delta calculations. `NetworkUsageSampler` correctly uses wall-clock time — the CPU sampler should follow the same pattern
- `NotchEventMonitor` geometry is not updated on screen changes (no `didChangeScreenParametersNotification` observer)

## Key conventions

- Domain types are all value types conforming to `Sendable` + `Equatable` — no reference semantics in business logic
- Samplers are `final class` only because they hold internal delta state for rate calculations (previous CPU ticks, previous network counters, etc.)
- Error handling: all failure paths return optionals (`-> CPUSample?`). No `throws`, no `do`/`catch`, no custom `Error` types anywhere in the codebase. `guard let` early-exit is the dominant pattern
- Resource cleanup: `deinit` for invalidating timers and stopping event monitors; `defer` blocks for Mach port deallocation and state snapshots
- Window level hierarchy: NotchPanel = `mainMenu + 3`, Settings = `mainMenu + 4`
- The app uses `.accessory` activation policy (LSUIElement = true) — no Dock icon, no main menu
- `NotchPanel.ignoresMouseEvents` is toggled based on interaction state so the compact island doesn't block clicks
- Zero third-party dependencies — Apple system frameworks only (AppKit, SwiftUI, Combine, Foundation, Darwin)
- No logging framework — all diagnostics are visual (the MAGI console itself is the system monitor)
- Fonts: "Share Tech Mono", "DS-Digital-Bold", and "SourceHanSerifCN-Bold" are bundled in `Resources/fonts/` and registered at launch via `CTFontManagerRegisterFontsForURL(.process)`. "Helvetica Neue Condensed Bold" is a macOS system font
- Detailed architecture docs exist in `.planning/codebase/` (ARCHITECTURE.md, CONVENTIONS.md, TESTING.md, etc.)
