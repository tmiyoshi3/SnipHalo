import SwiftUI
import Carbon

struct HotkeyRecorderView: View {
    @Binding var hotkey: HotkeyConfig
    @State private var isRecording = false
    @State private var eventMonitor: Any?

    var body: some View {
        HStack {
            Text("ショートカットキー")

            Button(action: toggleRecording) {
                Text(isRecording ? "キーを押してください..." : hotkey.displayString)
                    .frame(minWidth: 160)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
            }
            .background(isRecording ? Color.accentColor.opacity(0.15) : Color.clear)
            .cornerRadius(6)

            if isRecording {
                Button("キャンセル") {
                    stopRecording()
                }
            }
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = modifiersFromEvent(event)
            guard !modifiers.isEmpty else {
                return nil
            }

            let key = keyNameFromEvent(event)
            hotkey = HotkeyConfig(key: key, modifiers: modifiers)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func modifiersFromEvent(_ event: NSEvent) -> [String] {
        var mods: [String] = []
        let flags = event.modifierFlags
        if flags.contains(.control) { mods.append("control") }
        if flags.contains(.option) { mods.append("option") }
        if flags.contains(.shift) { mods.append("shift") }
        if flags.contains(.command) { mods.append("command") }
        return mods
    }

    private func keyNameFromEvent(_ event: NSEvent) -> String {
        let map: [Int: String] = [
            kVK_ANSI_A: "a", kVK_ANSI_B: "b", kVK_ANSI_C: "c", kVK_ANSI_D: "d",
            kVK_ANSI_E: "e", kVK_ANSI_F: "f", kVK_ANSI_G: "g", kVK_ANSI_H: "h",
            kVK_ANSI_I: "i", kVK_ANSI_J: "j", kVK_ANSI_K: "k", kVK_ANSI_L: "l",
            kVK_ANSI_M: "m", kVK_ANSI_N: "n", kVK_ANSI_O: "o", kVK_ANSI_P: "p",
            kVK_ANSI_Q: "q", kVK_ANSI_R: "r", kVK_ANSI_S: "s", kVK_ANSI_T: "t",
            kVK_ANSI_U: "u", kVK_ANSI_V: "v", kVK_ANSI_W: "w", kVK_ANSI_X: "x",
            kVK_ANSI_Y: "y", kVK_ANSI_Z: "z",
            kVK_ANSI_0: "0", kVK_ANSI_1: "1", kVK_ANSI_2: "2", kVK_ANSI_3: "3",
            kVK_ANSI_4: "4", kVK_ANSI_5: "5", kVK_ANSI_6: "6", kVK_ANSI_7: "7",
            kVK_ANSI_8: "8", kVK_ANSI_9: "9",
            kVK_Space: "space", kVK_Return: "return", kVK_Tab: "tab",
            kVK_Escape: "escape", kVK_Delete: "delete",
            kVK_ANSI_Semicolon: ";", kVK_ANSI_Quote: "'",
            kVK_ANSI_Comma: ",", kVK_ANSI_Period: ".",
            kVK_ANSI_Slash: "/", kVK_ANSI_Backslash: "\\",
            kVK_ANSI_Minus: "-", kVK_ANSI_Equal: "=",
            kVK_ANSI_LeftBracket: "[", kVK_ANSI_RightBracket: "]",
            kVK_ANSI_Grave: "`",
            kVK_F1: "f1", kVK_F2: "f2", kVK_F3: "f3", kVK_F4: "f4",
            kVK_F5: "f5", kVK_F6: "f6", kVK_F7: "f7", kVK_F8: "f8",
            kVK_F9: "f9", kVK_F10: "f10", kVK_F11: "f11", kVK_F12: "f12",
        ]
        return map[Int(event.keyCode)] ?? "space"
    }
}

extension HotkeyConfig {
    var displayString: String {
        var parts: [String] = []
        for mod in modifiers {
            switch mod.lowercased() {
            case "control", "ctrl": parts.append("⌃")
            case "option", "alt": parts.append("⌥")
            case "shift": parts.append("⇧")
            case "command", "cmd": parts.append("⌘")
            default: break
            }
        }
        parts.append(keyDisplayName)
        return parts.joined()
    }

    private var keyDisplayName: String {
        let map: [String: String] = [
            "space": "Space", "return": "Return", "tab": "Tab",
            "escape": "Esc", "delete": "Delete",
            "f1": "F1", "f2": "F2", "f3": "F3", "f4": "F4",
            "f5": "F5", "f6": "F6", "f7": "F7", "f8": "F8",
            "f9": "F9", "f10": "F10", "f11": "F11", "f12": "F12",
        ]
        return map[key.lowercased()] ?? key.uppercased()
    }
}
