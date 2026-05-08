# Launch Intro Animation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a first-run full-screen NERV initialization animation that can be skipped and then hands off to the existing notch interface.

**Architecture:** Add a small launch-intro subsystem beside the app bootstrap code: a `LaunchIntroStore` for `UserDefaults`, a `LaunchIntroWindowController` for the temporary full-screen AppKit window, and a `LaunchIntroView` for SwiftUI animation. `AppDelegate` will split startup into intro decision and main-interface creation so telemetry and notch UI start only after the intro completes.

**Tech Stack:** Swift 5.9, AppKit, SwiftUI, XCTest, Swift Package Manager.

---

## File Structure

- Create `Sources/NervNotchProApp/App/LaunchIntroStore.swift`: stores and marks whether the first-run launch intro completed.
- Create `Sources/NervNotchProApp/App/LaunchIntroWindowController.swift`: owns the temporary full-screen intro window and skip handling.
- Create `Sources/NervNotchProApp/UI/LaunchIntroView.swift`: renders the NERV boot text, scanlines, logo/classified phase, and completion callback.
- Modify `Sources/NervNotchProApp/App/AppDelegate.swift`: inject `LaunchIntroStore`, split `startMainInterface()`, show intro first on first launch.
- Create `Tests/NervNotchProTests/LaunchIntroStoreTests.swift`: TDD coverage for default state and completion persistence.
- Create `Tests/NervNotchProTests/LaunchIntroWindowControllerTests.swift`: test window construction and skip callback behavior.

## Task 1: Persist First-Run Intro State

**Files:**
- Create: `Sources/NervNotchProApp/App/LaunchIntroStore.swift`
- Test: `Tests/NervNotchProTests/LaunchIntroStoreTests.swift`

- [ ] **Step 1: Write the failing store tests**

```swift
import XCTest
@testable import NervNotchProApp

final class LaunchIntroStoreTests: XCTestCase {
    func testIntroDefaultsToNotCompleted() {
        let defaults = UserDefaults(suiteName: "LaunchIntroStoreTests.defaultsToNotCompleted")!
        defaults.removePersistentDomain(forName: "LaunchIntroStoreTests.defaultsToNotCompleted")
        let store = LaunchIntroStore(userDefaults: defaults)

        XCTAssertFalse(store.hasCompletedLaunchIntro)

        defaults.removePersistentDomain(forName: "LaunchIntroStoreTests.defaultsToNotCompleted")
    }

    func testMarkCompletedPersistsIntroCompletion() {
        let suiteName = "LaunchIntroStoreTests.markCompletedPersists"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = LaunchIntroStore(userDefaults: defaults)

        store.markCompleted()

        XCTAssertTrue(store.hasCompletedLaunchIntro)
        XCTAssertTrue(LaunchIntroStore(userDefaults: defaults).hasCompletedLaunchIntro)

        defaults.removePersistentDomain(forName: suiteName)
    }
}
```

- [ ] **Step 2: Run the store tests and verify RED**

Run: `rtk swift test --filter LaunchIntroStoreTests`

Expected: fail to compile because `LaunchIntroStore` does not exist.

- [ ] **Step 3: Add minimal store implementation**

```swift
import Foundation

struct LaunchIntroStore: Equatable, Sendable {
    private static let completedKey = "NervNotch.hasCompletedLaunchIntro"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedLaunchIntro: Bool {
        userDefaults.bool(forKey: Self.completedKey)
    }

    func markCompleted() {
        userDefaults.set(true, forKey: Self.completedKey)
    }
}
```

- [ ] **Step 4: Run the store tests and verify GREEN**

Run: `rtk swift test --filter LaunchIntroStoreTests`

Expected: pass.

## Task 2: Add Intro Window Controller

**Files:**
- Create: `Sources/NervNotchProApp/App/LaunchIntroWindowController.swift`
- Test: `Tests/NervNotchProTests/LaunchIntroWindowControllerTests.swift`

- [ ] **Step 1: Write failing window tests**

