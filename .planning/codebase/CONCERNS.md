# Codebase Concerns

**Analysis Date:** 2026-05-07

## Tech Debt

**[MagiTriadConsoleView] Monolithic UI file:**
- Issue: `Sources/NervNotchProApp/UI/MagiTriadConsoleView.swift` is 1665 lines containing approximately 40 type declarations (structs, views, shapes, layouts, and layout metric computations) in a single compilation unit. No separation between layout math, view composition, and primitive shapes.
- Files: `Sources/NervNotchProApp/UI/MagiTriadConsoleView.swift`
- Impact: Any change to layout metrics triggers a full recompile of the entire console. Navigation and reasoning about individual components is difficult. Code review burden is high — a 2-line layout tweak requires diffing a 1600+ line file.
- Fix approach: Extract `MagiConsoleLayoutMetrics`, `SynchronizationRateLayout`, and `EmergencyHoneycombLayout` into separate files under `Sources/NervNotchProApp/UI/Layout/`. Extract shape primitives (`MagiUnitShape`, `MagiHubShape`, `MagiConnectorShape`, `EmergencyHoneycombHexagon`, `Triangle`, `MagiWarningStrip`) into `Sources/NervNotchProApp/UI/Shapes/`. Keep the top-level `MagiTriadConsoleView` as a thin composition layer only.

**[AppSettings] Settings are ephemeral with no persistence:**
- Issue: `AppSettings` (`Sources/NervNotchProApp/Settings/AppSettings.swift`) is a plain struct with hardcoded defaults. No `UserDefaults`, property list, or any other persistence mechanism exists.
- Files: `Sources/NervNotchProApp/Settings/AppSettings.swift`
- Impact: Every app restart resets to factory defaults. Users cannot retain custom hover delays, close grace periods, or sampling intervals between sessions.
- Fix approach: Add `Codable` conformance to `AppSettings`, load from `UserDefaults` on init, and write back on `didSet` for each property. Provide a reset-to-defaults path.

**[AppSettings] Unused `fanModeEnabled` field:**
- Issue: `AppSettings.fanModeEnabled` is declared but never read anywhere in the codebase.
- Files: `Sources/NervNotchProApp/Settings/AppSettings.swift`
- Impact: Dead code that suggests an incomplete feature. Confuses maintainers.
- Fix approach: Either implement fan mode or remove the field.

**[Fonts] Hardcoded custom fonts not bundled with the app:**
- Issue: Four custom font families are referenced by name but none are bundled as app resources: `Share Tech Mono`, `Helvetica Neue Condensed Bold`, `DS-Digital-Bold`, `SourceHanSerifCN-Bold`.
- Files: `Sources/NervNotchProApp/UI/MagiTriadConsoleView.swift` (lines 4, 7, 9, 728, 729), `Sources/NervNotchProApp/UI/NervConsoleView.swift` (line 12)
- Impact: If a user does not have these fonts installed system-wide, SwiftUI silently falls back to the system default font, breaking the NERV command-console aesthetic. `Helvetica Neue Condensed Bold` is included in macOS but the others (`Share Tech Mono`, `DS-Digital-Bold`, `SourceHanSerifCN-Bold`) are third-party fonts that most users will not have.
- Fix approach: Bundle the `.ttf`/`.otf` files in `Sources/NervNotchProApp/Resources/Fonts/`, register them in `Info.plist` under `ATSApplicationFontsPath`, and reference them through `Font.custom(_:size:)` (which is already done — only the bundling is missing).

**[NotchGeometry] Unexplained magic numbers:**
- Issue: `NSScreen+NotchSize.swift` line 17 adds an unexplained `+4` to the computed notch width. `NotchGeometry.simulatedNotchSize` hardcodes `CGSize(width: 224, height: 36)` with no reference to real device measurements.
- Files: `Sources/NervNotchProApp/Notch/NSScreen+NotchSize.swift` (line 17), `Sources/NervNotchProApp/Notch/NotchGeometry.swift` (line 5)
- Impact: Future maintainers cannot determine whether the `+4` is an intentional correction for menu bar padding or a leftover debug offset. The simulated notch size may not match any real device.
- Fix approach: Document the `+4` with a comment explaining it accounts for the 2px gap on each side between the menu bar auxiliary areas and the physical notch. Add a comment noting which MacBook model the simulated dimensions match.

## Known Bugs

**No known bugs currently logged.** The codebase has no TODO, FIXME, HACK, or XXX markers. However, the following behavioral issues are likely:

