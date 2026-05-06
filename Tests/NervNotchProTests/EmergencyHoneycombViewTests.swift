import XCTest
@testable import NervNotchProApp

final class EmergencyHoneycombViewTests: XCTestCase {
    func testEmergencyHoneycombUsesContiguousHexGridInsideRightAuxiliaryFrame() {
        let metrics = MagiConsoleLayoutMetrics()
        let layout = EmergencyHoneycombLayout(containerSize: CGSize(
            width: metrics.rightAuxiliaryFrameStrokeWidth - 2,
            height: metrics.triadOuterFrameHeight - 2
        ))
        XCTAssertEqual(layout.titleText, "EMERGENCY｜警告")
        XCTAssertEqual(layout.contentInset, SynchronizationRateLayout(containerSize: .zero).contentInset)
        XCTAssertEqual(layout.titleTopPadding, SynchronizationRateLayout(containerSize: .zero).titleTopPadding)
        XCTAssertEqual(layout.titleAlignment, .center)
        XCTAssertEqual(layout.primaryCellLabel, "454:32")
        XCTAssertEqual(Set(layout.cells.map(\.column)).count, 3)
        XCTAssertEqual(layout.cells.count, 16)
        XCTAssertFalse(layout.cells.contains { $0.column == 0 && $0.row == 0 })
        XCTAssertFalse(layout.cells.contains { $0.column == 1 && $0.row == 0 })
        XCTAssertFalse(layout.cells.contains { $0.column == 0 && $0.row == 1 })
        XCTAssertFalse(layout.cells.contains { $0.column == 2 && $0.row == 0 })
        XCTAssertFalse(layout.cells.contains { $0.column == 2 && $0.row == 6 })
        XCTAssertGreaterThan(layout.topPadding, metrics.triadWarningStripTopInset + metrics.triadWarningStripHeight)
        XCTAssertGreaterThanOrEqual(layout.topPadding, layout.titleTopPadding + 16)
        XCTAssertGreaterThan(layout.connectedBorderLineWidth, layout.cellDividerLineWidth)
        XCTAssertGreaterThanOrEqual(layout.connectedBorderLineWidth, 3)

        for cell in layout.cells {
            XCTAssertGreaterThanOrEqual(cell.frame.minX, 0)
            XCTAssertLessThanOrEqual(cell.frame.maxX, layout.containerSize.width)
            XCTAssertGreaterThanOrEqual(cell.frame.minY, layout.topPadding)
            XCTAssertLessThanOrEqual(cell.frame.maxY, layout.containerSize.height)
        }

        XCTAssertGreaterThanOrEqual(layout.contiguousNeighborPairCount, 18)
        XCTAssertLessThanOrEqual(layout.maximumContiguousNeighborError, 0.001)
    }
}
