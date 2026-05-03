import SwiftUI

struct CentralDogmaJudgementView: View {
    let judgement: CentralDogmaJudgement

    var body: some View {
        HStack(spacing: 14) {
            Text("CENTRAL DOGMA JUDGEMENT")
                .font(NervStyle.monoTitle)
                .foregroundStyle(NervStyle.red)

            Rectangle()
                .fill(NervStyle.red.opacity(0.7))
                .frame(width: 1)

            Text(judgement.title)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundStyle(color)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(judgement.summary)
                .font(NervStyle.monoSmall)
                .foregroundStyle(NervStyle.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.55))
        .overlay(Rectangle().stroke(color.opacity(0.85), lineWidth: 1))
    }

    private var color: Color {
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
