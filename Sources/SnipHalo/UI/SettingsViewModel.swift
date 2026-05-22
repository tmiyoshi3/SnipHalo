import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var items: [MenuItemConfig]
    @Published var hotkey: HotkeyConfig
    @Published var selectedItemId: UUID?

    var onSave: (() -> Void)?

    init(config: AppConfig) {
        self.items = config.items
        self.hotkey = config.hotkey
    }

    var selectedItem: MenuItemConfig? {
        guard let id = selectedItemId else { return nil }
        return findItem(id: id, in: items)
    }

    func updateSelectedItem(_ updated: MenuItemConfig) {
        guard let id = selectedItemId else { return }
        updateItem(id: id, with: updated, in: &items)
    }

    func addItem(type: MenuItemType) {
        let newItem: MenuItemConfig
        switch type {
        case .text:
            newItem = MenuItemConfig(type: .text, title: "新しいテキスト", text: "")
        case .date:
            newItem = MenuItemConfig(type: .date, title: "日付", format: "yyyy-MM-dd")
        case .folder:
            newItem = MenuItemConfig(type: .folder, title: "新しいフォルダ", items: [])
        case .separator:
            newItem = MenuItemConfig(type: .separator)
        }

        if let selectedId = selectedItemId, let parentPath = findParentPath(id: selectedId, in: items) {
            insertAfter(id: selectedId, item: newItem, at: parentPath, in: &items)
        } else if let selectedId = selectedItemId, findItem(id: selectedId, in: items)?.type == .folder {
            appendToFolder(id: selectedId, item: newItem, in: &items)
        } else {
            items.append(newItem)
        }
        selectedItemId = newItem.id
    }

    func addItemToSelectedFolder(type: MenuItemType) {
        guard let selectedId = selectedItemId,
              findItem(id: selectedId, in: items)?.type == .folder else {
            addItem(type: type)
            return
        }

        let newItem: MenuItemConfig
        switch type {
        case .text:
            newItem = MenuItemConfig(type: .text, title: "新しいテキスト", text: "")
        case .date:
            newItem = MenuItemConfig(type: .date, title: "日付", format: "yyyy-MM-dd")
        case .folder:
            newItem = MenuItemConfig(type: .folder, title: "新しいフォルダ", items: [])
        case .separator:
            newItem = MenuItemConfig(type: .separator)
        }

        appendToFolder(id: selectedId, item: newItem, in: &items)
        selectedItemId = newItem.id
    }

    func duplicateSelected() {
        guard let id = selectedItemId, let original = findItem(id: id, in: items) else { return }
        let copy = original.deepCopy()
        insertAfter(id: id, item: copy, at: true, in: &items)
        selectedItemId = copy.id
    }

    func moveItemAfter(draggedId: UUID, targetId: UUID) {
        guard draggedId != targetId else { return }
        guard let draggedItem = findItem(id: draggedId, in: items) else { return }
        if isDescendant(targetId, of: draggedId) { return }
        removeItem(id: draggedId, from: &items)
        insertAfter(id: targetId, item: draggedItem, at: true, in: &items)
        selectedItemId = draggedId
    }

    func moveItemIntoFolder(draggedId: UUID, folderId: UUID) {
        guard draggedId != folderId else { return }
        guard let draggedItem = findItem(id: draggedId, in: items) else { return }
        if isDescendant(folderId, of: draggedId) { return }
        removeItem(id: draggedId, from: &items)
        appendToFolder(id: folderId, item: draggedItem, in: &items)
        selectedItemId = draggedId
    }

    func moveItemToRoot(draggedId: UUID) {
        guard let draggedItem = findItem(id: draggedId, in: items) else { return }
        removeItem(id: draggedId, from: &items)
        items.append(draggedItem)
        selectedItemId = draggedId
    }

    func deleteSelected() {
        guard let id = selectedItemId else { return }
        removeItem(id: id, from: &items)
        selectedItemId = nil
    }

    func moveSelectedUp() {
        guard let id = selectedItemId else { return }
        moveItem(id: id, direction: -1, in: &items)
    }

    func moveSelectedDown() {
        guard let id = selectedItemId else { return }
        moveItem(id: id, direction: 1, in: &items)
    }

    func save() {
        let config = AppConfig(version: 1, hotkey: hotkey, items: items)
        do {
            try ConfigManager.shared.saveConfig(config)
            onSave?()
        } catch {
            NSLog("SnipHalo: Failed to save config: \(error)")
        }
    }

    // MARK: - Tree helpers

    private func findItem(id: UUID, in list: [MenuItemConfig]) -> MenuItemConfig? {
        for item in list {
            if item.id == id { return item }
            if let children = item.items, let found = findItem(id: id, in: children) {
                return found
            }
        }
        return nil
    }

    private func updateItem(id: UUID, with updated: MenuItemConfig, in list: inout [MenuItemConfig]) {
        for i in list.indices {
            if list[i].id == id {
                list[i] = updated
                return
            }
            if list[i].items != nil {
                updateItem(id: id, with: updated, in: &list[i].items!)
            }
        }
    }

    private func removeItem(id: UUID, from list: inout [MenuItemConfig]) {
        list.removeAll { $0.id == id }
        for i in list.indices {
            if list[i].items != nil {
                removeItem(id: id, from: &list[i].items!)
            }
        }
    }

    private func findParentPath(id: UUID, in list: [MenuItemConfig]) -> Bool? {
        for item in list {
            if item.id == id { return true }
            if let children = item.items, findParentPath(id: id, in: children) != nil {
                return true
            }
        }
        return nil
    }

    private func insertAfter(id: UUID, item: MenuItemConfig, at parentPath: Bool, in list: inout [MenuItemConfig]) {
        for i in list.indices {
            if list[i].id == id {
                list.insert(item, at: i + 1)
                return
            }
            if list[i].items != nil {
                insertAfter(id: id, item: item, at: parentPath, in: &list[i].items!)
            }
        }
    }

    private func appendToFolder(id: UUID, item: MenuItemConfig, in list: inout [MenuItemConfig]) {
        for i in list.indices {
            if list[i].id == id && list[i].type == .folder {
                if list[i].items == nil { list[i].items = [] }
                list[i].items!.append(item)
                return
            }
            if list[i].items != nil {
                appendToFolder(id: id, item: item, in: &list[i].items!)
            }
        }
    }

    private func isDescendant(_ candidateId: UUID, of ancestorId: UUID) -> Bool {
        guard let ancestor = findItem(id: ancestorId, in: items) else { return false }
        return findItem(id: candidateId, in: ancestor.items ?? []) != nil
    }

    private func moveItem(id: UUID, direction: Int, in list: inout [MenuItemConfig]) {
        for i in list.indices {
            if list[i].id == id {
                let newIndex = i + direction
                guard newIndex >= 0 && newIndex < list.count else { return }
                list.swapAt(i, newIndex)
                return
            }
            if list[i].items != nil {
                moveItem(id: id, direction: direction, in: &list[i].items!)
            }
        }
    }
}
