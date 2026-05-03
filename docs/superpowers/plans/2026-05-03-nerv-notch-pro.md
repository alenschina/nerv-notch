# NERV Notch Pro Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native macOS notch status island that shows real CPU, memory, and network telemetry in a NERV/MAGI command-console UI.

**Architecture:** Start from an empty repository with a SwiftPM macOS executable and test target. Keep testable core logic in focused modules: notch geometry, telemetry models, MAGI decision logic, and interaction state. AppKit owns the transparent top `NSPanel`; SwiftUI owns the NERV/MAGI rendering.

**Tech Stack:** Swift 5.9+, SwiftPM, AppKit, SwiftUI, Combine, XCTest, Darwin Mach APIs, `getifaddrs`.

---

## File Structure

- `Package.swift`：SwiftPM package definition for executable and tests.
- `Sources/NervNotchProApp/main.swift`：process entry point.
- `Sources/NervNotchProApp/App/NervNotchApplication.swift`：NSApplication setup and app delegate wiring.
- `Sources/NervNotchProApp/App/AppDelegate.swift`：startup, screen observation, menu entry, sampler lifecycle.
- `Sources/NervNotchProApp/Notch/NotchPanel.swift`：transparent non-activating panel.
- `Sources/NervNotchProApp/Notch/NotchWindowController.swift`：creates the top overlay panel and hosts SwiftUI.
- `Sources/NervNotchProApp/Notch/NotchGeometry.swift`：pure notch and opened-panel geometry.
- `Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift`：click, hover, focus-out state transitions.
- `Sources/NervNotchProApp/Telemetry/SystemSnapshot.swift`：shared telemetry data model.
- `Sources/NervNotchProApp/Telemetry/CPUUsageSampler.swift`：CPU tick delta sampling.
- `Sources/NervNotchProApp/Telemetry/MemoryUsageSampler.swift`：memory page statistics sampling.
- `Sources/NervNotchProApp/Telemetry/NetworkUsageSampler.swift`：network byte delta sampling.
- `Sources/NervNotchProApp/Telemetry/TelemetrySampler.swift`：timer-driven aggregate sampler.
- `Sources/NervNotchProApp/Magi/MagiDecisionEngine.swift`：turns telemetry into MAGI panel decisions.
- `Sources/NervNotchProApp/ViewModels/NotchViewModel.swift`：observable state consumed by SwiftUI.
- `Sources/NervNotchProApp/UI/NervConsoleView.swift`：root SwiftUI view.
- `Sources/NervNotchProApp/UI/MagiDecisionPanelView.swift`：single MAGI window.
- `Sources/NervNotchProApp/UI/CentralDogmaJudgementView.swift`：bottom summary judgement.
- `Sources/NervNotchProApp/UI/NervStyle.swift`：colors, fonts, shared styling.
- `Sources/NervNotchProApp/UI/ScanlineOverlay.swift`：lightweight scanline/grid overlays.
- `Sources/NervNotchProApp/Settings/AppSettings.swift`：runtime settings and defaults.
- `Tests/NervNotchProTests/NotchGeometryTests.swift`
- `Tests/NervNotchProTests/NotchInteractionStateMachineTests.swift`
- `Tests/NervNotchProTests/MagiDecisionEngineTests.swift`
- `Tests/NervNotchProTests/TelemetryCalculationTests.swift`

## Task 1: SwiftPM Scaffold

**Files:**
- Create: `Package.swift`
- Create: `Sources/NervNotchProApp/main.swift`
- Create: `Sources/NervNotchProApp/App/NervNotchApplication.swift`
- Create: `Tests/NervNotchProTests/ScaffoldTests.swift`

- [ ] **Step 1: Write package manifest**

Create `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NervNotchPro",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "NervNotchPro", targets: ["NervNotchProApp"])
    ],
    targets: [
        .executableTarget(
            name: "NervNotchProApp",
            path: "Sources/NervNotchProApp"
        ),
        .testTarget(
            name: "NervNotchProTests",
            dependencies: ["NervNotchProApp"],
            path: "Tests/NervNotchProTests"
        )
    ]
)
```

- [ ] **Step 2: Add minimal application entry**

Create `Sources/NervNotchProApp/main.swift`:

```swift
import AppKit

let application = NervNotchApplication()
application.run()
```

Create `Sources/NervNotchProApp/App/NervNotchApplication.swift`:

```swift
import AppKit

final class NervNotchApplication {
    func run() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
```

- [ ] **Step 3: Add scaffold test**

Create `Tests/NervNotchProTests/ScaffoldTests.swift`:

```swift
import XCTest
@testable import NervNotchProApp

final class ScaffoldTests: XCTestCase {
    func testApplicationWrapperCanBeCreated() {
        let application = NervNotchApplication()
        XCTAssertNotNil(application)
    }
}
```

- [ ] **Step 4: Run scaffold tests**

Run:

```bash
rtk swift test
```

Expected: tests compile and `ScaffoldTests.testApplicationWrapperCanBeCreated` passes.

- [ ] **Step 5: Commit**

Run:

```bash
rtk git add Package.swift Sources Tests
rtk git commit -m "chore: scaffold macOS Swift package"
```

## Task 2: Notch Geometry

**Files:**
- Create: `Sources/NervNotchProApp/Notch/NotchGeometry.swift`
- Test: `Tests/NervNotchProTests/NotchGeometryTests.swift`

- [ ] **Step 1: Write failing geometry tests**

Create `Tests/NervNotchProTests/NotchGeometryTests.swift`:

```swift
import CoreGraphics
import XCTest
@testable import NervNotchProApp

final class NotchGeometryTests: XCTestCase {
    func testPhysicalNotchScreenRectIsCenteredAtTopOfScreen() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
            notchSize: CGSize(width: 210, height: 32),
            windowHeight: 460,
            usesSimulatedNotch: false
        )

        XCTAssertEqual(geometry.notchScreenRect.origin.x, 651)
        XCTAssertEqual(geometry.notchScreenRect.origin.y, 950)
        XCTAssertEqual(geometry.notchScreenRect.width, 210)
        XCTAssertEqual(geometry.notchScreenRect.height, 32)
    }

    func testSimulatedNotchUsesFallbackSize() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 0, y: 0, width: 1440, height: 900),
            notchSize: .zero,
            windowHeight: 460,
            usesSimulatedNotch: true
        )

        XCTAssertEqual(geometry.notchScreenRect.origin.x, 608)
        XCTAssertEqual(geometry.notchScreenRect.origin.y, 864)
        XCTAssertEqual(geometry.notchScreenRect.width, 224)
        XCTAssertEqual(geometry.notchScreenRect.height, 36)
    }

    func testOpenedPanelIsCenteredUnderTopEdge() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 100, y: 50, width: 1512, height: 982),
            notchSize: CGSize(width: 210, height: 32),
            windowHeight: 460,
            usesSimulatedNotch: false
        )

        let panel = geometry.openedPanelScreenRect(size: CGSize(width: 820, height: 420))

        XCTAssertEqual(panel.origin.x, 446)
        XCTAssertEqual(panel.origin.y, 612)
        XCTAssertEqual(panel.width, 820)
        XCTAssertEqual(panel.height, 420)
    }

    func testHitTestingUsesPaddingAroundNotch() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
            notchSize: CGSize(width: 210, height: 32),
            windowHeight: 460,
            usesSimulatedNotch: false
        )

        XCTAssertTrue(geometry.isPointInNotch(CGPoint(x: 645, y: 948)))
        XCTAssertFalse(geometry.isPointInNotch(CGPoint(x: 500, y: 948)))
    }
}
```

