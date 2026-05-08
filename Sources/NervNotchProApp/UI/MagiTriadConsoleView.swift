import SwiftUI

struct MagiConsoleTypography: Equatable {
    let englishFontName = "Share Tech Mono"
    let topUnitLabelSize: CGFloat = 32
    let bottomUnitLabelSize: CGFloat = 32
    let unitTitleFontName = "Helvetica Neue Condensed Bold"
    let unitSubtitleSize: CGFloat = 7
    let metricFontName = "DS-Digital-Bold"
    let metricValueSize: CGFloat = 20
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
            return 6
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
            return 136
        case .bottom:
            return 108
        }
    }

    var contentHeight: CGFloat {
        switch placement {
        case .top:
            return 80
        case .bottom:
            return 78
        }
    }

    var titleHeight: CGFloat {
        switch placement {
        case .top:
            return 44
        case .bottom:
            return 44
        }
    }

    var valueHeight: CGFloat {
        switch placement {
        case .top:
            return 31
        case .bottom:
            return 29
        }
    }

    var valueHorizontalInset: CGFloat {
        switch placement {
        case .top:
            return 20
        case .bottom:
            return 16
        }
    }

    var valueWidth: CGFloat {
        contentWidth - valueHorizontalInset * 2
    }

    var statusHeight: CGFloat {
        0
    }

    var titleAppearsBelowValue: Bool {
        placement == .bottom
    }
}

struct MagiConsoleLayoutMetrics: Equatable {
    let sideInfoWidth: CGFloat = 0
    let trailingInfoWidth: CGFloat = 0
    let triadWidth: CGFloat = 368
    let triadHeight: CGFloat = 258
    let triadOuterFrameHorizontalInset: CGFloat = 0
    let triadOuterFrameStrokeHorizontalInset: CGFloat = 38
    let triadOuterFrameStrokeLineWidth: CGFloat = 1
    let triadEmbeddedInfoReserveWidth: CGFloat = 62
    let sideAuxiliaryFrameWidth: CGFloat = 132
    /// Horizontal band reserved from each console edge for warning chrome; auxiliary red strokes align to this band.
    let sideWarningBackgroundWidth: CGFloat = 64
    /// The painted diagonal warning panels are this much narrower per side than `sideWarningBackgroundWidth` so red frames stay put.
    let sideWarningBackgroundPaintedNarrowing: CGFloat = 5

    var sideWarningBackgroundPaintedWidth: CGFloat {
        max(0, sideWarningBackgroundWidth - sideWarningBackgroundPaintedNarrowing)
    }

    let sideWarningBackgroundStripeWidth: CGFloat = 36
    let sideWarningBackgroundStripeHeight: CGFloat = 58
    let sideWarningBackgroundOpacity: Double = 0.36
    let consoleContentHorizontalPadding: CGFloat = 18
    let leftAuxiliaryFrameWarningStripClearance: CGFloat = 5
    let leftAuxiliaryFrameToTriadStrokeGap: CGFloat = 5
    let consoleContentTopPadding: CGFloat = 46
    let consoleContentBottomPadding: CGFloat = 20
    let triadEmbeddedInfoWidth: CGFloat = 118
    let triadEmbeddedInfoRowCount = 9
    let triadEmbeddedInfoFontSize: CGFloat = 7.2
    let triadEmbeddedInfoLineHeight: CGFloat = 8.2
    let triadEmbeddedInfoRowSpacing: CGFloat = 1.4
    let triadEmbeddedInfoTopInset: CGFloat = 42
    /// Inset from the outer red frame’s left edge to the left embedded info column’s leading edge.
    let triadEmbeddedLeftInfoInset: CGFloat = 80
    /// Inset from the outer red frame’s right edge to the right embedded info column’s trailing edge.
    let triadEmbeddedRightInfoInset: CGFloat = 22
    let triadOuterFrameBottomPadding: CGFloat = 4
    let triadWarningStripHeight: CGFloat = 16
    let triadWarningStripTopInset: CGFloat = 10
    let columnSpacing: CGFloat = 14
    let topUnitSize = CGSize(width: 149, height: 108)
    let bottomUnitSize = CGSize(width: 136, height: 104)
    let hubSize = CGSize(width: 120, height: 72.5)
    let topUnitCenter = CGPoint(x: 184, y: 55)
    let hubCenter = CGPoint(x: 184, y: 145.25)
    let casperCenter = CGPoint(x: 99.5, y: 190)
    let melchiorCenter = CGPoint(x: 268.5, y: 190)
    let sharedSlantRun = CGSize(width: 29, height: 29)
    let hubLowerSlantScale: CGFloat = 1.5
    let topUnitVerticalSideHeight: CGFloat = 64.5

    var triadContentOffsetY: CGFloat {
        triadWarningStripTopInset + triadWarningStripHeight + 20
    }

    var triadOuterFrameWidth: CGFloat {
        triadWidth + triadEmbeddedInfoReserveWidth * 2 - triadOuterFrameHorizontalInset * 2
    }

    var triadOuterFrameStrokeWidth: CGFloat {
        triadOuterFrameWidth - triadOuterFrameStrokeHorizontalInset * 2
    }

    var triadWarningStripHorizontalInset: CGFloat {
        triadOuterFrameStrokeHorizontalInset + triadOuterFrameStrokeLineWidth
    }

    var sideAuxiliaryFrameStrokeWidth: CGFloat {
        sideAuxiliaryFrameWidth - triadOuterFrameStrokeHorizontalInset * 2
    }

    var sideAuxiliaryFrameWarningStripWidth: CGFloat {
        sideAuxiliaryFrameWidth - triadWarningStripHorizontalInset * 2
    }

    var consoleWidth: CGFloat {
        consoleContentHorizontalPadding * 2 + triadClusterWidth
    }

    var triadOuterFrameStrokeLeftXInConsole: CGFloat {
        consoleContentHorizontalPadding
        + sideAuxiliaryFrameWidth
        + columnSpacing
        + triadOuterFrameStrokeHorizontalInset
    }

