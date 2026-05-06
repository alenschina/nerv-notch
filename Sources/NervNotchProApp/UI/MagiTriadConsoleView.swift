import SwiftUI

struct MagiConsoleTypography: Equatable {
    let englishFontName = "Share Tech Mono"
    let topUnitLabelSize: CGFloat = 14
    let bottomUnitLabelSize: CGFloat = 13
    let unitSubtitleSize: CGFloat = 8
    let metricValueSize: CGFloat = 20
    let statusTextSize: CGFloat = 7
}

struct MagiUnitLabel: Equatable {
    let title: String
    let subtitle: String
}

struct MagiTriadUnitLabels: Equatable {
    let balthasar = MagiUnitLabel(title: "BALTHASAR-2", subtitle: "MEMORY")
    let casper = MagiUnitLabel(title: "CASPER-3", subtitle: "NETWORK")
    let melchior = MagiUnitLabel(title: "MELCHIOR-1", subtitle: "CPU")
}

struct MagiUnitContentLayout: Equatable {
    enum Placement {
        case top
        case bottom
    }

    let placement: Placement

    var horizontalPadding: CGFloat {
        switch placement {
        case .top:
            return 20
        case .bottom:
            return 12
        }
    }

    var verticalPadding: CGFloat {
        switch placement {
        case .top:
            return 14
        case .bottom:
            return 12
        }
    }

    var contentWidth: CGFloat {
        switch placement {
        case .top:
            return 106
        case .bottom:
            return 108
        }
    }

    var contentHeight: CGFloat {
        switch placement {
        case .top:
            return 86
        case .bottom:
            return 78
        }
    }

    var titleHeight: CGFloat {
        23
    }

    var valueHeight: CGFloat {
        switch placement {
        case .top:
            return 31
        case .bottom:
            return 29
        }
    }

    var statusHeight: CGFloat {
        16
    }
}

struct MagiConsoleLayoutMetrics: Equatable {
    let sideInfoWidth: CGFloat = 154
    let trailingInfoWidth: CGFloat = 154
    let triadWidth: CGFloat = 368
    let triadHeight: CGFloat = 258
    let columnSpacing: CGFloat = 14
    let topUnitSize = CGSize(width: 149, height: 118)
    let bottomUnitSize = CGSize(width: 136, height: 104)
    let hubSize = CGSize(width: 120, height: 72.5)
    let topUnitCenter = CGPoint(x: 184, y: 60)
    let hubCenter = CGPoint(x: 184, y: 155.25)
    let casperCenter = CGPoint(x: 99.5, y: 200)
    let melchiorCenter = CGPoint(x: 268.5, y: 200)
    let sharedSlantRun = CGSize(width: 29, height: 29)
    let hubLowerSlantScale: CGFloat = 1.5
    let topUnitVerticalSideHeight: CGFloat = 74.5

    var bottomInnerCornerBevel: CGSize {
        hubLowerSlantRun
    }

    var hubUpperSlantRun: CGSize {
        sharedSlantRun
    }

    var hubLowerSlantRun: CGSize {
        CGSize(
            width: sharedSlantRun.width * hubLowerSlantScale,
            height: sharedSlantRun.height * hubLowerSlantScale
        )
    }

    var hubBottomEdgeLength: CGFloat {
        hubSize.width - hubLowerSlantRun.width * 2
    }

    var hubTopEdgeLength: CGFloat {
        hubSize.width - hubUpperSlantRun.width * 2
    }

    var topUnitLowerSideRun: CGSize {
        let height = topUnitSize.height - topUnitVerticalSideHeight
        return CGSize(width: slantWidth(forHeight: height), height: height)
    }

    var topUnitBottomEdgeLength: CGFloat {
        topUnitSize.width - topUnitLowerSideRun.width * 2
    }

    var balthasarBottomLeftEdge: CGPoint {
        CGPoint(
            x: topUnitCenter.x - topUnitBottomEdgeLength / 2,
            y: topUnitCenter.y + topUnitSize.height / 2
        )
    }

