import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?
    private var clickCount = 0
    private var clickTimer: Timer?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            if let resourcePath = Bundle.main.path(forResource: "StatusBarIconTemplate", ofType: "png"),
               let icon = NSImage(contentsOfFile: resourcePath) {
                icon.isTemplate = true
                icon.size = NSSize(width: 18, height: 18)
                button.image = icon
            } else {
                button.image = NSImage(systemSymbolName: "face.smiling", accessibilityDescription: "SnipHalo")
            }
            button.action = #selector(statusItemClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        statusMenu = NSMenu()
        statusMenu!.addItem(withTitle: L("menu.settings"), action: #selector(AppDelegate.openSettings), keyEquivalent: ",")
        statusMenu!.addItem(.separator())
        statusMenu!.addItem(withTitle: L("menu.editConfig"), action: #selector(AppDelegate.openConfigFile), keyEquivalent: "e")
        statusMenu!.addItem(withTitle: L("menu.reloadConfig"), action: #selector(AppDelegate.reloadConfig), keyEquivalent: "r")
        statusMenu!.addItem(.separator())
        statusMenu!.addItem(withTitle: L("menu.quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
            return
        }

        clickCount += 1
        if clickCount == 1 {
            clickTimer = Timer.scheduledTimer(withTimeInterval: NSEvent.doubleClickInterval, repeats: false) { [weak self] _ in
                self?.clickCount = 0
                self?.showMenu()
            }
        } else {
            clickTimer?.invalidate()
            clickCount = 0
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.openSettings()
            }
        }
    }

    private func showMenu() {
        guard let button = statusItem?.button, let menu = statusMenu else { return }
        statusItem?.menu = menu
        button.performClick(nil)
        statusItem?.menu = nil
    }
}
