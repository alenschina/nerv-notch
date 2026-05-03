import SwiftUI

enum NervStyle {
    static let background = Color(red: 0.015, green: 0.012, blue: 0.010)
    static let notchFill = Color.black.opacity(0.96)
    static let panelFill = Color(red: 0.075, green: 0.010, blue: 0.012).opacity(0.92)
    static let red = Color(red: 0.86, green: 0.02, blue: 0.02)
    static let orange = Color(red: 1.0, green: 0.48, blue: 0.06)
    static let green = Color(red: 0.18, green: 0.95, blue: 0.46)
    static let white = Color(red: 0.92, green: 0.90, blue: 0.84)
    static let muted = Color(red: 0.55, green: 0.50, blue: 0.44)

    static let mono = Font.system(.caption, design: .monospaced)
    static let monoSmall = Font.system(size: 9, weight: .medium, design: .monospaced)
    static let monoTitle = Font.system(size: 12, weight: .black, design: .monospaced)
    static let monoValue = Font.system(size: 30, weight: .black, design: .monospaced)
}
