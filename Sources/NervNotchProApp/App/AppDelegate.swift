import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: NotchWindowController?
    private var viewModel: NotchViewModel?
    private var timer: Timer?
    private let settings = AppSettings()
    private let sampler = TelemetrySampler()

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            self.start()
        }
    }

    @MainActor
    private func start() {
        let viewModel = NotchViewModel(settings: settings, decisionEngine: MagiDecisionEngine())
        self.viewModel = viewModel

        let screen = NSScreen.main ?? NSScreen.screens.first
        if let screen {
            let controller = NotchWindowController(
                screen: screen,
                viewModel: viewModel,
                usesSimulatedNotch: settings.usesSimulatedNotch
            )
            controller.showWindow(nil)
            windowController = controller
        }

        timer = Timer.scheduledTimer(
            timeInterval: settings.samplingInterval,
            target: self,
            selector: #selector(sampleTelemetry),
            userInfo: nil,
            repeats: true
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }

    @objc
    @MainActor
    private func sampleTelemetry() {
        guard let viewModel else { return }
        let snapshot = sampler.sample()
        viewModel.apply(snapshot)
    }
}
