import Foundation

class ConfigManager {
    static let shared = ConfigManager()

    private(set) var config: AppConfig

    private init() {
        config = AppConfig(version: 1, hotkey: HotkeyConfig(key: "space", modifiers: ["control"]), items: [])
    }

    func ensureDefaultConfig() {
        let fm = FileManager.default
        let dir = Constants.appSupportDirectory

        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        if !fm.fileExists(atPath: Constants.configFileURL.path) {
            fm.createFile(atPath: Constants.configFileURL.path, contents: Constants.defaultConfigJSON.data(using: .utf8))
            NSLog("SnipHalo: Created default config at \(Constants.configFileURL.path)")
        }
    }

    @discardableResult
    func loadConfig() -> Bool {
        do {
            let data = try Data(contentsOf: Constants.configFileURL)
            config = try JSONDecoder().decode(AppConfig.self, from: data)
            NSLog("SnipHalo: Config loaded (\(config.items.count) top-level items)")
            return true
        } catch {
            NSLog("SnipHalo: Failed to load config: \(error)")
            return false
        }
    }

    func saveConfig(_ newConfig: AppConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let data = try encoder.encode(newConfig)
        try data.write(to: Constants.configFileURL)
        config = newConfig
    }
}
