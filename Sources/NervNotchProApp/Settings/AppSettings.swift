import Foundation

struct AppSettings: Equatable, Sendable, Codable {
    var hoverDelay: TimeInterval = 1.0
    var closeGracePeriod: TimeInterval = 0.2
    var samplingInterval: TimeInterval = 1.0
    var usesSimulatedNotch: Bool = false
    var targetScreenIdentifier: String?
    var fanModeEnabled: Bool = true
    var autoPlayAudio: Bool = true
    var warningStripAnimated: Bool = true
    var syncWaveAnimated: Bool = true
    var sideWarningStripAnimated: Bool = true

    private static let userDefaultsKey = "NervNotch.settings"

    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
    }
}