- [ ] **Step 2: Run geometry tests to verify failure**

Run:

```bash
rtk swift test --filter NotchGeometryTests
```

Expected: FAIL because `NotchGeometry` does not exist.

- [ ] **Step 3: Implement geometry**

Create `Sources/NervNotchProApp/Notch/NotchGeometry.swift`:

```swift
import CoreGraphics

struct NotchGeometry: Equatable, Sendable {
    static let simulatedNotchSize = CGSize(width: 224, height: 36)
    static let hitTestPadding = CGSize(width: 10, height: 6)

    let screenFrame: CGRect
    let notchSize: CGSize
    let windowHeight: CGFloat
    let usesSimulatedNotch: Bool

    var effectiveNotchSize: CGSize {
        if usesSimulatedNotch || notchSize == .zero {
            return Self.simulatedNotchSize
        }
        return notchSize
    }

    var notchScreenRect: CGRect {
        let size = effectiveNotchSize
        return CGRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height
        )
    }

    func openedPanelScreenRect(size: CGSize) -> CGRect {
        CGRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height
        )
    }

    func windowFrame() -> CGRect {
        CGRect(
            x: screenFrame.minX,
            y: screenFrame.maxY - windowHeight,
            width: screenFrame.width,
            height: windowHeight
        )
    }

    func isPointInNotch(_ point: CGPoint) -> Bool {
        notchScreenRect
            .insetBy(dx: -Self.hitTestPadding.width, dy: -Self.hitTestPadding.height)
            .contains(point)
    }

    func isPointInOpenedPanel(_ point: CGPoint, size: CGSize) -> Bool {
        openedPanelScreenRect(size: size).contains(point)
    }
}
```

- [ ] **Step 4: Run geometry tests**

Run:

```bash
rtk swift test --filter NotchGeometryTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/Notch/NotchGeometry.swift Tests/NervNotchProTests/NotchGeometryTests.swift
rtk git commit -m "feat: add notch geometry calculations"
```

## Task 3: Interaction State Machine

**Files:**
- Create: `Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift`
- Test: `Tests/NervNotchProTests/NotchInteractionStateMachineTests.swift`

- [ ] **Step 1: Write failing interaction tests**

Create `Tests/NervNotchProTests/NotchInteractionStateMachineTests.swift`:

```swift
import XCTest
@testable import NervNotchProApp

final class NotchInteractionStateMachineTests: XCTestCase {
    func testClickNotchOpensImmediately() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.notchClicked, at: 10)
        XCTAssertEqual(machine.state, .opened)
    }

    func testHoverRequiresFullDelayBeforeOpening() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.mouseEnteredNotch, at: 10)
        machine.handle(.timerTick, at: 11.9)
        XCTAssertEqual(machine.state, .hoverArming(startedAt: 10))
        machine.handle(.timerTick, at: 12.0)
        XCTAssertEqual(machine.state, .opened)
    }

    func testLeavingNotchBeforeDelayCancelsHover() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.mouseEnteredNotch, at: 10)
        machine.handle(.mouseExitedNotch, at: 10.5)
        XCTAssertEqual(machine.state, .closed)
    }

    func testClickOutsideOpenedPanelClosesImmediately() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.notchClicked, at: 10)
        machine.handle(.outsideClicked, at: 10.1)
        XCTAssertEqual(machine.state, .closed)
    }

    func testLeavingPanelClosesAfterGracePeriod() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.notchClicked, at: 10)
        machine.handle(.mouseExitedPanel, at: 11)
        XCTAssertEqual(machine.state, .closing(startedAt: 11))
        machine.handle(.timerTick, at: 11.19)
        XCTAssertEqual(machine.state, .closing(startedAt: 11))
        machine.handle(.timerTick, at: 11.2)
        XCTAssertEqual(machine.state, .closed)
    }

    func testReenteringPanelCancelsClosing() {
        var machine = NotchInteractionStateMachine(hoverDelay: 2.0, closeGracePeriod: 0.2)
        machine.handle(.notchClicked, at: 10)
        machine.handle(.mouseExitedPanel, at: 11)
        machine.handle(.mouseEnteredPanel, at: 11.1)
        XCTAssertEqual(machine.state, .opened)
    }
}
```

- [ ] **Step 2: Run interaction tests to verify failure**

Run:

```bash
rtk swift test --filter NotchInteractionStateMachineTests
```

Expected: FAIL because `NotchInteractionStateMachine` does not exist.

- [ ] **Step 3: Implement interaction state machine**

Create `Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift`:

```swift
import Foundation

struct NotchInteractionStateMachine: Equatable, Sendable {
    enum State: Equatable, Sendable {
        case closed
        case hoverArming(startedAt: TimeInterval)
        case opened
        case closing(startedAt: TimeInterval)
    }

    enum Event: Equatable, Sendable {
        case notchClicked
        case outsideClicked
        case mouseEnteredNotch
        case mouseExitedNotch
        case mouseEnteredPanel
        case mouseExitedPanel
        case timerTick
    }

    private let hoverDelay: TimeInterval
    private let closeGracePeriod: TimeInterval
    private(set) var state: State = .closed

    init(hoverDelay: TimeInterval, closeGracePeriod: TimeInterval) {
        self.hoverDelay = hoverDelay
        self.closeGracePeriod = closeGracePeriod
    }

    mutating func handle(_ event: Event, at time: TimeInterval) {
        switch (state, event) {
        case (_, .notchClicked):
            state = .opened
        case (_, .outsideClicked):
            state = .closed
        case (.closed, .mouseEnteredNotch):
            state = .hoverArming(startedAt: time)
        case (.hoverArming, .mouseExitedNotch):
            state = .closed
        case let (.hoverArming(startedAt), .timerTick):
            if time - startedAt >= hoverDelay {
                state = .opened
            }
        case (.opened, .mouseExitedPanel):
            state = .closing(startedAt: time)
        case (.closing, .mouseEnteredPanel):
            state = .opened
        case let (.closing(startedAt), .timerTick):
            if time - startedAt >= closeGracePeriod {
                state = .closed
            }
        default:
            break
        }
    }
}
```

- [ ] **Step 4: Run interaction tests**

Run:

```bash
rtk swift test --filter NotchInteractionStateMachineTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift Tests/NervNotchProTests/NotchInteractionStateMachineTests.swift
rtk git commit -m "feat: add notch interaction state machine"
```

## Task 4: Telemetry Models And Calculations

**Files:**
- Create: `Sources/NervNotchProApp/Telemetry/SystemSnapshot.swift`
- Create: `Sources/NervNotchProApp/Telemetry/TelemetryCalculations.swift`
- Test: `Tests/NervNotchProTests/TelemetryCalculationTests.swift`

- [ ] **Step 1: Write failing telemetry calculation tests**

Create `Tests/NervNotchProTests/TelemetryCalculationTests.swift`:

