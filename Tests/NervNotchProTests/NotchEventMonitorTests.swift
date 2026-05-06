import XCTest
@testable import NervNotchProApp

final class NotchEventMonitorTests: XCTestCase {
    func testPointerRegionTrackerEmitsMouseExitedNotchWhenLeavingNotch() {
        var tracker = NotchPointerRegionTracker()

        XCTAssertEqual(
            tracker.update(isInNotch: true, isInOpenedPanel: false),
            [.mouseEnteredNotch]
        )

        XCTAssertEqual(
            tracker.update(isInNotch: false, isInOpenedPanel: false),
            [.mouseExitedNotch]
        )
    }

    func testPointerRegionTrackerDoesNotSpamMouseEnteredNotchWhileStayingInNotch() {
        var tracker = NotchPointerRegionTracker()

        XCTAssertEqual(tracker.update(isInNotch: true, isInOpenedPanel: false), [.mouseEnteredNotch])
        XCTAssertEqual(tracker.update(isInNotch: true, isInOpenedPanel: false), [])
        XCTAssertEqual(tracker.update(isInNotch: true, isInOpenedPanel: false), [])
    }

    func testPointerRegionTrackerEmitsPanelEnterAndExit() {
        var tracker = NotchPointerRegionTracker()

        XCTAssertEqual(tracker.update(isInNotch: false, isInOpenedPanel: true), [.mouseEnteredPanel])
        XCTAssertEqual(tracker.update(isInNotch: false, isInOpenedPanel: false), [.mouseExitedPanel])
    }
}

