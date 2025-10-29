
import SwiftUI

enum Theme {
    // Palette
    static let bg        = Color(hex: "#F3F1EC")     // warm beige background
    static let card      = Color(hex: "#FFFFFF")
    static let olive     = Color(hex: "#556B2F")     // primary
    static let oliveDark = Color(hex: "#3F521F")
    static let oliveSoft = Color(hex: "#DDE4CF")     // chips fill
    static let text      = Color(hex: "#23231F")
    static let subtext   = Color.black.opacity(0.45)
    static let border    = Color.black.opacity(0.08)

    // Typography
    static func titleXL() -> Font { .system(size: 34, weight: .bold, design: .rounded) }
    static func titleM()  -> Font { .system(size: 20, weight: .semibold, design: .rounded) }
    static func body()    -> Font { .system(size: 16, weight: .regular, design: .rounded) }
    static func label()   -> Font { .system(size: 13, weight: .medium, design: .rounded) }
}

extension Color {
    init(hex: String) {
        let v = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0; Scanner(string: v).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch v.count { case 3: (a,r,g,b)=(255,(int>>8)*17,(int>>4&0xF)*17,(int&0xF)*17)
                         case 6: (a,r,g,b)=(255,int>>16,int>>8&0xFF,int&0xFF)
                         case 8: (a,r,g,b)=(int>>24,int>>16&0xFF,int>>8&0xFF,int&0xFF)
                         default:(a,r,g,b)=(255,0,0,0) }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
