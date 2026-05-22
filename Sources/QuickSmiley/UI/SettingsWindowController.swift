import AppKit
import SwiftUI

class SettingsWindowController: NSWindowController {
    convenience init(config: AppConfig, onSave: @escaping () -> Void) {
        let viewModel = SettingsViewModel(config: config)
        viewModel.onSave = onSave
        let settingsView = SettingsView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "QuickSmiley 設定"
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.setContentSize(NSSize(width: 700, height: 500))
        window.center()

        self.init(window: window)
    }
}
