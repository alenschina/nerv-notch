import SwiftUI

struct NotchIslandLayout: Equatable {
    let compactNotchSize: CGSize
    private let hoverExpansionWidth: CGFloat = 16

    var compactSize: CGSize {
        compactSize(isHovering: false)
    }

    func compactSize(isHovering: Bool) -> CGSize {
        let iconSpaceWidth = compactNotchSize.height * 2
        let hoverWidth = isHovering ? hoverExpansionWidth : 0
        return CGSize(
            width: compactNotchSize.width + iconSpaceWidth + hoverWidth,
            height: compactNotchSize.height
        )
    }

    var expandedSize: CGSize {
        CGSize(width: 820, height: 420)
    }
}

struct NervConsoleView: View {
    @ObservedObject var viewModel: NotchViewModel
    let layout: NotchIslandLayout

    init(viewModel: NotchViewModel, compactNotchSize: CGSize = NotchGeometry.simulatedNotchSize) {
        self.viewModel = viewModel
        self.layout = NotchIslandLayout(compactNotchSize: compactNotchSize)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            islandSurface
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeOut(duration: 0.25), value: isExpanded)
        .animation(.easeInOut(duration: 0.18), value: isCompactHovering)
    }

    private var isExpanded: Bool {
        switch viewModel.interactionState {
        case .opened, .closing:
            return true
        case .closed, .hoverArming:
            return false
        }
    }

    private var isCompactHovering: Bool {
        if case .hoverArming = viewModel.interactionState {
            return true
        }
        return false
    }

    private var islandSurface: some View {
        ZStack {
            if isExpanded {
                expandedConsole
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                compactIsland
                    .transition(.opacity)
            }
        }
        .frame(
            width: isExpanded ? layout.expandedSize.width : layout.compactSize(isHovering: isCompactHovering).width,
            height: isExpanded ? layout.expandedSize.height : layout.compactSize(isHovering: isCompactHovering).height
        )
        .notchIslandChrome(isExpanded: isExpanded)
    }

    private var expandedConsole: some View {
        VStack(spacing: 10) {
            header

            HStack(spacing: 10) {
                MagiDecisionPanelView(decision: viewModel.magiState.cpu)
                MagiDecisionPanelView(decision: viewModel.magiState.memory)
                MagiDecisionPanelView(decision: viewModel.magiState.network)
            }

            CentralDogmaJudgementView(judgement: viewModel.magiState.judgement)
        }
        .padding(14)
    }

    private var compactIsland: some View {
        HStack(spacing: 10) {
            Text("NERV")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(NervStyle.red)

            Rectangle()
                .fill(NervStyle.red.opacity(0.75))
                .frame(width: 1, height: min(16, max(8, layout.compactSize.height - 14)))

            Text(viewModel.magiState.judgement.title)
                .font(NervStyle.monoSmall)
                .foregroundStyle(compactStatusColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var header: some View {
        HStack {
            Text("NERV HQ / MAGI SYS")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundStyle(NervStyle.red)
            Spacer()
            Text(viewModel.magiState.sampledAt.formatted(date: .omitted, time: .standard))
                .font(NervStyle.monoSmall)
                .foregroundStyle(NervStyle.muted)
        }
    }

    private var compactStatusColor: Color {
        switch viewModel.magiState.judgement.level {
        case .synchronized:
            return NervStyle.green
        case .elevatedAlert:
            return NervStyle.orange
        case .emergencyMode, .partialSync:
            return NervStyle.red
        }
    }
}
