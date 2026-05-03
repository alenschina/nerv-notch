import AppKit
import Combine
import SwiftUI

@MainActor
final class NotchWindowController: NSWindowController {
    private let viewModel: NotchViewModel
    private var cancellables = Set<AnyCancellable>()
    private var eventMonitor: NotchEventMonitor?
    private var timer: Timer?

    init(screen: NSScreen, viewModel: NotchViewModel, usesSimulatedNotch: Bool) {
        self.viewModel = viewModel

        let notchSize = screen.safeAreaInsets.top > 0
            ? CGSize(width: 210, height: max(32, screen.safeAreaInsets.top))
            : .zero

        let geometry = NotchGeometry(
            screenFrame: screen.frame,
            notchSize: notchSize,
            windowHeight: 460,
            usesSimulatedNotch: usesSimulatedNotch
        )

        let panel = NotchPanel(contentRect: geometry.windowFrame())
        super.init(window: panel)

        let hostingController = NSHostingController(rootView: NervConsoleView(viewModel: viewModel))
        panel.contentViewController = hostingController
        panel.setFrame(geometry.windowFrame(), display: true)
        hostingController.view.frame = panel.contentView?.bounds ?? .zero
        hostingController.view.autoresizingMask = [.width, .height]

        eventMonitor = NotchEventMonitor(
            geometry: geometry,
            openedPanelSize: CGSize(width: 820, height: 420)
        ) { [weak viewModel] event in
            Task { @MainActor in
                viewModel?.handleInteraction(event)
            }
        }
        eventMonitor?.start()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak viewModel] _ in
            Task { @MainActor in
                viewModel?.handleInteraction(.timerTick)
            }
        }

        viewModel.$interactionState
            .receive(on: DispatchQueue.main)
            .sink { [weak panel] state in
                switch state {
                case .opened, .closing:
                    panel?.ignoresMouseEvents = false
                case .closed, .hoverArming:
                    panel?.ignoresMouseEvents = true
                }
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        timer?.invalidate()
        eventMonitor?.stop()
    }
}