**[State machine] No deadlock detection or recovery:**
- Symptoms: If an event arrives out of order (e.g., `mouseExitedPanel` while in `closed` state), the state machine's `default: break` silently ignores it. If the global event monitor desyncs from internal state, the panel could get stuck in an invisible-but-open state.
- Files: `Sources/NervNotchProApp/Notch/NotchInteractionStateMachine.swift` (lines 54-55)
- Trigger: Rapid mouse movements across screen boundaries, Spaces transitions, or Mission Control activation while the panel is transitioning.
- Workaround: Clicking anywhere on screen sends `outsideClicked` which unconditionally resets to `.closed`.

## Security Considerations

**[Accessibility permissions] No permission check or prompt:**
- Risk: `NotchEventMonitor` uses `NSEvent.addGlobalMonitorForEvents` to track global mouse events. This API requires Accessibility (AX) permissions. Without them, global events silently return nil and the app cannot detect outside-clicks or mouse movement over the notch.
- Files: `Sources/NervNotchProApp/Notch/NotchEventMonitor.swift` (line 48)
- Current mitigation: The local event monitor (`addLocalMonitorForEvents`) still works without AX permissions, so notch-clicks and panel-clicks are detected. Only outside-click-to-close and hover-tracking break.
- Recommendations: Add an AX permission check using `AXIsProcessTrusted()` on startup and display an alert guiding users to System Preferences when permission is missing.

**[Code signing] Default ad-hoc signing prevents AX permissions:**
- Risk: `package-app.sh` defaults to `SIGNING_IDENTITY="-"` (ad-hoc signing). macOS does not grant Accessibility permissions to ad-hoc signed apps persistently — permissions reset on each build.
- Files: `scripts/package-app.sh` (line 9)
- Current mitigation: The README documents how to pass a Developer ID signing identity, but this requires an Apple Developer account.
- Recommendations: Add an entitlements plist with `com.apple.security.automation.apple-events` and `com.apple.security.cs.disable-library-validation` for debug builds. Document that persistent AX permissions require a Developer ID certificate.

**[No sandboxing entitlements]:**
- Risk: The app reads low-level system telemetry (CPU ticks via `host_processor_info`, memory via `host_statistics64`, network counters via `sysctl`) and monitors global mouse events. These operations may be restricted under macOS sandboxing.
- Files: `Package.swift` (no entitlements target), `scripts/package-app.sh` (no `--entitlements` flag)
- Current mitigation: The app is not sandboxed (no hardened runtime entitlements), which works for local development but would be rejected from the Mac App Store.
- Recommendations: For App Store distribution, add a `NervNotchPro.entitlements` file with appropriate sandbox exceptions. For direct distribution, add Hardened Runtime entitlements and notarization.

## Performance Bottlenecks

**[Timer] Constant 20Hz tick when idle:**
- Problem: `NotchWindowController` fires a `Timer` every 0.05 seconds (20Hz) exclusively to drive the interaction state machine's `.timerTick` events. This runs continuously even when the panel is closed and the cursor is not near the notch.
- Files: `Sources/NervNotchProApp/Notch/NotchWindowController.swift` (lines 49-53)
- Cause: The timer fires unconditionally. The state machine's `default: break` path means most ticks are no-ops in `closed` and `opened` states — only `.hoverArming` and `.closing` actually need timer events.
- Improvement path: Stop the timer when in `.closed` or `.opened` states. Restart it only when entering `.hoverArming` or `.closing`. Alternatively, use a one-shot `DispatchWorkItem` scheduled for the exact delay needed instead of polling.

**[Rendering] Continuous animation drains GPU:**
- Problem: `SynchronizationRateView` uses `TimelineView(.animation)` which drives continuous frame updates. The view renders 13 sine wave paths, guide lines, tick marks, and scan lines every frame.
- Files: `Sources/NervNotchProApp/UI/MagiTriadConsoleView.swift` (line 775)
- Cause: `TimelineView(.animation)` is designed for constant-speed animations that run every display frame (60fps/120fps on ProMotion). Even when the panel is closed, the collapsed compact island still has `NervConsoleView` alive in the view hierarchy (just with `.opacity(0)` or clipped).
- Improvement path: Use `.everyMinute` or a lower-frequency schedule for the synchronization rate view. Consider using `Canvas` with `timelineView` only updating the phase, not redrawing from scratch each frame. Alternatively, hide the expanded console content entirely (`if isExpanded`) rather than keeping it rendered off-screen.

**[Telemetry] No throttling based on panel visibility:**
- Problem: `AppDelegate.sampleTelemetry()` runs on a 1-second timer regardless of whether the console panel is visible or hidden (closed state).
- Files: `Sources/NervNotchProApp/App/AppDelegate.swift` (lines 32-38)
- Cause: The sampling timer has no awareness of the interaction state.
- Improvement path: Reduce sampling frequency when `interactionState == .closed` (e.g., once every 5 seconds). Resume normal 1-second sampling when the panel opens.

