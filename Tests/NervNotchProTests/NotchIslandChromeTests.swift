import XCTest
@testable import NervNotchProApp

final class NotchIslandChromeTests: XCTestCase {
    func testCompactChromeUsesPhysicalNotchLikeCornerInsets() {
        let metrics = NotchIslandChromeMetrics(isExpanded: false)

        XCTAssertEqual(metrics.topCornerRadius, 6)
        XCTAssertEqual(metrics.bottomCornerRadius, 14)
    }

    func testExpandedChromeUsesReferenceCornerInsets() {
        let metrics = NotchIslandChromeMetrics(isExpanded: true)

        XCTAssertEqual(metrics.topCornerRadius, 19)
        XCTAssertEqual(metrics.bottomCornerRadius, 24)
    }

    func testChromeShapeAnimatesCornerRadii() {
        var shape = NotchIslandShape(metrics: NotchIslandChromeMetrics(isExpanded: false))

        shape.animatableData = .init(19, 24)

        XCTAssertEqual(shape.metrics.topCornerRadius, 19)
        XCTAssertEqual(shape.metrics.bottomCornerRadius, 24)
    }

    func testChromeDoesNotDrawOuterBorder() {
        let style = NotchIslandChromeStyle()

        XCTAssertFalse(style.drawsOuterBorder)
    }

    func testChromeDoesNotDrawTopHighlight() {
        let style = NotchIslandChromeStyle()

        XCTAssertFalse(style.drawsTopHighlight)
    }

    func testLayoutUsesPhysicalNotchHeightForCompactIsland() {
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))

        XCTAssertEqual(layout.compactSize.height, 32)
    }

    func testLayoutAddsSquareIconSpaceOnBothSidesOfCompactIsland() {
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))

        XCTAssertEqual(layout.compactSize.width, 274)
    }

    func testLayoutExtendsCompactIslandWidthWhileHovering() {
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))

        XCTAssertEqual(layout.compactSize(isHovering: true).width, 290)
        XCTAssertEqual(layout.compactSize(isHovering: true).height, 32)
    }

    func testLayoutKeepsExpandedConsoleSizeIndependentFromPhysicalNotch() {
        let layout = NotchIslandLayout(compactNotchSize: CGSize(width: 210, height: 32))

        XCTAssertEqual(layout.expandedSize.width, 820)
        XCTAssertEqual(layout.expandedSize.height, 420)
    }

    func testMagiConsoleLayoutKeepsTriadCenteredBetweenSymmetricInfoColumns() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.sideInfoWidth, 154)
        XCTAssertEqual(metrics.triadWidth, 368)
        XCTAssertEqual(metrics.sideInfoWidth, metrics.trailingInfoWidth)
    }

    func testMagiTriadUsesReferenceUnitProportions() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.topUnitSize, CGSize(width: 216, height: 118))
        XCTAssertEqual(metrics.bottomUnitSize, CGSize(width: 136, height: 104))
        XCTAssertEqual(metrics.hubSize, CGSize(width: 120, height: 58))
        XCTAssertEqual(metrics.topUnitCenter, CGPoint(x: 184, y: 60))
        XCTAssertEqual(metrics.hubCenter, CGPoint(x: 184, y: 148))
    }

    func testMagiOuterUnitEnglishLabelsUseShareTechMonoWithReducedSizes() {
        let typography = MagiConsoleTypography()

        XCTAssertEqual(typography.englishFontName, "Share Tech Mono")
        XCTAssertEqual(typography.topUnitLabelSize, 26)
        XCTAssertEqual(typography.bottomUnitLabelSize, 24)
    }

    func testMagiBottomUnitsUseSymmetricInnerCornerBevels() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.bottomInnerCornerBevel, CGSize(width: 29, height: 29))
    }

    func testMagiBottomInnerBevelsShareHubLowerEdgeEndpoints() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubLowerLeftEdgeUpper, metrics.casperInnerBevelUpper)
        XCTAssertEqual(metrics.hubLowerLeftEdgeLower, metrics.casperInnerBevelLower)
        XCTAssertEqual(metrics.hubLowerRightEdgeUpper, metrics.melchiorInnerBevelUpper)
        XCTAssertEqual(metrics.hubLowerRightEdgeLower, metrics.melchiorInnerBevelLower)
    }

    func testMagiSharedSlantSlopeIsFortyFiveDegrees() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.sharedSlantRun.width, metrics.sharedSlantRun.height)
        XCTAssertEqual(metrics.sharedSlantRun, CGSize(width: 29, height: 29))
    }

    func testMagiHubTopEdgeFullyOverlapsBalthasarBottomEdge() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubTopEdgeLength, metrics.topUnitBottomEdgeLength)
        XCTAssertEqual(metrics.hubTopEdgeLength, metrics.hubSize.width - metrics.hubUpperSlantRun.width * 2)
        XCTAssertEqual(metrics.hubUpperLeftEdge, metrics.balthasarBottomLeftEdge)
        XCTAssertEqual(metrics.hubUpperRightEdge, metrics.balthasarBottomRightEdge)
    }

    func testMagiHubUpperSlantsUseLowerSlantsSupplementaryAngle() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubUpperSlantRun, metrics.sharedSlantRun)
        XCTAssertEqual(metrics.hubUpperSlantRun.width, metrics.hubLowerSlantRun.width)
        XCTAssertEqual(metrics.hubUpperSlantRun.height, metrics.hubLowerSlantRun.height)
    }

    func testMagiHubBottomEdgeAdaptsToSharedSlantSlope() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubLowerSlantRun, metrics.sharedSlantRun)
        XCTAssertEqual(metrics.hubBottomEdgeLength, metrics.hubSize.width - metrics.hubLowerSlantRun.width * 2)
    }

    func testMagiTriadSlantsShareTheSameSlope() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.bottomInnerCornerBevel, metrics.sharedSlantRun)
        XCTAssertEqual(
            metrics.topUnitLowerSideRun.width * metrics.sharedSlantRun.height,
            metrics.topUnitLowerSideRun.height * metrics.sharedSlantRun.width,
            accuracy: 0.001
        )
        XCTAssertEqual(
            metrics.hubLowerSlantRun.width * metrics.sharedSlantRun.height,
            metrics.hubLowerSlantRun.height * metrics.sharedSlantRun.width,
            accuracy: 0.001
        )
        XCTAssertEqual(
            metrics.hubUpperSlantRun.width * metrics.sharedSlantRun.height,
            metrics.hubUpperSlantRun.height * metrics.sharedSlantRun.width,
            accuracy: 0.001
        )
    }

    func testBalthasarBottomEdgeAdaptsToSharedSlantSlope() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.topUnitLowerSideRun.height, metrics.topUnitSize.height - metrics.topUnitVerticalSideHeight)
        XCTAssertEqual(
            metrics.topUnitBottomEdgeLength,
            metrics.topUnitSize.width - metrics.topUnitLowerSideRun.width * 2,
            accuracy: 0.001
        )
    }

    func testBalthasarSideEdgesAreVerticalBeforeLowerSlants() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(
            metrics.topUnitVerticalSideHeight,
            metrics.topUnitSize.height - metrics.hubUpperSlantRun.height - (metrics.topUnitSize.width - metrics.hubSize.width) / 2,
            accuracy: 0.001
        )
    }
}
