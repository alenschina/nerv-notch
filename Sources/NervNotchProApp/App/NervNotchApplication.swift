import AppKit

final class NervNotchApplication {
    private let appDelegate = AppDelegate()

    func run() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.delegate = appDelegate
        app.run()
    }
}
