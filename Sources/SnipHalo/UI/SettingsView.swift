import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var editingItem: MenuItemConfig?
    @State private var draggedItemId: UUID?
    @State private var dropTargetId: UUID?
    @State private var expandedFolders: Set<UUID> = []

    private static let rootDropTargetId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    var body: some View {
        HSplitView {
            sidebar
                .frame(minWidth: 220, maxWidth: 300)

            detailPanel
                .frame(minWidth: 300)
        }
        .frame(minWidth: 600, minHeight: 450)
        .onChange(of: viewModel.selectedItemId) { _ in
            editingItem = viewModel.selectedItem
        }
        .onAppear {
            expandedFolders = Self.allFolderIds(in: viewModel.items)
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 0) {
            List(selection: $viewModel.selectedItemId) {
                ForEach(flattenedItems) { entry in
                    menuRow(entry: entry)
                        .tag(entry.item.id)
                        .onDrop(of: [.plainText], delegate: MenuItemDropDelegate(
                            targetItem: entry.item,
                            draggedItemId: $draggedItemId,
                            dropTargetId: $dropTargetId,
                            onMoveAfter: viewModel.moveItemAfter,
                            onMoveIntoFolder: viewModel.moveItemIntoFolder
                        ))
                }

                rootDropZone
            }
            .listStyle(.sidebar)

            Divider()
            sidebarToolbar
        }
    }

    private var rootDropZone: some View {
        HStack(spacing: 4) {
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            Text(L("sidebar.root"))
                .font(.caption2)
                .foregroundColor(.secondary)
            Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(dropTargetId == Self.rootDropTargetId ? Color.accentColor.opacity(0.15) : Color.clear)
        )
        .onDrop(of: [.plainText], delegate: RootDropDelegate(
            draggedItemId: $draggedItemId,
            dropTargetId: $dropTargetId,
            rootId: Self.rootDropTargetId,
            onMoveToRoot: viewModel.moveItemToRoot
        ))
    }

    private var sidebarToolbar: some View {
        HStack(spacing: 4) {
            Menu {
                Button(L("type.text")) { viewModel.addItem(type: .text) }
                Button(L("type.date")) { viewModel.addItem(type: .date) }
                Button(L("type.folder")) { viewModel.addItem(type: .folder) }
                Button(L("type.separator")) { viewModel.addItem(type: .separator) }
            } label: {
                Image(systemName: "plus")
            }
            .menuStyle(.borderlessButton)
            .frame(width: 28)

            if viewModel.selectedItem?.type == .folder {
                Menu {
                    Button(L("type.text")) { viewModel.addItemToSelectedFolder(type: .text) }
                    Button(L("type.date")) { viewModel.addItemToSelectedFolder(type: .date) }
                    Button(L("type.folder")) { viewModel.addItemToSelectedFolder(type: .folder) }
                    Button(L("type.separator")) { viewModel.addItemToSelectedFolder(type: .separator) }
                } label: {
                    Image(systemName: "plus.rectangle.on.folder")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 28)
                .help(L("toolbar.addToFolder"))
            }

            Button(action: viewModel.duplicateSelected) {
                Image(systemName: "doc.on.doc")
            }
            .disabled(viewModel.selectedItemId == nil)
            .help(L("toolbar.duplicate"))

            Button(action: viewModel.deleteSelected) {
                Image(systemName: "minus")
            }
            .disabled(viewModel.selectedItemId == nil)

            Spacer()

            Button(action: viewModel.moveSelectedUp) {
                Image(systemName: "chevron.up")
            }
            .disabled(viewModel.selectedItemId == nil)

            Button(action: viewModel.moveSelectedDown) {
                Image(systemName: "chevron.down")
            }
            .disabled(viewModel.selectedItemId == nil)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    // MARK: - Tree rendering

    private var flattenedItems: [FlatEntry] {
        Self.flatten(items: viewModel.items, depth: 0, expandedFolders: expandedFolders)
    }

    private static func flatten(items: [MenuItemConfig], depth: Int, expandedFolders: Set<UUID>) -> [FlatEntry] {
        var result: [FlatEntry] = []
        for item in items {
            result.append(FlatEntry(item: item, depth: depth))
            if item.type == .folder && expandedFolders.contains(item.id) {
                result.append(contentsOf: flatten(items: item.items ?? [], depth: depth + 1, expandedFolders: expandedFolders))
            }
        }
        return result
    }

    private static func allFolderIds(in items: [MenuItemConfig]) -> Set<UUID> {
        var ids: Set<UUID> = []
        for item in items {
            if item.type == .folder {
                ids.insert(item.id)
                if let children = item.items {
                    ids.formUnion(allFolderIds(in: children))
                }
            }
        }
        return ids
    }

    private func menuRow(entry: FlatEntry) -> some View {
        let item = entry.item
        return HStack(spacing: 4) {
            if entry.depth > 0 {
                Spacer().frame(width: CGFloat(entry.depth) * 20)
            }

            if item.type == .folder {
                Button(action: {
                    if expandedFolders.contains(item.id) {
                        expandedFolders.remove(item.id)
                    } else {
                        expandedFolders.insert(item.id)
                    }
                }) {
                    Image(systemName: expandedFolders.contains(item.id) ? "chevron.down" : "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                }
                .buttonStyle(.plain)
            } else {
                Spacer().frame(width: 12)
            }

            Image(systemName: iconName(for: item.type))
                .foregroundColor(iconColor(for: item.type))
                .frame(width: 16)

            Text(displayTitle(for: item))
                .lineLimit(1)

            Spacer()

            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.5))
                .onDrag {
                    draggedItemId = item.id
                    return NSItemProvider(object: item.id.uuidString as NSString)
                }
        }
        .padding(.vertical, 2)
        .overlay(dropIndicator(for: item))
    }

    @ViewBuilder
    private func dropIndicator(for item: MenuItemConfig) -> some View {
        if dropTargetId == item.id {
            if item.type == .folder {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.accentColor, lineWidth: 2)
            } else {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 2)
                }
            }
        }
    }

    private func iconName(for type: MenuItemType) -> String {
        switch type {
        case .text: return "doc.text"
        case .date: return "calendar"
        case .folder: return "folder"
        case .separator: return "minus"
        }
    }

    private func iconColor(for type: MenuItemType) -> Color {
        switch type {
        case .text: return .primary
        case .date: return .orange
        case .folder: return .blue
        case .separator: return .secondary
        }
    }

    private func displayTitle(for item: MenuItemConfig) -> String {
        switch item.type {
        case .separator: return L("item.separatorDisplay")
        default: return item.title ?? L("item.untitled")
        }
    }

    // MARK: - Detail panel

    private var detailPanel: some View {
        VStack {
            if let item = editingItem {
                MenuItemEditorView(item: $editingItem.withDefault(item)) {
                    if let updated = editingItem {
                        viewModel.updateSelectedItem(updated)
                    }
                }
                .id(item.id)
                .padding()
            } else {
                VStack {
                    Spacer()
                    Text(L("detail.placeholder"))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }

            Spacer()
            Divider()

            HStack {
                HotkeyRecorderView(hotkey: $viewModel.hotkey)

                Spacer()

                Button(L("button.save")) {
                    if let updated = editingItem {
                        viewModel.updateSelectedItem(updated)
                    }
                    viewModel.save()
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            .padding()
        }
    }
}

// MARK: - Flat entry

struct FlatEntry: Identifiable {
    let item: MenuItemConfig
    let depth: Int
    var id: UUID { item.id }
}

// MARK: - Item editor

struct MenuItemEditorView: View {
    @Binding var item: MenuItemConfig
    var onChange: () -> Void

    var body: some View {
        Form {
            Picker(L("editor.type"), selection: $item.type) {
                Text(L("type.text")).tag(MenuItemType.text)
                Text(L("type.date")).tag(MenuItemType.date)
                Text(L("type.folder")).tag(MenuItemType.folder)
                Text(L("type.separator")).tag(MenuItemType.separator)
            }
            .onChange(of: item.type) { _ in onChange() }

            if item.type != .separator {
                TextField(L("editor.title"), text: Binding(
                    get: { item.title ?? "" },
                    set: { item.title = $0.isEmpty ? nil : $0 }
                ))
                .onChange(of: item.title) { _ in onChange() }
            }

            if item.type == .text {
                VStack(alignment: .leading) {
                    Text(L("editor.textLabel"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: Binding(
                        get: { item.text ?? "" },
                        set: { item.text = $0.isEmpty ? nil : $0 }
                    ))
                    .font(.body.monospaced())
                    .frame(minHeight: 120)
                    .border(Color.secondary.opacity(0.3))
                    .onChange(of: item.text) { _ in onChange() }
                }
            }

            if item.type == .date {
                TextField(L("editor.format"), text: Binding(
                    get: { item.format ?? "" },
                    set: { item.format = $0.isEmpty ? nil : $0 }
                ))
                .onChange(of: item.format) { _ in onChange() }

                if let fmt = item.format, !fmt.isEmpty {
                    let formatter = DateFormatter()
                    let _ = { formatter.dateFormat = fmt; formatter.locale = Locale(identifier: "ja_JP") }()
                    HStack {
                        Text(L("editor.preview"))
                            .foregroundColor(.secondary)
                        Text(formatter.string(from: Date()))
                            .fontWeight(.medium)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L("editor.formatExamples"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Group {
                        Text(L("editor.formatEx1"))
                        Text(L("editor.formatEx2"))
                        Text(L("editor.formatEx3"))
                        Text(L("editor.formatEx4"))
                        Text(L("editor.formatEx5"))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Drop delegates

struct MenuItemDropDelegate: DropDelegate {
    let targetItem: MenuItemConfig
    @Binding var draggedItemId: UUID?
    @Binding var dropTargetId: UUID?
    let onMoveAfter: (UUID, UUID) -> Void
    let onMoveIntoFolder: (UUID, UUID) -> Void

    func dropEntered(info: DropInfo) {
        dropTargetId = targetItem.id
    }

    func dropExited(info: DropInfo) {
        if dropTargetId == targetItem.id {
            dropTargetId = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedId = draggedItemId, draggedId != targetItem.id else { return false }
        if targetItem.type == .folder {
            onMoveIntoFolder(draggedId, targetItem.id)
        } else {
            onMoveAfter(draggedId, targetItem.id)
        }
        draggedItemId = nil
        dropTargetId = nil
        return true
    }
}

struct RootDropDelegate: DropDelegate {
    @Binding var draggedItemId: UUID?
    @Binding var dropTargetId: UUID?
    let rootId: UUID
    let onMoveToRoot: (UUID) -> Void

    func dropEntered(info: DropInfo) {
        dropTargetId = rootId
    }

    func dropExited(info: DropInfo) {
        if dropTargetId == rootId {
            dropTargetId = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedId = draggedItemId else { return false }
        onMoveToRoot(draggedId)
        draggedItemId = nil
        dropTargetId = nil
        return true
    }
}

// MARK: - Optional binding helper

extension Optional {
    func withDefault(_ defaultValue: Wrapped) -> Binding<Wrapped> where Wrapped: Any {
        fatalError("Use Binding($optional.withDefault) instead")
    }
}

extension Binding where Value == MenuItemConfig? {
    func withDefault(_ defaultValue: MenuItemConfig) -> Binding<MenuItemConfig> {
        Binding<MenuItemConfig>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
