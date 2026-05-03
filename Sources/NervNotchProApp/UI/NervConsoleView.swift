import SwiftUI

struct NervConsoleView: View {
    @ObservedObject var viewModel: NotchViewModel

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear

            if isExpanded {
                expandedConsole
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                compactIsland
                    .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .top)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeOut(duration: 0.16), value: isExpanded)
    }

    private var isExpanded: Bool {
        switch viewModel.interactionState {
        case .opened, .closing:
            return true
        case .closed, .hoverArming:
            return false
        }
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
        .frame(width: 820, height: 420)
        .background(NervStyle.background)
        .overlay(ScanlineOverlay())
        .overlay(Rectangle().stroke(NervStyle.red, lineWidth: 2))
    }

    private var compactIsland: some View {
        HStack(spacing: 10) {
            Text("NERV")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(NervStyle.red)

            Rectangle()
                .fill(NervStyle.red.opacity(0.75))
                .frame(width: 1, height: 16)

            Text(viewModel.magiState.judgement.title)
                .font(NervStyle.monoSmall)
                .foregroundStyle(compactStatusColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 14)
        .frame(width: 224, height: 36)
        .background(Color.black.opacity(0.92))
        .overlay(ScanlineOverlay().opacity(0.35))
        .overlay(Rectangle().stroke(compactStatusColor.opacity(0.9), lineWidth: 1))
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
