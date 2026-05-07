<!-- refreshed: 2026-05-07 -->
# Architecture

**Analysis Date:** 2026-05-07

## System Overview

```text
┌─────────────────────────────────────────────────────────────────────┐
│                         App Layer                                   │
│  `Sources/NervNotchProApp/main.swift`                              │
│  `Sources/NervNotchProApp/App/`                                     │
├─────────────────────────────────────────────────────────────────────┤
│                      NotchWindowController                          │
│  owns: NotchPanel (borderless NSPanel)                              │
│  hosts: NSHostingController(rootView: NervConsoleView)              │
│  manages: event monitors, reactive subscriptions, timer             │
│  `Sources/NervNotchProApp/Notch/NotchWindowController.swift`        │
├──────────────┬────────────────────┬─────────────────────────────────┤
│  UI Layer    │   ViewModel        │   Domain Logic                  │
│  (SwiftUI)   │                    │                                 │
│  `UI/`       │   `ViewModels/`    │  `Magi/` + `Telemetry/`         │
│              │   NotchViewModel   │  + `Notch/` (state machine)     │
├──────────────┴────────────────────┴─────────────────────────────────┤
│                       Platform / System APIs                        │
│  host_processor_info (CPU), host_statistics64 (Memory),              │
│  getifaddrs/sysctl (Network), NSEvent monitors, NSScreen extensions │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| `NervNotchApplication` | Bootstraps NSApplication with `.accessory` activation policy | `Sources/NervNotchProApp/App/NervNotchApplication.swift` |
| `AppDelegate` | Wires up `NotchWindowController`, `NotchViewModel`, `TelemetrySampler`, and a polling `Timer` | `Sources/NervNotchProApp/App/AppDelegate.swift` |
| `NotchWindowController` | Owns the `NotchPanel` (borderless `NSPanel`), hosts the SwiftUI view tree via `NSHostingController`, manages `NotchEventMonitor` and a tick timer, reacts to `interactionState` changes | `Sources/NervNotchProApp/Notch/NotchWindowController.swift` |
| `NotchPanel` | Borderless, floating `NSPanel` subclass; configures level, collection behavior, translucency | `Sources/NervNotchProApp/Notch/NotchPanel.swift` |
| `NotchViewModel` | Central `@MainActor ObservableObject` bridging telemetry and interaction state to SwiftUI views; owns `MagiDecisionEngine` and `NotchInteractionStateMachine` | `Sources/NervNotchProApp/ViewModels/NotchViewModel.swift` |
| `TelemetrySampler` | Composes `CPUUsageSampler`, `MemoryUsageSampler`, `NetworkUsageSampler` and produces a `SystemSnapshot` | `Sources/NervNotchProApp/Telemetry/TelemetrySampler.swift` |
| `MagiDecisionEngine` | Pure function evaluating a `SystemSnapshot` into a `MagiDecisionState` (three panel decisions + Central Dogma judgement) | `Sources/NervNotchProApp/Magi/MagiDecisionEngine.swift` |
| `NervConsoleView` | Root SwiftUI view; renders compact notch island or expanded MAGI console depending on `interactionState` | `Sources/NervNotchProApp/UI/NervConsoleView.swift` |
| `NotchInteractionStateMachine` | Deterministic finite state machine (4 states, 6 events) managing hover-to-open and outside-click-to-close behavior | `Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift` |
| `NotchEventMonitor` | Monitors `NSEvent` (global + local) for mouse clicks and movement, emits `NotchInteractionStateMachine.Event` via region tracking | `Sources/NervNotchProApp/Notch/NotchEventMonitor.swift` |
| `NotchGeometry` | Computes frame rects for notch-hit-test zone, compact island, opened panel, and full window based on `NSScreen` frame and notch size | `Sources/NervNotchProApp/Notch/NotchGeometry.swift` |

## Pattern Overview

**Overall:** MVVM (Model-View-ViewModel) with a functional core

**Key Characteristics:**
- SwiftUI views own no business logic -- they render `@Published` state from `NotchViewModel`
- Domain types (`SystemSnapshot`, `MagiDecisionState`, `NotchInteractionStateMachine.State`) are all value types conforming to `Sendable` & `Equatable`
- The decision engine (`MagiDecisionEngine`) is a `Sendable` struct with a pure `evaluate(_:) -> MagiDecisionState` method -- no side effects
- The interaction state machine (`NotchInteractionStateMachine`) is a pure `Sendable` struct -- no external dependencies
- Telemetry samplers use low-level Darwin APIs (Mach, sysctl, getifaddrs) and are stateful (`final class`) only for internal delta tracking
- All `@MainActor` boundaries are explicit: `NotchViewModel`, `NotchWindowController`, `AppDelegate.sampleTelemetry()` are all `@MainActor`
- Combine is used for single reactive binding: `NotchViewModel.$interactionState` drives `NotchPanel.ignoresMouseEvents`

## Layers

**App Layer:**
- Purpose: Application bootstrapping and root object graph assembly
- Location: `Sources/NervNotchProApp/App/`
- Contains: `NervNotchApplication`, `AppDelegate`
- Depends on: ViewModels, Notch, Telemetry, Magi
- Used by: `main.swift` (entry point)

**UI Layer:**
- Purpose: SwiftUI view definitions and visual styling
- Location: `Sources/NervNotchProApp/UI/`
- Contains: `NervConsoleView`, `MagiTriadConsoleView`, `MagiDecisionPanelView`, `CentralDogmaJudgementView`, `NotchIslandChrome`, `ScanlineOverlay`, `NervStyle`
- Depends on: ViewModels (via `@ObservedObject`), Magi (for `MagiDecisionState`, `MagiPanelDecision`, `CentralDogmaJudgement`)
- Used by: `NotchWindowController` (via `NSHostingController`)

**ViewModel Layer:**
- Purpose: Reactive bridge between domain state and SwiftUI views
- Location: `Sources/NervNotchProApp/ViewModels/`
- Contains: `NotchViewModel`
- Depends on: Magi (`MagiDecisionEngine`), Telemetry (`SystemSnapshot`), Notch (`NotchInteractionStateMachine`), Settings (`AppSettings`)
- Used by: `AppDelegate`, `NervConsoleView`, `NotchWindowController`

**Domain / Business Logic:**
- Purpose: Pure decision logic and data transformation
- Location: `Sources/NervNotchProApp/Magi/` and `Sources/NervNotchProApp/Telemetry/` (calculations)
- Contains: `MagiDecisionEngine`, `MagiDecisionState`, `MagiPanelDecision`, `CentralDogmaJudgement`, `TelemetryCalculations`, `SystemSnapshot`
- Depends on: Foundation only
- Used by: ViewModel

**Platform / System Integration:**
- Purpose: macOS-specific window management, event handling, screen geometry, and low-level system sampling
- Location: `Sources/NervNotchProApp/Notch/` and `Sources/NervNotchProApp/Telemetry/` (samplers)
- Contains: `NotchPanel`, `NotchWindowController`, `NotchGeometry`, `NotchEventMonitor`, `NotchInteractionStateMachine`, `NSScreen+NotchSize`, `CPUUsageSampler`, `MemoryUsageSampler`, `NetworkUsageSampler`
- Depends on: AppKit, CoreGraphics, Darwin
- Used by: AppDelegate (window setup), NotchWindowController (event wiring)

## Data Flow

### Primary Request Path (Telemetry Polling)

1. `AppDelegate` timer fires `sampleTelemetry()` (`Sources/NervNotchProApp/App/AppDelegate.swift:45-51`)
2. `TelemetrySampler.sample()` calls `CPUUsageSampler.sample()`, `MemoryUsageSampler.sample()`, `NetworkUsageSampler.sample()` in sequence (`Sources/NervNotchProApp/Telemetry/TelemetrySampler.swift:18-26`)
3. Returns a `SystemSnapshot` value type (`Sources/NervNotchProApp/Telemetry/SystemSnapshot.swift:40-45`)
4. `NotchViewModel.apply(_:)` passes the snapshot to `MagiDecisionEngine.evaluate(_:)` (`Sources/NervNotchProApp/ViewModels/NotchViewModel.swift:25-27`)
5. `MagiDecisionEngine` emits a `MagiDecisionState` which is assigned to `@Published magiState` (`Sources/NervNotchProApp/ViewModels/NotchViewModel.swift:26`)
6. SwiftUI re-renders `NervConsoleView` and child views bound to `viewModel.magiState`

### Interaction State Flow

1. `NotchEventMonitor` detects mouse events (click, enter, exit) at the local and global monitor level (`Sources/NervNotchProApp/Notch/NotchEventMonitor.swift:44-56`)
2. `NotchPointerRegionTracker` emits edge-triggered `NotchInteractionStateMachine.Event` values on region boundaries (`Sources/NervNotchProApp/Notch/NotchEventMonitor.swift:70-88`)
3. Events are forwarded via closure to `NotchViewModel.handleInteraction(_:)` (`Sources/NervNotchProApp/Notch/NotchWindowController.swift:39-46`)
4. A 50ms `Timer` also feeds `.timerTick` events for time-based transitions (`Sources/NervNotchProApp/Notch/NotchWindowController.swift:49-53`)
5. `NotchInteractionStateMachine.handle(_:at:)` transitions states deterministically (`Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift:32-57`)
6. `NotchViewModel` publishes `interactionState` via `@Published` (`Sources/NervNotchProApp/ViewModels/NotchViewModel.swift:31`)
7. `NotchWindowController` subscribes to `$interactionState` and toggles `NotchPanel.ignoresMouseEvents` (`Sources/NervNotchProApp/Notch/NotchWindowController.swift:55-65`)

**State Management:**
- `@Published` properties on `NotchViewModel` drive all SwiftUI reactivity
- The interaction state machine is a pure struct held as `@Published` copy
- No external state management library (no TCA, no Redux)

## Key Abstractions

**SystemSnapshot:**
- Purpose: A single-point-in-time telemetry reading for CPU, memory, and network
- Examples: `Sources/NervNotchProApp/Telemetry/SystemSnapshot.swift`
- Pattern: Sendable, Equatable value type; fields are optional to represent unavailable data

**MagiDecisionState:**
- Purpose: The canonical output of the MAGI decision engine -- three panel decisions plus one Central Dogma judgement
- Examples: `Sources/NervNotchProApp/Magi/MagiDecisionEngine.swift:3-40`
- Pattern: Sendable, Equatable value type composed of `MagiPanelDecision` and `CentralDogmaJudgement` enums

**NotchInteractionStateMachine:**
- Purpose: Encapsulates all interaction state transitions (hover arm, open, close, grace period) in a pure deterministic function
- Examples: `Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift`
- Pattern: Sendable, Equatable struct with `handle(_:at:)` mutating method using exhaustive `switch` over `(State, Event)` pairs

**NotchGeometry:**
- Purpose: Abstracts screen-aware layout calculations -- notch detection, island placement, hit testing, window sizing
- Examples: `Sources/NervNotchProApp/Notch/NotchGeometry.swift`
- Pattern: Sendable, Equatable value type with computed properties that derive all frame rects from base inputs

**MagiConsoleLayoutMetrics:**
- Purpose: Pixel-level layout constants for the expanded MAGI triad console, including frame positions, connector lines, warning strips, and embedded info column sizing
- Examples: `Sources/NervNotchProApp/UI/MagiTriadConsoleView.swift:108-434`
- Pattern: Equatable struct with computed vars only -- no mutable state

## Entry Points

**main.swift:**
- Location: `Sources/NervNotchProApp/main.swift`
- Triggers: Process launch (executable target)
- Responsibilities: Creates `NervNotchApplication()` and calls `.run()`

**NervNotchApplication.run():**
- Location: `Sources/NervNotchProApp/App/NervNotchApplication.swift`
- Responsibilities: Configures `NSApplication.shared` with `.accessory` activation policy (no dock icon), sets `AppDelegate`, starts the run loop

**AppDelegate.applicationDidFinishLaunching():**
- Location: `Sources/NervNotchProApp/App/AppDelegate.swift:10-13`
- Responsibilities: On `@MainActor`, calls `start()` which wires up the entire object graph: `NotchViewModel` -> `NotchWindowController` -> `NervConsoleView`, plus the telemetry polling `Timer`

## Architectural Constraints

- **Threading:** All AppKit/UI work is `@MainActor`. Telemetry sampling synchronously reads system APIs on the same main queue via `Timer`. No background queues or actors are used.
- **Global state:** `AppDelegate` holds the root references to `windowController`, `viewModel`, and `timer` as optional stored properties. No global singletons beyond `NSScreen` and `NSApplication.shared`.
- **Circular imports:** None detected. The dependency graph is strictly top-down: App -> ViewModel -> Domain, with no reverse references.
- **No third-party dependencies:** The `Package.swift` declares zero external package dependencies. Everything uses Apple system frameworks (AppKit, SwiftUI, Combine, Foundation, Darwin/CoreGraphics).
- **macOS 13+ only:** Platform constraint confirmed in `Package.swift:9` and `LSMinimumSystemVersion` in the packaging script.

## Anti-Patterns

### Sampler Live inside Timer Callback (Potential Precision Issue)

**What happens:** `TelemetrySampler.sample()` is called synchronously on every timer tick at `samplingInterval` (default 1.0s). The CPU sampler's delta calculation assumes the timer fires exactly at the interval.
**Why it's wrong:** `Timer.scheduledTimer` on the main run loop does not guarantee precise intervals. If the interval drifts, delta calculations become inaccurate.
**Do this instead:** Track actual wall-clock time between samples in each sampler (as `NetworkUsageSampler` already does -- `CPUUsageSampler` does not). Use `Date().timeIntervalSince(previousSampledAt)` for delta calculations in `CPUUsageSampler` as well.

### Direct NSEvent Monitor in WindowController

**What happens:** `NotchWindowController` hard-codes `NotchEventMonitor` with a specific geometry and layout inside its initializer. The event monitor is tightly coupled to the window controller lifecycle.
**Why it's wrong:** If the window needs to be repositioned (e.g., screen change, multi-monitor), the event monitor's geometry is stale. There is no `screenParametersDidChange` observer.
**Do this instead:** Observe `NSApplication.didChangeScreenParametersNotification` and recreate or update the event monitor geometry.

## Error Handling

**Strategy:** Fallback with optionals. Samplers return `nil` on system API failure, and the decision engine treats `nil` as "unavailable" rather than throwing.

**Patterns:**
- `CPUUsageSampler.sample() -> CPUSample?` -- returns nil on Mach API failure
- `MagiDecisionEngine.evaluate()` guards with `guard let sample else { return unavailablePanel(...) }` for each telemetry channel
- No `throws` functions, no `Result` types, no do/catch anywhere in the domain layer
- `Timer` is invalidated in `deinit` and `applicationWillTerminate` to prevent retain cycles

## Cross-Cutting Concerns

**Logging:** No logging framework. No `os_log`, no `print` calls detected. All diagnostics are visual (the MAGI console itself is the system monitor).

**Validation:** None beyond type safety. `AppSettings` uses default values for all fields. No settings file I/O -- settings exist only in memory.

**Authentication:** Not applicable. This is a local-only system monitor with no network services exposed.

---

*Architecture analysis: 2026-05-07*
