import AppKit

final class NervNotchApplication {
    func run() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
