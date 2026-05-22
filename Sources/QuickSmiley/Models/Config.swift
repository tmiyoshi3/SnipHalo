import Foundation

struct AppConfig: Codable {
    var version: Int
    var hotkey: HotkeyConfig
    var items: [MenuItemConfig]
}

struct HotkeyConfig: Codable {
    var key: String
    var modifiers: [String]
}
