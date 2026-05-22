import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private let configManager = ConfigManager.shared
    private let hotkeyManager = HotkeyManager()
    private let menuBuilder = MenuBuilder()
    private let pasteService = PasteService()

    private var snippetMenu: NSMenu?
    private var isMenuShowing = false
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = AccessibilityHelper.checkAndPrompt()

        configManager.ensureDefaultConfig()
        configManager.loadConfig()

        rebuildMenu()

        hotkeyManager.onHotkeyTriggered = { [weak self] in
            self?.showSnippetMenu()
        }
        hotkeyManager.register(config: configManager.config.hotkey)

        statusBarController = StatusBarController()
        statusBarController.setup()
    }

    @objc func reloadConfig() {
        configManager.loadConfig()
        rebuildMenu()
        hotkeyManager.register(config: configManager.config.hotkey)
        NSLog("QuickSmiley: Config reloaded and menu rebuilt")
    }

    @objc func menuItemSelected(_ sender: NSMenuItem) {
        guard let payload = sender.representedObject as? PastePayload else { return }

        let text: String
        switch payload {
        case .text(let t):
            text = t
        case .dateFormat(let fmt):
            let formatter = DateFormatter()
            formatter.dateFormat = fmt
            formatter.locale = Locale(identifier: "ja_JP")
            text = formatter.string(from: Date())
        }

        if !AccessibilityHelper.isTrusted() {
            NSLog("QuickSmiley: Accessibility permission not granted, cannot paste")
            _ = AccessibilityHelper.checkAndPrompt()
            return
        }

        pasteService.pasteText(text)
    }

    @objc func openConfigFile() {
        NSWorkspace.shared.open(Constants.configFileURL)
    }

    @objc func openSettings() {
        if let controller = settingsWindowController {
            controller.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let controller = SettingsWindowController(config: configManager.config) { [weak self] in
            self?.reloadConfig()
        }
        settingsWindowController = controller
        controller.window?.delegate = self
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func showSnippetMenu() {
        guard !isMenuShowing, snippetMenu != nil else { return }
        isMenuShowing = true

        rebuildMenu()
        guard let freshMenu = snippetMenu else {
            isMenuShowing = false
            return
        }

        let mouseLocation = NSEvent.mouseLocation

        let window = NSWindow(
            contentRect: NSRect(x: mouseLocation.x, y: mouseLocation.y - 1, width: 1, height: 1),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .popUpMenu
        window.orderFrontRegardless()

        freshMenu.popUp(positioning: nil, at: .zero, in: window.contentView)

        window.orderOut(nil)
        isMenuShowing = false
    }

    private func rebuildMenu() {
        snippetMenu = menuBuilder.buildMenu(
            from: configManager.config.items,
            target: self,
            action: #selector(menuItemSelected(_:))
        )
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        settingsWindowController = nil
    }
}
