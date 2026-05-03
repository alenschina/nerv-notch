import AppKit
import CoreGraphics

final class NotchEventMonitor {
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private let geometry: NotchGeometry
    private let openedPanelSize: CGSize
    private let onEvent: (NotchInteractionStateMachine.Event) -> Void

    init(
        geometry: NotchGeometry,
        openedPanelSize: CGSize,
        onEvent: @escaping (NotchInteractionStateMachine.Event) -> Void
    ) {
        self.geometry = geometry
        self.openedPanelSize = openedPanelSize
        self.onEvent = onEvent
    }

    func start() {
        stop()
        let mask: NSEvent.EventTypeMask = [.leftMouseDown, .mouseMoved]

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
            return event
        }
    }

    func stop() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
    }

    private func handle(_ event: NSEvent) {
        let point = NSEvent.mouseLocation

        switch event.type {
        case .leftMouseDown:
            if geometry.isPointInNotch(point) {
                onEvent(.notchClicked)
            } else if !geometry.isPointInOpenedPanel(point, size: openedPanelSize) {
                onEvent(.outsideClicked)
            }
        case .mouseMoved:
            if geometry.isPointInNotch(point) {
                onEvent(.mouseEnteredNotch)
            } else if geometry.isPointInOpenedPanel(point, size: openedPanelSize) {
                onEvent(.mouseEnteredPanel)
            } else {
                onEvent(.mouseExitedPanel)
            }
        default:
            break
        }
    }

    deinit {
        stop()
    }
}
