import Combine
import Foundation

@MainActor
final class NotchViewModel: ObservableObject {
    @Published private(set) var magiState: MagiDecisionState
    @Published private(set) var interactionState: NotchInteractionStateMachine.State = .closed

    let settings: AppSettings
    private let decisionEngine: MagiDecisionEngine
    private var stateMachine: NotchInteractionStateMachine

    init(settings: AppSettings, decisionEngine: MagiDecisionEngine) {
        self.settings = settings
        self.decisionEngine = decisionEngine
        self.stateMachine = NotchInteractionStateMachine(
            hoverDelay: settings.hoverDelay,
            closeGracePeriod: settings.closeGracePeriod
        )
        self.magiState = decisionEngine.evaluate(
            SystemSnapshot(sampledAt: Date(), cpu: nil, memory: nil, network: nil)
        )
    }

    func apply(_ snapshot: SystemSnapshot) {
        magiState = decisionEngine.evaluate(snapshot)
    }

    func handleInteraction(_ event: NotchInteractionStateMachine.Event, at time: TimeInterval = Date().timeIntervalSince1970) {
        stateMachine.handle(event, at: time)
        interactionState = stateMachine.state
    }
}
