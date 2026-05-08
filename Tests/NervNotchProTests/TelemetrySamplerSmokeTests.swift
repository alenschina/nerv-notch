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

    func testDiskSamplerReportsRootVolumeCapacityWhenAvailable() {
        let sample = DiskSpaceSampler().sample()
        XCTAssertNotNil(sample)
        XCTAssertGreaterThan(sample?.totalBytes ?? 0, 0)
        XCTAssertLessThanOrEqual(sample?.usedBytes ?? 0, sample?.totalBytes ?? 0)
    }

    func testSwapSamplerReportsSystemSwapUsageWhenAvailable() {
        let sample = SwapUsageSampler().sample()
        XCTAssertNotNil(sample)
        XCTAssertGreaterThanOrEqual(sample?.usedBytes ?? 0, 0)
        XCTAssertLessThanOrEqual(sample?.usedBytes ?? 0, sample?.totalBytes ?? 0)
    }

    func testBatterySamplerReportsPercentageWhenBatteryIsAvailable() {
        let sample = BatterySampler().sample()
        if let sample {
            XCTAssertGreaterThanOrEqual(sample.chargeRatio, 0)
            XCTAssertLessThanOrEqual(sample.chargeRatio, 1)
        }
    }
}
