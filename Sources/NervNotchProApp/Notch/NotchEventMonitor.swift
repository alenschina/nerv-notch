import AppKit
import CoreGraphics

/// Emits pointer enter/exit events only on region transitions so hover state can reset when the cursor leaves the notch island.
struct NotchPointerRegionTracker: Equatable, Sendable {
    private var wasInNotch = false
    private var wasInOpenedPanel = false

    mutating func update(isInNotch: Bool, isInOpenedPanel: Bool) -> [NotchInteractionStateMachine.Event] {
        var events: [NotchInteractionStateMachine.Event] = []

        if isInNotch != wasInNotch {
            events.append(isInNotch ? .mouseEnteredNotch : .mouseExitedNotch)
        }

        if isInOpenedPanel != wasInOpenedPanel {
            events.append(isInOpenedPanel ? .mouseEnteredPanel : .mouseExitedPanel)
        }

        wasInNotch = isInNotch
        wasInOpenedPanel = isInOpenedPanel
        return events
    }
}

final class NotchEventMonitor {
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var regionTracker = NotchPointerRegionTracker()
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
            let inNotch = geometry.isPointInNotch(point)
            let inOpenedPanel = geometry.isPointInOpenedPanel(point, size: openedPanelSize)
            for event in regionTracker.update(isInNotch: inNotch, isInOpenedPanel: inOpenedPanel) {
                onEvent(event)
            }
        default:
            break
        }
    }

    deinit {
        stop()
    }
}
