import Foundation

struct AppSettings: Equatable, Sendable, Codable {
    var hoverDelay: TimeInterval = 1.0
    var closeGracePeriod: TimeInterval = 0.2
    var samplingInterval: TimeInterval = 1.0
    var usesSimulatedNotch: Bool = false
    var targetScreenIdentifier: String?
    var fanModeEnabled: Bool = true
    var autoPlayAudio: Bool = true
    var volume: Float = 0.35
    var warningStripAnimated: Bool = true
    var syncWaveAnimated: Bool = true
    var sideWarningStripAnimated: Bool = true
    var clickOnlyMode: Bool = false
    var alwaysShowLaunchIntro: Bool = false

    private static let userDefaultsKey = "NervNotch.settings"

    enum CodingKeys: String, CodingKey {
        case hoverDelay
        case closeGracePeriod
        case samplingInterval
        case usesSimulatedNotch
        case targetScreenIdentifier
        case fanModeEnabled
        case autoPlayAudio
        case volume
        case warningStripAnimated
        case syncWaveAnimated
        case sideWarningStripAnimated
        case clickOnlyMode
        case alwaysShowLaunchIntro
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hoverDelay = try container.decodeIfPresent(TimeInterval.self, forKey: .hoverDelay) ?? hoverDelay
        closeGracePeriod = try container.decodeIfPresent(TimeInterval.self, forKey: .closeGracePeriod) ?? closeGracePeriod
        samplingInterval = try container.decodeIfPresent(TimeInterval.self, forKey: .samplingInterval) ?? samplingInterval
        usesSimulatedNotch = try container.decodeIfPresent(Bool.self, forKey: .usesSimulatedNotch) ?? usesSimulatedNotch
        targetScreenIdentifier = try container.decodeIfPresent(String.self, forKey: .targetScreenIdentifier)
        fanModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .fanModeEnabled) ?? fanModeEnabled
        autoPlayAudio = try container.decodeIfPresent(Bool.self, forKey: .autoPlayAudio) ?? autoPlayAudio
        volume = try container.decodeIfPresent(Float.self, forKey: .volume) ?? volume
        warningStripAnimated = try container.decodeIfPresent(Bool.self, forKey: .warningStripAnimated) ?? warningStripAnimated
        syncWaveAnimated = try container.decodeIfPresent(Bool.self, forKey: .syncWaveAnimated) ?? syncWaveAnimated
        sideWarningStripAnimated = try container.decodeIfPresent(Bool.self, forKey: .sideWarningStripAnimated) ?? sideWarningStripAnimated
        clickOnlyMode = try container.decodeIfPresent(Bool.self, forKey: .clickOnlyMode) ?? clickOnlyMode
        alwaysShowLaunchIntro = try container.decodeIfPresent(Bool.self, forKey: .alwaysShowLaunchIntro) ?? alwaysShowLaunchIntro
    }

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
