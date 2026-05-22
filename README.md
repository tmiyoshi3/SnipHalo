# SnipHalo

A macOS menu bar snippet manager. Quickly paste frequently used text and dates via a customizable hotkey.

## Features

![](screenshot.png)
- **Hotkey triggered** — Default `Ctrl+Space` (customizable in settings)
- **Text snippets** — Paste boilerplate, signatures, email addresses with one click
- **Date/Time** — Auto-insert current date/time with formats like `yyyy-MM-dd`
- **Folders** — Organize snippets hierarchically (displayed as submenus)
- **Settings UI** — Drag & drop reordering, move between folders, duplicate items
- **Clipboard preservation** — Restores original clipboard contents after paste

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9+ / Xcode Command Line Tools
- Accessibility permission (prompted on first launch)

## Build & Install

```bash
git clone <repository-url>
cd SnipHalo
./build.sh
```

This generates `SnipHalo.app`. Move it to `/Applications` and launch.

## Usage

1. Launch the app — an icon appears in the menu bar
2. Press `Ctrl+Space` to open the snippet menu
3. Click an item to paste it at the cursor position

### Status Bar Icon

| Action | Result |
|--------|--------|
| Single click | Show menu |
| Double click | Open settings |
| Right click | Show menu |

### Settings UI

Open via the menu "Settings..." or double-click the status bar icon.

- **Add items** — Click `+` to add Text / Date-Time / Folder / Separator
- **Duplicate** — Toolbar duplicate button (document icon)
- **Reorder** — Drag the handle (≡) on the right side of each row
- **Move into folder** — Drop onto a folder row
- **Move to root** — Drop onto the "Root" zone at the bottom of the list
- **Change hotkey** — Click the hotkey field at the bottom and press a new key combination

## Configuration

```
~/Library/Application Support/SnipHalo/config.json
```

A default config with sample snippets is auto-generated on first launch. You can edit via the settings UI or directly edit the JSON file (menu "Edit Config JSON...").

### Example

```json
{
  "version": 1,
  "hotkey": { "key": "space", "modifiers": ["control"] },
  "items": [
    {
      "type": "folder",
      "title": "Greetings",
      "items": [
        { "type": "text", "title": "Thank you", "text": "Thank you for your hard work.\nI appreciate your continued support." }
      ]
    },
    { "type": "date", "title": "Today", "format": "yyyy-MM-dd" },
    { "type": "separator" },
    { "type": "text", "title": "Email Address", "text": "user@example.com" }
  ]
}
```

### Item Types

| type | Description | Fields |
|------|-------------|--------|
| `text` | Text snippet | `text` — text to paste |
| `date` | Date/Time | `format` — `DateFormatter` format string |
| `folder` | Folder (submenu) | `items` — array of child items |
| `separator` | Separator line | none |

## Project Structure

```
Sources/SnipHalo/
├── main.swift
├── AppDelegate.swift
├── Models/
│   ├── Config.swift            # AppConfig, HotkeyConfig
│   └── MenuItem.swift          # MenuItemConfig, MenuItemType
├── UI/
│   ├── SettingsView.swift      # Settings screen (SwiftUI)
│   ├── SettingsViewModel.swift # Settings logic
│   ├── SettingsWindowController.swift
│   ├── StatusBarController.swift
│   └── HotkeyRecorderView.swift
├── Services/
│   ├── ConfigManager.swift     # Config read/write
│   ├── MenuBuilder.swift       # NSMenu construction
│   ├── HotkeyManager.swift     # Global hotkey (Carbon API)
│   ├── PasteService.swift      # Clipboard & paste simulation
│   └── AccessibilityHelper.swift
└── Utilities/
    └── Constants.swift
```

## Localization

Supports English (default) and Japanese. The UI language follows the system setting. To launch in a specific language:

```bash
./SnipHalo.app/Contents/MacOS/SnipHalo -AppleLanguages "(en)"
./SnipHalo.app/Contents/MacOS/SnipHalo -AppleLanguages "(ja)"
```

## License

MIT
