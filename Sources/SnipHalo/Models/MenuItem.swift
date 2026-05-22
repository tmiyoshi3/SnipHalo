import Foundation

enum MenuItemType: String, Codable, CaseIterable {
    case text
    case date
    case folder
    case separator
}

struct MenuItemConfig: Codable, Identifiable {
    var id: UUID
    var type: MenuItemType
    var title: String?
    var text: String?
    var format: String?
    var items: [MenuItemConfig]?

    var children: [MenuItemConfig]? {
        type == .folder ? (items ?? []) : nil
    }

    enum CodingKeys: String, CodingKey {
        case type, title, text, format, items
    }

    init(id: UUID = UUID(), type: MenuItemType, title: String? = nil, text: String? = nil, format: String? = nil, items: [MenuItemConfig]? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.text = text
        self.format = format
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.type = try container.decode(MenuItemType.self, forKey: .type)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.format = try container.decodeIfPresent(String.self, forKey: .format)
        self.items = try container.decodeIfPresent([MenuItemConfig].self, forKey: .items)
    }

    func deepCopy() -> MenuItemConfig {
        MenuItemConfig(
            type: type,
            title: title,
            text: text,
            format: format,
            items: items?.map { $0.deepCopy() }
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(format, forKey: .format)
        try container.encodeIfPresent(items, forKey: .items)
    }
}

enum PastePayload {
    case text(String)
    case dateFormat(String)
}