    var triadOuterFrameStrokeRightXInConsole: CGFloat {
        triadOuterFrameStrokeLeftXInConsole + triadOuterFrameStrokeWidth
    }

    var leftAuxiliaryFrameStrokeLeftXInConsole: CGFloat {
        sideWarningBackgroundWidth + leftAuxiliaryFrameWarningStripClearance
    }

    var leftAuxiliaryFrameStrokeRightXInConsole: CGFloat {
        triadOuterFrameStrokeLeftXInConsole - leftAuxiliaryFrameToTriadStrokeGap
    }

    var leftAuxiliaryFrameStrokeWidth: CGFloat {
        leftAuxiliaryFrameStrokeRightXInConsole - leftAuxiliaryFrameStrokeLeftXInConsole
    }

    var leftAuxiliaryFrameStrokeOffsetX: CGFloat {
        let auxiliaryFrameCenterX = consoleContentHorizontalPadding + sideAuxiliaryFrameWidth / 2
        let desiredStrokeCenterX = (leftAuxiliaryFrameStrokeLeftXInConsole + leftAuxiliaryFrameStrokeRightXInConsole) / 2
        return desiredStrokeCenterX - auxiliaryFrameCenterX
    }

    var rightAuxiliaryFrameStrokeLeftXInConsole: CGFloat {
        triadOuterFrameStrokeRightXInConsole + leftAuxiliaryFrameToTriadStrokeGap
    }

    var rightAuxiliaryFrameStrokeRightXInConsole: CGFloat {
        consoleWidth - sideWarningBackgroundWidth - leftAuxiliaryFrameWarningStripClearance
    }

    var rightAuxiliaryFrameStrokeWidth: CGFloat {
        rightAuxiliaryFrameStrokeRightXInConsole - rightAuxiliaryFrameStrokeLeftXInConsole
    }

    var rightAuxiliaryFrameStrokeOffsetX: CGFloat {
        let auxiliaryFrameCenterX = consoleContentHorizontalPadding
        + sideAuxiliaryFrameWidth
        + columnSpacing
        + triadOuterFrameWidth
        + columnSpacing
        + sideAuxiliaryFrameWidth / 2
        let desiredStrokeCenterX = (rightAuxiliaryFrameStrokeLeftXInConsole + rightAuxiliaryFrameStrokeRightXInConsole) / 2
        return desiredStrokeCenterX - auxiliaryFrameCenterX
    }

    var triadClusterWidth: CGFloat {
        sideAuxiliaryFrameWidth * 2 + triadOuterFrameWidth + columnSpacing * 2
    }

    var triadOuterFrameHeight: CGFloat {
        triadHeight + triadContentOffsetY + triadOuterFrameBottomPadding
    }

    var consoleFramedContentTopY: CGFloat {
        consoleContentTopPadding
    }

    var consoleFramedContentBottomY: CGFloat {
        consoleFramedContentTopY + triadOuterFrameHeight
    }

    var triadContentOriginXInOuterFrame: CGFloat {
        (triadOuterFrameWidth - triadWidth) / 2
    }

    var balthasarLeftEdgeInOuterFrame: CGFloat {
        triadContentOriginXInOuterFrame + topUnitCenter.x - topUnitSize.width / 2
    }

    var balthasarRightEdgeInOuterFrame: CGFloat {
        triadContentOriginXInOuterFrame + topUnitCenter.x + topUnitSize.width / 2
    }

    var casperTopYInOuterFrame: CGFloat {
        triadContentOffsetY + casperCenter.y - bottomUnitSize.height / 2
    }

    var melchiorTopYInOuterFrame: CGFloat {
        triadContentOffsetY + melchiorCenter.y - bottomUnitSize.height / 2
    }

    var triadEmbeddedInfoContentHeight: CGFloat {
        CGFloat(triadEmbeddedInfoRowCount) * triadEmbeddedInfoLineHeight
        + CGFloat(triadEmbeddedInfoRowCount - 1) * triadEmbeddedInfoRowSpacing
    }

    var triadLeadingEmbeddedInfoLeadingX: CGFloat {
        triadEmbeddedLeftInfoInset
    }

    var triadLeadingEmbeddedInfoTrailingX: CGFloat {
        triadLeadingEmbeddedInfoLeadingX + triadEmbeddedInfoWidth
    }

    var triadTrailingEmbeddedInfoLeadingX: CGFloat {
        triadOuterFrameWidth - triadEmbeddedRightInfoInset - triadEmbeddedInfoWidth
    }

    var triadTrailingEmbeddedInfoTrailingX: CGFloat {
        triadTrailingEmbeddedInfoLeadingX + triadEmbeddedInfoWidth
    }

    var triadEmbeddedInfoBottomY: CGFloat {
        triadEmbeddedInfoTopInset + triadEmbeddedInfoContentHeight
    }

    var triadLeadingEmbeddedInfoCenter: CGPoint {
        CGPoint(
            x: triadLeadingEmbeddedInfoLeadingX + triadEmbeddedInfoWidth / 2,
            y: triadEmbeddedInfoTopInset + triadEmbeddedInfoContentHeight / 2
        )
    }

    var triadTrailingEmbeddedInfoCenter: CGPoint {
        CGPoint(
            x: triadTrailingEmbeddedInfoLeadingX + triadEmbeddedInfoWidth / 2,
            y: triadEmbeddedInfoTopInset + triadEmbeddedInfoContentHeight / 2
        )
    }

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
    let warningStripAnimated: Bool
    let syncWaveAnimated: Bool
    let sideWarningStripAnimated: Bool

    private let metrics = MagiConsoleLayoutMetrics()

