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

    func testSettingsWindowAppearsAboveExpandedIslandPanel() {
        let controller = SettingsWindowController(onQuit: {})

        let window = controller.makeWindowForTesting()

        XCTAssertGreaterThan(window.level.rawValue, (NSWindow.Level.mainMenu + 3).rawValue)
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
        XCTAssertTrue(model.isSidebarVisible)
        XCTAssertEqual(SettingsPane.general.title, "通用")
        XCTAssertEqual(SettingsPane.general.systemImageName, "gearshape")
    }

    func testSettingsSidebarVisibilityCanBeToggledWithoutChangingSelection() {
        var model = SettingsNavigationModel()

        model.toggleSidebar()

        XCTAssertFalse(model.isSidebarVisible)
        XCTAssertEqual(model.selection, .general)
    }

    func testSettingsRootUsesFixedTrailingSidebarToggleInsteadOfSystemSplitToggle() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceFile = projectRoot
            .appendingPathComponent("Sources/NervNotchProApp/Settings/SettingsWindowController.swift")
        let settingsSource = try String(contentsOf: sourceFile)

        XCTAssertFalse(settingsSource.contains("NavigationSplitView"))
        XCTAssertTrue(settingsSource.contains("SettingsSidebarToggleButton"))
        XCTAssertTrue(settingsSource.contains(".frame(maxWidth: .infinity, alignment: .trailing)"))
    }
}
