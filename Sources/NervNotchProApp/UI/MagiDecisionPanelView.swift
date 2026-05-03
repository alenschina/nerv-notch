import SwiftUI

struct MagiDecisionPanelView: View {
    let decision: MagiPanelDecision

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(decision.codeName)
                    .font(NervStyle.monoTitle)
                    .foregroundStyle(NervStyle.red)
                Spacer(minLength: 8)
                Text(decision.statusText)
                    .font(NervStyle.monoSmall)
                    .foregroundStyle(statusColor)
            }

            Text(decision.title)
                .font(NervStyle.monoSmall)
                .foregroundStyle(NervStyle.muted)

            Spacer(minLength: 4)

            Text(decision.primaryValue)
                .font(NervStyle.monoValue)
                .foregroundStyle(NervStyle.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(decision.secondaryValue)
                .font(NervStyle.monoSmall)
                .foregroundStyle(NervStyle.orange)
                .lineLimit(1)

            Divider()
                .overlay(NervStyle.red.opacity(0.65))

            Text(decision.decisionText)
                .font(NervStyle.monoSmall)
                .foregroundStyle(statusColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(minWidth: 190, minHeight: 180)
        .background(NervStyle.panelFill)
        .overlay(
            Rectangle()
                .stroke(statusColor.opacity(0.85), lineWidth: 1)
        )
    }

    private var statusColor: Color {
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