    var body: some View {
        ZStack {
            MagiSideWarningBackgroundStrips(isAnimated: sideWarningStripAnimated)

            consoleGrid

            VStack {
                HStack(alignment: .top, spacing: metrics.columnSpacing) {
                    MagiAuxiliaryFramedView(
                        strokeWidth: metrics.leftAuxiliaryFrameStrokeWidth,
                        strokeOffsetX: metrics.leftAuxiliaryFrameStrokeOffsetX
                    ) {
                        SynchronizationRateView(
                            rateText: SynchronizationRateLayout.rateText(swapUsageRatio: state.swapUsageRatio),
                            batteryText: state.batteryPercentageText,
                            isAnimated: syncWaveAnimated
                        )
                    }
                        .frame(width: metrics.sideAuxiliaryFrameWidth, height: metrics.triadOuterFrameHeight)

                    MagiTriadFramedView(
                        balthasar: state.memory,
                        casper: state.network,
                        melchior: state.cpu,
                        judgement: state.judgement,
                        leadingRows: leftRows,
                        trailingRows: rightRows,
                        warningStripAnimated: warningStripAnimated
                    )
                    .frame(width: metrics.triadOuterFrameWidth, height: metrics.triadOuterFrameHeight)

                    MagiAuxiliaryFramedView(
                        strokeWidth: metrics.rightAuxiliaryFrameStrokeWidth,
                        strokeOffsetX: metrics.rightAuxiliaryFrameStrokeOffsetX
                    ) {
                        EmergencyHoneycombView(
                            diskUsageRatio: state.diskUsageRatio,
                            diskIORateText: state.diskIORateText
                        )
                    }
                        .frame(width: metrics.sideAuxiliaryFrameWidth, height: metrics.triadOuterFrameHeight)
                }
            }
            .padding(.horizontal, metrics.consoleContentHorizontalPadding)
            .padding(.top, metrics.consoleContentTopPadding)
            .padding(.bottom, metrics.consoleContentBottomPadding)
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

private struct MagiSideWarningBackgroundStrips: View {
    let isAnimated: Bool
    private let metrics = MagiConsoleLayoutMetrics()

    var body: some View {
        HStack(spacing: 0) {
            MagiSideWarningBackgroundStrip(
                isAnimated: isAnimated,
                scrollDirection: .up
            )
                .frame(width: metrics.sideWarningBackgroundPaintedWidth)

            Spacer(minLength: 0)

            MagiSideWarningBackgroundStrip(
                isAnimated: isAnimated,
                scrollDirection: .down
            )
                .frame(width: metrics.sideWarningBackgroundPaintedWidth)
        }
        .allowsHitTesting(false)
    }
}

private enum SideWarningScrollDirection {
    case up
    case down
}

private struct MagiSideWarningBackgroundStrip: View {
    let isAnimated: Bool
    let scrollDirection: SideWarningScrollDirection
    private let metrics = MagiConsoleLayoutMetrics()

    var body: some View {
        GeometryReader { proxy in
            let stripeWidth = metrics.sideWarningBackgroundStripeWidth
            let directionMultiplier: CGFloat = scrollDirection == .up ? -1 : 1

            TimelineView(.animation) { timeline in
                let rawPhase = timeline.date.timeIntervalSinceReferenceDate * 12
                let phase = isAnimated
                    ? (rawPhase * directionMultiplier).truncatingRemainder(dividingBy: stripeWidth)
                    : 0

                ZStack {
                    Color.black.opacity(0.28)

                    NervStyle.orange
                        .opacity(metrics.sideWarningBackgroundOpacity)

                    Path { path in
                        let stripeHeight = metrics.sideWarningBackgroundStripeHeight
                        var y = -stripeHeight + phase

                        while y < proxy.size.height + stripeHeight + stripeWidth {
                            path.move(to: CGPoint(x: 0, y: y + stripeHeight))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: y + stripeHeight * 0.45))
                            path.addLine(to: CGPoint(x: 0, y: y + stripeHeight * 1.45))
                            path.closeSubpath()
                            y += stripeWidth
                        }
                    }
                    .fill(Color.black.opacity(0.72))

                    Path { path in
                        let rowHeight: CGFloat = 7
                        var y: CGFloat = phase.truncatingRemainder(dividingBy: rowHeight)
                        if y > 0 { y -= rowHeight }

                        while y <= proxy.size.height {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                            y += rowHeight
                        }
                    }
                    .stroke(Color.black.opacity(0.42), lineWidth: 1)
                }
                .overlay(
                    Rectangle()
                        .stroke(NervStyle.orange.opacity(0.18), lineWidth: 1)
                )
                .clipped()
            }
        }
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

private struct MagiTriadFramedView: View {
    let balthasar: MagiPanelDecision
    let casper: MagiPanelDecision
    let melchior: MagiPanelDecision
    let judgement: CentralDogmaJudgement
    let leadingRows: [String]
    let trailingRows: [String]
    let warningStripAnimated: Bool

    private let metrics = MagiConsoleLayoutMetrics()

    var body: some View {
        ZStack(alignment: .top) {
            MagiConsoleFramedChrome(strokeWidth: metrics.triadOuterFrameStrokeWidth, warningStripAnimated: warningStripAnimated)

            MagiTriadView(
                balthasar: balthasar,
                casper: casper,
                melchior: melchior,
                judgement: judgement
            )
            .frame(width: metrics.triadWidth, height: metrics.triadHeight)
            .offset(y: metrics.triadContentOffsetY)

            MagiTriadEmbeddedInfoColumn(rows: leadingRows)
                .frame(
                    width: metrics.triadEmbeddedInfoWidth,
                    height: metrics.triadEmbeddedInfoContentHeight,
                    alignment: .topLeading
                )
                .position(metrics.triadLeadingEmbeddedInfoCenter)

            MagiTriadEmbeddedInfoColumn(rows: trailingRows)
                .frame(
                    width: metrics.triadEmbeddedInfoWidth,
                    height: metrics.triadEmbeddedInfoContentHeight,
                    alignment: .topLeading
                )
                .position(metrics.triadTrailingEmbeddedInfoCenter)
        }
        .frame(width: metrics.triadOuterFrameWidth, height: metrics.triadOuterFrameHeight)
    }
}

struct SynchronizationRateLayout: Equatable {
    let containerSize: CGSize
    let contentInset: CGFloat = 7
    let waveCount = 13
    let phaseVelocity: CGFloat = 1.35
    let titleText = "VIRTUAL MEM / SWAP 使用率"
    let batteryTitleText = "BATTERY / 电池"
    let titleTopPadding: CGFloat = 34
    let batteryTitleTopPadding: CGFloat = 12
    let batteryHorizontalInset: CGFloat = 3
    let batteryValueFontSize: CGFloat = 21
    let batteryContentVerticalOffset: CGFloat = 3
    let batteryPanelTopExtension: CGFloat = 4
    let batteryTitleValueSpacing: CGFloat = 10
    let batteryTitleAlignmentName = "center"
    let rateLabelFontName = "SourceHanSerifCN-Bold"
    let rateValueFontName = "DS-Digital-Bold"

    static func rateText(swapUsageRatio: Double?) -> String {
        guard let swapUsageRatio else {
            return "--"
        }

        let rate = min(100, max(0, swapUsageRatio * 100))
        if rate.rounded() == rate {
            return "\(Int(rate))%"
        }

        return "\(String(format: "%.1f", rate))%"
    }

    var upperPanelHeight: CGFloat {
        containerSize.height * 4 / 5
    }

    var batteryPanelTopY: CGFloat {
        upperPanelHeight - batteryPanelTopExtension
    }

    var batteryPanelHeight: CGFloat {
        max(0, containerSize.height - batteryPanelTopY)
    }

    var batteryContentHeight: CGFloat {
        batteryPanelHeight
    }

    var batteryContentCenterY: CGFloat {
        batteryPanelTopY + batteryPanelHeight / 2 + batteryContentVerticalOffset
    }

    var batterySeparatorY: CGFloat {
        batteryPanelTopY
    }

    var waveRenderTopY: CGFloat {
        titleTopPadding + 18
    }

    var waveRenderHeight: CGFloat {
        upperPanelHeight * 0.54
    }

    var waveMaskBottomY: CGFloat {
        waveRenderHeight
    }

    var topGuideY: CGFloat {
        waveRenderTopY
    }

    var bottomGuideY: CGFloat {
        waveRenderTopY + waveRenderHeight
    }

    var waveTopY: CGFloat {
        waveRenderTopY + waveRenderHeight * 0.24
    }

    var waveBottomY: CGFloat {
        waveRenderTopY + waveRenderHeight * 0.70
    }

    var rateBaselineY: CGFloat {
        upperPanelHeight * 0.82
    }

    var bottomTickY: CGFloat {
        batteryPanelTopY - 17
    }

    func phase(at time: TimeInterval) -> CGFloat {
        CGFloat(time) * phaseVelocity
    }
}

private struct SynchronizationRateView: View {
    let rateText: String
    let batteryText: String
    let isAnimated: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let layout = SynchronizationRateLayout(containerSize: proxy.size)
                let phase = isAnimated ? layout.phase(at: timeline.date.timeIntervalSinceReferenceDate) : 0

                ZStack {
                    SynchronizationScanlineField()

                    VStack(spacing: 0) {
                        Text(layout.titleText)
                            .font(.system(size: 7.6, weight: .black, design: .monospaced))
                            .foregroundStyle(NervStyle.orange)
                            .lineLimit(1)
                            .minimumScaleFactor(0.28)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .shadow(color: NervStyle.orange.opacity(0.75), radius: 3)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, layout.contentInset)
                    .padding(.top, layout.titleTopPadding)

                    SynchronizationGuideLines(layout: layout)

                    ForEach(0..<layout.waveCount, id: \.self) { index in
                        SynchronizationWaveShape(
                            phase: phase,
                            lineIndex: index,
                            lineCount: layout.waveCount
                        )
                        .stroke(
                            waveColor(for: index, count: layout.waveCount),
                            style: StrokeStyle(lineWidth: 0.95, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: waveColor(for: index, count: layout.waveCount).opacity(0.45), radius: 2)
                        .padding(.horizontal, layout.contentInset + 2)
                    }
                    .frame(width: proxy.size.width, height: layout.waveRenderHeight)
                    .position(
                        x: proxy.size.width / 2,
                        y: layout.waveRenderTopY + layout.waveRenderHeight / 2
                    )
                    .clipped()

                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("同步率")
                            .font(.custom(layout.rateLabelFontName, size: 15))

                        Text(rateText)
                            .font(.custom(layout.rateValueFontName, size: 17))
                    }
                    .fontWeight(.black)
                    .foregroundStyle(NervStyle.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.34)
                    .shadow(color: NervStyle.red.opacity(0.95), radius: 5)
                    .frame(width: max(0, proxy.size.width - layout.contentInset * 2))
                    .position(x: proxy.size.width / 2, y: layout.rateBaselineY)

                    SynchronizationTickMarks(layout: layout)

                    BatteryPanelSeparator(layout: layout)

                    VStack(spacing: layout.batteryTitleValueSpacing) {
                        Text(layout.batteryTitleText)
                            .font(.system(size: 7.6, weight: .black, design: .monospaced))
                            .foregroundStyle(NervStyle.orange)
                            .lineLimit(1)
                            .minimumScaleFactor(0.28)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .shadow(color: NervStyle.orange.opacity(0.75), radius: 3)

                        HStack(alignment: .center, spacing: 5) {
                            BatteryReserveIcon(chargeText: batteryText)
                                .frame(
                                    width: BatteryReserveIconLayout(chargeText: batteryText).iconWidth,
                                    height: BatteryReserveIconLayout(chargeText: batteryText).iconHeight
                                )
                                .shadow(color: NervStyle.red.opacity(0.75), radius: 4)

                            Text(batteryText)
                                .font(.custom(layout.rateValueFontName, size: layout.batteryValueFontSize))
                                .fontWeight(.black)
                                .foregroundStyle(NervStyle.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.26)
                                .shadow(color: NervStyle.red.opacity(0.95), radius: 5)
                        }
                        .frame(
                            width: max(0, proxy.size.width - layout.batteryHorizontalInset * 2),
                            alignment: .center
                        )
                    }
                    .padding(.horizontal, layout.batteryHorizontalInset)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .frame(
                        width: proxy.size.width,
                        height: layout.batteryContentHeight,
                        alignment: .top
                    )
                    .position(
                        x: proxy.size.width / 2,
                        y: layout.batteryContentCenterY
                    )
                }
                .background(Color.black.opacity(0.28))
                .clipped()
            }
        }
        .allowsHitTesting(false)
    }

