import SwiftUI

struct LaunchIntroView: View {
    private let onFinish: () -> Void
    private let bootText = """
    INITIALIZING NERV NOTCH PRO ...

    [OK] MAGI ONLINE / マギ接続
    [OK] TELEMETRY BUS READY / 監視回線待機
    [OK] NOTCH GEOMETRY LOCKED / 形状同期完了
    [OK] CENTRAL DOGMA LINK ESTABLISHED
    """

    @State private var displayedText = ""
    @State private var phase: LaunchIntroPhase = .bootText
    @State private var didFinish = false

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            NervStyle.background
                .ignoresSafeArea()

            launchGrid
            scanlines
            vignette

            bootTextLayer
                .opacity(phase == .bootText ? 1 : 0)
                .offset(y: phase == .bootText ? 0 : -12)

            logoLayer
                .opacity(phase == .logo ? 1 : 0)
                .scaleEffect(phase == .logo ? 1 : 0.92)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            finish()
        }
        .task {
            await runBootSequence()
        }
    }

    private var launchGrid: some View {
        GeometryReader { proxy in
            Path { path in
                let spacing: CGFloat = 32
                var x: CGFloat = 0
                while x <= proxy.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                    x += spacing
                }

                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(NervStyle.orange.opacity(0.08), lineWidth: 1)
        }
        .ignoresSafeArea()
    }

    private var scanlines: some View {
        LinearGradient(
            stops: [
                .init(color: NervStyle.orange.opacity(0.07), location: 0),
                .init(color: .clear, location: 0.18),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 4)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            NervStyle.orange.opacity(0.05)
                .mask(
                    VStack(spacing: 3) {
                        ForEach(0..<120, id: \.self) { _ in
                            Rectangle()
                                .frame(height: 1)
                            Spacer(minLength: 1)
                        }
                    }
                )
        )
        .ignoresSafeArea()
    }

    private var vignette: some View {
        RadialGradient(
            colors: [
                .clear,
                Color.black.opacity(0.70)
            ],
            center: .center,
            startRadius: 180,
            endRadius: 760
        )
        .ignoresSafeArea()
    }

    private var bootTextLayer: some View {
        Text(displayedText)
            .font(.custom(LaunchIntroTypography.fontName, size: 18))
            .foregroundStyle(NervStyle.orange)
            .shadow(color: NervStyle.orange.opacity(0.55), radius: 4)
            .lineSpacing(8)
            .frame(width: 620, alignment: .leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.easeInOut(duration: 0.5), value: phase)
    }

    private var logoLayer: some View {
        VStack(spacing: 34) {
            if let icon = NervIslandIcon.image {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 260)
                    .shadow(color: NervStyle.red.opacity(0.45), radius: 22)
            }

            VStack(spacing: 0) {
                classifiedStrip
                Text("使徒来袭")
                    .font(.custom(LaunchIntroTypography.fontName, size: 96))
                    .foregroundStyle(NervStyle.red)
                    .tracking(12)
                    .shadow(color: NervStyle.red.opacity(0.5), radius: 7)
                    .padding(.leading, 12)
                    .frame(width: 480, height: 142)
                    .background(Color.black)
                classifiedStrip
            }
            .frame(width: 480)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .animation(.easeInOut(duration: 0.7), value: phase)
    }

    private var classifiedStrip: some View {
        GeometryReader { proxy in
            Path { path in
                let stripeWidth: CGFloat = 12
                var x = -proxy.size.height
                while x < proxy.size.width {
                    path.move(to: CGPoint(x: x, y: proxy.size.height))
                    path.addLine(to: CGPoint(x: x + stripeWidth, y: proxy.size.height))
                    path.addLine(to: CGPoint(x: x + stripeWidth + proxy.size.height, y: 0))
                    path.addLine(to: CGPoint(x: x + proxy.size.height, y: 0))
                    path.closeSubpath()
                    x += stripeWidth * 2
                }
            }
            .fill(NervStyle.red)
            .background(Color(red: 0.07, green: 0, blue: 0))
            .shadow(color: NervStyle.red.opacity(0.3), radius: 5)
        }
        .frame(height: 15)
    }

    private func runBootSequence() async {
        guard displayedText.isEmpty else { return }

        for index in bootText.indices {
            guard !didFinish else { return }
            displayedText = String(bootText[...index])
            try? await Task.sleep(nanoseconds: 12_000_000)
        }

        guard !didFinish else { return }
        try? await Task.sleep(nanoseconds: 520_000_000)

        guard !didFinish else { return }
        phase = .logo
        try? await Task.sleep(nanoseconds: 2_200_000_000)

        finish()
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        onFinish()
    }
}

private enum LaunchIntroPhase {
    case bootText
    case logo
}

private enum LaunchIntroTypography {
    static let fontName = "SourceHanSerifCN-Bold"
}
