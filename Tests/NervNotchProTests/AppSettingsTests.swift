import XCTest
@testable import NervNotchProApp

final class AppSettingsTests: XCTestCase {
    func testDefaultSettingsPreferPhysicalNotchWhenAvailable() {
        let settings = AppSettings()

        XCTAssertFalse(settings.usesSimulatedNotch)
    }

    func testLaunchIntroDoesNotRepeatByDefault() {
        let settings = AppSettings()

        XCTAssertFalse(settings.alwaysShowLaunchIntro)
    }

    func testDecodingOlderSettingsDefaultsLaunchIntroRepeatToFalse() throws {
        let json = """
        {
          "hoverDelay": 1.0,
          "closeGracePeriod": 0.2,
          "samplingInterval": 1.0,
          "usesSimulatedNotch": false,
          "fanModeEnabled": true,
          "autoPlayAudio": false,
          "volume": 0.2,
          "warningStripAnimated": true,
          "syncWaveAnimated": true,
          "sideWarningStripAnimated": true,
          "clickOnlyMode": true
        }
        """
        let settings = try JSONDecoder().decode(AppSettings.self, from: Data(json.utf8))

        XCTAssertFalse(settings.alwaysShowLaunchIntro)
        XCTAssertFalse(settings.autoPlayAudio)
        XCTAssertEqual(settings.volume, 0.2)
        XCTAssertTrue(settings.clickOnlyMode)
    }
}