    private func waveColor(for index: Int, count: Int) -> Color {
        let midpoint = Double(max(count - 1, 1)) / 2
        let distance = abs(Double(index) - midpoint) / midpoint

        if index.isMultiple(of: 3) {
            return NervStyle.orange.opacity(0.16 + (1 - distance) * 0.18)
        }

        return Color(red: 0.36, green: 0.12, blue: 0.92).opacity(0.18 + (1 - distance) * 0.24)
    }
}

struct BatteryReserveIconLayout: Equatable {
    let chargeText: String
    let segmentCount = 8
    let iconWidth: CGFloat = 48
    let iconHeight: CGFloat = 19
    let strokeColorName = "NervStyle.red"
    let fillColorName = "NervStyle.red"

    var filledSegmentCount: Int {
        guard let percentage = percentageValue else {
            return 0
        }

        let normalized = min(100, max(0, percentage))
        guard normalized > 0 else {
            return 0
        }
        return min(segmentCount, max(1, Int(ceil(normalized / 100 * Double(segmentCount)))))
    }

    private var percentageValue: Double? {
        let trimmed = chargeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasSuffix("%") else {
            return nil
        }
        return Double(trimmed.dropLast())
    }
}

private struct BatteryReserveIcon: View {
    let chargeText: String

    var body: some View {
        let layout = BatteryReserveIconLayout(chargeText: chargeText)

        GeometryReader { proxy in
            let terminalWidth = max(3, proxy.size.width * 0.10)
            let bodyWidth = max(1, proxy.size.width - terminalWidth)
            let segmentSpacing: CGFloat = 1.0
            let horizontalInset: CGFloat = 2
            let availableSegmentWidth = max(1, bodyWidth - horizontalInset * 2 - segmentSpacing * CGFloat(layout.segmentCount - 1))
            let segmentWidth = max(2, availableSegmentWidth / CGFloat(layout.segmentCount))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(NervStyle.red, lineWidth: 2)
                    .frame(width: bodyWidth, height: proxy.size.height)

                RoundedRectangle(cornerRadius: 1.2)
                    .fill(NervStyle.red)
                    .frame(width: terminalWidth, height: proxy.size.height * 0.48)
                    .offset(x: bodyWidth - 0.7)

                HStack(spacing: segmentSpacing) {
                    ForEach(0..<layout.segmentCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 1.4)
                            .fill(index < layout.filledSegmentCount ? NervStyle.red : Color.clear)
                            .frame(width: segmentWidth, height: proxy.size.height - 6)
                    }
                }
                .padding(.leading, horizontalInset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

private struct SynchronizationGuideLines: View {
    let layout: SynchronizationRateLayout

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let left = layout.contentInset
                let right = proxy.size.width - layout.contentInset
                let topRuleY = layout.topGuideY
                let bottomRuleY = layout.bottomGuideY

                path.move(to: CGPoint(x: left, y: topRuleY))
                path.addLine(to: CGPoint(x: right, y: topRuleY))
                path.move(to: CGPoint(x: left, y: bottomRuleY))
                path.addLine(to: CGPoint(x: right, y: bottomRuleY))

                let guideCount = 5
                for index in 1..<guideCount {
                    let x = left + (right - left) * CGFloat(index) / CGFloat(guideCount)
                    path.move(to: CGPoint(x: x, y: topRuleY + 2))
                    path.addLine(to: CGPoint(x: x, y: bottomRuleY - 3))
                }
            }
            .stroke(NervStyle.orange.opacity(0.34), style: StrokeStyle(lineWidth: 0.75, dash: [5, 5]))

            Path { path in
                let left = layout.contentInset
                let right = proxy.size.width - layout.contentInset

                path.move(to: CGPoint(x: left, y: layout.topGuideY))
                path.addLine(to: CGPoint(x: right, y: layout.topGuideY))
                path.move(to: CGPoint(x: left, y: layout.bottomGuideY))
                path.addLine(to: CGPoint(x: right, y: layout.bottomGuideY))
            }
            .stroke(NervStyle.orange.opacity(0.78), lineWidth: 1)
            .shadow(color: NervStyle.orange.opacity(0.4), radius: 2)
        }
    }
}

