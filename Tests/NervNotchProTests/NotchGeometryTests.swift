import CoreGraphics
import XCTest
@testable import NervNotchProApp

final class NotchGeometryTests: XCTestCase {
    func testPhysicalNotchScreenRectIsCenteredAtTopOfScreen() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
            notchSize: CGSize(width: 210, height: 32),
            windowHeight: 460,
            usesSimulatedNotch: false
        )

        XCTAssertEqual(geometry.notchScreenRect.origin.x, 651)
        XCTAssertEqual(geometry.notchScreenRect.origin.y, 950)
        XCTAssertEqual(geometry.notchScreenRect.width, 210)
        XCTAssertEqual(geometry.notchScreenRect.height, 32)
    }

    func testSimulatedNotchUsesFallbackSize() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 0, y: 0, width: 1440, height: 900),
            notchSize: .zero,
            windowHeight: 460,
            usesSimulatedNotch: true
        )

        XCTAssertEqual(geometry.notchScreenRect.origin.x, 608)
        XCTAssertEqual(geometry.notchScreenRect.origin.y, 864)
        XCTAssertEqual(geometry.notchScreenRect.width, 224)
        XCTAssertEqual(geometry.notchScreenRect.height, 36)
    }

    func testPhysicalNotchHeightIsNotClampedToFallbackHeight() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
            notchSize: CGSize(width: 210, height: 28),
            windowHeight: 460,
            usesSimulatedNotch: false
        )

        XCTAssertEqual(geometry.effectiveNotchSize.height, 28)
        XCTAssertEqual(geometry.notchScreenRect.height, 28)
    }

    func testOpenedPanelIsCenteredUnderTopEdge() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 100, y: 50, width: 1512, height: 982),
            notchSize: CGSize(width: 210, height: 32),
            windowHeight: 460,
            usesSimulatedNotch: false
        )

        let metrics = MagiConsoleLayoutMetrics()
        let expectedHeight = metrics.consoleContentTopPadding
        + metrics.triadOuterFrameHeight
        + metrics.consoleContentBottomPadding

        let panel = geometry.openedPanelScreenRect(size: CGSize(width: 820, height: expectedHeight))

        XCTAssertEqual(panel.origin.x, 446)
        XCTAssertEqual(panel.origin.y, 1032 - expectedHeight)
        XCTAssertEqual(panel.width, 820)
        XCTAssertEqual(panel.height, expectedHeight)
    }

    func testHitTestingUsesPaddingAroundNotch() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
            notchSize: CGSize(width: 210, height: 32),
            windowHeight: 460,
            usesSimulatedNotch: false
        )

        XCTAssertTrue(geometry.isPointInNotch(CGPoint(x: 645, y: 948)))
        XCTAssertFalse(geometry.isPointInNotch(CGPoint(x: 500, y: 948)))
    }

    func testCompactIslandScreenRectIncludesIconSpaceOnBothSides() {
        let geometry = NotchGeometry(
            screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
            notchSize: CGSize(width: 210, height: 32),
            windowHeight: 460,
            usesSimulatedNotch: false
        )

        XCTAssertEqual(geometry.compactIslandScreenRect.origin.x, 619)
        XCTAssertEqual(geometry.compactIslandScreenRect.width, 274)
        XCTAssertEqual(geometry.compactIslandScreenRect.height, 32)
    }
}
