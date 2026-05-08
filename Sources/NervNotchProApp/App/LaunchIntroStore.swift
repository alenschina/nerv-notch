import Foundation

struct LaunchIntroStore {
    private static let completedKey = "NervNotch.hasCompletedLaunchIntro"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedLaunchIntro: Bool {
        userDefaults.bool(forKey: Self.completedKey)
    }

    func markCompleted() {
        userDefaults.set(true, forKey: Self.completedKey)
    }
}
