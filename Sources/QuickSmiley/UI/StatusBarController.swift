import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "face.smiling", accessibilityDescription: "QuickSmiley")
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "設定...", action: #selector(AppDelegate.openSettings), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Edit Config JSON...", action: #selector(AppDelegate.openConfigFile), keyEquivalent: "e")
        menu.addItem(withTitle: "Reload Config", action: #selector(AppDelegate.reloadConfig), keyEquivalent: "r")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit QuickSmiley", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
    }
}
