import Foundation

struct NotchInteractionStateMachine: Equatable, Sendable {
    private static let comparisonEpsilon: TimeInterval = 1e-9

    enum State: Equatable, Sendable {
        case closed
        case hoverArming(startedAt: TimeInterval)
        case opened
        case closing(startedAt: TimeInterval)
    }

    enum Event: Equatable, Sendable {
        case notchClicked
        case outsideClicked
        case mouseEnteredNotch
        case mouseExitedNotch
        case mouseEnteredPanel
        case mouseExitedPanel
        case timerTick
    }

    private let hoverDelay: TimeInterval
    private let closeGracePeriod: TimeInterval
    private(set) var state: State = .closed

    init(hoverDelay: TimeInterval, closeGracePeriod: TimeInterval) {
        self.hoverDelay = hoverDelay
        self.closeGracePeriod = closeGracePeriod
    }

    mutating func handle(_ event: Event, at time: TimeInterval) {
        switch (state, event) {
        case (_, .notchClicked):
            state = .opened
        case (_, .outsideClicked):
            state = .closed
        case (.closed, .mouseEnteredNotch):
            state = .hoverArming(startedAt: time)
        case (.hoverArming, .mouseExitedNotch):
            state = .closed
        case let (.hoverArming(startedAt), .timerTick):
            if hasElapsed(from: startedAt, to: time, threshold: hoverDelay) {
                state = .opened
            }
        case (.opened, .mouseExitedPanel):
            state = .closing(startedAt: time)
        case (.closing, .mouseEnteredPanel):
            state = .opened
        case let (.closing(startedAt), .timerTick):
            if hasElapsed(from: startedAt, to: time, threshold: closeGracePeriod) {
                state = .closed
            }
        default:
            break
        }
    }

    private func hasElapsed(from startTime: TimeInterval, to time: TimeInterval, threshold: TimeInterval) -> Bool {
        (time - startTime) + Self.comparisonEpsilon >= threshold
    }
}