```swift
import XCTest
@testable import NervNotchProApp

final class TelemetryCalculationTests: XCTestCase {
    func testCPUUsageUsesTickDelta() {
        let previous = CPUTicks(user: 100, system: 50, idle: 850, nice: 0)
        let current = CPUTicks(user: 180, system: 80, idle: 940, nice: 0)
        let usage = TelemetryCalculations.cpuUsage(previous: previous, current: current)
        XCTAssertEqual(usage, 0.55, accuracy: 0.001)
    }

    func testMemoryUsageRatio() {
        let memory = MemorySample(totalBytes: 1000, usedBytes: 730, availableBytes: 270, compressedBytes: 80)
        XCTAssertEqual(TelemetryCalculations.memoryUsageRatio(memory), 0.73, accuracy: 0.001)
    }

    func testNetworkRateUsesByteDeltaPerSecond() {
        let previous = NetworkCounters(receivedBytes: 1_000, sentBytes: 2_000)
        let current = NetworkCounters(receivedBytes: 3_048, sentBytes: 4_560)
        let rate = TelemetryCalculations.networkRate(previous: previous, current: current, interval: 2.0)
        XCTAssertEqual(rate.downBytesPerSecond, 1024)
        XCTAssertEqual(rate.upBytesPerSecond, 1280)
    }

    func testNetworkRateClampsCounterResetToZero() {
        let previous = NetworkCounters(receivedBytes: 4_000, sentBytes: 4_000)
        let current = NetworkCounters(receivedBytes: 2_000, sentBytes: 3_000)
        let rate = TelemetryCalculations.networkRate(previous: previous, current: current, interval: 1.0)
        XCTAssertEqual(rate.downBytesPerSecond, 0)
        XCTAssertEqual(rate.upBytesPerSecond, 0)
    }
}
```

- [ ] **Step 2: Run telemetry calculation tests to verify failure**

Run:

```bash
rtk swift test --filter TelemetryCalculationTests
```

Expected: FAIL because telemetry models do not exist.

- [ ] **Step 3: Implement telemetry models**

Create `Sources/NervNotchProApp/Telemetry/SystemSnapshot.swift`:

```swift
import Foundation

struct CPUTicks: Equatable, Sendable {
    let user: UInt64
    let system: UInt64
    let idle: UInt64
    let nice: UInt64

    var total: UInt64 {
        user + system + idle + nice
    }
}

struct CPUSample: Equatable, Sendable {
    let usageRatio: Double
    let coreCount: Int
    let userRatio: Double
    let systemRatio: Double
    let idleRatio: Double
}

struct MemorySample: Equatable, Sendable {
    let totalBytes: UInt64
    let usedBytes: UInt64
    let availableBytes: UInt64
    let compressedBytes: UInt64
}

struct NetworkCounters: Equatable, Sendable {
    let receivedBytes: UInt64
    let sentBytes: UInt64
}

struct NetworkRate: Equatable, Sendable {
    let downBytesPerSecond: UInt64
    let upBytesPerSecond: UInt64
    let activeInterfaceCount: Int
}

struct SystemSnapshot: Equatable, Sendable {
    let sampledAt: Date
    let cpu: CPUSample?
    let memory: MemorySample?
    let network: NetworkRate?
}
```

- [ ] **Step 4: Implement pure calculations**

Create `Sources/NervNotchProApp/Telemetry/TelemetryCalculations.swift`:

```swift
import Foundation

enum TelemetryCalculations {
    static func cpuUsage(previous: CPUTicks, current: CPUTicks) -> Double {
        let totalDelta = current.total.saturatingSubtract(previous.total)
        guard totalDelta > 0 else { return 0 }

        let idleDelta = current.idle.saturatingSubtract(previous.idle)
        let busyDelta = totalDelta.saturatingSubtract(idleDelta)
        return Double(busyDelta) / Double(totalDelta)
    }

    static func memoryUsageRatio(_ sample: MemorySample) -> Double {
        guard sample.totalBytes > 0 else { return 0 }
        return Double(sample.usedBytes) / Double(sample.totalBytes)
    }

    static func networkRate(previous: NetworkCounters, current: NetworkCounters, interval: TimeInterval) -> NetworkRate {
        guard interval > 0 else {
            return NetworkRate(downBytesPerSecond: 0, upBytesPerSecond: 0, activeInterfaceCount: 0)
        }

        let downDelta = current.receivedBytes >= previous.receivedBytes ? current.receivedBytes - previous.receivedBytes : 0
        let upDelta = current.sentBytes >= previous.sentBytes ? current.sentBytes - previous.sentBytes : 0

        return NetworkRate(
            downBytesPerSecond: UInt64(Double(downDelta) / interval),
            upBytesPerSecond: UInt64(Double(upDelta) / interval),
            activeInterfaceCount: 0
        )
    }
}

private extension UInt64 {
    func saturatingSubtract(_ other: UInt64) -> UInt64 {
        self >= other ? self - other : 0
    }
}
```

- [ ] **Step 5: Run telemetry calculation tests**

Run:

```bash
rtk swift test --filter TelemetryCalculationTests
```

Expected: PASS.

- [ ] **Step 6: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/Telemetry Tests/NervNotchProTests/TelemetryCalculationTests.swift
rtk git commit -m "feat: add telemetry data calculations"
```

## Task 5: MAGI Decision Engine

**Files:**
- Create: `Sources/NervNotchProApp/Magi/MagiDecisionEngine.swift`
- Test: `Tests/NervNotchProTests/MagiDecisionEngineTests.swift`

- [ ] **Step 1: Write failing MAGI decision tests**

Create `Tests/NervNotchProTests/MagiDecisionEngineTests.swift`:

```swift
import XCTest
@testable import NervNotchProApp

final class MagiDecisionEngineTests: XCTestCase {
    func testNormalSnapshotProducesSynchronizedJudgement() {
        let snapshot = SystemSnapshot(
            sampledAt: Date(timeIntervalSince1970: 0),
            cpu: CPUSample(usageRatio: 0.25, coreCount: 10, userRatio: 0.15, systemRatio: 0.10, idleRatio: 0.75),
            memory: MemorySample(totalBytes: 1000, usedBytes: 420, availableBytes: 580, compressedBytes: 30),
            network: NetworkRate(downBytesPerSecond: 200_000, upBytesPerSecond: 80_000, activeInterfaceCount: 1)
        )

        let state = MagiDecisionEngine().evaluate(snapshot)

        XCTAssertEqual(state.cpu.level, .normal)
        XCTAssertEqual(state.memory.level, .normal)
        XCTAssertEqual(state.network.level, .normal)
        XCTAssertEqual(state.judgement.level, .synchronized)
    }

    func testCriticalCPUProducesEmergencyMode() {
        let snapshot = SystemSnapshot(
            sampledAt: Date(timeIntervalSince1970: 0),
            cpu: CPUSample(usageRatio: 0.94, coreCount: 10, userRatio: 0.70, systemRatio: 0.24, idleRatio: 0.06),
            memory: MemorySample(totalBytes: 1000, usedBytes: 500, availableBytes: 500, compressedBytes: 30),
            network: NetworkRate(downBytesPerSecond: 0, upBytesPerSecond: 0, activeInterfaceCount: 1)
        )

        let state = MagiDecisionEngine().evaluate(snapshot)

        XCTAssertEqual(state.cpu.level, .critical)
        XCTAssertEqual(state.judgement.level, .emergencyMode)
    }

    func testMissingTelemetryProducesPartialSync() {
        let snapshot = SystemSnapshot(
            sampledAt: Date(timeIntervalSince1970: 0),
            cpu: nil,
            memory: MemorySample(totalBytes: 1000, usedBytes: 500, availableBytes: 500, compressedBytes: 30),
            network: NetworkRate(downBytesPerSecond: 0, upBytesPerSecond: 0, activeInterfaceCount: 0)
        )

        let state = MagiDecisionEngine().evaluate(snapshot)

        XCTAssertEqual(state.cpu.level, .unavailable)
        XCTAssertEqual(state.judgement.level, .partialSync)
    }
}
```

- [ ] **Step 2: Run MAGI tests to verify failure**

Run:

```bash
rtk swift test --filter MagiDecisionEngineTests
```

Expected: FAIL because `MagiDecisionEngine` does not exist.

- [ ] **Step 3: Implement decision engine**

Create `Sources/NervNotchProApp/Magi/MagiDecisionEngine.swift`:

```swift
import Foundation

