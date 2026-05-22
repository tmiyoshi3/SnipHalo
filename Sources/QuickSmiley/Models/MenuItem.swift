import Foundation

enum MenuItemType: String, Codable {
    case text
    case date
    case folder
    case separator
}

struct MenuItemConfig: Codable {
    var type: MenuItemType
    var title: String?
    var text: String?
    var format: String?
    var items: [MenuItemConfig]?
}

enum PastePayload {
    case text(String)
    case dateFormat(String)
}
