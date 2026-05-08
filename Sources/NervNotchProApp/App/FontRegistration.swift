import CoreText
import Foundation

enum FontRegistration {
    static func registerBundledFonts() {
        guard let fontsURL = Bundle.module.resourceURL?.appendingPathComponent("fonts") else { return }

        guard CTFontManagerRegisterFontsForURL(fontsURL as CFURL, .process, nil) else {
            // Registration failure is non-fatal; the app falls back to available fonts.
            return
        }
    }
}
