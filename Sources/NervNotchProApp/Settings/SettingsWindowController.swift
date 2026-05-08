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
    case appearance
    case audio
    case general

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .general:
            return "通用"
        case .audio:
            return "声音"
        case .appearance:
            return "外观"
        }
    }

    var systemImageName: String {
        switch self {
        case .general:
            return "gearshape"
        case .audio:
            return "speaker.wave.2"
        case .appearance:
            return "paintbrush"
        }
    }
}

struct SettingsNavigationModel: Equatable {
    var selection: SettingsPane = SettingsPane.allCases.first ?? .general
    var isSidebarVisible = true

    mutating func toggleSidebar() {
        isSidebarVisible.toggle()
    }
}

@MainActor
final class SettingsWindowController {
    static let windowLevel = NSWindow.Level.mainMenu + 4

    private let actions: SettingsActions
    private let settings: AppSettings
    private let onSettingsChanged: (AppSettings) -> Void
    private var window: NSWindow?

    init(
        settings: AppSettings = AppSettings(),
        onQuit: @MainActor @escaping () -> Void = { NSApp.terminate(nil) },
        onSettingsChanged: @escaping (AppSettings) -> Void = { _ in }
    ) {
        self.settings = settings
        self.actions = SettingsActions(onQuitApplication: onQuit)
        self.onSettingsChanged = onSettingsChanged
    }

    func showSettings() {
        let window = window ?? makeWindow()
        self.window = window
        let currentSettings = AppSettings.load()
        window.contentViewController = NSHostingController(
            rootView: SettingsRootView(actions: actions, settings: currentSettings, onSettingsChanged: onSettingsChanged)
        )
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
        window.title = "NervNotch Settings"
        window.isReleasedWhenClosed = false
        window.level = Self.windowLevel
        window.contentMinSize = NSSize(width: 560, height: 360)
        window.center()
        window.contentViewController = NSHostingController(
            rootView: SettingsRootView(actions: actions, settings: settings, onSettingsChanged: onSettingsChanged)
        )
        return window
    }
}

struct SettingsRootView: View {
    let actions: SettingsActions
    let onSettingsChanged: (AppSettings) -> Void
    @State private var navigation = SettingsNavigationModel()
    @State private var settingsState: AppSettings

    init(actions: SettingsActions, settings: AppSettings, onSettingsChanged: @escaping (AppSettings) -> Void) {
        self.actions = actions
        self.onSettingsChanged = onSettingsChanged
        self._settingsState = State(initialValue: settings)
    }

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

                SettingsDetailView(
                    selection: navigation.selection,
                    actions: actions,
                    settings: $settingsState,
                    onSettingsChanged: onSettingsChanged
                )
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
    @Binding var settings: AppSettings
    let onSettingsChanged: (AppSettings) -> Void

    var body: some View {
        switch selection {
        case .general:
            GeneralSettingsView(actions: actions, settings: $settings, onSettingsChanged: onSettingsChanged)
        case .audio:
            AudioSettingsView(settings: $settings, onSettingsChanged: onSettingsChanged)
        case .appearance:
            AppearanceSettingsView(settings: $settings, onSettingsChanged: onSettingsChanged)
        }
    }
}

private struct GeneralSettingsView: View {
    let actions: SettingsActions
    @Binding var settings: AppSettings
    let onSettingsChanged: (AppSettings) -> Void

    private var clickOnlyModeBinding: Binding<Bool> {
        Binding(
            get: { settings.clickOnlyMode },
            set: {
                settings.clickOnlyMode = $0
                onSettingsChanged(settings)
            }
        )
    }

    private var alwaysShowLaunchIntroBinding: Binding<Bool> {
        Binding(
            get: { settings.alwaysShowLaunchIntro },
            set: {
                settings.alwaysShowLaunchIntro = $0
                onSettingsChanged(settings)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("通用")
                .font(.title2)
                .fontWeight(.semibold)

            Divider()

            Toggle(isOn: clickOnlyModeBinding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("仅点击模式")
                        .font(.headline)
                    Text("仅响应鼠标点击来展开或收起 island 面板，忽略鼠标悬停和移出事件。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Toggle(isOn: alwaysShowLaunchIntroBinding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("每次启动播放初始化动画")
                        .font(.headline)
                    Text("开启后，每次重新启动应用都会播放 NERV 初始化动画，而不是只在首次启动时播放。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前应用")
                        .font(.headline)
                    Text("结束 NervNotch 进程并关闭所有窗口。")
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

private struct AudioSettingsView: View {
    @Binding var settings: AppSettings
    let onSettingsChanged: (AppSettings) -> Void

    private var autoPlayBinding: Binding<Bool> {
        Binding(
            get: { settings.autoPlayAudio },
            set: {
                settings.autoPlayAudio = $0
                onSettingsChanged(settings)
            }
        )
    }

    private var volumeBinding: Binding<Float> {
        Binding(
            get: { settings.volume },
            set: {
                settings.volume = $0
                onSettingsChanged(settings)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("声音")
                .font(.title2)
                .fontWeight(.semibold)

            Divider()

            Toggle(isOn: autoPlayBinding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("展开时自动播放")
                        .font(.headline)
                    Text("展开 island 面板时自动播放背景音乐。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("音量")
                    .font(.headline)

                HStack {
                    Image(systemName: "speaker.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Slider(value: volumeBinding, in: 0...1)

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(24)
    }
}

private struct AppearanceSettingsView: View {
    @Binding var settings: AppSettings
    let onSettingsChanged: (AppSettings) -> Void

    private var warningStripBinding: Binding<Bool> {
        Binding(
            get: { settings.warningStripAnimated },
            set: {
                settings.warningStripAnimated = $0
                onSettingsChanged(settings)
            }
        )
    }

    private var syncWaveBinding: Binding<Bool> {
        Binding(
            get: { settings.syncWaveAnimated },
            set: {
                settings.syncWaveAnimated = $0
                onSettingsChanged(settings)
            }
        )
    }

    private var sideWarningStripBinding: Binding<Bool> {
        Binding(
            get: { settings.sideWarningStripAnimated },
            set: {
                settings.sideWarningStripAnimated = $0
                onSettingsChanged(settings)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("外观")
                .font(.title2)
                .fontWeight(.semibold)

            Divider()

            Toggle(isOn: warningStripBinding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("中央警戒线动画")
                        .font(.headline)
                    Text("控制中央框架中的斜纹警戒线是否滚动。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Toggle(isOn: sideWarningStripBinding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("两侧警戒线动画")
                        .font(.headline)
                    Text("控制左右两侧的斜纹警戒线是否滚动。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Toggle(isOn: syncWaveBinding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("波形图动画")
                        .font(.headline)
                    Text("控制左侧面板中的同步波形图是否动态。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(24)
    }
}