private struct SynchronizationTickMarks: View {
    let layout: SynchronizationRateLayout

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let left = layout.contentInset
                let right = proxy.size.width - layout.contentInset
                let tickCount = 6

                for index in 0...tickCount {
                    let x = left + (right - left) * CGFloat(index) / CGFloat(tickCount)
                    path.move(to: CGPoint(x: x, y: layout.bottomTickY))
                    path.addLine(to: CGPoint(x: x, y: layout.bottomTickY + 10))
                }
            }
            .stroke(NervStyle.orange.opacity(0.72), lineWidth: 1)
            .shadow(color: NervStyle.orange.opacity(0.45), radius: 2)
        }
    }
}

private struct BatteryPanelSeparator: View {
    let layout: SynchronizationRateLayout

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: layout.contentInset, y: layout.batterySeparatorY))
                path.addLine(to: CGPoint(x: proxy.size.width - layout.contentInset, y: layout.batterySeparatorY))
            }
            .stroke(NervStyle.red.opacity(0.82), lineWidth: 1)
            .shadow(color: NervStyle.red.opacity(0.55), radius: 3)
        }
    }
}

private struct SynchronizationScanlineField: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += 4
                }
            }
            .stroke(NervStyle.orange.opacity(0.08), lineWidth: 0.7)
        }
    }
}

private struct SynchronizationWaveShape: Shape {
    let phase: CGFloat
    let lineIndex: Int
    let lineCount: Int

