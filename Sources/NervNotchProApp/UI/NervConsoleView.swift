import SwiftUI

struct NervConsoleView: View {
    @ObservedObject var viewModel: NotchViewModel

    var body: some View {
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
}
