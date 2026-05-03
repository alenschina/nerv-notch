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