struct MagiDecisionState: Equatable, Sendable {
    let sampledAt: Date
    let cpu: MagiPanelDecision
    let memory: MagiPanelDecision
    let network: MagiPanelDecision
    let judgement: CentralDogmaJudgement
}

struct MagiPanelDecision: Equatable, Sendable {
    enum Level: Equatable, Sendable {
        case normal
        case highLoad
        case critical
        case idle
        case unavailable
    }

    let codeName: String
    let title: String
    let primaryValue: String
    let secondaryValue: String
    let level: Level
    let statusText: String
    let decisionText: String
}

struct CentralDogmaJudgement: Equatable, Sendable {
    enum Level: Equatable, Sendable {
        case synchronized
        case elevatedAlert
        case emergencyMode
        case partialSync
    }

    let level: Level
    let title: String
    let summary: String
}

struct MagiDecisionEngine: Sendable {
    func evaluate(_ snapshot: SystemSnapshot) -> MagiDecisionState {
        let cpu = evaluateCPU(snapshot.cpu)
        let memory = evaluateMemory(snapshot.memory)
        let network = evaluateNetwork(snapshot.network)
        let judgement = evaluateJudgement(panels: [cpu, memory, network])

        return MagiDecisionState(
            sampledAt: snapshot.sampledAt,
            cpu: cpu,
            memory: memory,
            network: network,
            judgement: judgement
        )
    }

    private func evaluateCPU(_ sample: CPUSample?) -> MagiPanelDecision {
        guard let sample else {
            return unavailablePanel(codeName: "MELCHIOR-01", title: "CPU LOAD")
        }

        let percent = sample.usageRatio * 100
        let level: MagiPanelDecision.Level
        let status: String
        let decision: String

        if sample.usageRatio >= 0.90 {
            level = .critical
            status = "CRITICAL"
            decision = "PROCESSOR SATURATION"
        } else if sample.usageRatio >= 0.70 {
            level = .highLoad
            status = "HIGH LOAD"
            decision = "LOAD RISING"
        } else {
            level = .normal
            status = "NORMAL"
            decision = "LOAD ACCEPTABLE"
        }

        return MagiPanelDecision(
            codeName: "MELCHIOR-01",
            title: "CPU LOAD",
            primaryValue: "\(Int(percent.rounded()))%",
            secondaryValue: "\(sample.coreCount) CORES",
            level: level,
            statusText: status,
            decisionText: decision
        )
    }

    private func evaluateMemory(_ sample: MemorySample?) -> MagiPanelDecision {
        guard let sample else {
            return unavailablePanel(codeName: "BALTHASAR-02", title: "MEMORY")
        }

        let ratio = TelemetryCalculations.memoryUsageRatio(sample)
        let level: MagiPanelDecision.Level
        let status: String
        let decision: String

        if ratio >= 0.90 {
            level = .critical
            status = "CRITICAL"
            decision = "MEMORY PRESSURE CRITICAL"
        } else if ratio >= 0.75 {
            level = .highLoad
            status = "HIGH LOAD"
            decision = "MEMORY PRESSURE RISING"
        } else {
            level = .normal
            status = "NORMAL"
            decision = "MEMORY STABLE"
        }

        return MagiPanelDecision(
            codeName: "BALTHASAR-02",
            title: "MEMORY",
            primaryValue: "\(Int((ratio * 100).rounded()))%",
            secondaryValue: ByteFormat.megabytes(sample.availableBytes) + " FREE",
            level: level,
            statusText: status,
            decisionText: decision
        )
    }

    private func evaluateNetwork(_ sample: NetworkRate?) -> MagiPanelDecision {
        guard let sample else {
            return unavailablePanel(codeName: "CASPER-03", title: "NETWORK")
        }

        if sample.activeInterfaceCount == 0 {
            return MagiPanelDecision(
                codeName: "CASPER-03",
                title: "NETWORK",
                primaryValue: "0 KB/s",
                secondaryValue: "NO ACTIVE LINK",
                level: .idle,
                statusText: "COMM LINK IDLE",
                decisionText: "COMMUNICATION STANDBY"
            )
        }

        let totalRate = sample.downBytesPerSecond + sample.upBytesPerSecond
        let level: MagiPanelDecision.Level
        let status: String
        let decision: String

        if totalRate >= 100_000_000 {
            level = .critical
            status = "CRITICAL"
            decision = "BANDWIDTH SATURATION"
        } else if totalRate >= 25_000_000 {
            level = .highLoad
            status = "HIGH TRAFFIC"
            decision = "COMM LOAD RISING"
        } else {
            level = .normal
            status = "ACTIVE"
            decision = "COMM LINK ACTIVE"
        }

        return MagiPanelDecision(
            codeName: "CASPER-03",
            title: "NETWORK",
            primaryValue: ByteFormat.rate(sample.downBytesPerSecond),
            secondaryValue: "UP " + ByteFormat.rate(sample.upBytesPerSecond),
            level: level,
            statusText: status,
            decisionText: decision
        )
    }

    private func evaluateJudgement(panels: [MagiPanelDecision]) -> CentralDogmaJudgement {
        if panels.contains(where: { $0.level == .unavailable }) {
            return CentralDogmaJudgement(level: .partialSync, title: "PARTIAL SYNC", summary: "MAGI CONSENSUS DEGRADED")
        }

        if panels.contains(where: { $0.level == .critical }) {
            return CentralDogmaJudgement(level: .emergencyMode, title: "EMERGENCY MODE", summary: "CENTRAL DOGMA ALERT")
        }

        if panels.contains(where: { $0.level == .highLoad }) {
            return CentralDogmaJudgement(level: .elevatedAlert, title: "ELEVATED ALERT", summary: "SYSTEM LOAD INCREASING")
        }

        return CentralDogmaJudgement(level: .synchronized, title: "SYNCHRONIZED", summary: "MAGI SYSTEMS NOMINAL")
    }

    private func unavailablePanel(codeName: String, title: String) -> MagiPanelDecision {
        MagiPanelDecision(
            codeName: codeName,
            title: title,
            primaryValue: "--",
            secondaryValue: "NO SIGNAL",
            level: .unavailable,
            statusText: "DATA UNAVAILABLE",
            decisionText: "SIGNAL LOST"
        )
    }
}

enum ByteFormat {
    static func megabytes(_ bytes: UInt64) -> String {
        "\(bytes / 1_048_576) MB"
    }

    static func rate(_ bytesPerSecond: UInt64) -> String {
        if bytesPerSecond >= 1_048_576 {
            return "\(bytesPerSecond / 1_048_576) MB/s"
        }
        return "\(bytesPerSecond / 1024) KB/s"
    }
}
```

- [ ] **Step 4: Run MAGI tests**

Run:

```bash
rtk swift test --filter MagiDecisionEngineTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/Magi Tests/NervNotchProTests/MagiDecisionEngineTests.swift
rtk git commit -m "feat: add MAGI decision engine"
```

## Task 6: Real Telemetry Samplers

**Files:**
- Create: `Sources/NervNotchProApp/Telemetry/CPUUsageSampler.swift`
- Create: `Sources/NervNotchProApp/Telemetry/MemoryUsageSampler.swift`
- Create: `Sources/NervNotchProApp/Telemetry/NetworkUsageSampler.swift`
- Create: `Sources/NervNotchProApp/Telemetry/TelemetrySampler.swift`
- Modify: `Sources/NervNotchProApp/Telemetry/TelemetryCalculations.swift`
- Test: `Tests/NervNotchProTests/TelemetrySamplerSmokeTests.swift`

- [ ] **Step 1: Add smoke tests for aggregate sampler**

Create `Tests/NervNotchProTests/TelemetrySamplerSmokeTests.swift`:

```swift
import XCTest
@testable import NervNotchProApp

