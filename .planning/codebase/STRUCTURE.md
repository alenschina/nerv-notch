# Codebase Structure

**Analysis Date:** 2026-05-07

## Directory Layout

```
nerv-notch-pro/
├── Package.swift                              # Swift Package Manager manifest
├── README.md                                  # Project overview and dev commands
├── .gitignore                                 # Excludes .build/, dist/, .DS_Store, .superpowers/
├── .claude/                                   # Claude Code project config (settings.local.json)
├── .planning/                                 # GSD planning artifacts (this file)
│   └── codebase/
├── .vscode/                                   # VS Code debug config (launch.json)
├── Sources/                                   # Production source code
│   └── NervNotchProApp/                       # Single executable target (~3172 lines)
│       ├── main.swift                         # Entry point
│       ├── App/                               # Application bootstrapping
│       │   ├── AppDelegate.swift              # Root object graph, timer, telemetry wiring
│       │   └── NervNotchApplication.swift     # NSApplication config and run loop
│       ├── Magi/                              # Decision engine domain
│       │   └── MagiDecisionEngine.swift       # Decision types + pure evaluation logic
│       ├── Notch/                             # macOS window/event/geometry
│       │   ├── NSScreen+NotchSize.swift       # Safe area-based notch detection
│       │   ├── NotchEventMonitor.swift        # Global + local NSEvent monitoring
│       │   ├── NotchGeometry.swift            # Screen-relative frame calculations
│       │   ├── NotchInteractionStateMachine.swift  # Hover/click state machine
│       │   ├── NotchPanel.swift               # Borderless NSPanel subclass
│       │   └── NotchWindowController.swift    # NSWindowController, layout, reactive subscriptions
│       ├── UI/                                # SwiftUI views and styling
│       │   ├── CentralDogmaJudgementView.swift # Judgement bar component
│       │   ├── MagiDecisionPanelView.swift    # Individual MAGI panel component
│       │   ├── MagiTriadConsoleView.swift     # Expanded console: triad, sync rate, honeycomb, frames (1665 lines)
│       │   ├── NervConsoleView.swift          # Root view: compact island + expanded console
│       │   ├── NervStyle.swift                # Color palette and font constants
│       │   ├── NotchIslandChrome.swift        # Rounded clip shape, chrome modifier, scanline overlay
│       │   └── ScanlineOverlay.swift          # CRT scanline / grid Canvas overlay
│       ├── ViewModels/                        # ViewModel layer
│       │   └── NotchViewModel.swift           # @MainActor ObservableObject bridging domain to UI
│       ├── Telemetry/                         # System sampling
│       │   ├── CPUUsageSampler.swift          # host_processor_info-based CPU delta sampling
│       │   ├── MemoryUsageSampler.swift       # host_statistics64-based memory sampling
│       │   ├── NetworkUsageSampler.swift      # getifaddrs + sysctl-based network rate sampling
│       │   ├── SystemSnapshot.swift           # Value types: CPUSample, MemorySample, NetworkRate, SystemSnapshot
│       │   ├── TelemetryCalculations.swift    # Pure functions: cpuUsage, memoryUsageRatio, networkRate
│       │   └── TelemetrySampler.swift         # Facade composing all three samplers
│       ├── Settings/                          # Runtime configuration
│       │   └── AppSettings.swift              # Default Settings struct (in-memory only)
│       └── Resources/                         # Bundled assets
│           └── nerv-island-icon.png           # NERV logo icon for compact island
├── Tests/                                     # Test target (~836 lines)
│   └── NervNotchProTests/
│       ├── AppSettingsTests.swift             # Settings default value tests
│       ├── EmergencyHoneycombViewTests.swift  # Honeycomb layout cell count validation
│       ├── MagiDecisionEngineTests.swift      # Threshold-based decision scenarios
│       ├── NotchEventMonitorTests.swift       # Region tracker edge transitions
│       ├── NotchGeometryTests.swift           # Frame rect and hit-test validation
│       ├── NotchInteractionStateMachineTests.swift  # All state transitions
│       ├── NotchIslandChromeTests.swift       # Chrome metrics by state
│       ├── NotchViewModelTests.swift          # ViewModel apply + interaction
│       ├── ScaffoldTests.swift                # Basic sanity check
│       ├── SynchronizationRateViewTests.swift # Rate calculation tests
│       ├── TelemetryCalculationTests.swift    # TelemetryCalculations pure functions
│       └── TelemetrySamplerSmokeTests.swift   # Sampler does not crash
├── scripts/                                   # Development and packaging
│   ├── run-dev.sh                             # swift run NervNotchPro
│   └── package-app.sh                         # Build release binary, assemble .app bundle, codesign
├── dist/                                      # Packaging output (gitignored)
│   └── NervNotchPro.app/                      # Assembled .app bundle after running package-app.sh
├── docs/                                      # Documentation
│   └── superpowers/                           # Superpowers planning artifacts (specs, plans)
└── .build/                                    # SPM build artifacts (gitignored)
```

