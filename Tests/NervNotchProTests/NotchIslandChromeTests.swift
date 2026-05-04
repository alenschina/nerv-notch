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
        XCTAssertEqual(metrics.triadWidth, 300)
        XCTAssertEqual(metrics.sideInfoWidth, metrics.trailingInfoWidth)
    }
}
