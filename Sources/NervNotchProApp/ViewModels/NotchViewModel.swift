import Combine
import Foundation

@MainActor
final class NotchViewModel: ObservableObject {
    @Published private(set) var magiState: MagiDecisionState
    @Published private(set) var interactionState: NotchInteractionStateMachine.State = .closed

    @Published var settings: AppSettings
    private let decisionEngine: MagiDecisionEngine
    private var stateMachine: NotchInteractionStateMachine

    init(settings: AppSettings, decisionEngine: MagiDecisionEngine) {
        self.settings = settings
        self.decisionEngine = decisionEngine
        self.stateMachine = NotchInteractionStateMachine(
            hoverDelay: settings.hoverDelay,
            closeGracePeriod: settings.closeGracePeriod
        )
        self.magiState = .defaultValue
    }

    func apply(_ snapshot: SystemSnapshot) {
        magiState = decisionEngine.evaluate(snapshot)
    }

    func handleInteraction(_ event: NotchInteractionStateMachine.Event, at time: TimeInterval = Date().timeIntervalSince1970) {
        if settings.clickOnlyMode {
            switch event {
            case .notchClicked, .outsideClicked:
                break
            case .mouseEnteredNotch, .mouseExitedNotch, .mouseEnteredPanel, .mouseExitedPanel, .timerTick:
                return
            }
        }
        stateMachine.handle(event, at: time)
        interactionState = stateMachine.state
    }
}
