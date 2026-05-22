import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var editingItem: MenuItemConfig?

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
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 0) {
            List(selection: $viewModel.selectedItemId) {
                MenuTreeView(items: viewModel.items, selectedId: $viewModel.selectedItemId)
            }
            .listStyle(.sidebar)

            Divider()
            sidebarToolbar
        }
    }

    private var sidebarToolbar: some View {
        HStack(spacing: 4) {
            Menu {
                Button("テキスト") { viewModel.addItem(type: .text) }
                Button("日付・時刻") { viewModel.addItem(type: .date) }
                Button("フォルダ") { viewModel.addItem(type: .folder) }
                Button("区切り線") { viewModel.addItem(type: .separator) }
            } label: {
                Image(systemName: "plus")
            }
            .menuStyle(.borderlessButton)
            .frame(width: 28)

            if viewModel.selectedItem?.type == .folder {
                Menu {
                    Button("テキスト") { viewModel.addItemToSelectedFolder(type: .text) }
                    Button("日付・時刻") { viewModel.addItemToSelectedFolder(type: .date) }
                    Button("フォルダ") { viewModel.addItemToSelectedFolder(type: .folder) }
                    Button("区切り線") { viewModel.addItemToSelectedFolder(type: .separator) }
                } label: {
                    Image(systemName: "plus.rectangle.on.folder")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 28)
                .help("選択中のフォルダ内に追加")
            }

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
                    Text("項目を選択してください")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }

            Spacer()
            Divider()

            HStack {
                Spacer()
                Button("保存") {
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

// MARK: - Tree view

struct MenuTreeView: View {
    let items: [MenuItemConfig]
    @Binding var selectedId: UUID?

    var body: some View {
        ForEach(items) { item in
            if item.type == .folder {
                DisclosureGroup {
                    if let children = item.items {
                        MenuTreeView(items: children, selectedId: $selectedId)
                    }
                } label: {
                    menuItemLabel(item)
                }
                .tag(item.id)
            } else {
                menuItemLabel(item)
                    .tag(item.id)
            }
        }
    }

    private func menuItemLabel(_ item: MenuItemConfig) -> some View {
        HStack(spacing: 6) {
            Image(systemName: iconName(for: item.type))
                .foregroundColor(iconColor(for: item.type))
                .frame(width: 16)
            Text(displayTitle(for: item))
                .lineLimit(1)
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
        case .separator: return "── 区切り線 ──"
        default: return item.title ?? "(無題)"
        }
    }
}

// MARK: - Item editor

struct MenuItemEditorView: View {
    @Binding var item: MenuItemConfig
    var onChange: () -> Void

    var body: some View {
        Form {
            Picker("種類", selection: $item.type) {
                Text("テキスト").tag(MenuItemType.text)
                Text("日付・時刻").tag(MenuItemType.date)
                Text("フォルダ").tag(MenuItemType.folder)
                Text("区切り線").tag(MenuItemType.separator)
            }
            .onChange(of: item.type) { _ in onChange() }

            if item.type != .separator {
                TextField("タイトル", text: Binding(
                    get: { item.title ?? "" },
                    set: { item.title = $0.isEmpty ? nil : $0 }
                ))
                .onChange(of: item.title) { _ in onChange() }
            }

            if item.type == .text {
                VStack(alignment: .leading) {
                    Text("テキスト（改行可）")
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
                TextField("フォーマット", text: Binding(
                    get: { item.format ?? "" },
                    set: { item.format = $0.isEmpty ? nil : $0 }
                ))
                .onChange(of: item.format) { _ in onChange() }

                if let fmt = item.format, !fmt.isEmpty {
                    let formatter = DateFormatter()
                    let _ = { formatter.dateFormat = fmt; formatter.locale = Locale(identifier: "ja_JP") }()
                    HStack {
                        Text("プレビュー:")
                            .foregroundColor(.secondary)
                        Text(formatter.string(from: Date()))
                            .fontWeight(.medium)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("フォーマット例")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Group {
                        Text("yyyy-MM-dd → 2026-05-22")
                        Text("yyyy/MM/dd HH:mm → 2026/05/22 14:30")
                        Text("yyyy年MM月dd日 → 2026年05月22日")
                        Text("HH:mm:ss → 14:30:00")
                        Text("E → 木 (曜日)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
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
