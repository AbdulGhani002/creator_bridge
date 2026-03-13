import SwiftUI

// MARK: - App Colors & Theme

struct AppTheme {
    // Primary Colors
    static let primary = Color(red: 0.314, green: 0.282, blue: 0.902) // #5048e5
    static let primaryLight = Color(red: 0.314, green: 0.282, blue: 0.902).opacity(0.1)
    static let primaryDark = Color(red: 0.200, green: 0.157, blue: 0.690)
    
    // Background Colors
    static let backgroundLight = Color(red: 0.965, green: 0.965, blue: 0.973) // #f6f6f8
    static let backgroundDark = Color(red: 0.071, green: 0.067, blue: 0.129) // #121121
    
    // Semantic Colors
    static let successGreen = Color(red: 0.047, green: 0.667, blue: 0.416) // #0baa6a
    static let successGreenLight = Color(red: 0.047, green: 0.667, blue: 0.416).opacity(0.1)
    
    static let warningOrange = Color(red: 1.0, green: 0.584, blue: 0.0) // #ff9500
    static let warningOrangeLight = Color(red: 1.0, green: 0.584, blue: 0.0).opacity(0.1)
    
    static let errorRed = Color(red: 1.0, green: 0.231, blue: 0.188) // #ff3b30
    static let errorRedLight = Color(red: 1.0, green: 0.231, blue: 0.188).opacity(0.1)
    
    static let infoBlue = Color(red: 0.0, green: 0.478, blue: 1.0) // #0079ff
    static let infoBlueLight = Color(red: 0.0, green: 0.478, blue: 1.0).opacity(0.1)
    
    // Neutral Colors
    static let slate900 = Color(red: 0.063, green: 0.071, blue: 0.128)
    static let slate800 = Color(red: 0.110, green: 0.125, blue: 0.188)
    static let slate700 = Color(red: 0.176, green: 0.188, blue: 0.251)
    static let slate600 = Color(red: 0.384, green: 0.404, blue: 0.478)
    static let slate500 = Color(red: 0.498, green: 0.514, blue: 0.576)
    static let slate400 = Color(red: 0.635, green: 0.647, blue: 0.702)
    static let slate300 = Color(red: 0.800, green: 0.808, blue: 0.843)
    static let slate200 = Color(red: 0.902, green: 0.906, blue: 0.929)
    static let slate100 = Color(red: 0.965, green: 0.965, blue: 0.973)
    static let slate50 = Color(red: 0.988, green: 0.988, blue: 0.992)

    // Text Aliases (match usage in views)
    static let text900 = slate900
    static let text800 = slate800
    static let text700 = slate700
    static let text600 = slate600
    static let text500 = slate500
    static let text400 = slate400
    static let text300 = slate300

    // Spacing
    static let spacing1: CGFloat = 4
    static let spacing2: CGFloat = 8
    static let spacing3: CGFloat = 16
    static let spacing4: CGFloat = 24
    static let spacing5: CGFloat = 32
    static let spacing6: CGFloat = 48

    // Border Radius
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusFull: CGFloat = .infinity
    
    // Shadows
    static let shadowSm = Color.black.opacity(0.04)
    static let shadowMd = Color.black.opacity(0.08)
    static let shadowLg = Color.black.opacity(0.12)
}

// MARK: - Helper Computed Properties

extension Color {
    static let sbg = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.071, green: 0.067, blue: 0.129, alpha: 1.0) // dark
            : UIColor(red: 0.965, green: 0.965, blue: 0.973, alpha: 1.0) // light
    })
    
    static let stext = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            : UIColor(red: 0.063, green: 0.071, blue: 0.128, alpha: 1.0)
    })
}

// MARK: - Custom Color Modifier

struct ThemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(nil)
    }
}

extension View {
    func applyTheme() -> some View {
        modifier(ThemeModifier())
    }
}