    var balthasarBottomRightEdge: CGPoint {
        CGPoint(
            x: topUnitCenter.x + topUnitBottomEdgeLength / 2,
            y: topUnitCenter.y + topUnitSize.height / 2
        )
    }

    var hubUpperLeftEdge: CGPoint {
        CGPoint(
            x: hubCenter.x - hubTopEdgeLength / 2,
            y: hubCenter.y - hubSize.height / 2
        )
    }

    var hubUpperRightEdge: CGPoint {
        CGPoint(
            x: hubCenter.x + hubTopEdgeLength / 2,
            y: hubCenter.y - hubSize.height / 2
        )
    }

    private func slantWidth(forHeight height: CGFloat) -> CGFloat {
        height * sharedSlantRun.width / sharedSlantRun.height
    }

    var hubLowerLeftEdgeUpper: CGPoint {
        CGPoint(
            x: hubCenter.x - hubSize.width / 2,
            y: hubCenter.y - hubSize.height / 2 + hubUpperSlantRun.height
        )
    }

    var hubLowerLeftEdgeLower: CGPoint {
        CGPoint(
            x: hubCenter.x - hubBottomEdgeLength / 2,
            y: hubCenter.y + hubSize.height / 2
        )
    }

    var hubLowerRightEdgeUpper: CGPoint {
        CGPoint(
            x: hubCenter.x + hubSize.width / 2,
            y: hubCenter.y - hubSize.height / 2 + hubUpperSlantRun.height
        )
    }

    var hubLowerRightEdgeLower: CGPoint {
        CGPoint(
            x: hubCenter.x + hubBottomEdgeLength / 2,
            y: hubCenter.y + hubSize.height / 2
        )
    }

    var casperInnerBevelUpper: CGPoint {
        CGPoint(
            x: casperCenter.x + bottomUnitSize.width / 2 - bottomInnerCornerBevel.width,
            y: casperCenter.y - bottomUnitSize.height / 2
        )
    }

    var casperInnerBevelLower: CGPoint {
        CGPoint(
            x: casperCenter.x + bottomUnitSize.width / 2,
            y: casperCenter.y - bottomUnitSize.height / 2 + bottomInnerCornerBevel.height
        )
    }

    var melchiorInnerBevelUpper: CGPoint {
        CGPoint(
            x: melchiorCenter.x - bottomUnitSize.width / 2 + bottomInnerCornerBevel.width,
            y: melchiorCenter.y - bottomUnitSize.height / 2
        )
    }

    var melchiorInnerBevelLower: CGPoint {
        CGPoint(
            x: melchiorCenter.x - bottomUnitSize.width / 2,
            y: melchiorCenter.y - bottomUnitSize.height / 2 + bottomInnerCornerBevel.height
        )
    }
}

struct MagiTriadConsoleView: View {
    let state: MagiDecisionState

    private let metrics = MagiConsoleLayoutMetrics()

