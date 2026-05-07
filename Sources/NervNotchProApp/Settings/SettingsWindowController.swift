import AppKit
import SwiftUI

struct SettingsActions {
    let onQuitApplication: @MainActor () -> Void

    @MainActor
    func quitApplication() {
        onQuitApplication()
    }
}

enum SettingsPane: String, CaseIterable, Identifiable {
    case general

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .general:
            return "通用"
        }
    }

    var systemImageName: String {
        switch self {
        case .general:
            return "gearshape"
        }
    }
}

struct SettingsNavigationModel: Equatable {
    var selection: SettingsPane = .general
}

@MainActor
final class SettingsWindowController {
    private let actions: SettingsActions
    private var window: NSWindow?

    init(onQuit: @MainActor @escaping () -> Void = { NSApp.terminate(nil) }) {
        self.actions = SettingsActions(onQuitApplication: onQuit)
    }

    func showSettings() {
        let window = window ?? makeWindow()
        self.window = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func makeWindowForTesting() -> NSWindow {
        makeWindow()
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 420),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "NervNotchPro Settings"
        window.isReleasedWhenClosed = false
        window.contentMinSize = NSSize(width: 560, height: 360)
        window.center()
        window.contentViewController = NSHostingController(
            rootView: SettingsRootView(actions: actions)
        )
        return window
    }
}

struct SettingsRootView: View {
    let actions: SettingsActions
    @State private var navigation = SettingsNavigationModel()

    var body: some View {
        NavigationSplitView {
            List(SettingsPane.allCases, selection: $navigation.selection) { pane in
                Label(pane.title, systemImage: pane.systemImageName)
                    .tag(pane)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 220)
        } detail: {
            switch navigation.selection {
            case .general:
                GeneralSettingsView(actions: actions)
            }
        }
        .frame(minWidth: 560, minHeight: 360)
    }
}

private struct GeneralSettingsView: View {
    let actions: SettingsActions

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("通用")
                .font(.title2)
                .fontWeight(.semibold)

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前应用")
                        .font(.headline)
                    Text("结束 NervNotchPro 进程并关闭所有窗口。")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("退出当前应用", role: .destructive) {
                    actions.quitApplication()
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding(24)
    }
}
