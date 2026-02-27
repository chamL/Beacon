import Foundation

/// Helper som henter verdier fra Keys.plist
enum Secrets {
    private static let plistName = "Keys"

    private static var dictionary: [String: Any]? = {
        guard let url = Bundle.main.url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dict = plist as? [String: Any] else {
            print("⚠️ Kunne ikke laste \(plistName).plist")
            return nil
        }
        return dict
    }()

    static func value(forKey key: String) -> String? {
        return dictionary?[key] as? String
    }
}
