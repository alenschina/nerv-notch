import XCTest
@testable import NervNotchProApp

final class AppSettingsTests: XCTestCase {
    func testDefaultSettingsPreferPhysicalNotchWhenAvailable() {
        let settings = AppSettings()

        XCTAssertFalse(settings.usesSimulatedNotch)
    }
}