final class TelemetrySamplerSmokeTests: XCTestCase {
    func testSamplerReturnsSnapshotWithSampleDate() {
        let sampler = TelemetrySampler()
        let snapshot = sampler.sample()
        XCTAssertLessThan(abs(snapshot.sampledAt.timeIntervalSinceNow), 2)
    }

    func testMemorySamplerReportsPhysicalMemoryWhenAvailable() {
        let sample = MemoryUsageSampler().sample()
        XCTAssertNotNil(sample)
        XCTAssertGreaterThan(sample?.totalBytes ?? 0, 0)
    }
}
```

- [ ] **Step 2: Run smoke tests to verify failure**

Run:

```bash
rtk swift test --filter TelemetrySamplerSmokeTests
```

Expected: FAIL because real samplers do not exist.

- [ ] **Step 3: Implement CPU sampler**

Create `Sources/NervNotchProApp/Telemetry/CPUUsageSampler.swift`:

```swift
import Darwin
import Foundation

final class CPUUsageSampler {
    private var previousTicks: CPUTicks?

    func sample() -> CPUSample? {
        guard let current = readTicks() else { return nil }
        defer { previousTicks = current }

        guard let previousTicks else {
            return CPUSample(usageRatio: 0, coreCount: ProcessInfo.processInfo.processorCount, userRatio: 0, systemRatio: 0, idleRatio: 1)
        }

        let usage = TelemetryCalculations.cpuUsage(previous: previousTicks, current: current)
        let totalDelta = current.total >= previousTicks.total ? current.total - previousTicks.total : 0
        guard totalDelta > 0 else {
            return CPUSample(usageRatio: 0, coreCount: ProcessInfo.processInfo.processorCount, userRatio: 0, systemRatio: 0, idleRatio: 1)
        }

        let userDelta = current.user >= previousTicks.user ? current.user - previousTicks.user : 0
        let systemDelta = current.system >= previousTicks.system ? current.system - previousTicks.system : 0
        let idleDelta = current.idle >= previousTicks.idle ? current.idle - previousTicks.idle : 0

        return CPUSample(
            usageRatio: usage,
            coreCount: ProcessInfo.processInfo.processorCount,
            userRatio: Double(userDelta) / Double(totalDelta),
            systemRatio: Double(systemDelta) / Double(totalDelta),
            idleRatio: Double(idleDelta) / Double(totalDelta)
        )
    }

    private func readTicks() -> CPUTicks? {
        var cpuInfo: processor_info_array_t?
        var processorMsgCount: mach_msg_type_number_t = 0
        var processorCount: natural_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &processorCount,
            &cpuInfo,
            &processorMsgCount
        )

        guard result == KERN_SUCCESS, let cpuInfo else { return nil }
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: cpuInfo),
                vm_size_t(processorMsgCount) * vm_size_t(MemoryLayout<integer_t>.stride)
            )
        }

        var user: UInt64 = 0
        var system: UInt64 = 0
        var idle: UInt64 = 0
        var nice: UInt64 = 0

        let stride = Int(CPU_STATE_MAX)
        for index in 0..<Int(processorCount) {
            let base = index * stride
            user += UInt64(cpuInfo[base + Int(CPU_STATE_USER)])
            system += UInt64(cpuInfo[base + Int(CPU_STATE_SYSTEM)])
            idle += UInt64(cpuInfo[base + Int(CPU_STATE_IDLE)])
            nice += UInt64(cpuInfo[base + Int(CPU_STATE_NICE)])
        }

        return CPUTicks(user: user, system: system, idle: idle, nice: nice)
    }
}
```

- [ ] **Step 4: Implement memory sampler**

Create `Sources/NervNotchProApp/Telemetry/MemoryUsageSampler.swift`:

```swift
import Darwin
import Foundation

final class MemoryUsageSampler {
    func sample() -> MemorySample? {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) { statsPointer in
            statsPointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { reboundPointer in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, reboundPointer, &count)
            }
        }

        guard result == KERN_SUCCESS else { return nil }

        let pageSize = UInt64(vm_kernel_page_size)
        let total = ProcessInfo.processInfo.physicalMemory
        let free = UInt64(stats.free_count) * pageSize
        let inactive = UInt64(stats.inactive_count) * pageSize
        let compressed = UInt64(stats.compressor_page_count) * pageSize
        let available = free + inactive
        let used = total > available ? total - available : 0

        return MemorySample(
            totalBytes: total,
            usedBytes: used,
            availableBytes: available,
            compressedBytes: compressed
        )
    }
}
```

- [ ] **Step 5: Implement network sampler**

Create `Sources/NervNotchProApp/Telemetry/NetworkUsageSampler.swift`:

```swift
import Darwin
import Foundation

final class NetworkUsageSampler {
    private var previousCounters: NetworkCounters?
    private var previousDate: Date?

    func sample(at date: Date = Date()) -> NetworkRate? {
        guard let current = readCounters() else { return nil }
        defer {
            previousCounters = current.counters
            previousDate = date
        }

        guard let previousCounters, let previousDate else {
            return NetworkRate(downBytesPerSecond: 0, upBytesPerSecond: 0, activeInterfaceCount: current.activeInterfaceCount)
        }

        var rate = TelemetryCalculations.networkRate(
            previous: previousCounters,
            current: current.counters,
            interval: date.timeIntervalSince(previousDate)
        )

        rate = NetworkRate(
            downBytesPerSecond: rate.downBytesPerSecond,
            upBytesPerSecond: rate.upBytesPerSecond,
            activeInterfaceCount: current.activeInterfaceCount
        )

        return rate
    }

    private func readCounters() -> (counters: NetworkCounters, activeInterfaceCount: Int)? {
        var addresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addresses) == 0, let firstAddress = addresses else { return nil }
        defer { freeifaddrs(addresses) }

        var received: UInt64 = 0
        var sent: UInt64 = 0
        var activeCount = 0

        var pointer: UnsafeMutablePointer<ifaddrs>? = firstAddress
        while let currentPointer = pointer {
            let interface = currentPointer.pointee
            let name = String(cString: interface.ifa_name)
            let flags = Int32(interface.ifa_flags)
            let isUp = (flags & IFF_UP) == IFF_UP
            let isLoopback = (flags & IFF_LOOPBACK) == IFF_LOOPBACK

            if isUp, !isLoopback, let data = interface.ifa_data {
                let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                if name.hasPrefix("en") || name.hasPrefix("bridge") || name.hasPrefix("utun") || name.hasPrefix("awdl") {
                    received += UInt64(networkData.ifi_ibytes)
                    sent += UInt64(networkData.ifi_obytes)
                    activeCount += 1
                }
            }

            pointer = interface.ifa_next
        }

        return (NetworkCounters(receivedBytes: received, sentBytes: sent), activeCount)
    }
}
```

- [ ] **Step 6: Implement aggregate sampler**

Create `Sources/NervNotchProApp/Telemetry/TelemetrySampler.swift`:

```swift
import Foundation

final class TelemetrySampler {
    private let cpuSampler: CPUUsageSampler
    private let memorySampler: MemoryUsageSampler
    private let networkSampler: NetworkUsageSampler

