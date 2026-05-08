import XCTest
@testable import NervNotchProApp

final class MagiDecisionEngineTests: XCTestCase {
    func testNormalSnapshotProducesSynchronizedJudgement() {
        let snapshot = SystemSnapshot(
            sampledAt: Date(timeIntervalSince1970: 0),
            cpu: CPUSample(usageRatio: 0.25, coreCount: 10, userRatio: 0.15, systemRatio: 0.10, idleRatio: 0.75),
            memory: MemorySample(totalBytes: 1000, usedBytes: 420, availableBytes: 580, compressedBytes: 30),
            network: NetworkRate(downBytesPerSecond: 200_000, upBytesPerSecond: 80_000, activeInterfaceCount: 1),
            disk: DiskSpaceSample(totalBytes: 1000, usedBytes: 450, availableBytes: 550)
        )

        let state = MagiDecisionEngine().evaluate(snapshot)

        XCTAssertEqual(state.cpu.level, .normal)
        XCTAssertEqual(state.memory.level, .normal)
        XCTAssertEqual(state.network.level, .normal)
        XCTAssertEqual(state.diskUsageRatio, 0.45)
        XCTAssertEqual(state.judgement.level, .synchronized)
    }

    func testCriticalCPUProducesEmergencyMode() {
        let snapshot = SystemSnapshot(
            sampledAt: Date(timeIntervalSince1970: 0),
            cpu: CPUSample(usageRatio: 0.94, coreCount: 10, userRatio: 0.70, systemRatio: 0.24, idleRatio: 0.06),
            memory: MemorySample(totalBytes: 1000, usedBytes: 500, availableBytes: 500, compressedBytes: 30),
            network: NetworkRate(downBytesPerSecond: 0, upBytesPerSecond: 0, activeInterfaceCount: 1),
            disk: DiskSpaceSample(totalBytes: 1000, usedBytes: 500, availableBytes: 500)
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
            network: NetworkRate(downBytesPerSecond: 0, upBytesPerSecond: 0, activeInterfaceCount: 0),
            disk: nil
        )

        let state = MagiDecisionEngine().evaluate(snapshot)

        XCTAssertEqual(state.cpu.level, .unavailable)
        XCTAssertEqual(state.judgement.level, .partialSync)
    }
}