## Directory Purposes

**Sources/NervNotchProApp/App/:**
- Purpose: Application lifecycle management and root object graph assembly
- Contains: `NervNotchApplication` (NSApplication config), `AppDelegate` (timer, sampler, window controller wiring)
- Key files: `AppDelegate.swift` (52 lines), `NervNotchApplication.swift` (12 lines)

**Sources/NervNotchProApp/Magi/:**
- Purpose: The MAGI decision engine -- pure domain logic for evaluating system telemetry into NGE-themed decisions
- Contains: Decision types (`MagiDecisionState`, `MagiPanelDecision`, `CentralDogmaJudgement`), the `MagiDecisionEngine` evaluator, `ByteFormat` helpers
- Key files: `MagiDecisionEngine.swift` (234 lines)

**Sources/NervNotchProApp/Notch/:**
- Purpose: macOS platform integration -- window management (`NSPanel`, `NSWindowController`), screen geometry calculations, event monitoring, and interaction state machine
- Contains: 6 files covering window, geometry, events, state machine, and screen extensions
- Key files: `NotchWindowController.swift` (76 lines), `NotchGeometry.swift` (67 lines), `NotchEventMonitor.swift` (94 lines)

**Sources/NervNotchProApp/UI/:**
- Purpose: All SwiftUI view definitions and visual styling constants
- Contains: 7 files ranging from small style enums (17 lines) to the large expanded console view (1665 lines)
- Key files: `MagiTriadConsoleView.swift` (1665 lines -- the largest file, containing the full MAGI triad console with synchronization rate, emergency honeycomb, framing chrome, wave animations, and unit shapes), `NervConsoleView.swift` (181 lines)

**Sources/NervNotchProApp/ViewModels/:**
- Purpose: Reactive bridge layer connecting domain state to SwiftUI views via `@Published` properties
- Contains: `NotchViewModel.swift` (33 lines)
- Key files: `NotchViewModel.swift` -- the only ViewModel, holding references to `AppSettings`, `MagiDecisionEngine`, and `NotchInteractionStateMachine`

**Sources/NervNotchProApp/Telemetry/:**
- Purpose: Low-level system resource sampling using Darwin APIs (Mach, sysctl, getifaddrs)
- Contains: 3 sampler classes + data types + pure calculation functions
- Key files: `CPUUsageSampler.swift` (86 lines), `NetworkUsageSampler.swift` (145 lines), `SystemSnapshot.swift` (45 lines), `TelemetryCalculations.swift` (38 lines)

**Sources/NervNotchProApp/Settings/:**
- Purpose: Runtime configuration with defaults
- Contains: `AppSettings.swift` (10 lines) -- a simple struct with default values, no persistence

**Sources/NervNotchProApp/Resources/:**
- Purpose: Bundled asset files processed by SPM `.process("Resources")`
- Contains: `nerv-island-icon.png` -- the NERV logo displayed in the compact island

**Tests/NervNotchProTests/:**
- Purpose: Unit tests for domain logic, state machine, geometry, and settings
- Contains: 12 test files corresponding to source modules
- Key files: `NotchIslandChromeTests.swift` (429 lines -- largest test file), `NotchGeometryTests.swift` (91 lines)

**scripts/:**
- Purpose: Shell scripts for development (`run-dev.sh`) and packaging (`package-app.sh`)
- Contains: 2 bash scripts

**dist/:**
- Purpose: Packaging output directory where `package-app.sh` assembles the `.app` bundle
- Generated: Yes (by packaging script)
- Committed: No (in `.gitignore`)

**.build/:**
- Purpose: Swift Package Manager build artifacts (debug/release binaries, derived data, checkouts)
- Generated: Yes (by `swift build`)
- Committed: No (in `.gitignore`)

## File Size Breakdown