    init(
        cpuSampler: CPUUsageSampler = CPUUsageSampler(),
        memorySampler: MemoryUsageSampler = MemoryUsageSampler(),
        networkSampler: NetworkUsageSampler = NetworkUsageSampler()
    ) {
        self.cpuSampler = cpuSampler
        self.memorySampler = memorySampler
        self.networkSampler = networkSampler
    }

    func sample(at date: Date = Date()) -> SystemSnapshot {
        SystemSnapshot(
            sampledAt: date,
            cpu: cpuSampler.sample(),
            memory: memorySampler.sample(),
            network: networkSampler.sample(at: date)
        )
    }
}
```

- [ ] **Step 7: Run telemetry tests**

Run:

```bash
rtk swift test --filter Telemetry
```

Expected: PASS for calculation and smoke tests. The first CPU and network samples may be zero because they need a previous sample; that is acceptable.

- [ ] **Step 8: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/Telemetry Tests/NervNotchProTests/TelemetrySamplerSmokeTests.swift
rtk git commit -m "feat: collect real system telemetry"
```

## Task 7: View Model And Sampling Timer

**Files:**
- Create: `Sources/NervNotchProApp/Settings/AppSettings.swift`
- Create: `Sources/NervNotchProApp/ViewModels/NotchViewModel.swift`
- Test: `Tests/NervNotchProTests/NotchViewModelTests.swift`

- [ ] **Step 1: Write failing view model test**

Create `Tests/NervNotchProTests/NotchViewModelTests.swift`:

```swift
import XCTest
@testable import NervNotchProApp

final class NotchViewModelTests: XCTestCase {
    func testViewModelUpdatesDecisionFromSnapshot() {
        let viewModel = NotchViewModel(
            settings: AppSettings(),
            decisionEngine: MagiDecisionEngine()
        )

        let snapshot = SystemSnapshot(
            sampledAt: Date(timeIntervalSince1970: 1),
            cpu: CPUSample(usageRatio: 0.8, coreCount: 10, userRatio: 0.6, systemRatio: 0.2, idleRatio: 0.2),
            memory: MemorySample(totalBytes: 1000, usedBytes: 400, availableBytes: 600, compressedBytes: 0),
            network: NetworkRate(downBytesPerSecond: 1024, upBytesPerSecond: 2048, activeInterfaceCount: 1)
        )

        viewModel.apply(snapshot)

        XCTAssertEqual(viewModel.magiState.cpu.level, .highLoad)
        XCTAssertEqual(viewModel.magiState.judgement.level, .elevatedAlert)
    }
}
```

- [ ] **Step 2: Run view model test to verify failure**

Run:

```bash
rtk swift test --filter NotchViewModelTests
```

Expected: FAIL because `AppSettings` and `NotchViewModel` do not exist.

- [ ] **Step 3: Implement settings**

Create `Sources/NervNotchProApp/Settings/AppSettings.swift`:

```swift
import Foundation

struct AppSettings: Equatable, Sendable {
    var hoverDelay: TimeInterval = 2.0
    var closeGracePeriod: TimeInterval = 0.2
    var samplingInterval: TimeInterval = 1.0
    var usesSimulatedNotch: Bool = true
    var targetScreenIdentifier: String?
    var fanModeEnabled: Bool = true
}
```

- [ ] **Step 4: Implement view model**

Create `Sources/NervNotchProApp/ViewModels/NotchViewModel.swift`:

```swift
import Combine
import Foundation

@MainActor
final class NotchViewModel: ObservableObject {
    @Published private(set) var magiState: MagiDecisionState
    @Published private(set) var interactionState: NotchInteractionStateMachine.State = .closed

    let settings: AppSettings
    private let decisionEngine: MagiDecisionEngine
    private var stateMachine: NotchInteractionStateMachine

    init(settings: AppSettings, decisionEngine: MagiDecisionEngine) {
        self.settings = settings
        self.decisionEngine = decisionEngine
        self.stateMachine = NotchInteractionStateMachine(
            hoverDelay: settings.hoverDelay,
            closeGracePeriod: settings.closeGracePeriod
        )

        self.magiState = decisionEngine.evaluate(
            SystemSnapshot(sampledAt: Date(), cpu: nil, memory: nil, network: nil)
        )
    }

    func apply(_ snapshot: SystemSnapshot) {
        magiState = decisionEngine.evaluate(snapshot)
    }

    func handleInteraction(_ event: NotchInteractionStateMachine.Event, at time: TimeInterval = Date().timeIntervalSince1970) {
        stateMachine.handle(event, at: time)
        interactionState = stateMachine.state
    }
}
```

- [ ] **Step 5: Run view model tests**

Run:

```bash
rtk swift test --filter NotchViewModelTests
```

Expected: PASS.

- [ ] **Step 6: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/Settings Sources/NervNotchProApp/ViewModels Tests/NervNotchProTests/NotchViewModelTests.swift
rtk git commit -m "feat: connect telemetry snapshots to MAGI view model"
```

## Task 8: NERV/MAGI SwiftUI Components

**Files:**
- Create: `Sources/NervNotchProApp/UI/NervStyle.swift`
- Create: `Sources/NervNotchProApp/UI/ScanlineOverlay.swift`
- Create: `Sources/NervNotchProApp/UI/MagiDecisionPanelView.swift`
- Create: `Sources/NervNotchProApp/UI/CentralDogmaJudgementView.swift`
- Create: `Sources/NervNotchProApp/UI/NervConsoleView.swift`

- [ ] **Step 1: Add shared style tokens**

Create `Sources/NervNotchProApp/UI/NervStyle.swift`:

```swift
import SwiftUI

enum NervStyle {
    static let background = Color(red: 0.015, green: 0.012, blue: 0.010)
    static let panelFill = Color(red: 0.075, green: 0.010, blue: 0.012).opacity(0.92)
    static let red = Color(red: 0.86, green: 0.02, blue: 0.02)
    static let orange = Color(red: 1.0, green: 0.48, blue: 0.06)
    static let green = Color(red: 0.18, green: 0.95, blue: 0.46)
    static let white = Color(red: 0.92, green: 0.90, blue: 0.84)
    static let muted = Color(red: 0.55, green: 0.50, blue: 0.44)

    static let mono = Font.system(.caption, design: .monospaced)
    static let monoSmall = Font.system(size: 9, weight: .medium, design: .monospaced)
    static let monoTitle = Font.system(size: 12, weight: .black, design: .monospaced)
    static let monoValue = Font.system(size: 30, weight: .black, design: .monospaced)
}
```

- [ ] **Step 2: Add scanline overlay**

Create `Sources/NervNotchProApp/UI/ScanlineOverlay.swift`:

```swift
import SwiftUI

struct ScanlineOverlay: View {
    var body: some View {
        Canvas { context, size in
            let lineColor = Color.white.opacity(0.055)
            for y in stride(from: 0.0, through: size.height, by: 4.0) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(lineColor), lineWidth: 1)
            }

            let gridColor = NervStyle.red.opacity(0.11)
            for x in stride(from: 0.0, through: size.width, by: 24.0) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }
}
```

- [ ] **Step 3: Add MAGI panel view**

Create `Sources/NervNotchProApp/UI/MagiDecisionPanelView.swift`:

```swift
import SwiftUI

