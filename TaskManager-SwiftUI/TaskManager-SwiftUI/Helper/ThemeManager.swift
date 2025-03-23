import SwiftUI

struct ThemeManager {
    static let shared = ThemeManager()
    
    struct Colors {
        // Background colors
        static func gradientBackground(for colorScheme: ColorScheme) -> [Color] {
            switch colorScheme {
            case .dark:
                return [.blue.opacity(0.2), .purple.opacity(0.2)]
            case .light:
                return [.blue.opacity(0.1), .purple.opacity(0.1)]
            @unknown default:
                return [.blue.opacity(0.1), .purple.opacity(0.1)]
            }
        }
        
        // Button colors
        static func buttonGradient(for colorScheme: ColorScheme) -> [Color] {
            switch colorScheme {
            case .dark:
                return [.blue.opacity(0.8), .purple.opacity(0.8)]
            case .light:
                return [.blue, .purple]
            @unknown default:
                return [.blue, .purple]
            }
        }
    }
}