| File | Lines | Category |
|------|-------|----------|
| `UI/MagiTriadConsoleView.swift` | 1665 | UI (expanded console) |
| `Magi/MagiDecisionEngine.swift` | 234 | Domain |
| `UI/NervConsoleView.swift` | 181 | UI (root view) |
| `Telemetry/NetworkUsageSampler.swift` | 145 | Telemetry |
| `UI/NotchIslandChrome.swift` | 108 | UI (chrome) |
| `Notch/NotchEventMonitor.swift` | 94 | Notch |
| `Telemetry/CPUUsageSampler.swift` | 86 | Telemetry |
| `Notch/NotchWindowController.swift` | 76 | Notch |
| `Notch/NotchGeometry.swift` | 67 | Notch |
| `UI/MagiDecisionPanelView.swift` | 63 | UI (panel) |
| `Notch/NotchInteractionStateMachine.swift` | 62 | Notch |
| Other source files | 10-52 each | Various |

## Naming Conventions

**Files:**
- PascalCase: All Swift source files use UpperCamelCase matching the primary type defined in the file (e.g., `NotchViewModel.swift`, `MagiDecisionEngine.swift`)
- One primary type per file, with supporting private types in the same file

**Directories:**
- PascalCase: All source directories use UpperCamelCase (`App/`, `Magi/`, `Notch/`, `UI/`, `ViewModels/`, `Telemetry/`, `Settings/`)
- Structure follows feature/module groupings, not technical layers (e.g., `Notch/` contains panel, window controller, geometry, state machine, and event monitor)

**Types:**
- Structs: PascalCase, typically `Sendable` + `Equatable` (`SystemSnapshot`, `MagiDecisionState`, `NotchGeometry`)
- Classes: `final class` with PascalCase, always `@MainActor` when touching AppKit (`NotchWindowController`, `NotchPanel`, `AppDelegate`, `NervNotchApplication`)
- Enums: PascalCase, use associated values for state data (`NotchInteractionStateMachine.State`, `NotchInteractionStateMachine.Event`)

**Functions:**
- camelCase for methods and computed properties
- Domain logic uses pure functions returning value types (`evaluate(_:) -> MagiDecisionState`)

**Tests:**
- Test files mirror source file names with `Tests` suffix: `NotchViewModelTests.swift`, `MagiDecisionEngineTests.swift`, `TelemetryCalculationTests.swift`
- Test methods use descriptive camelCase names describing the scenario

## Where to Add New Code

**New Telemetry Channel (e.g., disk I/O, GPU):**
- Primary code: `Sources/NervNotchProApp/Telemetry/` -- add a new `*Sampler.swift` file
- Data types: Add to `SystemSnapshot.swift` or a new file in `Telemetry/`
- Tests: `Tests/NervNotchProTests/` -- add `*SamplerTests.swift`

**New MAGI Panel Decision (e.g., thermal, battery):**
- Decision types: `Sources/NervNotchProApp/Magi/MagiDecisionEngine.swift` -- add to `MagiDecisionState`
- Evaluation logic: Add `evaluateThermal(_:)` private method in `MagiDecisionEngine`
- Tests: `Tests/NervNotchProTests/MagiDecisionEngineTests.swift`

**New UI Component:**
- Implementation: `Sources/NervNotchProApp/UI/` -- add `NewComponentView.swift`
- If it has its own layout metrics, define a layout struct in the same file
- If consumed by `NervConsoleView`, add the view reference there

**New Settings:**
- Implementation: `Sources/NervNotchProApp/Settings/AppSettings.swift` -- add a new `var` with default value

**New Interaction State or Event:**
- Add to `NotchInteractionStateMachine.State` or `.Event` enum in `Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift`
- Add transition cases in the `handle(_:at:)` switch

**Shared Helpers / Utilities:**
- Format/display helpers: Add to existing domain file (like `ByteFormat` in `MagiDecisionEngine.swift`) or create a new file in the relevant module directory
- There is no separate `Utils/` or `Helpers/` directory -- utility code lives alongside its domain

## Special Directories

**.build/:**
- Purpose: SPM build artifacts (compiled binaries, module maps, derived data)
- Generated: Yes (by `swift build`)
- Committed: No

**dist/:**
- Purpose: Assembled .app bundle output from `package-app.sh`
- Generated: Yes (by packaging script)
- Committed: No

**docs/superpowers/:**
- Purpose: Superpowers extension planning artifacts (specs, plans from brainstorm sessions)
- Generated: Partially (by Superpowers extension)
- Committed: Yes (not in `.gitignore`)

**.claude/:**
- Purpose: Claude Code project-level settings
- Contains: `settings.local.json` (project-specific Claude config)
- Committed: No (part of `.gitignore` glob)

---

*Structure analysis: 2026-05-07*
