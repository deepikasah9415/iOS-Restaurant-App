import SwiftUI

// MARK: - App Color Palette
extension Color {
    // Primary Colors
    static let primaryGreen = Color.green
    static let primaryText = Color.black
    static let secondaryText = Color.gray
    
    // UI Element Colors
    static let accentGreen = Color.green.opacity(0.15)
    static let buttonPrimary = Color.green
    static let buttonSecondary = Color.green.opacity(0.2)
    
    // Action Colors
    static let actionAdd = Color.green
    static let actionRemove = Color.red
    static let actionNotification = Color.red
    
    // Background Colors
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let pageBackground = Color(UIColor.systemGray6)
    
    // Shadow
    static let standardShadow = Color.black.opacity(0.1)
    
    // Gradient Colors
    static let overlayGradientLight = Color.black.opacity(0.3)
    static let overlayGradientDark = Color.black.opacity(0.6)
}

// MARK: - UI Constants for Consistent Design
struct UIConstants {
    // Corner Radii
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusExtraLarge: CGFloat = 20
    
    // Padding
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 12
    static let paddingStandard: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    
    // Shadow
    static let shadowRadius: CGFloat = 4
    static let shadowY: CGFloat = 2
} 