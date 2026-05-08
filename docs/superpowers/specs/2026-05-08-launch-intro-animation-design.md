# 首次启动初始化动画设计

## 背景

NERV Notch Pro 当前启动后会直接创建 notch 浮窗并开始 telemetry 采样。用户希望在安装后首次打开应用时，先展示一段类似 `eva-speedtest` 网页的 NERV 初始化动画，然后再进入当前应用本体。

参考网页的启动体验由全屏黑色遮罩承载：橙红色终端文字逐字输出，状态项显示 `[OK]`，文本淡出后出现 NERV/机密视觉，再整体淡出并显示网页主体。本设计将该体验移植为 macOS 原生 SwiftUI/AppKit 启动窗口。

## 目标

- 仅在安装后首次启动时播放初始化动画。
- 动画覆盖整个屏幕中央显示，不嵌入 notch 面板。
- 动画结束后再显示现有 notch 主窗口。
- 用户可以通过 `Esc` 或鼠标点击跳过动画。
- 跳过或完整播放结束后都写入完成标记，后续启动不再播放。
- 保持现有 notch 状态机、telemetry、音频和设置窗口逻辑清晰隔离。

## 非目标

- 不改变当前 notch 展开/收起交互状态机。
- 不引入第三方依赖。
- 不实现设置页里的“重新播放启动动画”开关。
- 不在每次启动都播放动画。
- 不复制参考网页的测速功能或网页布局，仅复刻启动过场的表现节奏。

## 推荐方案

采用独立启动覆盖窗口。

`AppDelegate.start()` 在完成字体注册后判断首次启动标记。如果首次启动未完成，先展示一个临时的无边框全屏启动窗口。启动窗口负责播放 SwiftUI 动画；当动画结束或用户跳过时，写入 `UserDefaults` 标记，关闭启动窗口，然后继续创建现有 `NotchWindowController` 并启动采样定时器。

非首次启动时，`AppDelegate.start()` 直接走现有主窗口启动流程。

## 组件设计

### LaunchIntroStore

轻量存储首次启动状态，封装 `UserDefaults` key。

职责：

- 读取是否已经完成首次启动动画。
- 标记启动动画已经完成。
- 为测试提供可注入的 `UserDefaults` suite。

建议 key：

```swift
NervNotch.hasCompletedLaunchIntro
```

### LaunchIntroWindowController

AppKit 窗口控制器，负责启动动画窗口的生命周期。

职责：

- 创建覆盖主屏幕的无边框窗口。
- 窗口背景为透明或黑色，内容由 `LaunchIntroView` 承载。
- 设置较高窗口层级，保证显示在普通应用窗口之上。
- 监听内容视图的完成回调并关闭窗口。
- 支持 `Esc` 跳过。

窗口行为：

- 目标屏幕使用 `NSScreen.main ?? NSScreen.screens.first`。
- frame 使用目标屏幕 `frame`，视觉内容居中。
- 不显示标题栏，不进入 Dock，不改变现有 `.accessory` 激活策略。
- 动画结束后释放 controller，避免长期占用。

### LaunchIntroView

SwiftUI 视图，负责视觉和时序。

表现：

- 黑色全屏背景。
- 微弱扫描线和暗角，匹配现有 `NervStyle` 的橙红色体系。
- 终端文字逐字输出，例如：

```text
INITIALIZING NERV NOTCH PRO ...

[OK] MAGI ONLINE / マギ接続
[OK] TELEMETRY BUS READY / 監視回線待機
[OK] NOTCH GEOMETRY LOCKED / 形状同期完了
[OK] CENTRAL DOGMA LINK ESTABLISHED
```

- 文字输出完成后淡出。
- 随后显示现有 `nerv-island-icon.png` 和“机密”视觉条。
- logo 段落淡入、短暂停留、轻微放大淡出。
- 最后调用完成回调。

跳过：

- 鼠标点击启动视图时立即完成。
- `Esc` 由窗口层处理，触发同一个完成回调。

动效节奏：

- 打字间隔约 `10ms` 到 `14ms`。
- 文本淡出约 `0.5s`。
- logo/机密段落约 `1.6s` 到 `2.8s`。
- 整体淡出约 `0.65s`。

### AppDelegate 启动流程

将当前 `start()` 拆成两个阶段：

- `start()`：注册字体，决定是否播放启动动画。
- `startMainInterface()`：创建 `NotchViewModel`、音频绑定、notch 主窗口和采样 timer。

伪流程：

```swift
FontRegistration.registerBundledFonts()

if launchIntroStore.hasCompletedLaunchIntro {
    startMainInterface()
} else {
    showLaunchIntro {
        launchIntroStore.markCompleted()
        startMainInterface()
    }
}
```

这样首次启动期间不会提前创建 notch 主窗口，也不会提前开始 telemetry timer。

## 数据流

首次启动：

```text
applicationDidFinishLaunching
→ AppDelegate.start()
→ FontRegistration.registerBundledFonts()
→ LaunchIntroStore.hasCompletedLaunchIntro == false
→ LaunchIntroWindowController.show()
→ LaunchIntroView 动画完成或跳过
→ LaunchIntroStore.markCompleted()
→ LaunchIntroWindowController.close()
→ AppDelegate.startMainInterface()
→ NotchWindowController + telemetry timer
```

后续启动：

```text
applicationDidFinishLaunching
→ AppDelegate.start()
→ FontRegistration.registerBundledFonts()
→ LaunchIntroStore.hasCompletedLaunchIntro == true
→ AppDelegate.startMainInterface()
```

## 错误处理

- 如果找不到主屏幕，沿用现有逻辑：不创建 notch 主窗口，但应用不崩溃。
- 如果图标资源读取失败，启动动画仍播放文字和机密条，只省略 logo 图片。
- 如果启动窗口创建失败，应直接进入主界面，避免应用卡在启动阶段。
- 完成回调需要幂等，防止动画自然结束和用户跳过同时触发。

## 测试计划

新增或扩展单元测试：

- `LaunchIntroStoreTests` 验证默认未完成、标记完成后为已完成。
- 使用独立 `UserDefaults` suite，测试后清理 suite，避免污染真实用户设置。
- 如引入启动流程协调类型，可测试首次启动会选择播放动画，非首次启动直接进入主界面。

不做脆弱的像素级动画渲染测试。SwiftUI 动画视觉通过本地运行人工验收，单元测试覆盖状态持久化和启动分支。

## 验收标准

- 首次安装后打开应用，会先显示全屏居中的 NERV 初始化动画。
- 动画完整结束后，现有 notch 浮窗正常出现并开始显示 telemetry。
- 首次动画期间 notch 主窗口不可见。
- 按 `Esc` 或点击可跳过，并进入 notch 主界面。
- 再次启动应用时不播放初始化动画。
- 现有测试通过。
