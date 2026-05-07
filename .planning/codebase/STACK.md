# Technology Stack

**Analysis Date:** 2026-05-07

## Languages

**Primary:**
- Swift 5.9 - All application code, tests, and Package.swift manifest.

**No secondary languages.** This is a pure Swift project.

## Runtime

**Environment:**
- macOS native application binary
- Minimum deployment target: macOS 13 (Ventura)
- Application type: `.accessory` (LSUIElement) -- no Dock icon; runs as a menu-bar-adjacent agent process

**Package Manager:**
- Swift Package Manager (SPM) 5.9
- Lockfile: `Package.swift` (no `Package.resolved` needed -- zero external dependencies)
- Build command: `swift build`
- Run command: `swift run NervNotchPro`

## Frameworks

**Core:**
- SwiftUI - Primary UI framework for all views. Used in every UI file under `Sources/NervNotchProApp/UI/`.
- AppKit - Window management, application lifecycle, event monitoring, and screen geometry. Used in `main.swift`, `AppDelegate.swift`, `NervNotchApplication.swift`, `NotchWindowController.swift`, `NotchPanel.swift`, `NotchEventMonitor.swift`, and `NSScreen+NotchSize.swift`.
- Combine - Reactive binding between `NotchViewModel` (an `ObservableObject`) and the SwiftUI view layer. Used in `NotchViewModel.swift` and `NotchWindowController.swift`.
- Foundation - Standard data types, timers, date handling, and file I/O. Used pervasively.
- Darwin - Low-level Mach kernel interfaces for CPU, memory, and network telemetry. Used in `CPUUsageSampler.swift`, `MemoryUsageSampler.swift`, and `NetworkUsageSampler.swift`.
- CoreGraphics - Rect/point geometry calculations and screen coordinates. Used in `NotchGeometry.swift` and `NotchEventMonitor.swift`.

**Testing:**
- XCTest - Apple's built-in testing framework
- Test runner: `swift test`
- No additional mocking or assertion libraries

**Build/Dev:**
- Swift toolchain (swiftc, swift build, swift run, swift test) - All compilation and execution
- VS Code with Swift extension - IDE (configured in `.vscode/launch.json`)
- No third-party build tools, linters, or formatters

## Key Dependencies

**Critical:**
- None. The project has zero external package dependencies. All functionality is implemented against first-party Apple frameworks.

**Apple frameworks used (all first-party, no SPM dependencies required):**
- `AppKit` - Window lifecycle, event handling, accessibility panel configuration
- `SwiftUI` - Declarative UI with `View`, `Shape`, `Canvas`, `TimelineView`, animations
- `Combine` - `ObservableObject`, `@Published`, `AnyCancellable`
- `Foundation` - `Timer`, `Date`, `TimeInterval`, `Bundle`, `ProcessInfo`
- `Darwin` - `host_processor_info`, `host_statistics64`, `getifaddrs`, `sysctl`, Mach VM APIs
- `CoreGraphics` - `CGPoint`, `CGRect`, `CGSize`, `CGFloat`

## Configuration

**Environment:**
- No `.env` files or environment variable mechanism present
- App configuration is entirely compile-time via `AppSettings` struct in `Sources/NervNotchProApp/Settings/AppSettings.swift`:
  - `hoverDelay`: 1.0 seconds (how long cursor must hover over notch before opening)
  - `closeGracePeriod`: 0.2 seconds (how long after cursor leaves panel before closing)
  - `samplingInterval`: 1.0 seconds (telemetry poll interval)
  - `usesSimulatedNotch`: false (force simulated notch geometry for non-notch Macs)
  - `targetScreenIdentifier`: nil (specific screen targeting, nil = main screen)
  - `fanModeEnabled`: true (fan-oriented Easter egg flag)

**Build:**
- `Package.swift` - Swift Package Manager manifest with platform constraint `.macOS(.v13)`, single executable product `NervNotchPro`, and one test target
- `.vscode/launch.json` - Debug and Release launch configurations for VS Code

**Packaging:**
- `scripts/package-app.sh` - Shell script that builds release binary, assembles `.app` bundle structure (Info.plist, executable, resources), and codesigns
- Environment variables for packaging: `PRODUCT_BUNDLE_IDENTIFIER`, `VERSION`, `BUILD_NUMBER`, `SIGNING_IDENTITY` (all have defaults)

## Platform Requirements

**Development:**
- macOS 13+ with Xcode or Swift toolchain (Swift 5.9+)
- VS Code with Swift extension (optional; debug configurations provided)

**Production:**
- macOS 13+ (matching minimum deployment target)
- No notarization or distribution mechanism configured (ad-hoc signature by default)
- Output: standalone `.app` bundle in `dist/NervNotchPro.app`

## Custom Fonts

The UI references custom fonts by name. These are expected to be installed on the system or bundled:
- `SourceHanSerifCN-Bold` (expanded header CJK label) - referenced in `NervConsoleView.swift`
- `Share Tech Mono` (English Magi labels) - referenced in `MagiTriadConsoleView.swift` 
- `DS-Digital-Bold` (telemetry metric values) - referenced in `MagiTriadConsoleView.swift`
- `Helvetica Neue Condensed Bold` (unit subtitles) - referenced in `MagiTriadConsoleView.swift`

## Resource Assets

- `Sources/NervNotchProApp/Resources/nerv-island-icon.png` - Compact island NERV icon, loaded at runtime via `Bundle.main` or `Bundle.module`

---

*Stack analysis: 2026-05-07*
