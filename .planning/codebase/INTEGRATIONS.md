# External Integrations

**Analysis Date:** 2026-05-07

## Summary

NERV Notch Pro is a fully offline, self-contained macOS application. It has **zero external API integrations**, **zero cloud service dependencies**, **zero network requests**, and **zero database connections**. All data is sourced from local system telemetry via Darwin kernel interfaces.

## System-Level Integrations

These are not "external" in the traditional sense, but rather the operating system interfaces the app consumes locally.

### CPU Telemetry

- **API:** Mach kernel `host_processor_info()` with `PROCESSOR_CPU_LOAD_INFO` flavor
- **Files:** `Sources/NervNotchProApp/Telemetry/CPUUsageSampler.swift`
- **Mechanism:** Reads per-core CPU tick counters (user, system, idle, nice) from the Mach kernel, computes delta between samples to derive usage percentages
- **Output:** `CPUSample` with usage ratio, core count, and breakdown ratios

### Memory Telemetry

- **API:** Mach kernel `host_statistics64()` with `HOST_VM_INFO64` flavor, plus `host_page_size()`
- **Files:** `Sources/NervNotchProApp/Telemetry/MemoryUsageSampler.swift`
- **Mechanism:** Reads VM statistics (free, active, inactive, wired, compressed pages) and combines with `ProcessInfo.processInfo.physicalMemory` for total memory
- **Output:** `MemorySample` with total, used, available, and compressed bytes

### Network Telemetry

- **API:** BSD layer `getifaddrs()` for interface enumeration, `sysctl()` with `NET_RT_IFLIST2` for per-interface byte counters, `if_indextoname()` for interface name resolution
- **Files:** `Sources/NervNotchProApp/Telemetry/NetworkUsageSampler.swift`
- **Mechanism:** Enumerates active, non-loopback network interfaces (matching prefixes: `en`, `bridge`, `utun`, `awdl`), reads cumulative byte counters via routing socket sysctl, computes delta between samples
- **Output:** `NetworkRate` with download/upload bytes per second and active interface count

### Screen and Notch Detection

- **API:** `NSScreen` safe area insets (`safeAreaInsets.top`, `auxiliaryTopLeftArea`, `auxiliaryTopRightArea`)
- **Files:** `Sources/NervNotchProApp/Notch/NSScreen+NotchSize.swift`
- **Mechanism:** Detects physical notch presence by checking if safe area top inset > 0 and menu bar areas exist. Computes notch width from screen frame minus left/right auxiliary areas. Falls back to a simulated notch size (`224x36`) when no physical notch is detected or simulation is forced.
- **Dependency:** Requires a Mac with a notch (MacBook Pro 2021+ or MacBook Air 2022+) for physical notch detection; simulated mode works on any Mac

### Mouse Event Monitoring

- **API:** `NSEvent.addGlobalMonitorForEvents(matching:)` and `NSEvent.addLocalMonitorForEvents(matching:)`
- **Files:** `Sources/NervNotchProApp/Notch/NotchEventMonitor.swift`
- **Mechanism:** Registers both global and local monitors for `.leftMouseDown` and `.mouseMoved` events to track cursor position relative to the notch island and expanded panel. Drives the interaction state machine (hover-to-open, click-to-open, outside-click-to-close).

## Data Storage

**Databases:**
- None. All state is transient and in-memory.

**File Storage:**
- Local filesystem only for reading the app's own bundled resource: `nerv-island-icon.png`
- No file writes, no preferences storage, no UserDefaults usage

**Caching:**
- None. Previous telemetry samples are held in-memory for delta calculation (previous CPU ticks, previous network counters) and discarded after each sample.

## Authentication & Identity

**Auth Provider:**
- Not applicable. The app is a local system monitor utility with no user accounts, no login flow, and no network access.

## Monitoring & Observability

**Error Tracking:**
- None. No crash reporting, error tracking, or telemetry services integrated.
- Errors are handled locally: telemetry samplers return `nil` on failure, decision engine produces `.unavailable` status

**Logs:**
- None configured. The app does not use `os_log`, `NSLog`, or any logging framework. Console output is limited to the packaging script's echo statements.

## CI/CD & Deployment

**Hosting:**
- Local macOS execution only. No deployment platform.

**CI Pipeline:**
- None configured. No GitHub Actions, Jenkins, or other CI workflows.

**Distribution:**
- `scripts/package-app.sh` produces a local `.app` bundle with ad-hoc signature (`codesign --force --deep --sign "-"`)
- For signed distribution, `SIGNING_IDENTITY` env var can be set to a Developer ID identity
- No notarization step included in the packaging script

## Environment Configuration

**Required env vars:**
- None for running the app. The app has zero required environment variables.
- Optional packaging env vars: `PRODUCT_BUNDLE_IDENTIFIER` (default: `dev.local.NervNotchPro`), `VERSION` (default: `0.1.0`), `BUILD_NUMBER` (default: `1`), `SIGNING_IDENTITY` (default: `-` for ad-hoc)

**Secrets location:**
- Not applicable. No secrets, API keys, or credentials are used by this application.

## Webhooks & Callbacks

**Incoming:**
- None. The application does not expose any HTTP endpoints.

**Outgoing:**
- None. The application makes zero outbound network requests.

## Integration Diagram

```
+---------------------------+
|     SwiftUI View Layer    |
|  (MagiTriadConsoleView,   |
|   NervConsoleView, etc.)  |
+------------+--------------+
             | Combine @Published
             v
+------------+--------------+
|    NotchViewModel          |
|  (ObservableObject)        |
+------------+--------------+
             |
    +--------+--------+
    |                  |
    v                  v
+---+-------------+  +--+-------------------+
| MagiDecisionEngine |  | NotchInteractionState |
| (pure logic)       |  | Machine (pure logic)   |
+---+---------------+  +--+--------------------+
    |
    v
+---+------------------+
| SystemSnapshot        |
| (CPU + Mem + Network) |
+---+------------------+
    |
    v
+---+------------------+
| TelemetrySampler      |
+---+------------------+
    |       |       |
    v       v       v
+---+--+ +--+---+ +--+------+
| CPU  | | Mem   | | Network |
| Mach | | Mach  | | BSD     |
| host_| | host_ | | getif-  |
| proc | | stat  | | addrs /  |
| info | | 64    | | sysctl   |
+------+ +------+ +---------+
    |
    v
+---+-------------------+
| Darwin Kernel (macOS) |
+-------------------------+
```

All integrations flow inward from the Darwin kernel. No external network, API, or service boundaries exist.

---

*Integration audit: 2026-05-07*
