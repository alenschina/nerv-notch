import XCTest
@testable import NervNotchProApp

final class SynchronizationRateViewTests: XCTestCase {
    func testSynchronizationRateLayoutMatchesLeftAuxiliaryFrame() {
        let metrics = MagiConsoleLayoutMetrics()
        let layout = SynchronizationRateLayout(containerSize: CGSize(
            width: metrics.sideAuxiliaryFrameStrokeWidth,
            height: metrics.triadOuterFrameHeight
        ))

        XCTAssertEqual(SynchronizationRateLayout.rateText(cpuLoadText: "42%"), "58%")
        XCTAssertEqual(layout.titleText, "SYNCHRONIZATION RATE / 同步率")
        XCTAssertEqual(layout.rateLabelFontName, "SourceHanSerifCN-Bold")
        XCTAssertEqual(layout.rateValueFontName, "DS-Digital-Bold")
        XCTAssertEqual(layout.contentInset, 7)
        XCTAssertGreaterThan(layout.titleTopPadding, metrics.triadWarningStripTopInset + metrics.triadWarningStripHeight)
        XCTAssertEqual(layout.waveCount, 13)
        XCTAssertLessThan(layout.waveTopY, layout.rateBaselineY)
        XCTAssertLessThan(layout.rateBaselineY, layout.bottomTickY)
    }

    func testSynchronizationRateUsesOneHundredMinusCPULoad() {
        XCTAssertEqual(SynchronizationRateLayout.rateText(cpuLoadText: "25%"), "75%")
        XCTAssertEqual(SynchronizationRateLayout.rateText(cpuLoadText: "42.9%"), "57.1%")
        XCTAssertEqual(SynchronizationRateLayout.rateText(cpuLoadText: "100%"), "0%")
        XCTAssertEqual(SynchronizationRateLayout.rateText(cpuLoadText: "--"), "--")
    }

    func testSynchronizationRatePhaseAdvancesHorizontally() {
        let layout = SynchronizationRateLayout(containerSize: CGSize(width: 56, height: 308))

        XCTAssertEqual(layout.phase(at: 0), 0, accuracy: 0.0001)
        XCTAssertEqual(layout.phase(at: 1), layout.phaseVelocity, accuracy: 0.0001)
        XCTAssertEqual(layout.phase(at: 2), layout.phaseVelocity * 2, accuracy: 0.0001)
    }
}