**[Telemetry] `CPUUsageSampler.readTicks()` allocates kernel memory on every call:**
- Problem: Each `host_processor_info` call allocates a kernel buffer that must be deallocated with `vm_deallocate`. This is a round-trip to the kernel on every 1-second sample.
- Files: `Sources/NervNotchProApp/Telemetry/CPUUsageSampler.swift` (lines 54-68)
- Cause: This is inherent to the `host_processor_info` API — there is no way to reuse the buffer.
- Improvement path: This is acceptable for a 1Hz sampling rate. No change needed unless the sampling frequency increases significantly.

## Fragile Areas

**[NotchWindowController] Timer/viewModel lifecycle coupling:**
- Files: `Sources/NervNotchProApp/Notch/NotchWindowController.swift` (lines 10, 49-53)
- Why fragile: The timer captures `[weak viewModel]`. If the view model is deallocated (possible if the window controller is replaced), the timer continues running and calling into a nil view model indefinitely, wasting CPU.
- Safe modification: When modifying view model lifecycle, always validate that the timer is properly invalidated in `deinit` and that the window controller outlives the view model.
- Test coverage: No tests exist for `NotchWindowController`.

**[NotchEventMonitor] Duplicate event monitoring could stack:**
- Files: `Sources/NervNotchProApp/Notch/NotchEventMonitor.swift` (lines 44-55)
- Why fragile: `start()` calls `stop()` first, which is safe, but the class holds both a global and local monitor. If `start()` is called twice concurrently or if an exception occurs between `stop()` and setting new monitors, monitors could leak.
- Safe modification: Wrap monitor setup in a serial queue. Add a `private let monitorQueue = DispatchQueue(label: "notch.monitor")` and dispatch `start()`/`stop()` through it.
- Test coverage: `NotchEventMonitorTests` covers the `NotchPointerRegionTracker` logic only, not the NSEvent monitor lifecycle.

**[NervNotchApplication] No `NSApplicationDelegate` protocol checks at runtime:**
- Files: `Sources/NervNotchProApp/App/NervNotchApplication.swift` (line 9)
- Why fragile: The app delegate is set before `app.run()` is called. If the delegate does not properly conform to `NSApplicationDelegate` (e.g., missing `@MainActor` on callbacks), there will be no compile-time error, but `applicationDidFinishLaunching` may not fire.
- Safe modification: Do not modify the delegate pattern. The current `@MainActor` annotation on the delegate method is correct.
- Test coverage: `ScaffoldTests` only verifies the application wrapper can be instantiated.

**[NotchPanel] Window level collision potential:**
- Files: `Sources/NervNotchProApp/Notch/NotchPanel.swift` (line 21)
- Why fragile: The panel uses `level: .mainMenu + 3` to float above other windows. If another app or system UI element uses the same window level, the notch panel may render behind it or block interactions.
- Safe modification: Add a small random offset or use a named `NSWindow.Level` constant to document intent. Ensure `ignoresMouseEvents` is set correctly per interaction state.
- Test coverage: No tests cover window level behavior.

## Scaling Limits

**[Single-screen architecture]:**
- Current capacity: One window on one screen (the main screen or first screen).
- Limit: Multi-monitor setups (e.g., MacBook with notched display + external monitor) are not handled. The app only creates one `NotchWindowController` for the first available screen.
- Scaling path: Create a `NotchWindowController` per screen in a `[NSScreen: NotchWindowController]` dictionary. Respond to `NSApplication.didChangeScreenParametersNotification` to add/remove controllers as screens connect/disconnect.

**[Hardcoded layout dimensions]:**
- Current capacity: All layout values in `MagiConsoleLayoutMetrics` are pixel-absolute (e.g., `triadWidth: CGFloat = 368`, `topUnitSize = CGSize(width: 149, height: 108)`).
- Limit: On non-Retina displays or displays with different scaling factors, the layout may appear disproportionately large or small relative to the notch size. The expanded panel width is hardcoded to 820px regardless of screen width.
- Scaling path: Express layout dimensions as ratios of `effectiveNotchSize` or `screenFrame.width` instead of absolute pixels. The compact island already uses this approach, but the expanded console does not.

## Dependencies at Risk

**[Zero external dependencies]:**
- Risk: The project has zero third-party package dependencies (empty `Package.swift` dependencies). While this eliminates supply-chain risk, it means all platform integration is hand-rolled against low-level Darwin APIs (`host_processor_info`, `host_statistics64`, `sysctl`, `getifaddrs`).
- Impact: Every macOS major version update requires re-validating these low-level API calls. The `NET_RT_IFLIST2` sysctl and `if_msghdr2` structure are particularly susceptible to breaking changes in new macOS releases.
- Migration plan: Monitor the WWDC release notes for each macOS version. Wrap low-level Darwin calls in version-checked adapters. Consider adopting `MetricKit` or `IOKit` frameworks when available for telemetry.

