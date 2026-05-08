import XCTest
@testable import NervNotchProApp

final class SynchronizationRateViewTests: XCTestCase {
    func testSynchronizationRateLayoutMatchesLeftAuxiliaryFrame() {
        let metrics = MagiConsoleLayoutMetrics()
        let layout = SynchronizationRateLayout(containerSize: CGSize(
            width: metrics.sideAuxiliaryFrameStrokeWidth,
            height: metrics.triadOuterFrameHeight
        ))

        XCTAssertEqual(SynchronizationRateLayout.rateText(swapUsageRatio: 0.42), "42%")
        XCTAssertEqual(layout.titleText, "VIRTUAL MEM / SWAP 使用率")
        XCTAssertEqual(layout.batteryTitleText, "BATTERY / 电池")
        XCTAssertEqual(layout.rateLabelFontName, "SourceHanSerifCN-Bold")
        XCTAssertEqual(layout.rateValueFontName, "DS-Digital-Bold")
        XCTAssertEqual(layout.contentInset, 7)
        XCTAssertGreaterThan(layout.titleTopPadding, metrics.triadWarningStripTopInset + metrics.triadWarningStripHeight)
        XCTAssertEqual(layout.waveCount, 13)
        XCTAssertLessThan(layout.waveTopY, layout.rateBaselineY)
        XCTAssertLessThan(layout.rateBaselineY, layout.bottomTickY)
        XCTAssertEqual(layout.upperPanelHeight, layout.containerSize.height * 4 / 5, accuracy: 0.001)
        XCTAssertEqual(layout.batteryPanelTopExtension, 4)
        XCTAssertEqual(layout.batteryPanelTopY, layout.containerSize.height * 4 / 5 - layout.batteryPanelTopExtension, accuracy: 0.001)
        XCTAssertEqual(layout.batteryPanelHeight, layout.containerSize.height / 5 + layout.batteryPanelTopExtension, accuracy: 0.001)
        XCTAssertLessThan(layout.bottomTickY, layout.batteryPanelTopY)
        XCTAssertGreaterThan(layout.topGuideY, layout.titleTopPadding + 13)
        XCTAssertLessThan(layout.waveRenderHeight, layout.upperPanelHeight)
        XCTAssertLessThanOrEqual(layout.waveMaskBottomY, layout.waveRenderHeight)
        XCTAssertEqual(layout.batteryContentHeight, layout.batteryPanelHeight, accuracy: 0.001)
        XCTAssertEqual(layout.batteryContentVerticalOffset, 3)
        XCTAssertEqual(layout.batteryTitleValueSpacing, 10)
        XCTAssertEqual(layout.batteryTitleAlignmentName, "center")
        XCTAssertEqual(layout.batterySeparatorY, layout.batteryPanelTopY, accuracy: 0.001)
        XCTAssertEqual(
            layout.batteryContentCenterY,
            layout.batteryPanelTopY + layout.batteryPanelHeight / 2 + layout.batteryContentVerticalOffset,
            accuracy: 0.001
        )
        XCTAssertGreaterThan(layout.batteryValueFontSize, 18)
        XCTAssertLessThan(layout.batteryHorizontalInset, layout.contentInset)
    }

    func testSynchronizationRateUsesSwapUsageRatio() {
        XCTAssertEqual(SynchronizationRateLayout.rateText(swapUsageRatio: 0.25), "25%")
        XCTAssertEqual(SynchronizationRateLayout.rateText(swapUsageRatio: 0.429), "42.9%")
        XCTAssertEqual(SynchronizationRateLayout.rateText(swapUsageRatio: 1.2), "100%")
        XCTAssertEqual(SynchronizationRateLayout.rateText(swapUsageRatio: nil), "--")
    }

    func testBatteryIconUsesRedSegmentFillFromBatteryPercentage() {
        XCTAssertEqual(BatteryReserveIconLayout(chargeText: "0%").filledSegmentCount, 0)
        XCTAssertEqual(BatteryReserveIconLayout(chargeText: "18%").filledSegmentCount, 2)
        XCTAssertEqual(BatteryReserveIconLayout(chargeText: "71%").filledSegmentCount, 6)
        XCTAssertEqual(BatteryReserveIconLayout(chargeText: "100%").filledSegmentCount, 8)
        XCTAssertEqual(BatteryReserveIconLayout(chargeText: "--").filledSegmentCount, 0)

        let layout = BatteryReserveIconLayout(chargeText: "71%")
        XCTAssertEqual(layout.segmentCount, 8)
        XCTAssertEqual(layout.strokeColorName, "NervStyle.red")
        XCTAssertEqual(layout.fillColorName, "NervStyle.red")
        XCTAssertEqual(layout.iconWidth, 48)
        XCTAssertEqual(layout.iconHeight, 19)
    }

    func testSynchronizationRatePhaseAdvancesHorizontally() {
        let layout = SynchronizationRateLayout(containerSize: CGSize(width: 56, height: 308))

        XCTAssertEqual(layout.phase(at: 0), 0, accuracy: 0.0001)
        XCTAssertEqual(layout.phase(at: 1), layout.phaseVelocity, accuracy: 0.0001)
        XCTAssertEqual(layout.phase(at: 2), layout.phaseVelocity * 2, accuracy: 0.0001)
    }
}