    func path(in rect: CGRect) -> Path {
        let top = rect.height * 0.24
        let bottom = rect.height * 0.70
        let centerY = (top + bottom) / 2
        let amplitude = max(8, (bottom - top) * 0.65)
        let width = max(rect.width, 1)
        let sampleCount = max(Int(width * 2), 36)
        let frequency: CGFloat = 1.05
        let lineOffset = CGFloat(lineIndex) / CGFloat(max(lineCount - 1, 1))
        let localPhase = phase + lineOffset * .pi * 2

        var path = Path()

        for sample in 0...sampleCount {
            let progress = CGFloat(sample) / CGFloat(sampleCount)
            let x = rect.minX + progress * rect.width
            let angle = progress * .pi * 2 * frequency + localPhase
            let modulation = sin(Double(progress * .pi * 2 + localPhase * 0.35))
            let y = centerY + sin(Double(angle)) * Double(amplitude) * (0.78 + modulation * 0.12)
            let point = CGPoint(x: x, y: CGFloat(y))

            if sample == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        return path
    }
}

struct EmergencyHoneycombCell: Equatable {
    let column: Int
    let row: Int
    let center: CGPoint
    let sideLength: CGFloat
    let label: String
    let isFilled: Bool

    var frame: CGRect {
        CGRect(
            x: center.x - sideLength,
            y: center.y - hexHeight / 2,
            width: sideLength * 2,
            height: hexHeight
        )
    }

    var hexHeight: CGFloat {
        sqrt(3) * sideLength
    }
}

struct EmergencyHoneycombLayout: Equatable {
    let containerSize: CGSize
    var diskUsageRatio: Double? = nil
    var diskIORateText: String = "R --  W --"
    let contentInset: CGFloat = 7
    let topPadding: CGFloat = 50
    let bottomPadding: CGFloat = 31
    let titleText = "DISK SPACE / 磁盘容量"
    let ioTitleText = "DISK I/O"
    let titleTopPadding: CGFloat = 34
    let ioBottomPadding: CGFloat = 8
    let titleAlignment: Alignment = .center
    let honeycombScale: CGFloat = 0.94
    let connectedBorderLineWidth: CGFloat = 4
    let cellDividerLineWidth: CGFloat = 1.2

    var ioRateText: String {
        diskIORateText
    }

    private let columnCount = 3
    private let rowCount = 7

    var cells: [EmergencyHoneycombCell] {
        let sideLength = resolvedSideLength
        let hexHeight = sqrt(3) * sideLength
        let bounds = normalizedCellBounds(sideLength: sideLength)
        let originX = -bounds.minX + max(0, (containerSize.width - bounds.width) / 2)
        let originY = topPadding - bounds.minY + max(0, (availableHeight - bounds.height) / 2)

        let filledCoordinates = Set(filledCellCoordinates)

        return includedCoordinates.map { coordinate in
                let column = coordinate.column
                let row = coordinate.row
                let x = originX + sideLength + CGFloat(column) * sideLength * 1.5
                let y = originY + hexHeight / 2 + CGFloat(row) * hexHeight + CGFloat(column) * hexHeight / 2

                return EmergencyHoneycombCell(
                    column: column,
                    row: row,
                    center: CGPoint(x: x, y: y),
                    sideLength: sideLength,
                    label: "DISK",
                    isFilled: filledCoordinates.contains(HoneycombCoordinate(column: column, row: row))
                )
        }
    }

    var filledCells: [EmergencyHoneycombCell] {
        cells.filter(\.isFilled)
    }

    var emptyCells: [EmergencyHoneycombCell] {
        cells.filter { !$0.isFilled }
    }

    var contiguousNeighborPairCount: Int {
        contiguousNeighborErrors.count
    }

    var maximumContiguousNeighborError: CGFloat {
        contiguousNeighborErrors.max() ?? 0
    }

    private var resolvedSideLength: CGFloat {
        let unitBounds = normalizedCellBounds(sideLength: 1)
        let widthBound = containerSize.width / unitBounds.width
        let heightBound = availableHeight / unitBounds.height
        return max(1, min(widthBound, heightBound) * honeycombScale)
    }

    private var availableHeight: CGFloat {
        max(1, containerSize.height - topPadding - bottomPadding)
    }

    private var contiguousNeighborErrors: [CGFloat] {
        let expectedDistance = sqrt(3) * resolvedSideLength
        var errors: [CGFloat] = []

        for leftIndex in cells.indices {
            for rightIndex in cells.index(after: leftIndex)..<cells.endIndex {
                let distance = hypot(
                    cells[leftIndex].center.x - cells[rightIndex].center.x,
                    cells[leftIndex].center.y - cells[rightIndex].center.y
                )
                let error = abs(distance - expectedDistance)

                if error <= 0.001 {
                    errors.append(error)
                }
            }
        }

        return errors
    }

    private var includedCoordinates: [HoneycombCoordinate] {
        (0..<columnCount).flatMap { column in
            (0..<rowCount).compactMap { row in
                shouldIncludeCell(column: column, row: row) ? HoneycombCoordinate(column: column, row: row) : nil
            }
        }
    }

    private var filledCellCoordinates: [HoneycombCoordinate] {
        let ratio = min(1, max(0, diskUsageRatio ?? 0))
        let filledCellCount = Int((Double(includedCoordinates.count) * ratio).rounded())
        let hexHeight = CGFloat(sqrt(3.0))

        return Array(
            includedCoordinates
                .sorted { left, right in
                    let leftY = CGFloat(left.row) * hexHeight + CGFloat(left.column) * hexHeight / 2
                    let rightY = CGFloat(right.row) * hexHeight + CGFloat(right.column) * hexHeight / 2

                    if leftY != rightY {
                        return leftY > rightY
                    }
                    return left.column < right.column
                }
                .prefix(filledCellCount)
        )
    }

