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
        XCTAssertEqual(metrics.triadWidth, 344)
        XCTAssertEqual(metrics.sideInfoWidth, metrics.trailingInfoWidth)
    }

    func testMagiTriadUsesReferenceUnitProportions() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.topUnitSize, CGSize(width: 216, height: 118))
        XCTAssertEqual(metrics.bottomUnitSize, CGSize(width: 136, height: 104))
        XCTAssertEqual(metrics.hubSize, CGSize(width: 120, height: 58))
        XCTAssertEqual(metrics.topUnitCenter, CGPoint(x: 172, y: 60))
        XCTAssertEqual(metrics.hubCenter, CGPoint(x: 172, y: 145))
    }

    func testMagiBottomUnitsUseSymmetricInnerCornerBevels() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.bottomInnerCornerBevel, CGSize(width: 24, height: 29))
    }

    func testMagiBottomInnerBevelsShareHubLowerEdgeEndpoints() {
        let metrics = MagiConsoleLayoutMetrics()

        XCTAssertEqual(metrics.hubLowerLeftEdgeUpper, metrics.casperInnerBevelUpper)
        XCTAssertEqual(metrics.hubLowerLeftEdgeLower, metrics.casperInnerBevelLower)
        XCTAssertEqual(metrics.hubLowerRightEdgeUpper, metrics.melchiorInnerBevelUpper)
        XCTAssertEqual(metrics.hubLowerRightEdgeLower, metrics.melchiorInnerBevelLower)
    }
}