## Missing Critical Features

**[Settings UI]:**
- Problem: There is no user interface to configure any app behavior. Hover delay, close grace period, sampling interval, and simulated notch toggle are all compile-time constants.
- Blocks: Users cannot customize the app. Developers testing different values must modify source code and rebuild.
- Priority: Medium — currently acceptable for a prototype/fan project.

**[Quit mechanism]:**
- Problem: The app uses `LSUIElement = true` (no dock icon) and has no status bar menu. The only way to quit is Activity Monitor or `killall`.
- Blocks: Normal users cannot easily quit the app.
- Priority: High — basic usability requirement. Add an `NSStatusBar` item with a Quit option.

**[Error reporting / logging]:**
- Problem: Telemetry samplers return `nil` on any failure with no logging or error propagation. Users have no way to know if CPU/memory/network monitoring has failed.
- Blocks: Debugging telemetry issues requires attaching a debugger. Users see `--` values in the MAGI console with no explanation.
- Priority: Medium — add `os_log` or `NSLog` entries for sampler failures.

**[Screen change handling]:**
- Problem: If a user unplugs an external display or changes display arrangement, the notch panel position is not updated. The `NotchWindowController` is created once in `applicationDidFinishLaunching` and never re-positioned.
- Blocks: The panel renders at the wrong position after display changes.
- Priority: Medium — observe `NSApplication.didChangeScreenParametersNotification` and recompute geometry/position.

## Test Coverage Gaps

**[No NotchWindowController tests]:**
- What's not tested: Window creation, frame calculation, timer lifecycle, Combine subscription setup, event monitor wiring.
- Files: `Sources/NervNotchProApp/Notch/NotchWindowController.swift`
- Risk: The most complex glue code in the app has zero automated test coverage.
- Priority: High

**[CPUUsageSampler / NetworkUsageSampler untested]:**
- What's not tested: CPU tick reading from `host_processor_info`, network counter reading from `sysctl`, counter wrap-around handling, interface name filtering.
- Files: `Sources/NervNotchProApp/Telemetry/CPUUsageSampler.swift`, `Sources/NervNotchProApp/Telemetry/NetworkUsageSampler.swift`
- Risk: Regressions in telemetry parsing would not be caught. The only telemetry smoke test covers `MemoryUsageSampler` and sample date verification.
- Priority: Medium

**[MagiDecisionEngine] Only 3 test cases:**
- What's not tested: High-load memory, critical memory, network-critical, network-idle, network-unavailable, high-load judgement, partial-sync with multiple unavailable panels, boundary values (exactly 0.90, exactly 0.70).
- Files: `Sources/NervNotchProApp/Magi/MagiDecisionEngine.swift`
- Risk: Boundary condition changes in decision thresholds could silently change behavior.
- Priority: Low

**[NSScreen+NotchSize untested]:**
- What's not tested: Physical notch detection logic, fallback for non-notch Macs, menu bar width calculation.
- Files: `Sources/NervNotchProApp/Notch/NSScreen+NotchSize.swift`
- Risk: The notch detection heuristic may break on future MacBook models or macOS versions.
- Priority: Medium

**[Brittle chrome tests use source-code string matching]:**
- What's not tested: `NotchIslandChromeTests` (429 lines) reads source files from disk and uses `String.contains(_:)` to verify implementation details (e.g., "does compact island layout use ZStack?"). This tests what the code looks like, not what it does.
- Files: `Tests/NervNotchProTests/NotchIslandChromeTests.swift` (lines 53-101)
- Risk: Any refactoring that preserves identical behavior (e.g., replacing `ZStack` with a custom container) breaks these tests. They provide false confidence — a passing test only proves the source file hasn't been renamed.
- Priority: Medium — refactor to behavioral tests that verify layout output (e.g., computed frame sizes, hit-test regions) rather than source code structure.

**[No integration tests]:**
- What's not tested: The full pipeline from `TelemetrySampler.sample()` through `MagiDecisionEngine.evaluate()` to `NotchViewModel.apply()` and UI rendering.
- Risk: Integration bugs at layer boundaries go undetected.
- Priority: Low

**[No UI performance tests]:**
- What's not tested: Frame rates during expanded console animation, CPU overhead of the 20Hz timer, memory footprint of `TimelineView(.animation)`.
- Risk: Performance regressions from seemingly minor changes (e.g., adding a shadow to a frequently-updated view) are invisible.
- Priority: Low

---

*Concerns audit: 2026-05-07*
