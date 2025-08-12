import SwiftUI

extension Color {
    init(hex: String) {
        let r, g, b, a: Double
        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexColor.hasPrefix("#") { hexColor.removeFirst() }
        if hexColor.count == 6 { hexColor.append("FF") }

        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            r = Double((hexNumber & 0xFF000000) >> 24) / 255
            g = Double((hexNumber & 0x00FF0000) >> 16) / 255
            b = Double((hexNumber & 0x0000FF00) >> 8) / 255
            a = Double(hexNumber & 0x000000FF) / 255
            self = Color(red: r, green: g, blue: b, opacity: a)
            return
        }
        self = .yellow
    }

    func toHex() -> String? {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let rgba: Int = (Int)(r*255)<<24 | (Int)(g*255)<<16 | (Int)(b*255)<<8 | (Int)(a*255)
        return String(format: "#%08X", rgba)
        #else
        return nil
        #endif
    }
}


