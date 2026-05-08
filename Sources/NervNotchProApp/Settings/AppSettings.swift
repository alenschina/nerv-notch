import Foundation

struct AppSettings: Equatable, Sendable {
    var hoverDelay: TimeInterval = 1.0
    var closeGracePeriod: TimeInterval = 0.2
    var samplingInterval: TimeInterval = 1.0
    var usesSimulatedNotch: Bool = false
    var targetScreenIdentifier: String?
    var fanModeEnabled: Bool = true
    var autoPlayAudio: Bool = true
}
