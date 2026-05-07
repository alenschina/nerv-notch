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
    var isSidebarVisible = true

    mutating func toggleSidebar() {
        isSidebarVisible.toggle()
    }
}

@MainActor
final class SettingsWindowController {
    static let windowLevel = NSWindow.Level.mainMenu + 4

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
        window.orderFrontRegardless()
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
        window.level = Self.windowLevel
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
        VStack(spacing: 0) {
            HStack {
                Spacer()

                SettingsSidebarToggleButton(isSidebarVisible: navigation.isSidebarVisible) {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        navigation.toggleSidebar()
                    }
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 12)
            .background(.bar)

            Divider()

            HStack(spacing: 0) {
                if navigation.isSidebarVisible {
                    SettingsSidebarView(selection: $navigation.selection)
                        .frame(width: 180)
                        .transition(.move(edge: .leading).combined(with: .opacity))

                    Divider()
                }

                SettingsDetailView(selection: navigation.selection, actions: actions)
            }
        }
        .frame(minWidth: 560, minHeight: 360)
    }
}

private struct SettingsSidebarToggleButton: View {
    let isSidebarVisible: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "sidebar.left")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isSidebarVisible ? "收起左侧面板" : "展开左侧面板")
        .accessibilityLabel(isSidebarVisible ? "收起左侧面板" : "展开左侧面板")
    }
}

private struct SettingsSidebarView: View {
    @Binding var selection: SettingsPane

    var body: some View {
        List(SettingsPane.allCases, selection: $selection) { pane in
            Label(pane.title, systemImage: pane.systemImageName)
                .tag(pane)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }
}

private struct SettingsDetailView: View {
    let selection: SettingsPane
    let actions: SettingsActions

    var body: some View {
        switch selection {
        case .general:
            GeneralSettingsView(actions: actions)
        }
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
