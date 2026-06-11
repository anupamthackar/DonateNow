import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Using built-in hex converter as a robust fallback to avoid Asset Catalog crashes
    let primary = ColorTheme.hex("#16a34a")
    let primaryActive = ColorTheme.hex("#15803d")
    let border = ColorTheme.hex("#e5e7eb")
    
    // We can also define fallback colors if Assets are not fully configured yet
    static func hex(_ hex: String) -> Color {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHex = cleanHex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        guard Scanner(string: cleanHex).scanHexInt64(&rgb) else {
            return .gray
        }
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }
}