    var body: some View {
        ZStack {
            consoleGrid

            VStack(spacing: 12) {
                topStatusArea

                HStack(alignment: .top, spacing: metrics.columnSpacing) {
                    MagiConsoleInfoColumn(
                        alignment: .leading,
                        rows: leftRows,
                        width: metrics.sideInfoWidth
                    )

                    MagiTriadView(
                        balthasar: state.memory,
                        casper: state.network,
                        melchior: state.cpu,
                        judgement: state.judgement
                    )
                    .frame(width: metrics.triadWidth, height: metrics.triadHeight)

                    MagiConsoleInfoColumn(
                        alignment: .leading,
                        rows: rightRows,
                        width: metrics.trailingInfoWidth
                    )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .background(
            RadialGradient(
                colors: [
                    NervStyle.green.opacity(0.10),
                    NervStyle.background.opacity(0.15),
                    Color.black.opacity(0.35)
                ],
                center: .center,
                startRadius: 30,
                endRadius: 390
            )
        )
    }

    private var topStatusArea: some View {
        VStack(spacing: 7) {
            HStack(spacing: 8) {
                MagiConsoleStatusBanner(text: "DIRECT LINK CONNECTION: MAGI 01")
                MagiConsoleStatusBanner(text: "ACCESS MODE: SUPERVISER")
            }

            HStack(spacing: 8) {
                MagiConsoleStatusBanner(text: "RESULT OF THE DELIBERATION", isEmphasized: false)
                    .frame(width: 250)
                MagiConsoleStatusBanner(text: "MOTION: \(state.judgement.title)", isEmphasized: true)
            }
        }
        .frame(maxWidth: 650)
    }

    private var consoleGrid: some View {
        GeometryReader { proxy in
            Path { path in
                let rowHeight: CGFloat = 8
                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += rowHeight
                }
            }
            .stroke(NervStyle.green.opacity(0.07), lineWidth: 0.6)
        }
        .allowsHitTesting(false)
    }

    private var leftRows: [String] {
        [
            "CODE : 258",
            "FILE : MAGI.SYS",
            "EXTENSION : 4096",
            "EX_MODE : ON",
            "PRIORITY : AAA",
            "CPU : \(state.cpu.primaryValue)",
            "MEM : \(state.memory.primaryValue)",
            "NET : \(state.network.primaryValue)"
        ]
    }

    private var rightRows: [String] {
        [
            "Layer 3:",
            "ConnectionControl",
            "Q:331",
            "Layer 2:",
            "DebLink: \(state.network.statusText)",
            "Q:321-LAPD",
            "Layer 1:",
            "Physical Connection",
            "L431-Basic Interface"
        ]
    }
}

private struct MagiConsoleStatusBanner: View {
    let text: String
    var isEmphasized = true

    var body: some View {
        Text(text)
            .font(.system(size: isEmphasized ? 15 : 12, weight: .black, design: .monospaced))
            .foregroundStyle(NervStyle.orange)
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .padding(.horizontal, 10)
            .padding(.vertical, isEmphasized ? 8 : 7)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.42))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(NervStyle.orange.opacity(0.78), lineWidth: 1.5)
                    .shadow(color: NervStyle.orange.opacity(0.85), radius: 5)
            )
    }
}

private struct MagiConsoleInfoColumn: View {
    let alignment: HorizontalAlignment
    let rows: [String]
    let width: CGFloat

    var body: some View {
        VStack(alignment: alignment, spacing: 5) {
            ForEach(rows, id: \.self) { row in
                Text(row)
                    .font(NervStyle.monoSmall)
                    .fontWeight(.black)
                    .foregroundStyle(NervStyle.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .frame(maxWidth: .infinity, alignment: frameAlignment)
            }
        }
        .padding(.top, 18)
        .frame(width: width, alignment: frameAlignment)
        .shadow(color: NervStyle.orange.opacity(0.75), radius: 4)
    }

    private var frameAlignment: Alignment {
        alignment == .trailing ? .trailing : .leading
    }
}

private struct MagiTriadView: View {
    let balthasar: MagiPanelDecision
    let casper: MagiPanelDecision
    let melchior: MagiPanelDecision
    let judgement: CentralDogmaJudgement

    private let metrics = MagiConsoleLayoutMetrics()
    private let labels = MagiTriadUnitLabels()

    var body: some View {
        ZStack {
            MagiConnectorShape()
                .stroke(NervStyle.green.opacity(0.82), style: StrokeStyle(lineWidth: 5, lineCap: .square, lineJoin: .miter))
                .shadow(color: NervStyle.green.opacity(0.65), radius: 8)

            MagiUnitView(
                decision: balthasar,
                label: labels.balthasar,
                placement: .top
            )
            .frame(width: metrics.topUnitSize.width, height: metrics.topUnitSize.height)
            .position(metrics.topUnitCenter)

            MagiHubView(judgement: judgement)
                .frame(width: metrics.hubSize.width, height: metrics.hubSize.height)
                .position(metrics.hubCenter)

            MagiUnitView(
                decision: casper,
                label: labels.casper,
                placement: .bottomLeft
            )
            .frame(width: metrics.bottomUnitSize.width, height: metrics.bottomUnitSize.height)
            .position(metrics.casperCenter)

            MagiUnitView(
                decision: melchior,
                label: labels.melchior,
                placement: .bottomRight
            )
            .frame(width: metrics.bottomUnitSize.width, height: metrics.bottomUnitSize.height)
            .position(metrics.melchiorCenter)
        }
    }
}

private struct MagiUnitView: View {
    enum Placement {
        case top
        case bottomLeft
        case bottomRight
    }