struct MagiDecisionPanelView: View {
    let decision: MagiPanelDecision

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(decision.codeName)
                    .font(NervStyle.monoTitle)
                    .foregroundStyle(NervStyle.red)
                Spacer(minLength: 8)
                Text(decision.statusText)
                    .font(NervStyle.monoSmall)
                    .foregroundStyle(statusColor)
            }

            Text(decision.title)
                .font(NervStyle.monoSmall)
                .foregroundStyle(NervStyle.muted)

            Spacer(minLength: 4)

            Text(decision.primaryValue)
                .font(NervStyle.monoValue)
                .foregroundStyle(NervStyle.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(decision.secondaryValue)
                .font(NervStyle.monoSmall)
                .foregroundStyle(NervStyle.orange)
                .lineLimit(1)

            Divider()
                .overlay(NervStyle.red.opacity(0.65))

            Text(decision.decisionText)
                .font(NervStyle.monoSmall)
                .foregroundStyle(statusColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(minWidth: 190, minHeight: 180)
        .background(NervStyle.panelFill)
        .overlay(
            Rectangle()
                .stroke(statusColor.opacity(0.85), lineWidth: 1)
        )
    }

    private var statusColor: Color {
        switch decision.level {
        case .normal, .idle:
            return NervStyle.green
        case .highLoad:
            return NervStyle.orange
        case .critical, .unavailable:
            return NervStyle.red
        }
    }
}
```

- [ ] **Step 4: Add Central Dogma view**

Create `Sources/NervNotchProApp/UI/CentralDogmaJudgementView.swift`:

```swift
import SwiftUI

struct CentralDogmaJudgementView: View {
    let judgement: CentralDogmaJudgement

    var body: some View {
        HStack(spacing: 14) {
            Text("CENTRAL DOGMA JUDGEMENT")
                .font(NervStyle.monoTitle)
                .foregroundStyle(NervStyle.red)

            Rectangle()
                .fill(NervStyle.red.opacity(0.7))
                .frame(width: 1)

            Text(judgement.title)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundStyle(color)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(judgement.summary)
                .font(NervStyle.monoSmall)
                .foregroundStyle(NervStyle.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.55))
        .overlay(Rectangle().stroke(color.opacity(0.85), lineWidth: 1))
    }

    private var color: Color {
        switch judgement.level {
        case .synchronized:
            return NervStyle.green
        case .elevatedAlert:
            return NervStyle.orange
        case .emergencyMode, .partialSync:
            return NervStyle.red
        }
    }
}
```

- [ ] **Step 5: Add root console view**

Create `Sources/NervNotchProApp/UI/NervConsoleView.swift`:

```swift
import SwiftUI

struct NervConsoleView: View {
    @ObservedObject var viewModel: NotchViewModel

    var body: some View {
        VStack(spacing: 10) {
            header

            HStack(spacing: 10) {
                MagiDecisionPanelView(decision: viewModel.magiState.cpu)
                MagiDecisionPanelView(decision: viewModel.magiState.memory)
                MagiDecisionPanelView(decision: viewModel.magiState.network)
            }

            CentralDogmaJudgementView(judgement: viewModel.magiState.judgement)
        }
        .padding(14)
        .frame(width: 820, height: 420)
        .background(NervStyle.background)
        .overlay(ScanlineOverlay())
        .overlay(Rectangle().stroke(NervStyle.red, lineWidth: 2))
    }

    private var header: some View {
        HStack {
            Text("NERV HQ / MAGI SYS")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundStyle(NervStyle.red)
            Spacer()
            Text(viewModel.magiState.sampledAt.formatted(date: .omitted, time: .standard))
                .font(NervStyle.monoSmall)
                .foregroundStyle(NervStyle.muted)
        }
    }
}
```

- [ ] **Step 6: Build to verify UI compiles**

Run:

```bash
rtk swift build
```

Expected: build succeeds.

- [ ] **Step 7: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/UI
rtk git commit -m "feat: add NERV MAGI SwiftUI console"
```

## Task 9: AppKit Notch Window

**Files:**
- Create: `Sources/NervNotchProApp/Notch/NotchPanel.swift`
- Create: `Sources/NervNotchProApp/Notch/NotchWindowController.swift`
- Modify: `Sources/NervNotchProApp/App/NervNotchApplication.swift`
- Create: `Sources/NervNotchProApp/App/AppDelegate.swift`

- [ ] **Step 1: Add transparent panel**

Create `Sources/NervNotchProApp/Notch/NotchPanel.swift`:

```swift
import AppKit

final class NotchPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        isMovable = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        collectionBehavior = [.fullScreenAuxiliary, .stationary, .canJoinAllSpaces, .ignoresCycle]
        level = .mainMenu + 3
        ignoresMouseEvents = true
        acceptsMouseMovedEvents = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
```

- [ ] **Step 2: Add window controller**

Create `Sources/NervNotchProApp/Notch/NotchWindowController.swift`:

```swift
import AppKit
import Combine
import SwiftUI

final class NotchWindowController: NSWindowController {
    private let viewModel: NotchViewModel
    private var cancellables = Set<AnyCancellable>()

    init(screen: NSScreen, viewModel: NotchViewModel, usesSimulatedNotch: Bool) {
        self.viewModel = viewModel

        let notchSize = screen.safeAreaInsets.top > 0
            ? CGSize(width: 210, height: max(32, screen.safeAreaInsets.top))
            : .zero

        let geometry = NotchGeometry(
            screenFrame: screen.frame,
            notchSize: notchSize,
            windowHeight: 460,
            usesSimulatedNotch: usesSimulatedNotch
        )

        let panel = NotchPanel(contentRect: geometry.windowFrame())
        super.init(window: panel)

        panel.contentViewController = NSHostingController(rootView: NervConsoleView(viewModel: viewModel))
        panel.setFrame(geometry.windowFrame(), display: true)

        viewModel.$interactionState
            .receive(on: DispatchQueue.main)
            .sink { [weak panel] state in
                switch state {
                case .opened, .closing:
                    panel?.ignoresMouseEvents = false
                case .closed, .hoverArming:
                    panel?.ignoresMouseEvents = true
                }
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

- [ ] **Step 3: Add app delegate**

Create `Sources/NervNotchProApp/App/AppDelegate.swift`:

```swift
import AppKit
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: NotchWindowController?
    private var viewModel: NotchViewModel?
    private var timer: Timer?
    private let settings = AppSettings()
    private let sampler = TelemetrySampler()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let viewModel = NotchViewModel(settings: settings, decisionEngine: MagiDecisionEngine())
        self.viewModel = viewModel

        let screen = NSScreen.main ?? NSScreen.screens.first
        if let screen {
            let controller = NotchWindowController(
                screen: screen,
                viewModel: viewModel,
                usesSimulatedNotch: settings.usesSimulatedNotch
            )
            controller.showWindow(nil)
            windowController = controller
        }

        timer = Timer.scheduledTimer(withTimeInterval: settings.samplingInterval, repeats: true) { [weak self] _ in
            guard let self, let viewModel = self.viewModel else { return }
            let snapshot = self.sampler.sample()
            Task { @MainActor in
                viewModel.apply(snapshot)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }
}
```

- [ ] **Step 4: Wire delegate into application wrapper**

Replace `Sources/NervNotchProApp/App/NervNotchApplication.swift` with:

```swift
import AppKit

final class NervNotchApplication {
    private let appDelegate = AppDelegate()

    func run() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.delegate = appDelegate
        app.run()
    }
}
```

- [ ] **Step 5: Build app**

Run:

```bash
rtk swift build
```

Expected: build succeeds.

- [ ] **Step 6: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/App Sources/NervNotchProApp/Notch
rtk git commit -m "feat: show NERV console in notch panel"
```

## Task 10: Global Mouse Monitoring

**Files:**
- Create: `Sources/NervNotchProApp/Notch/NotchEventMonitor.swift`
- Modify: `Sources/NervNotchProApp/Notch/NotchWindowController.swift`

