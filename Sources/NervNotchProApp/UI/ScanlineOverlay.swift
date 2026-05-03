import SwiftUI

struct ScanlineOverlay: View {
    var body: some View {
        Canvas { context, size in
            let lineColor = Color.white.opacity(0.055)
            for y in stride(from: 0.0, through: size.height, by: 4.0) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(lineColor), lineWidth: 1)
            }

            let gridColor = NervStyle.red.opacity(0.11)
            for x in stride(from: 0.0, through: size.width, by: 24.0) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }
}