    let decision: MagiPanelDecision
    let label: MagiUnitLabel
    let placement: Placement
    private let typography = MagiConsoleTypography()
    private var contentLayout: MagiUnitContentLayout {
        MagiUnitContentLayout(placement: placement == .top ? .top : .bottom)
    }

    var body: some View {
        ZStack {
            unitShape
                .fill(Color.black.opacity(0.62))
                .overlay(
                    unitShape
                        .stroke(strokeColor.opacity(0.9), lineWidth: 4)
                        .shadow(color: strokeColor.opacity(0.85), radius: 8)
                )

            unitContent
                .frame(width: contentLayout.contentWidth, height: contentLayout.contentHeight)
                .position(contentPosition)
                .shadow(color: strokeColor.opacity(0.82), radius: 7)
        }
    }

    private var unitContent: some View {
        VStack(spacing: 4) {
            UnitTitleBlock(
                label: label,
                color: strokeColor,
                fontName: typography.englishFontName,
                titleSize: placement == .top ? typography.topUnitLabelSize : typography.bottomUnitLabelSize,
                subtitleSize: typography.unitSubtitleSize,
                titleScale: 0.50
            )
            .frame(height: contentLayout.titleHeight)

            Spacer(minLength: 0)

            DecisionPlaque(
                text: decision.primaryValue,
                color: NervStyle.orange,
                fontName: typography.englishFontName,
                fontSize: typography.metricValueSize
            )
            .frame(height: contentLayout.valueHeight)

            Text(compactStatusText)
                .font(.custom(typography.englishFontName, size: typography.statusTextSize))
                .fontWeight(.black)
                .foregroundStyle(strokeColor.opacity(0.82))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.55)
                .frame(height: contentLayout.statusHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var contentPosition: CGPoint {
        switch placement {
        case .top:
            return CGPoint(x: 74.5, y: 58)
        case .bottomLeft:
            return CGPoint(x: 63, y: 52)
        case .bottomRight:
            return CGPoint(x: 73, y: 52)
        }
    }

    private var compactStatusText: String {
        switch decision.level {
        case .normal:
            return "NORMAL"
        case .idle:
            return "IDLE"
        case .highLoad:
            return "HIGH LOAD"
        case .critical:
            return "CRITICAL"
        case .unavailable:
            return "NO DATA"
        }
    }

    private var unitShape: MagiUnitShape {
        MagiUnitShape(placement: placement)
    }

    private var strokeColor: Color {
        switch decision.level {
        case .normal, .idle:
            return NervStyle.green
        case .highLoad:
            return NervStyle.orange
        case .critical, .unavailable:
            return NervStyle.red
        }
    }

}

private struct UnitTitleBlock: View {
    let label: MagiUnitLabel
    let color: Color
    let fontName: String
    let titleSize: CGFloat
    let subtitleSize: CGFloat
    let titleScale: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Text(label.title)
                .font(.custom(fontName, size: titleSize))
                .fontWeight(.black)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(titleScale)

            Text(label.subtitle)
                .font(.custom(fontName, size: subtitleSize))
                .fontWeight(.black)
                .foregroundStyle(color.opacity(0.78))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct DecisionPlaque: View {
    let text: String
    let color: Color
    let fontName: String
    let fontSize: CGFloat

    var body: some View {
        Text(text)
            .font(.custom(fontName, size: fontSize))
            .fontWeight(.black)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.42)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.22))
    }
}

private struct MagiHubView: View {
    let judgement: CentralDogmaJudgement

