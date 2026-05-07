# Coding Conventions

**Analysis Date:** 2026-05-07

## Naming Patterns

**Files:**
- PascalCase with descriptive names matching the primary type they contain
- Files that define a single type are named after that type: `NotchViewModel.swift` contains `NotchViewModel`, `MagiDecisionEngine.swift` contains `MagiDecisionEngine`
- Extension files use `TypeName+Category.swift` format: `NSScreen+NotchSize.swift`
- No barrel/index files; each file exports its own types

**Types (Classes, Structs, Enums):**
- PascalCase: `NotchViewModel`, `MagiDecisionEngine`, `SystemSnapshot`
- Nested types follow the same PascalCase convention: `MagiPanelDecision.Level`, `NotchInteractionStateMachine.Event`
- Enum cases are camelCase: `.synchronized`, `.emergencyMode`, `.hoverArming`

**Functions and Methods:**
- camelCase with verb-first naming: `evaluate()`, `handleInteraction()`, `isPointInNotch()`, `sample()`
- Boolean-returning functions prefixed with `is` or `has`: `isExpanded`, `isPointInNotch()`, `hasElapsed()`
- Action methods use descriptive verb phrases: `handle(_:at:)`, `apply(_:)`, `readTicks()`

**Variables and Properties:**
- camelCase: `viewModel`, `previousTicks`, `samplingInterval`, `hoverDelay`
- Stored properties that track previous state use `previous` prefix: `previousTicks`, `previousCounters`, `previousSampledAt`
- Computed properties use descriptive nouns: `notchScreenRect`, `effectiveNotchSize`, `compactIslandScreenRect`
- Static constants use camelCase: `simulatedNotchSize`, `hitTestPadding`, `comparisonEpsilon`

## Code Style

**Formatting:**
- 4-space indentation (Swift convention)
- No trailing semicolons
- Opening braces on the same line as the declaration (K&R variant)
- No formatter/linter config detected (no `.swift-format`, `.swiftlint.yml`, or similar)

**Access Control:**
- `private` for internal implementation details (`private var`, `private func`, `private extension`)
- `private(set)` for read-only public properties backed by mutable storage: `@Published private(set) var magiState`
- No explicit `public`/`internal` keywords -- types rely on Swift's default `internal` access level (the `@testable import` in tests confirms this)
- `fileprivate` not used in the codebase

**Actor Isolation:**
- `@MainActor` annotation on all UI-bound classes and methods: `NotchViewModel`, `NotchWindowController`, `AppDelegate.start()`
- `Task { @MainActor in }` used to bridge from non-isolated contexts into the main actor
- `Sendable` conformance on all value types passed across concurrency domains: `MagiDecisionState`, `SystemSnapshot`, `NotchGeometry`, `AppSettings`
- `Equatable` conformance on every data model struct alongside `Sendable`

**Class Design:**
- All reference types are `final class` -- no inheritance beyond framework base classes (`NSObject`, `NSPanel`, `NSWindowController`, `NSApplicationDelegate`)
- No subclassing of project-defined classes
- `deinit` used for deterministic cleanup: invalidating timers, stopping event monitors
- `defer` blocks used for resource cleanup (memory deallocation in `CPUUsageSampler`, `NetworkUsageSampler`) and state updates (storing previous tick values)

## Import Organization

**Order (observed across source files):**
1. System frameworks first (alphabetical): `AppKit`, `Combine`, `CoreGraphics`, `Darwin`, `Foundation`, `SwiftUI`
2. No third-party imports -- project has zero external package dependencies

**Typical import blocks:**
```swift
import Foundation              // Data types, Date, Timer
import AppKit                  // NSApplication, NSPanel, NSScreen
import SwiftUI                 // View protocol, Color, Font
import Combine                 // ObservableObject, @Published, AnyCancellable
```

**Key observation:** Files import only what they use. UI files import `SwiftUI` and `AppKit`. Logic files import `Foundation`. Telemetry samplers import `Darwin` for Mach kernel APIs. No file imports all frameworks indiscriminately.

## Error Handling

