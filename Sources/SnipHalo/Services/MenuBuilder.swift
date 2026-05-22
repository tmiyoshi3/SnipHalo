import AppKit

class MenuBuilder {
    func buildMenu(from items: [MenuItemConfig], target: AnyObject, action: Selector) -> NSMenu {
        let menu = NSMenu()
        addItems(items, to: menu, target: target, action: action)
        return menu
    }

    private func addItems(_ items: [MenuItemConfig], to menu: NSMenu, target: AnyObject, action: Selector) {
        for item in items {
            switch item.type {
            case .separator:
                menu.addItem(.separator())

            case .folder:
                let menuItem = NSMenuItem(title: item.title ?? L("type.folder"), action: nil, keyEquivalent: "")
                let submenu = NSMenu(title: item.title ?? "")
                addItems(item.items ?? [], to: submenu, target: target, action: action)
                menuItem.submenu = submenu
                menu.addItem(menuItem)

            case .text:
                let menuItem = NSMenuItem(title: item.title ?? "", action: action, keyEquivalent: "")
                menuItem.target = target
                menuItem.representedObject = PastePayload.text(item.text ?? "")
                menu.addItem(menuItem)

            case .date:
                let format = item.format ?? "yyyy-MM-dd"
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "ja_JP")
                let preview = formatter.string(from: Date())
                let title = item.title ?? format
                let menuItem = NSMenuItem(title: "\(title)  \(preview)", action: action, keyEquivalent: "")
                menuItem.target = target
                menuItem.representedObject = PastePayload.dateFormat(format)
                menu.addItem(menuItem)
            }
        }
    }
}
