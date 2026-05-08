import XCTest
@testable import NervNotchProApp

final class LaunchIntroStoreTests: XCTestCase {
    func testIntroDefaultsToNotCompleted() {
        let suiteName = "LaunchIntroStoreTests.defaultsToNotCompleted"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = LaunchIntroStore(userDefaults: defaults)

        XCTAssertFalse(store.hasCompletedLaunchIntro)

        defaults.removePersistentDomain(forName: suiteName)
    }

    func testMarkCompletedPersistsIntroCompletion() {
        let suiteName = "LaunchIntroStoreTests.markCompletedPersists"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = LaunchIntroStore(userDefaults: defaults)

        store.markCompleted()

        XCTAssertTrue(store.hasCompletedLaunchIntro)
        XCTAssertTrue(LaunchIntroStore(userDefaults: defaults).hasCompletedLaunchIntro)

        defaults.removePersistentDomain(forName: suiteName)
    }
}
