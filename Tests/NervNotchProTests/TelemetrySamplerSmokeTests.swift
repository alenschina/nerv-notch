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
