import AppKit
import ApplicationServices

class AccessibilityHelper {
    static func checkAndPrompt() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func isTrusted() -> Bool {
        return AXIsProcessTrusted()
    }
}
