import XCTest
@testable import NervNotchProApp

final class EmergencyHoneycombViewTests: XCTestCase {
    func testEmergencyHoneycombUsesContiguousHexGridInsideRightAuxiliaryFrame() {
        let metrics = MagiConsoleLayoutMetrics()
        let layout = EmergencyHoneycombLayout(containerSize: CGSize(
            width: metrics.rightAuxiliaryFrameStrokeWidth - 2,
            height: metrics.triadOuterFrameHeight - 2
        ))
        XCTAssertEqual(layout.titleText, "DISK SPACE / 磁盤容量")
        XCTAssertEqual(layout.ioTitleText, "DISK I/O")
        XCTAssertEqual(layout.ioRateText, "R --  W --")
        XCTAssertEqual(layout.contentInset, SynchronizationRateLayout(containerSize: .zero).contentInset)
        XCTAssertEqual(layout.titleTopPadding, SynchronizationRateLayout(containerSize: .zero).titleTopPadding)
        XCTAssertEqual(layout.titleAlignment, .center)
        XCTAssertEqual(layout.honeycombScale, 0.94)
        XCTAssertTrue(layout.cells.allSatisfy { $0.label == "DISK" })
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

    func testDiskHoneycombFillsCellsFromBottomToTopByUsageRatio() {
        let metrics = MagiConsoleLayoutMetrics()
        let layout = EmergencyHoneycombLayout(
            containerSize: CGSize(
                width: metrics.rightAuxiliaryFrameStrokeWidth - 2,
                height: metrics.triadOuterFrameHeight - 2
            ),
            diskUsageRatio: 0.5,
            diskIORateText: "R 512 KB/s  W 128 KB/s"
        )

        XCTAssertEqual(layout.titleText, "DISK SPACE / 磁盤容量")
        XCTAssertEqual(layout.ioRateText, "R 512 KB/s  W 128 KB/s")
        XCTAssertEqual(layout.filledCells.count, 8)
        XCTAssertEqual(layout.emptyCells.count, 8)

        let highestFilledCellY = layout.filledCells.map(\.center.y).min() ?? 0
        let lowestEmptyCellY = layout.emptyCells.map(\.center.y).max() ?? 0
        XCTAssertGreaterThanOrEqual(highestFilledCellY, lowestEmptyCellY)
    }
}
