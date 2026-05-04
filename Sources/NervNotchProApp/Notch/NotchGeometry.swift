import CoreGraphics

struct NotchGeometry: Equatable, Sendable {
    static let simulatedNotchSize = CGSize(width: 224, height: 36)
    static let hitTestPadding = CGSize(width: 10, height: 6)

    let screenFrame: CGRect
    let notchSize: CGSize
    let windowHeight: CGFloat
    let usesSimulatedNotch: Bool

    var effectiveNotchSize: CGSize {
        if usesSimulatedNotch || notchSize == .zero {
            return Self.simulatedNotchSize
        }
        return notchSize
    }

    var notchScreenRect: CGRect {
        let size = effectiveNotchSize
        return CGRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height
        )
    }

    var compactIslandScreenRect: CGRect {
        let notch = effectiveNotchSize
        let size = CGSize(width: notch.width + notch.height * 2, height: notch.height)
        return CGRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height
        )
    }

    func openedPanelScreenRect(size: CGSize) -> CGRect {
        CGRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height
        )
    }

    func windowFrame() -> CGRect {
        CGRect(
            x: screenFrame.minX,
            y: screenFrame.maxY - windowHeight,
            width: screenFrame.width,
            height: windowHeight
        )
    }

    func isPointInNotch(_ point: CGPoint) -> Bool {
        compactIslandScreenRect
            .insetBy(dx: -Self.hitTestPadding.width, dy: -Self.hitTestPadding.height)
            .contains(point)
    }

    func isPointInOpenedPanel(_ point: CGPoint, size: CGSize) -> Bool {
        openedPanelScreenRect(size: size).contains(point)
    }
}
