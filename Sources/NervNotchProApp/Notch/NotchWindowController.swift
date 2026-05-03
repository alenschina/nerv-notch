import AppKit
import Combine
import SwiftUI

@MainActor
final class NotchWindowController: NSWindowController {
    private let viewModel: NotchViewModel
    private var cancellables = Set<AnyCancellable>()

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

        panel.contentViewController = NSHostingController(rootView: NervConsoleView(viewModel: viewModel))
        panel.setFrame(geometry.windowFrame(), display: true)

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
}