    var body: some View {
        ZStack {
            MagiHubShape()
                .fill(Color.black.opacity(0.78))
                .overlay(
                    MagiHubShape()
                        .stroke(hubColor.opacity(0.94), lineWidth: 4)
                        .shadow(color: hubColor.opacity(0.82), radius: 8)
                )

            VStack(spacing: 1) {
                Text("MAGI")
                    .font(.system(size: 25, weight: .black, design: .serif))
                    .foregroundStyle(NervStyle.white)
                    .lineLimit(1)

                Text(judgement.title)
                    .font(.system(size: 7, weight: .black, design: .monospaced))
                    .foregroundStyle(hubColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
            }
            .shadow(color: hubColor.opacity(0.9), radius: 6)
        }
    }

    private var hubColor: Color {
        switch judgement.level {
        case .synchronized:
            return NervStyle.green
        case .elevatedAlert:
            return NervStyle.orange
        case .emergencyMode, .partialSync:
            return NervStyle.red
        }
    }
}

private struct MagiConnectorShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let metrics = MagiConsoleLayoutMetrics()
        let centerX = rect.midX
        let topJoinY = rect.minY + metrics.topUnitCenter.y + metrics.topUnitSize.height / 2
        let hubTopY = rect.minY + metrics.hubCenter.y - metrics.hubSize.height / 2
        let hubBottomY = rect.minY + metrics.hubCenter.y + metrics.hubSize.height / 2

        path.move(to: CGPoint(x: centerX - metrics.topUnitBottomEdgeLength / 2, y: topJoinY))
        path.addLine(to: CGPoint(x: centerX - metrics.hubTopEdgeLength / 2, y: hubTopY))

        path.move(to: CGPoint(x: centerX + metrics.topUnitBottomEdgeLength / 2, y: topJoinY))
        path.addLine(to: CGPoint(x: centerX + metrics.hubTopEdgeLength / 2, y: hubTopY))

        path.move(to: CGPoint(x: centerX, y: hubBottomY))
        path.addLine(to: CGPoint(x: centerX, y: rect.minY + metrics.casperCenter.y))

        return path
    }
}

private struct MagiUnitShape: Shape {
    let placement: MagiUnitView.Placement

    func path(in rect: CGRect) -> Path {
        switch placement {
        case .top:
            topPath(in: rect)
        case .bottomLeft, .bottomRight:
            bottomPath(in: rect)
        }
    }

    private func topPath(in rect: CGRect) -> Path {
        let metrics = MagiConsoleLayoutMetrics()
        let bottomHalf = metrics.topUnitBottomEdgeLength / 2
        let lowerSideY = rect.minY + metrics.topUnitVerticalSideHeight

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: lowerSideY))
        path.addLine(to: CGPoint(x: rect.midX + bottomHalf, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - bottomHalf, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: lowerSideY))
        path.closeSubpath()
        return path
    }

    private func bottomPath(in rect: CGRect) -> Path {
        switch placement {
        case .top:
            return topPath(in: rect)
        case .bottomLeft:
            return bottomLeftPath(in: rect)
        case .bottomRight:
            return bottomRightPath(in: rect)
        }
    }

    private func bottomLeftPath(in rect: CGRect) -> Path {
        let bevel = MagiConsoleLayoutMetrics().bottomInnerCornerBevel
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - bevel.width, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bevel.height))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }

    private func bottomRightPath(in rect: CGRect) -> Path {
        let bevel = MagiConsoleLayoutMetrics().bottomInnerCornerBevel
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + bevel.width, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + bevel.height))
        path.closeSubpath()
        return path
    }
}

private struct MagiHubShape: Shape {
    func path(in rect: CGRect) -> Path {
        let metrics = MagiConsoleLayoutMetrics()
        let topInset = (rect.width - metrics.hubTopEdgeLength) / 2
        let bottomInset = (rect.width - metrics.hubBottomEdgeLength) / 2
        let sideJoinY = rect.minY + metrics.hubUpperSlantRun.height

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + topInset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topInset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: sideJoinY))
        path.addLine(to: CGPoint(x: rect.maxX - bottomInset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + bottomInset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: sideJoinY))
        path.closeSubpath()
        return path
    }
}
