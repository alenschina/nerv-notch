import AppKit
import SwiftUI

@MainActor
final class LaunchIntroWindowController: NSWindowController {
    private var didFinish = false
    private let onFinish: () -> Void

    init(screen: NSScreen, onFinish: @escaping () -> Void) {
        self.onFinish = onFinish

        let panel = LaunchIntroWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isOpaque = false
        panel.isReleasedWhenClosed = false
        panel.level = .mainMenu + 5

        super.init(window: panel)

        panel.onCancel = { [weak self] in
            self?.finish()
        }

        panel.contentViewController = NSHostingController(
            rootView: LaunchIntroView(onFinish: { [weak self] in
                self?.finish()
            })
        )
        panel.setFrame(screen.frame, display: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(sender)
    }

    func finishForTesting() {
        finish()
    }

    func makeWindowForTesting() -> NSWindow {
        guard let window else {
            fatalError("LaunchIntroWindowController was initialized without a window")
        }
        return window
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        close()
        onFinish()
    }
}

private final class LaunchIntroWindow: NSWindow {
    var onCancel: (() -> Void)?

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    override func cancelOperation(_ sender: Any?) {
        onCancel?()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            onCancel?()
        } else {
            super.keyDown(with: event)
        }
    }
}
