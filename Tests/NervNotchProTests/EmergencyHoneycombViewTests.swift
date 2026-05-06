import XCTest
@testable import NervNotchProApp

final class EmergencyHoneycombViewTests: XCTestCase {
    func testEmergencyHoneycombUsesContiguousHexGridInsideRightAuxiliaryFrame() {
        let metrics = MagiConsoleLayoutMetrics()
        let layout = EmergencyHoneycombLayout(containerSize: CGSize(
            width: metrics.rightAuxiliaryFrameStrokeWidth - 2,
            height: metrics.triadOuterFrameHeight - 2
        ))
        let legacyFullGridSideLength = min(
            layout.containerSize.width / 5,
            (layout.containerSize.height - layout.topPadding - layout.bottomPadding) / (sqrt(3) * 8)
        )

        XCTAssertEqual(layout.titleText, "EMERGENCY")
        XCTAssertEqual(layout.primaryCellLabel, "454:32")
        XCTAssertEqual(Set(layout.cells.map(\.column)).count, 3)
        XCTAssertEqual(layout.cells.count, 19)
        XCTAssertFalse(layout.cells.contains { $0.column == 0 && $0.row == 0 })
        XCTAssertFalse(layout.cells.contains { $0.column == 2 && $0.row == 6 })
        XCTAssertGreaterThan(layout.topPadding, metrics.triadWarningStripTopInset + metrics.triadWarningStripHeight)
        XCTAssertGreaterThan(layout.cells[0].sideLength, legacyFullGridSideLength)
        XCTAssertGreaterThan(layout.connectedBorderLineWidth, layout.cellDividerLineWidth)
        XCTAssertGreaterThanOrEqual(layout.connectedBorderLineWidth, 3)

        for cell in layout.cells {
            XCTAssertGreaterThanOrEqual(cell.frame.minX, 0)
            XCTAssertLessThanOrEqual(cell.frame.maxX, layout.containerSize.width)
            XCTAssertGreaterThanOrEqual(cell.frame.minY, layout.topPadding)
            XCTAssertLessThanOrEqual(cell.frame.maxY, layout.containerSize.height)
        }

        XCTAssertGreaterThanOrEqual(layout.contiguousNeighborPairCount, 24)
        XCTAssertLessThanOrEqual(layout.maximumContiguousNeighborError, 0.001)
    }
}
