import SwiftUI

enum AppTheme {
    static let primary = Color(red: 0.11, green: 0.48, blue: 0.97)
    static let secondary = Color(red: 0.08, green: 0.74, blue: 0.67)
    static let accent = Color(red: 0.98, green: 0.54, blue: 0.33)

    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.72)

    static let chipInactive = Color.white.opacity(0.12)
    static let chipActive = Color.white.opacity(0.24)

    static let rowGradient = LinearGradient(
        colors: [Color.white.opacity(0.22), Color.white.opacity(0.12)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.11, blue: 0.20),
            Color(red: 0.07, green: 0.19, blue: 0.31),
            Color(red: 0.10, green: 0.29, blue: 0.36)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