    private func normalizedCellBounds(sideLength: CGFloat) -> CGRect {
        let hexHeight = sqrt(3) * sideLength
        let frames = includedCoordinates.map { coordinate in
            let center = CGPoint(
                x: sideLength + CGFloat(coordinate.column) * sideLength * 1.5,
                y: hexHeight / 2 + CGFloat(coordinate.row) * hexHeight + CGFloat(coordinate.column) * hexHeight / 2
            )

            return CGRect(
                x: center.x - sideLength,
                y: center.y - hexHeight / 2,
                width: sideLength * 2,
                height: hexHeight
            )
        }

        return frames.reduce(frames[0]) { partialResult, frame in
            partialResult.union(frame)
        }
    }

    private func shouldIncludeCell(column: Int, row: Int) -> Bool {
        switch (column, row) {
        case (0, 0), (1, 0), (0, 1), (2, 0), (2, 6):
            return false
        default:
            return true
        }
    }
}

private struct EmergencyHoneycombView: View {
    let diskUsageRatio: Double?
    let diskIORateText: String

    var body: some View {
        GeometryReader { proxy in
            let layout = EmergencyHoneycombLayout(
                containerSize: proxy.size,
                diskUsageRatio: diskUsageRatio,
                diskIORateText: diskIORateText
            )

            ZStack {
                Color.black.opacity(0.42)

                VStack(spacing: 0) {
                    Text(layout.titleText)
                        .font(.system(size: 7.6, weight: .black, design: .monospaced))
                        .foregroundStyle(NervStyle.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.28)
                        .frame(maxWidth: .infinity, alignment: layout.titleAlignment)
                        .shadow(color: NervStyle.orange.opacity(0.75), radius: 3)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, layout.contentInset)
                .padding(.top, layout.titleTopPadding)

                VStack(spacing: 2) {
                    Spacer(minLength: 0)

                    Text(layout.ioTitleText)
                        .font(.system(size: 7.6, weight: .black, design: .monospaced))
                        .foregroundStyle(NervStyle.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.28)
                        .frame(maxWidth: .infinity, alignment: layout.titleAlignment)
                        .shadow(color: NervStyle.orange.opacity(0.75), radius: 3)

                    Text(layout.ioRateText)
                        .font(.custom(MagiConsoleTypography().metricFontName, size: 10.4))
                        .fontWeight(.black)
                        .foregroundStyle(NervStyle.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.42)
                        .frame(maxWidth: .infinity, alignment: layout.titleAlignment)
                        .shadow(color: NervStyle.orange.opacity(0.75), radius: 3)
                }
                .padding(.horizontal, layout.contentInset)
                .padding(.bottom, layout.ioBottomPadding)

                ForEach(Array(layout.cells.enumerated()), id: \.offset) { _, cell in
                    EmergencyHoneycombCellView(cell: cell)
                        .frame(width: cell.frame.width, height: cell.frame.height)
                        .position(cell.center)
                }

                EmergencyHoneycombStrokeLayer(
                    cells: layout.cells,
                    color: NervStyle.red.opacity(0.82),
                    lineWidth: layout.connectedBorderLineWidth
                )
                .shadow(color: NervStyle.red.opacity(0.65), radius: 3)

                EmergencyHoneycombStrokeLayer(
                    cells: layout.cells,
                    color: Color.black.opacity(0.96),
                    lineWidth: layout.cellDividerLineWidth
                )
            }
            .clipped()
        }
        .allowsHitTesting(false)
    }
}

private struct EmergencyHoneycombStrokeLayer: View {
    let cells: [EmergencyHoneycombCell]
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
            EmergencyHoneycombHexagon()
                .stroke(color, lineWidth: lineWidth)
                .frame(width: cell.frame.width, height: cell.frame.height)
                .position(cell.center)
        }
        .allowsHitTesting(false)
    }
}

private struct EmergencyHoneycombCellView: View {
    let cell: EmergencyHoneycombCell

    var body: some View {
        ZStack {
            EmergencyHoneycombHexagon()
                .fill(fillColor)
                .shadow(color: NervStyle.red.opacity(0.42), radius: 3)

            VStack(spacing: 2) {
                Triangle()
                    .fill(Color.black.opacity(0.95))
                    .frame(width: 9, height: 6)
                Text(cell.label)
                    .font(.system(size: 6.2, weight: .black, design: .monospaced))
                    .minimumScaleFactor(0.38)
                Triangle()
                    .fill(Color.black.opacity(0.95))
                    .rotationEffect(.degrees(180))
                    .frame(width: 9, height: 6)
            }
            .lineLimit(1)
            .foregroundStyle(Color.black.opacity(0.94))
            .padding(.horizontal, 2)
        }
    }

    private var fillColor: Color {
        cell.isFilled ? NervStyle.red.opacity(0.94) : Color.black.opacity(0.18)
    }
}

private struct HoneycombCoordinate: Equatable, Hashable {
    let column: Int
    let row: Int
}

private struct EmergencyHoneycombHexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let quarterWidth = rect.width * 0.25
        let points = [
            CGPoint(x: rect.minX + quarterWidth, y: rect.minY),
            CGPoint(x: rect.maxX - quarterWidth, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.midY),
            CGPoint(x: rect.maxX - quarterWidth, y: rect.maxY),
            CGPoint(x: rect.minX + quarterWidth, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.midY)
        ]

        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct MagiAuxiliaryFramedView<Content: View>: View {
    var strokeWidth: CGFloat?
    var strokeOffsetX: CGFloat = 0
    private let content: Content

    private let metrics = MagiConsoleLayoutMetrics()

    init(
        strokeWidth: CGFloat? = nil,
        strokeOffsetX: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.strokeWidth = strokeWidth
        self.strokeOffsetX = strokeOffsetX
        self.content = content()
    }

    var body: some View {
        let resolvedStrokeWidth = strokeWidth ?? metrics.sideAuxiliaryFrameStrokeWidth

        MagiConsoleFramedChrome(
            strokeWidth: resolvedStrokeWidth,
            strokeOffsetX: strokeOffsetX
        )
        .overlay {
            content
                .frame(width: max(0, resolvedStrokeWidth - 2), height: metrics.triadOuterFrameHeight - 2)
                .offset(x: strokeOffsetX)
                .padding(.top, 1)
        }
    }
}

