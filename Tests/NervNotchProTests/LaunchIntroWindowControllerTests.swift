import AppKit
import XCTest
@testable import NervNotchProApp

@MainActor
final class LaunchIntroWindowControllerTests: XCTestCase {
    func testIntroWindowCoversProvidedScreenAndFloatsAboveNotchPanel() throws {
        let screen = try XCTUnwrap(NSScreen.main ?? NSScreen.screens.first)
        let controller = LaunchIntroWindowController(screen: screen, onFinish: {})

        let window = controller.makeWindowForTesting()

        XCTAssertEqual(window.frame, screen.frame)
        XCTAssertFalse(window.styleMask.contains(.titled))
        XCTAssertGreaterThan(window.level.rawValue, (NSWindow.Level.mainMenu + 3).rawValue)
        XCTAssertFalse(window.isOpaque)
    }

    func testFinishCallbackIsOnlyCalledOnce() throws {
        let screen = try XCTUnwrap(NSScreen.main ?? NSScreen.screens.first)
        var finishCount = 0
        let controller = LaunchIntroWindowController(screen: screen, onFinish: {
            finishCount += 1
        })

        controller.finishForTesting()
        controller.finishForTesting()

        XCTAssertEqual(finishCount, 1)
    }
}
