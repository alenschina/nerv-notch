# NERV Notch

macOS 状态栏悬浮岛，采用 NERV/MAGI 指挥终端美学风格。实时展示 CPU、内存、网络、磁盘、Swap、电池等遥测数据，常驻于 MacBook 刘海区域。

## 系统要求

- macOS 13+
- 字体（需自行安装）：Share Tech Mono、DS-Digital-Bold、SourceHanSerifCN-Bold、Helvetica Neue Condensed Bold

## 功能

- CPU / 内存 / 网络 / 磁盘空间 / 磁盘 I/O / Swap / 电池实时遥测
- MAGI 三贤人决策面板（Melchior / Balthazar / Casper）
- Central Dogma 综合裁决
- 悬停约 1 秒展开完整控制台，点击外部关闭
- 紧凑模式下的警告条滚动动画
- 零第三方依赖，纯 Apple 系统框架

## 快速开始

```bash
./scripts/run-dev.sh
```

## 开发

```bash
# 构建
swift build

# 运行全部测试
swift test

# 运行单个测试
swift test --filter NotchGeometryTests/testNotchScreenRect

# 并行测试
swift test --parallel
```

### 本地打包

```bash
./scripts/package-app.sh
open dist/NervNotch.app
```

签名发布：

```bash
SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
  PRODUCT_BUNDLE_IDENTIFIER="com.example.NervNotch" \
  VERSION="0.1.0" BUILD_NUMBER="1" \
  ./scripts/package-app.sh
```

## Release

推送版本标签即可触发 GitHub Actions 自动构建、签名、公证，生成 DMG 并上传为 draft release：

```bash
git tag v0.1.0
git push origin v0.1.0
```

也可从 Actions 页面手动触发。未配置签名证书时仍可生成未签名 DMG（本地使用）。

签名和公证需要配置 [repository secrets](.github/workflows/release.yml)：`MACOS_CERTIFICATE`、`MACOS_CERTIFICATE_PASSWORD`、`MACOS_SIGNING_IDENTITY`、`MACOS_KEYCHAIN_PASSWORD`、`APPLE_NOTARY_KEY`、`APPLE_NOTARY_KEY_ID`、`APPLE_NOTARY_ISSUER`。

## 架构

Swift 5.9，MVVM + 函数式核心。SwiftUI 视图托管在 AppKit `NSPanel` 中。Combine 仅用于单条 `@Published` ↔ `sink` 绑定。

详细架构文档见 [`.planning/codebase/`](.planning/codebase/)（ARCHITECTURE.md、CONVENTIONS.md、TESTING.md）。

## 许可

个人同人原型项目，不包含受版权保护的图像素材。