```swift
import AppKit
import XCTest
@testable import NervNotchProApp

@MainActor
final class LaunchIntroWindowControllerTests: XCTestCase {
    func testIntroWindowCoversProvidedScreenAndFloatsAboveNotchPanel() {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let controller = LaunchIntroWindowController(screen: screen, onFinish: {})

        let window = controller.makeWindowForTesting()

        XCTAssertEqual(window.frame, screen.frame)
        XCTAssertEqual(window.styleMask.intersection(.titled), [])
        XCTAssertGreaterThan(window.level.rawValue, (NSWindow.Level.mainMenu + 3).rawValue)
        XCTAssertFalse(window.isOpaque)
    }

    func testFinishCallbackIsOnlyCalledOnce() {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        var finishCount = 0
        let controller = LaunchIntroWindowController(screen: screen, onFinish: {
            finishCount += 1
        })

        controller.finishForTesting()
        controller.finishForTesting()

        XCTAssertEqual(finishCount, 1)
    }
}
```

- [ ] **Step 2: Run the window tests and verify RED**

Run: `rtk swift test --filter LaunchIntroWindowControllerTests`

Expected: fail to compile because `LaunchIntroWindowController` does not exist.

- [ ] **Step 3: Add window controller implementation**

Implement a borderless full-screen `NSPanel`, host `LaunchIntroView`, expose `makeWindowForTesting()` and `finishForTesting()`, and make finish idempotent.

- [ ] **Step 4: Run window tests and verify GREEN**

Run: `rtk swift test --filter LaunchIntroWindowControllerTests`

Expected: pass.

## Task 3: Add SwiftUI Launch Intro View

**Files:**
- Create: `Sources/NervNotchProApp/UI/LaunchIntroView.swift`
- Modify: `Sources/NervNotchProApp/App/LaunchIntroWindowController.swift`

- [ ] **Step 1: Add `LaunchIntroView` with completion callback**

Create a SwiftUI view with black background, scanlines, boot text typing phase, logo/classified phase, click-to-skip, and a guarded completion callback.

- [ ] **Step 2: Wire `LaunchIntroWindowController` content**

Set the window content to `NSHostingController(rootView: LaunchIntroView(onFinish: finish))`.

- [ ] **Step 3: Build**

Run: `rtk swift build`

Expected: build succeeds.

## Task 4: Gate App Startup Behind First-Run Intro

**Files:**
- Modify: `Sources/NervNotchProApp/App/AppDelegate.swift`

- [ ] **Step 1: Split startup flow**

Add `launchIntroStore`, `launchIntroWindowController`, `startMainInterface()`, and `completeLaunchIntro()`.

- [ ] **Step 2: Use intro on first launch only**

In `start()`, register fonts, check `launchIntroStore.hasCompletedLaunchIntro`, and either call `startMainInterface()` or show `LaunchIntroWindowController`.

- [ ] **Step 3: Ensure timer starts only in main interface**

Keep telemetry timer creation inside `startMainInterface()`.

- [ ] **Step 4: Run focused and full tests**

Run: `rtk swift test --filter LaunchIntroStoreTests`

Run: `rtk swift test --filter LaunchIntroWindowControllerTests`

Run: `rtk swift test`

Expected: all pass.

## Task 5: Manual Runtime Verification

**Files:**
- No new files.

- [ ] **Step 1: Build the app**

Run: `rtk swift build`

Expected: build succeeds.

- [ ] **Step 2: Run packaged or dev app with fresh defaults**

Use a fresh user-defaults state during local manual verification, then start the app and confirm the intro appears before the notch panel.

- [ ] **Step 3: Verify skip**

Press `Esc` or click the intro window; the intro should close and the notch panel should appear.

## Self-Review

- Spec coverage: first-run storage, full-screen window, skip handling, delayed notch startup, and testing are covered.
- Placeholder scan: no open placeholders remain; Task 3 and Task 4 intentionally describe implementation boundaries because UI code is straightforward and must follow local SwiftUI patterns.
- Type consistency: `LaunchIntroStore`, `LaunchIntroWindowController`, and `LaunchIntroView` names match across tasks.
