import Foundation

enum Constants {
    static let appName = "QuickSmiley"
    static let configFileName = "config.json"

    static var appSupportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(appName)
    }

    static var configFileURL: URL {
        appSupportDirectory.appendingPathComponent(configFileName)
    }

    static let defaultConfigJSON = """
    {
      "version": 1,
      "hotkey": { "key": "space", "modifiers": ["control"] },
      "items": [
        {
          "type": "folder",
          "title": "挨拶",
          "items": [
            { "type": "text", "title": "おはようございます", "text": "おはようございます。" },
            { "type": "text", "title": "お疲れ様です", "text": "お疲れ様です。\\nいつもお世話になっております。" },
            { "type": "text", "title": "よろしくお願いします", "text": "よろしくお願いいたします。" }
          ]
        },
        {
          "type": "folder",
          "title": "日付・時刻",
          "items": [
            { "type": "date", "title": "yyyy-MM-dd", "format": "yyyy-MM-dd" },
            { "type": "date", "title": "yyyy/MM/dd", "format": "yyyy/MM/dd" },
            { "type": "date", "title": "yyyy年MM月dd日", "format": "yyyy年MM月dd日" },
            { "type": "date", "title": "yyyy/MM/dd HH:mm", "format": "yyyy/MM/dd HH:mm" },
            { "type": "date", "title": "HH:mm", "format": "HH:mm" }
          ]
        },
        { "type": "separator" },
        {
          "type": "folder",
          "title": "記号・顔文字",
          "items": [
            { "type": "text", "title": "(^^)", "text": "(^^)" },
            { "type": "text", "title": "(T_T)", "text": "(T_T)" },
            { "type": "text", "title": "(´・ω・`)", "text": "(´・ω・`)" },
            { "type": "text", "title": "→", "text": "→" },
            { "type": "text", "title": "※", "text": "※" }
          ]
        },
        { "type": "separator" },
        { "type": "text", "title": "メールアドレス", "text": "user@example.com" }
      ]
    }
    """
}
