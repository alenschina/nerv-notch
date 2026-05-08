import XCTest
@testable import NervNotchProApp

final class LaunchIntroPresentationPolicyTests: XCTestCase {
    func testShowsIntroWhenIntroHasNotCompleted() {
        let policy = LaunchIntroPresentationPolicy()

        XCTAssertTrue(policy.shouldShowLaunchIntro(settings: AppSettings(), hasCompletedLaunchIntro: false))
    }

    func testDoesNotShowIntroAfterCompletionWhenRepeatSettingIsDisabled() {
        let policy = LaunchIntroPresentationPolicy()

        XCTAssertFalse(policy.shouldShowLaunchIntro(settings: AppSettings(), hasCompletedLaunchIntro: true))
    }

    func testShowsIntroAfterCompletionWhenRepeatSettingIsEnabled() {
        let policy = LaunchIntroPresentationPolicy()
        var settings = AppSettings()
        settings.alwaysShowLaunchIntro = true

        XCTAssertTrue(policy.shouldShowLaunchIntro(settings: settings, hasCompletedLaunchIntro: true))
    }
}