- [ ] **Step 1: Add event monitor**

Create `Sources/NervNotchProApp/Notch/NotchEventMonitor.swift`:

```swift
import AppKit
import CoreGraphics

final class NotchEventMonitor {
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private let geometry: NotchGeometry
    private let openedPanelSize: CGSize
    private let onEvent: (NotchInteractionStateMachine.Event) -> Void

    init(
        geometry: NotchGeometry,
        openedPanelSize: CGSize,
        onEvent: @escaping (NotchInteractionStateMachine.Event) -> Void
    ) {
        self.geometry = geometry
        self.openedPanelSize = openedPanelSize
        self.onEvent = onEvent
    }

    func start() {
        stop()
        let mask: NSEvent.EventTypeMask = [.leftMouseDown, .mouseMoved]

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
            return event
        }
    }

    func stop() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
    }

    private func handle(_ event: NSEvent) {
        let point = NSEvent.mouseLocation

        switch event.type {
        case .leftMouseDown:
            if geometry.isPointInNotch(point) {
                onEvent(.notchClicked)
            } else if !geometry.isPointInOpenedPanel(point, size: openedPanelSize) {
                onEvent(.outsideClicked)
            }
        case .mouseMoved:
            if geometry.isPointInNotch(point) {
                onEvent(.mouseEnteredNotch)
            } else if geometry.isPointInOpenedPanel(point, size: openedPanelSize) {
                onEvent(.mouseEnteredPanel)
            } else {
                onEvent(.mouseExitedPanel)
            }
        default:
            break
        }
    }

    deinit {
        stop()
    }
}
```

- [ ] **Step 2: Attach monitor in window controller**

Modify `Sources/NervNotchProApp/Notch/NotchWindowController.swift`:

```swift
import AppKit
import Combine
import SwiftUI

final class NotchWindowController: NSWindowController {
    private let viewModel: NotchViewModel
    private var cancellables = Set<AnyCancellable>()
    private var eventMonitor: NotchEventMonitor?
    private var timer: Timer?

    init(screen: NSScreen, viewModel: NotchViewModel, usesSimulatedNotch: Bool) {
        self.viewModel = viewModel

        let notchSize = screen.safeAreaInsets.top > 0
            ? CGSize(width: 210, height: max(32, screen.safeAreaInsets.top))
            : .zero

        let geometry = NotchGeometry(
            screenFrame: screen.frame,
            notchSize: notchSize,
            windowHeight: 460,
            usesSimulatedNotch: usesSimulatedNotch
        )

        let panel = NotchPanel(contentRect: geometry.windowFrame())
        super.init(window: panel)

        panel.contentViewController = NSHostingController(rootView: NervConsoleView(viewModel: viewModel))
        panel.setFrame(geometry.windowFrame(), display: true)

        eventMonitor = NotchEventMonitor(
            geometry: geometry,
            openedPanelSize: CGSize(width: 820, height: 420)
        ) { [weak viewModel] event in
            Task { @MainActor in
                viewModel?.handleInteraction(event)
            }
        }
        eventMonitor?.start()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak viewModel] _ in
            Task { @MainActor in
                viewModel?.handleInteraction(.timerTick)
            }
        }

        viewModel.$interactionState
            .receive(on: DispatchQueue.main)
            .sink { [weak panel] state in
                switch state {
                case .opened, .closing:
                    panel?.ignoresMouseEvents = false
                case .closed, .hoverArming:
                    panel?.ignoresMouseEvents = true
                }
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timer?.invalidate()
        eventMonitor?.stop()
    }
}
```

- [ ] **Step 3: Build app**

Run:

```bash
rtk swift build
```

Expected: build succeeds.

- [ ] **Step 4: Commit**

Run:

```bash
rtk git add Sources/NervNotchProApp/Notch
rtk git commit -m "feat: add notch mouse interaction monitoring"
```

## Task 11: Manual Run Script And Verification

**Files:**
- Create: `scripts/run-dev.sh`
- Create: `README.md`

- [ ] **Step 1: Add development run script**

Create `scripts/run-dev.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

swift run NervNotchPro
```

Run:

```bash
rtk chmod +x scripts/run-dev.sh
```

- [ ] **Step 2: Add README**

Create `README.md`:

```markdown
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

## MVP Scope

- CPU telemetry
- Memory telemetry
- Network telemetry
- MAGI decision panels
- Central Dogma judgement
- Click-to-open and outside-click-to-close notch panel
- Hover for 2 seconds to open

This project is a local fan-oriented prototype and does not bundle copyrighted image assets.
```

- [ ] **Step 3: Run full tests**

Run:

```bash
rtk swift test
```

Expected: PASS.

- [ ] **Step 4: Build release binary**

Run:

```bash
rtk swift build -c release
```

Expected: build succeeds.

- [ ] **Step 5: Commit**

Run:

```bash
rtk git add README.md scripts/run-dev.sh
rtk git commit -m "docs: add development run instructions"
```

## Task 12: Final QA Pass

**Files:**
- Modify only if QA reveals concrete fixes.

- [ ] **Step 1: Run complete test suite**

Run:

```bash
rtk swift test
```

Expected: PASS.

- [ ] **Step 2: Build debug and release**

Run:

```bash
rtk swift build
rtk swift build -c release
```

Expected: both builds succeed.

- [ ] **Step 3: Manual app verification**

Run:

```bash
./scripts/run-dev.sh
```

Expected manual checks:

- A transparent top panel appears centered at the active screen top.
- The NERV/MAGI console renders with red/black command-console styling.
- CPU, memory, and network values update approximately every second.
- Clicking the notch region opens the panel.
- Clicking outside the panel closes it.
- Hovering the notch region for 2 seconds opens the panel.
- Moving outside the panel closes it after a short grace period.
- Non-notch Macs still show a simulated top-centered Island.

- [ ] **Step 4: Fix only blocking QA failures**

If a test or build fails, add the smallest patch that restores the expected behavior. For example, if a Swift concurrency warning becomes an error around `@MainActor`, isolate the affected UI type on the main actor instead of weakening concurrency checks broadly.

- [ ] **Step 5: Commit QA fixes**

If fixes were needed, run:

```bash
rtk git add Sources Tests README.md scripts
rtk git commit -m "fix: address final QA issues"
```

If no fixes were needed, do not create an empty commit.

## Self-Review

Spec coverage:

- Native macOS implementation: covered by Tasks 1, 9, 10, 11.
- Real notch priority and simulated notch fallback: covered by Tasks 2, 9, 10.
- Click open, outside click close, hover 2 seconds, focus-out close: covered by Tasks 3 and 10.
- CPU, memory, network telemetry: covered by Tasks 4 and 6.
- MAGI three-window model and Central Dogma judgement: covered by Tasks 5 and 8.
- NERV/MAGI command-console visual direction: covered by Task 8.
- Localized telemetry degradation: covered by Tasks 5 and 6.
- Settings defaults: covered by Task 7.
- Tests and QA: covered across Tasks 2-7 and 12.

Placeholder scan:

- No placeholder markers or unnamed implementation gaps are intentionally present.
- The only conditional instruction is Task 12 QA fix handling, which is bounded to concrete failures discovered by verification.

Type consistency:

- `SystemSnapshot`, `CPUSample`, `MemorySample`, `NetworkRate`, `MagiDecisionState`, and `NotchInteractionStateMachine` names are introduced before later tasks consume them.
- SwiftUI views consume `NotchViewModel.magiState` and decision types defined in earlier tasks.
- AppKit window code consumes `NotchGeometry` and state machine events defined in earlier tasks.
