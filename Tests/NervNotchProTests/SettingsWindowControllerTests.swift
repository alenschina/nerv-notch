import AppKit
import SwiftUI
import XCTest
@testable import NervNotchProApp

@MainActor
final class SettingsWindowControllerTests: XCTestCase {
    func testSettingsWindowUsesClassicSidebarDetailLayout() {
        let controller = SettingsWindowController(onQuit: {})

        let window = controller.makeWindowForTesting()

        XCTAssertEqual(window.title, "NervNotchPro Settings")
        XCTAssertEqual(window.contentMinSize.width, 560)
        XCTAssertEqual(window.contentMinSize.height, 360)
        XCTAssertTrue(window.contentViewController is NSHostingController<SettingsRootView>)
    }

    func testQuitActionCanBeInjectedForSettingsView() {
        var didQuit = false
        let actions = SettingsActions(onQuitApplication: {
            didQuit = true
        })

        actions.quitApplication()

        XCTAssertTrue(didQuit)
    }

    func testSettingsSidebarStartsOnGeneralPane() {
        let model = SettingsNavigationModel()

        XCTAssertEqual(model.selection, .general)
        XCTAssertEqual(SettingsPane.general.title, "通用")
        XCTAssertEqual(SettingsPane.general.systemImageName, "gearshape")
    }
}
