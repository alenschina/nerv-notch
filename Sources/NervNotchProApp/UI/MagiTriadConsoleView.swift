import SwiftUI

struct MagiConsoleLayoutMetrics: Equatable {
    let sideInfoWidth: CGFloat = 154
    let trailingInfoWidth: CGFloat = 154
    let triadWidth: CGFloat = 300
    let triadHeight: CGFloat = 258
    let columnSpacing: CGFloat = 14
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

    var body: some View {
        ZStack {
            MagiConnectorShape()
                .stroke(NervStyle.green.opacity(0.84), style: StrokeStyle(lineWidth: 7, lineCap: .square, lineJoin: .miter))
                .shadow(color: NervStyle.green.opacity(0.65), radius: 8)

            MagiUnitView(
                decision: balthasar,
                label: "BALTHASAR-2",
                placement: .top
            )
            .frame(width: 190, height: 108)
            .position(x: 150, y: 55)

            MagiHubView(judgement: judgement)
                .frame(width: 112, height: 58)
                .position(x: 150, y: 132)

            MagiUnitView(
                decision: casper,
                label: "CASPER-3",
                placement: .bottomLeft
            )
            .frame(width: 136, height: 104)
            .position(x: 72, y: 206)

            MagiUnitView(
                decision: melchior,
                label: "MELCHIOR-1",
                placement: .bottomRight
            )
            .frame(width: 136, height: 104)
            .position(x: 228, y: 206)
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

            VStack(spacing: placement == .top ? 8 : 7) {
                Text(decisionMarker)
                    .font(.system(size: placement == .top ? 26 : 22, weight: .black, design: .default))
                    .foregroundStyle(strokeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(strokeColor.opacity(0.82), lineWidth: 1.4)
                    )

                Text(label)
                    .font(.system(size: placement == .top ? 24 : 20, weight: .black, design: .monospaced))
                    .foregroundStyle(strokeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)

                Text(decision.primaryValue)
                    .font(NervStyle.monoSmall)
                    .fontWeight(.black)
                    .foregroundStyle(NervStyle.white.opacity(0.86))
                    .lineLimit(1)
            }
            .shadow(color: strokeColor.opacity(0.82), radius: 7)
            .padding(.horizontal, 8)
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
        let centerX = rect.midX
        let hubTop = rect.minY + 104
        let hubBottom = rect.minY + 160
        let lowerY = rect.minY + 158
        let leftX = rect.minX + 72
        let rightX = rect.maxX - 72

        path.move(to: CGPoint(x: centerX, y: rect.minY + 92))
        path.addLine(to: CGPoint(x: centerX, y: hubTop))

        path.move(to: CGPoint(x: centerX, y: hubBottom))
        path.addLine(to: CGPoint(x: centerX, y: rect.minY + 180))

        path.move(to: CGPoint(x: centerX - 46, y: lowerY))
        path.addLine(to: CGPoint(x: leftX, y: rect.minY + 180))
        path.addLine(to: CGPoint(x: leftX, y: rect.maxY - 104))

        path.move(to: CGPoint(x: centerX + 46, y: lowerY))
        path.addLine(to: CGPoint(x: rightX, y: rect.minY + 180))
        path.addLine(to: CGPoint(x: rightX, y: rect.maxY - 104))

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
            rectanglePath(in: rect)
        }
    }

    private func topPath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.66))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.30, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.30, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.66))
        path.closeSubpath()
        return path
    }

    private func rectanglePath(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
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
