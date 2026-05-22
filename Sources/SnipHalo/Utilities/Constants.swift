import Foundation

func L(_ key: String) -> String {
    NSLocalizedString(key, bundle: .main, comment: "")
}

enum Constants {
    static let appName = "SnipHalo"
    static let configFileName = "config.json"

    static var appSupportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(appName)
    }

    static var configFileURL: URL {
        appSupportDirectory.appendingPathComponent(configFileName)
    }

    static let defaultConfig = AppConfig(
        version: 1,
        hotkey: HotkeyConfig(key: "space", modifiers: ["control"]),
        items: [
            MenuItemConfig(type: .folder, title: "Greetings", items: [
                MenuItemConfig(type: .text, title: "Good morning", text: "Good morning."),
                MenuItemConfig(type: .text, title: "Thank you", text: "Thank you for your hard work.\nI appreciate your continued support."),
                MenuItemConfig(type: .text, title: "Best regards", text: "Best regards."),
            ]),
            MenuItemConfig(type: .folder, title: "Date/Time", items: [
                MenuItemConfig(type: .date, title: "yyyy-MM-dd", format: "yyyy-MM-dd"),
                MenuItemConfig(type: .date, title: "yyyy/MM/dd", format: "yyyy/MM/dd"),
                MenuItemConfig(type: .date, title: "yyyy/MM/dd HH:mm", format: "yyyy/MM/dd HH:mm"),
                MenuItemConfig(type: .date, title: "HH:mm", format: "HH:mm"),
            ]),
            MenuItemConfig(type: .separator),
            MenuItemConfig(type: .folder, title: "Symbols & Emoticons", items: [
                MenuItemConfig(type: .text, title: "(^^)", text: "(^^)"),
                MenuItemConfig(type: .text, title: "(T_T)", text: "(T_T)"),
                MenuItemConfig(type: .text, title: ":)", text: ":)"),
                MenuItemConfig(type: .text, title: "->", text: "→"),
                MenuItemConfig(type: .text, title: "*", text: "※"),
            ]),
            MenuItemConfig(type: .separator),
            MenuItemConfig(type: .text, title: "Email Address", text: "user@example.com"),
        ]
    )
}
