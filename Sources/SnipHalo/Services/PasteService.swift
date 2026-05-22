import AppKit
import Carbon

class PasteService {
    private struct PasteboardSnapshot {
        struct Item {
            var types: [NSPasteboard.PasteboardType]
            var dataByType: [NSPasteboard.PasteboardType: Data]
        }
        var items: [Item]
    }

    func pasteText(_ text: String) {
        let snapshot = savePasteboard()

        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
            simulatePaste()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.restorePasteboard(snapshot)
            }
        }
    }

    private func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false) else {
            NSLog("SnipHalo: Failed to create CGEvent for paste")
            return
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: .cgAnnotatedSessionEventTap)
        keyUp.post(tap: .cgAnnotatedSessionEventTap)
    }

    private func savePasteboard() -> PasteboardSnapshot {
        let pb = NSPasteboard.general
        var items: [PasteboardSnapshot.Item] = []

        for pbItem in pb.pasteboardItems ?? [] {
            var dataByType: [NSPasteboard.PasteboardType: Data] = [:]
            for type in pbItem.types {
                if let data = pbItem.data(forType: type) {
                    dataByType[type] = data
                }
            }
            items.append(.init(types: pbItem.types, dataByType: dataByType))
        }

        return PasteboardSnapshot(items: items)
    }

    private func restorePasteboard(_ snapshot: PasteboardSnapshot) {
        guard !snapshot.items.isEmpty else { return }

        let pb = NSPasteboard.general
        pb.clearContents()

        var newItems: [NSPasteboardItem] = []
        for savedItem in snapshot.items {
            let item = NSPasteboardItem()
            for type in savedItem.types {
                if let data = savedItem.dataByType[type] {
                    item.setData(data, forType: type)
                }
            }
            newItems.append(item)
        }

        pb.writeObjects(newItems)
    }
}
