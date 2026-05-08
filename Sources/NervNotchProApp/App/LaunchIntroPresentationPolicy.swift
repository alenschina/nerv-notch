import Foundation

struct LaunchIntroPresentationPolicy: Equatable, Sendable {
    func shouldShowLaunchIntro(settings: AppSettings, hasCompletedLaunchIntro: Bool) -> Bool {
        settings.alwaysShowLaunchIntro || !hasCompletedLaunchIntro
    }
}
