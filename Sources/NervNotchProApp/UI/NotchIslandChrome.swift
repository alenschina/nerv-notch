import SwiftUI

struct NotchIslandChromeMetrics: Equatable {
    var topCornerRadius: CGFloat
    var bottomCornerRadius: CGFloat

    init(isExpanded: Bool) {
        if isExpanded {
            self.topCornerRadius = 19
            self.bottomCornerRadius = 24
        } else {
            self.topCornerRadius = 6
            self.bottomCornerRadius = 14
        }
    }
}

struct NotchIslandShape: Shape {
    var metrics: NotchIslandChromeMetrics

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatablePair(metrics.topCornerRadius, metrics.bottomCornerRadius)
        }
        set {
            metrics.topCornerRadius = newValue.first
            metrics.bottomCornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let topRadius = min(metrics.topCornerRadius, rect.width / 2, rect.height / 2)
        let bottomRadius = min(metrics.bottomCornerRadius, rect.width / 2, rect.height / 2)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topRadius, y: rect.minY + topRadius),
            control: CGPoint(x: rect.minX + topRadius, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX + topRadius, y: rect.maxY - bottomRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topRadius + bottomRadius, y: rect.maxY),
            control: CGPoint(x: rect.minX + topRadius, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - topRadius - bottomRadius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - topRadius, y: rect.maxY - bottomRadius),
            control: CGPoint(x: rect.maxX - topRadius, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - topRadius, y: rect.minY + topRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX - topRadius, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct NotchIslandChrome: ViewModifier {
    let edgeColor: Color
    let isExpanded: Bool
    let showsScanlines: Bool

    func body(content: Content) -> some View {
        let shape = NotchIslandShape(metrics: NotchIslandChromeMetrics(isExpanded: isExpanded))

        content
            .background(
                shape
                    .fill(NervStyle.notchFill)
                    .shadow(color: .black.opacity(isExpanded ? 0.45 : 0), radius: isExpanded ? 18 : 0, x: 0, y: isExpanded ? 10 : 0)
            )
            .clipShape(shape)
            .overlay {
                if showsScanlines {
                    ScanlineOverlay()
                        .opacity(0.28)
                        .clipShape(shape)
                }
            }
            .overlay(
                shape
                    .stroke(edgeColor.opacity(0.36), lineWidth: 1)
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.white.opacity(0.06))
                    .frame(height: 1)
            }
    }
}

extension View {
    func notchIslandChrome(edgeColor: Color, isExpanded: Bool, showsScanlines: Bool = true) -> some View {
        modifier(NotchIslandChrome(edgeColor: edgeColor, isExpanded: isExpanded, showsScanlines: showsScanlines))
    }
}
