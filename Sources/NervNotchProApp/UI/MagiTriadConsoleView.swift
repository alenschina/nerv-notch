import SwiftUI

struct MagiConsoleLayoutMetrics: Equatable {
    let sideInfoWidth: CGFloat = 154
    let trailingInfoWidth: CGFloat = 154
    let triadWidth: CGFloat = 344
    let triadHeight: CGFloat = 258
    let columnSpacing: CGFloat = 14
    let topUnitSize = CGSize(width: 216, height: 118)
    let bottomUnitSize = CGSize(width: 136, height: 104)
    let hubSize = CGSize(width: 120, height: 58)
    let topUnitCenter = CGPoint(x: 172, y: 60)
    let hubCenter = CGPoint(x: 172, y: 145)
    let casperCenter = CGPoint(x: 68, y: 197)
    let melchiorCenter = CGPoint(x: 276, y: 197)
    let bottomInnerCornerBevel = CGSize(width: 24, height: 29)

    var hubLowerLeftEdgeUpper: CGPoint {
        CGPoint(x: hubCenter.x - hubSize.width / 2, y: hubCenter.y)
    }

    var hubLowerLeftEdgeLower: CGPoint {
        CGPoint(
            x: hubCenter.x - hubSize.width / 2 + hubSize.width * 0.2,
            y: hubCenter.y + hubSize.height / 2
        )
    }

    var hubLowerRightEdgeUpper: CGPoint {
        CGPoint(x: hubCenter.x + hubSize.width / 2, y: hubCenter.y)
    }

    var hubLowerRightEdgeLower: CGPoint {
        CGPoint(
            x: hubCenter.x + hubSize.width / 2 - hubSize.width * 0.2,
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

    var body: some View {
        ZStack {
            MagiConnectorShape()
                .stroke(NervStyle.green.opacity(0.82), style: StrokeStyle(lineWidth: 5, lineCap: .square, lineJoin: .miter))
                .shadow(color: NervStyle.green.opacity(0.65), radius: 8)

            MagiUnitView(
                decision: balthasar,
                label: "BALTHASAR-2",
                placement: .top
            )
            .frame(width: metrics.topUnitSize.width, height: metrics.topUnitSize.height)
            .position(metrics.topUnitCenter)

            MagiHubView(judgement: judgement)
                .frame(width: metrics.hubSize.width, height: metrics.hubSize.height)
                .position(metrics.hubCenter)

            MagiUnitView(
                decision: casper,
                label: "CASPER-3",
                placement: .bottomLeft
            )
            .frame(width: metrics.bottomUnitSize.width, height: metrics.bottomUnitSize.height)
            .position(metrics.casperCenter)

            MagiUnitView(
                decision: melchior,
                label: "MELCHIOR-1",
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
    let label: String
    let placement: Placement

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
            .shadow(color: strokeColor.opacity(0.82), radius: 7)
            .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private var unitContent: some View {
        switch placement {
        case .top:
            ZStack {
                Text(label)
                    .font(.system(size: 30, weight: .black, design: .monospaced))
                    .foregroundStyle(strokeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)
                    .position(x: 108, y: 38)

                DecisionPlaque(text: decisionMarker, color: strokeColor, fontSize: 28)
                    .frame(width: 88, height: 42)
                    .position(x: 108, y: 78)
            }

        case .bottomLeft, .bottomRight:
            ZStack {
                DecisionPlaque(text: decisionMarker, color: strokeColor, fontSize: 26)
                    .frame(width: 84, height: 40)
                    .position(x: 68, y: 33)

                Text(label)
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundStyle(strokeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.34)
                    .position(x: 68, y: 78)
            }
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

    private var decisionMarker: String {
        switch decision.level {
        case .normal, .idle:
            return "承認"
        case .highLoad:
            return "審議"
        case .critical, .unavailable:
            return "否定"
        }
    }
}

private struct DecisionPlaque: View {
    let text: String
    let color: Color
    let fontSize: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .black, design: .default))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.58)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.36))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(0.82), lineWidth: 1.5)
                    .shadow(color: color.opacity(0.9), radius: 6)
            )
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

        path.move(to: CGPoint(x: centerX - metrics.topUnitSize.width * 0.34, y: topJoinY))
        path.addLine(to: CGPoint(x: centerX - metrics.hubSize.width * 0.2, y: hubTopY))

        path.move(to: CGPoint(x: centerX + metrics.topUnitSize.width * 0.34, y: topJoinY))
        path.addLine(to: CGPoint(x: centerX + metrics.hubSize.width * 0.2, y: hubTopY))

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
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.62))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.34, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.34, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.62))
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
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.20, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.20, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