**Pattern: Optional returns for failure, never throws.**
The codebase uses `nil` returns to signal failure instead of Swift's `throws` mechanism. System calls (Mach kernel APIs, sysctl) return optionals that are unwrapped with `guard let`:

```swift
// Sources/NervNotchProApp/Telemetry/CPUUsageSampler.swift
func sample() -> CPUSample? {
    guard let ticks = readTicks() else { return nil }
    // ...
}

func readTicks() -> CPUTicks? {
    let result = host_processor_info(...)
    guard result == KERN_SUCCESS, let processorInfo else { return nil }
    // ...
}
```

**Guard-based early exits** are the dominant pattern, used for:
- Nil-checking optional system call results
- Validating arithmetic preconditions (`guard totalDelta > 0 else` in `TelemetryCalculations.swift`)
- Checking sensor availability (`guard let sample else` in `MagiDecisionEngine.swift`)

**No `do`/`catch` blocks, no `try`, no custom `Error` types** found in the codebase. All failure paths return optionals or fallback defaults.

## Logging

**Framework:** No logging framework detected. No `os.Logger`, `NSLog`, `print`, or other logging calls found in the codebase. The application communicates state entirely through the UI (visual status indicators in the notch island).

## Comments

**When to Comment:**
- Single-line `///` documentation comments on major types and public methods only
- Example from `Sources/NervNotchProApp/Notch/NotchEventMonitor.swift`:
```swift
/// Emits pointer enter/exit events only on region transitions so hover state can reset when the cursor leaves the notch island.
struct NotchPointerRegionTracker: Equatable, Sendable {
```

**Style:**
- Brief, single-sentence descriptions focused on "what" not "how"
- No JSDoc/TSDoc-style annotations (not applicable to Swift)
- No inline comments explaining non-obvious code -- the code is self-documenting
- No TODO/FIXME comments found in the codebase

## Function Design

**Size:** Most functions are short and focused:
- 3-10 lines for simple evaluators and computed properties
- 15-30 lines for telemetry samplers with system call logic
- The largest file is `MagiTriadConsoleView.swift` (1665 lines) containing extensive layout metrics, which is a layout configuration rather than behavioral logic

**Parameters:**
- Functions typically take 1-3 parameters
- Struct initializers with multiple properties use labeled arguments: `NotchGeometry(screenFrame:notchSize:windowHeight:usesSimulatedNotch:)`
- Callback closures passed as trailing parameters: `onEvent: @escaping (Event) -> Void`

**Return Values:**
- Data models return concrete struct types: `-> SystemSnapshot`, `-> MagiDecisionState`
- Fallible operations return optionals: `-> CPUSample?`, `-> MemorySample?`
- Pure calculations return value types: `-> Double`, `-> String`
- No functions return tuples except internal helpers (e.g., `readCounters()` in `NetworkUsageSampler`)

## Module Design

**Exports:** Each Swift file defines 1-3 closely related types. No explicit access control on top-level types (relying on `internal` default), with `@testable import` granting test access.

**Type Organization:**
- Value types (struct/enum) for data, configuration, and pure logic: `MagiDecisionEngine` (struct with `func evaluate()`), `NotchGeometry`, `AppSettings`
- Reference types (`final class`) only where needed: NSObject subclasses, stateful samplers with mutable `previous` state, Combine ObservableObjects
- Namespace enums (`enum NervStyle`, `enum ByteFormat`, `enum TelemetryCalculations`) for grouping static methods and constants -- no instances created
- Extensions on system types: `extension NSScreen`, `extension View`, `private extension UInt64`

**Dependency Injection:**
- Dependencies passed through initializers with default parameter values:
```swift
// Sources/NervNotchProApp/Telemetry/TelemetrySampler.swift
init(
    cpuSampler: CPUUsageSampler = CPUUsageSampler(),
    memorySampler: MemoryUsageSampler = MemoryUsageSampler(),
    networkSampler: NetworkUsageSampler = NetworkUsageSampler()
)
```
This pattern enables testing with real implementations (no mocks) while keeping construction ergonomic.

---

*Convention analysis: 2026-05-07*