private extension MagiAuxiliaryFramedView where Content == EmptyView {
    init(strokeWidth: CGFloat? = nil, strokeOffsetX: CGFloat = 0) {
        self.init(strokeWidth: strokeWidth, strokeOffsetX: strokeOffsetX) {
            EmptyView()
        }
    }
}

private struct MagiTriadEmbeddedInfoColumn: View {
    let rows: [String]

    private let metrics = MagiConsoleLayoutMetrics()

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.triadEmbeddedInfoRowSpacing) {
            ForEach(rows, id: \.self) { row in
                Text(row)
                    .font(.system(size: metrics.triadEmbeddedInfoFontSize, weight: .black, design: .monospaced))
                    .foregroundStyle(NervStyle.orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: metrics.triadEmbeddedInfoLineHeight,
                        maxHeight: metrics.triadEmbeddedInfoLineHeight,
                        alignment: .leading
                    )
            }
        }
        .shadow(color: NervStyle.orange.opacity(0.68), radius: 3)
    }
}

private struct MagiConsoleFramedChrome: View {
    let strokeWidth: CGFloat
    var strokeOffsetX: CGFloat = 0
    var warningStripAnimated: Bool = false

    private let metrics = MagiConsoleLayoutMetrics()

    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .top) {
                Rectangle()
                    .strokeBorder(NervStyle.red.opacity(0.9), lineWidth: metrics.triadOuterFrameStrokeLineWidth)
                    .frame(width: strokeWidth)
                    .shadow(color: NervStyle.red.opacity(0.55), radius: 4)

                MagiWarningStrip(isAnimated: warningStripAnimated)
                    .frame(
                        width: max(0, strokeWidth - metrics.triadOuterFrameStrokeLineWidth * 2),
                        height: metrics.triadWarningStripHeight
                    )
                    .padding(.top, metrics.triadWarningStripTopInset)
            }
            .frame(width: strokeWidth)
            .offset(x: strokeOffsetX)
        }
        .background(Color.black.opacity(0.18))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MagiWarningStrip: View {
    let isAnimated: Bool
    private let stripeWidth: CGFloat = 18

    var body: some View {
        GeometryReader { proxy in
            if isAnimated {
                TimelineView(.animation) { timeline in
                    let phase = timeline.date.timeIntervalSinceReferenceDate * 30
                    let offset = phase.truncatingRemainder(dividingBy: stripeWidth)
                    MagiWarningStripPattern(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        stripeWidth: stripeWidth,
                        phaseOffset: offset
                    )
                }
            } else {
                MagiWarningStripPattern(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    stripeWidth: stripeWidth,
                    phaseOffset: 0
                )
            }
        }
        .clipped()
        .overlay(
            Rectangle()
                .strokeBorder(NervStyle.orange.opacity(0.85), lineWidth: 1)
        )
        .shadow(color: NervStyle.orange.opacity(0.65), radius: 3)
        .clipped()
    }
}

private struct MagiWarningStripPattern: View {
    let width: CGFloat
    let height: CGFloat
    let stripeWidth: CGFloat
    let phaseOffset: CGFloat

    var body: some View {
        ZStack {
            NervStyle.orange

            Path { path in
                var x = -stripeWidth + phaseOffset
                while x < width + stripeWidth {
                    path.move(to: CGPoint(x: x, y: height))
                    path.addLine(to: CGPoint(x: x + stripeWidth * 0.45, y: 0))
                    path.addLine(to: CGPoint(x: x + stripeWidth, y: 0))
                    path.addLine(to: CGPoint(x: x + stripeWidth * 0.55, y: height))
                    path.closeSubpath()
                    x += stripeWidth
                }
            }
            .fill(Color.black.opacity(0.88))
        }
        .frame(width: width, height: height)
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

            clippedUnitContent
        }
    }

    private var clippedUnitContent: some View {
        ZStack {
            unitContent
                .frame(width: contentLayout.contentWidth, height: contentLayout.contentHeight)
                .position(contentPosition)
                .shadow(color: strokeColor.opacity(0.82), radius: 7)
        }
        .clipShape(unitShape)
    }

    private var unitContent: some View {
        VStack(spacing: 4) {
            if contentLayout.titleAppearsBelowValue {
                valueBlock

                Spacer(minLength: 0)

                titleBlock
            } else {
                titleBlock

                Spacer(minLength: 0)

                valueBlock
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var titleBlock: some View {
        UnitTitleBlock(
            label: label,
            color: strokeColor,
            fontName: typography.englishFontName,
            titleFontName: typography.unitTitleFontName,
            titleSize: placement == .top ? typography.topUnitLabelSize : typography.bottomUnitLabelSize,
            subtitleSize: typography.unitSubtitleSize,
            titleScale: 0.50
        )
        .frame(height: contentLayout.titleHeight)
    }

    private var valueBlock: some View {
        DecisionPlaque(
            text: decision.primaryValue,
            color: NervStyle.orange,
            fontName: typography.metricFontName,
            fontSize: typography.metricValueSize
        )
        .frame(width: contentLayout.valueWidth)
        .frame(height: contentLayout.valueHeight)
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
    let titleFontName: String
    let titleSize: CGFloat
    let subtitleSize: CGFloat
    let titleScale: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Text(label.title)
                .font(titleFont)
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

    private var titleFont: Font {
        .custom(titleFontName, size: titleSize)
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
                    .font(.system(size: 20, weight: .black, design: .serif))
                    .foregroundStyle(NervStyle.white)
                    .lineLimit(1)

                Text(judgement.title)
                    .font(.system(size: 6.5, weight: .black, design: .monospaced))
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

        path.move(to: CGPoint(x: centerX - metrics.topUnitBottomEdgeLength / 2, y: topJoinY))
        path.addLine(to: CGPoint(x: centerX - metrics.hubTopEdgeLength / 2, y: hubTopY))

        path.move(to: CGPoint(x: centerX + metrics.topUnitBottomEdgeLength / 2, y: topJoinY))
        path.addLine(to: CGPoint(x: centerX + metrics.hubTopEdgeLength / 2, y: hubTopY))

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
