import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: NotchWindowController?
    private var viewModel: NotchViewModel?
    private var timer: Timer?
    private var settings = AppSettings.load()
    private let sampler = TelemetrySampler()
    @MainActor private lazy var settingsWindowController = SettingsWindowController(
        settings: settings,
        onSettingsChanged: { [weak self] updated in
            self?.applySettings(updated)
        }
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            self.start()
        }
    }

    @MainActor
    private func start() {
        FontRegistration.registerBundledFonts()

        let viewModel = NotchViewModel(settings: settings, decisionEngine: MagiDecisionEngine())
        self.viewModel = viewModel

        AudioManager.shared.autoPlayAudio = settings.autoPlayAudio
        AudioManager.shared.attach(to: viewModel)

        let screen = NSScreen.main ?? NSScreen.screens.first
        if let screen {
            let controller = NotchWindowController(
                screen: screen,
                viewModel: viewModel,
                usesSimulatedNotch: settings.usesSimulatedNotch,
                onOpenSettings: { [weak self] in
                    self?.openSettings()
                }
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

    @MainActor
    private func openSettings() {
        settingsWindowController.showSettings()
    }

    @MainActor
    private func applySettings(_ updated: AppSettings) {
        settings = updated
        updated.save()
        AudioManager.shared.autoPlayAudio = updated.autoPlayAudio
    }
}
