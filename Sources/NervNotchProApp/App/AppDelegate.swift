import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: NotchWindowController?
    private var launchIntroWindowController: LaunchIntroWindowController?
    private var viewModel: NotchViewModel?
    private var timer: Timer?
    private var settings = AppSettings.load()
    private var didStartMainInterface = false
    private let launchIntroStore = LaunchIntroStore()
    private let launchIntroPresentationPolicy = LaunchIntroPresentationPolicy()
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

        guard !didStartMainInterface else { return }

        if !launchIntroPresentationPolicy.shouldShowLaunchIntro(
            settings: settings,
            hasCompletedLaunchIntro: launchIntroStore.hasCompletedLaunchIntro
        ) {
            startMainInterface()
            return
        }

        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            startMainInterface()
            return
        }

        let controller = LaunchIntroWindowController(screen: screen) { [weak self] in
            self?.completeLaunchIntro()
        }
        launchIntroWindowController = controller
        controller.showWindow(nil)
    }

    @MainActor
    private func startMainInterface() {
        guard !didStartMainInterface else { return }
        didStartMainInterface = true

        let viewModel = NotchViewModel(settings: settings, decisionEngine: MagiDecisionEngine())
        self.viewModel = viewModel

        AudioManager.shared.autoPlayAudio = settings.autoPlayAudio
        AudioManager.shared.normalVolume = settings.volume
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

    @MainActor
    private func completeLaunchIntro() {
        launchIntroStore.markCompleted()
        launchIntroWindowController = nil
        startMainInterface()
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
        AudioManager.shared.normalVolume = updated.volume
        viewModel?.settings = updated
    }
}
