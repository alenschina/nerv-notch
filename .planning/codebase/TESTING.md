# Testing Patterns

**Analysis Date:** 2026-05-07

## Test Framework

**Runner:**
- XCTest (Apple's built-in testing framework)
- Integrated with Swift Package Manager via `Package.swift`:
```swift
.testTarget(
    name: "NervNotchProTests",
    dependencies: ["NervNotchProApp"],
    path: "Tests/NervNotchProTests"
)
```

**Assertion Library:**
- XCTest built-in assertions (`XCTAssertEqual`, `XCTAssertTrue`, `XCTAssertNil`, etc.)
- No third-party assertion or matcher libraries

**Run Commands:**
```bash
swift test                                          # Run all tests
swift test --filter MagiDecisionEngineTests         # Run specific test class
swift test --filter "testNormalSnapshot"            # Run specific test method
swift test --parallel                               # Run tests in parallel
```

## Test File Organization

**Location:**
- All tests live in `Tests/NervNotchProTests/`
- One test file per source file, matching the source module's directory structure
- No subdirectories within the test target

**Naming:**
- Test file naming: `<SourceTypeName>Tests.swift`
- Examples: `MagiDecisionEngineTests.swift` tests `MagiDecisionEngine`, `NotchViewModelTests.swift` tests `NotchViewModel`, `NotchInteractionStateMachineTests.swift` tests `NotchInteractionStateMachine`
- When multiple related types are tested, the file is named after the primary type or concept: `TelemetryCalculationTests.swift` covers `TelemetryCalculations` and `UInt64` extension, `NotchIslandChromeTests.swift` covers `NotchIslandChromeMetrics`, `NotchIslandShape`, `NotchIslandChromeStyle`, and `NotchIslandLayout`
- Smoke/integration-style tests are named descriptively: `TelemetrySamplerSmokeTests.swift`, `ScaffoldTests.swift`

**File Count and Size:**
```
Tests/NervNotchProTests/
  NotchIslandChromeTests.swift      429 lines   (layout/UI verification)
  NotchGeometryTests.swift           91 lines   (geometry calculations)
  NotchInteractionStateMachineTests.swift  52 lines   (state machine transitions)
  MagiDecisionEngineTests.swift      48 lines   (decision logic)
  NotchViewModelTests.swift          39 lines   (async view model)
  EmergencyHoneycombViewTests.swift  39 lines   (honeycomb layout)
  SynchronizationRateViewTests.swift 37 lines   (sync rate layout)
  NotchEventMonitorTests.swift       34 lines   (event tracking)
  TelemetryCalculationTests.swift    32 lines   (telemetry math)
  TelemetrySamplerSmokeTests.swift   16 lines   (system call smoke tests)
  AppSettingsTests.swift             10 lines   (defaults)
  ScaffoldTests.swift                 9 lines   (application bootstrap)
```

## Test Structure

**Suite Organization:**
All test classes follow the same structure:

```swift
import XCTest
@testable import NervNotchProApp

final class TypeNameTests: XCTestCase {
    func testSpecificScenarioWithExpectedOutcome() {
        // Arrange: create test inputs directly
        // Act: call production code
        // Assert: verify using XCTAssert*
    }
}
```

**Key Patterns:**
- `final class` for all test classes
- `@testable import NervNotchProApp` to access `internal` types
- Every test class inherits from `XCTestCase`
- No `setUp()` or `tearDown()` methods -- tests are self-contained and create fresh instances inline
- No shared test fixtures or state between test methods
- Test method names use `test` prefix + descriptive scenario: `testNormalSnapshotProducesSynchronizedJudgement()`, `testHoverRequiresFullDelayBeforeOpening()`

**Setup Pattern:**
- Tests construct production types directly in each test method:
```swift
// Tests/NervNotchProTests/MagiDecisionEngineTests.swift
func testNormalSnapshotProducesSynchronizedJudgement() {
    let snapshot = SystemSnapshot(
        sampledAt: Date(timeIntervalSince1970: 0),
        cpu: CPUSample(usageRatio: 0.25, coreCount: 10, ...),
        memory: MemorySample(totalBytes: 1000, usedBytes: 420, ...),
        network: NetworkRate(downBytesPerSecond: 200_000, ...)
    )
    let state = MagiDecisionEngine().evaluate(snapshot)
    XCTAssertEqual(state.cpu.level, .normal)
}
```
- No factory methods or builder patterns -- struct initializers used directly

## Mocking

**Framework:** None. No mocking library is used. No protocols are defined for dependency injection in tests.

**Approach:**
- Tests call real production code directly
- Value types (structs) are constructed with test data at the call site
- State machines are tested by sequencing real events through the production `handle(_:at:)` method
- System-level telemetry samplers (`CPUUsageSampler`, `MemoryUsageSampler`) are tested via smoke tests that verify they return non-nil results with sane values -- no system API mocking
- The `TelemetrySampler` class accepts its sub-samplers through its initializer with default parameters, allowing theoretical substitution in tests, though no test currently does this

**What to Mock:**
- Not applicable in this codebase. Tests are structured to avoid mocking entirely.

**What NOT to Mock:**
- Production value types (`MagiDecisionEngine`, `NotchGeometry`, `SystemSnapshot`) -- tested directly
- State machines (`NotchInteractionStateMachine`) -- tested by feeding events and verifying state
- UI layout metrics (`MagiConsoleLayoutMetrics`, `SynchronizationRateLayout`) -- tested by verifying pixel-level calculations

## Fixtures and Factories

**Test Data:**
Test values are constructed inline in each test method using production struct initializers. There are no shared fixture files or factory functions. Common patterns:

```swift
// Standardized test dates:
Date(timeIntervalSince1970: 0)

// Test CPU samples with known ratios:
CPUSample(usageRatio: 0.25, coreCount: 10, userRatio: 0.15, systemRatio: 0.10, idleRatio: 0.75)

// Standard test screen geometry:
NotchGeometry(
    screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
    notchSize: CGSize(width: 210, height: 32),
    windowHeight: 460,
    usesSimulatedNotch: false
)

// State machine with predictable delays:
NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
```

**Location:**
- All test data is defined locally within each test method
- No `fixtures/` or `__Snapshots__/` directories exist

## Coverage

**Requirements:** No explicit coverage target enforced. No coverage configuration in `Package.swift`.

**Coverage Measurement:**
```bash
swift test --enable-code-coverage
```
No CI pipeline configuration found for automated coverage reporting.

## Test Types

**Unit Tests:**
All 12 test files are unit tests with the following scopes:
- **Logic tests:** `MagiDecisionEngineTests`, `TelemetryCalculationTests`, `NotchInteractionStateMachineTests` -- pure functions and state transitions, no I/O
- **Layout/UI verification:** `NotchIslandChromeTests`, `NotchGeometryTests`, `EmergencyHoneycombViewTests`, `SynchronizationRateViewTests` -- verify computed pixel positions, corner radii, hex grid layouts
- **ViewModel tests:** `NotchViewModelTests` -- async tests using `await` to verify `@Published` property updates
- **Event tracking:** `NotchEventMonitorTests` -- verify event emission on region enter/exit transitions
- **Smoke tests:** `TelemetrySamplerSmokeTests`, `ScaffoldTests` -- verify system calls don't crash and return data
- **Defaults:** `AppSettingsTests` -- verify initial default values

**Integration Tests:**
- `TelemetrySamplerSmokeTests` is the closest to an integration test -- it calls real Darwin/Mach system APIs and verifies the returned data is sensible (non-nil, positive values)

**E2E Tests:**
- Not used. No UI automation or end-to-end testing framework detected.

## Common Patterns

**State Machine Testing:**
State machines are tested by applying event sequences and asserting the resulting state after each transition:
```swift
// Tests/NervNotchProTests/NotchInteractionStateMachineTests.swift
func testHoverRequiresFullDelayBeforeOpening() {
    var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
    machine.handle(.mouseEnteredNotch, at: 10)
    machine.handle(.timerTick, at: 11.9)
    XCTAssertEqual(machine.state, .hoverArming(startedAt: 10))
    machine.handle(.timerTick, at: 12.0)
    XCTAssertEqual(machine.state, .opened)
}
```

**Async ViewModel Testing:**
ViewModel tests use `async`/`await` to call `@MainActor` methods and read `@Published` properties:
```swift
// Tests/NervNotchProTests/NotchViewModelTests.swift
func testViewModelUpdatesDecisionFromSnapshot() async {
    let viewModel = await NotchViewModel(
        settings: AppSettings(),
        decisionEngine: MagiDecisionEngine()
    )
    await viewModel.apply(snapshot)
    let magiState = await viewModel.magiState
    XCTAssertEqual(magiState.cpu.level, .highLoad)
}
```

**Layout Verification Testing:**
UI layout code is tested without rendering by verifying computed metrics:
```swift
// Tests/NervNotchProTests/NotchIslandChromeTests.swift
func testCompactChromeUsesPhysicalNotchLikeCornerInsets() {
    let metrics = NotchIslandChromeMetrics(isExpanded: false)
    XCTAssertEqual(metrics.topCornerRadius, 6)
    XCTAssertEqual(metrics.bottomCornerRadius, 14)
}
```

**Smoke Testing System Calls:**
System samplers are validated with relaxed assertions that verify the system responds:
```swift
// Tests/NervNotchProTests/TelemetrySamplerSmokeTests.swift
func testMemorySamplerReportsPhysicalMemoryWhenAvailable() {
    let sample = MemoryUsageSampler().sample()
    XCTAssertNotNil(sample)
    XCTAssertGreaterThan(sample?.totalBytes ?? 0, 0)
}
```

**Assertion Patterns:**
All assertions used in the codebase (256 total assertions across 12 test files):
- `XCTAssertEqual` -- exact value comparison (dominant assertion type)
- `XCTAssertEqual(_:_:accuracy:)` -- floating-point comparisons with epsilon tolerance
- `XCTAssertTrue` / `XCTAssertFalse` -- boolean checks
- `XCTAssertNotNil` -- optional unwrapping verification
- `XCTAssertGreaterThan` / `XCTAssertLessThan` / `XCTAssertGreaterThanOrEqual` / `XCTAssertLessThanOrEqual` -- range checks
- No `XCTUnwrap`, `XCTFail`, or `XCTSkip` used

---

*Testing analysis: 2026-05-07*
