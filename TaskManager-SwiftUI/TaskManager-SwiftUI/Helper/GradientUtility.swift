import SwiftUI

struct GradientUtility {
    // Update defaultGradient to use environment
    static func defaultGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: ThemeManager.Colors.gradientBackground(for: colorScheme)),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Update buttonGradient to use environment
    static func buttonGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: ThemeManager.Colors.buttonGradient(for: colorScheme)),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension UIColor {
    convenience init(gradient colors: [UIColor]) {
        let gradientColors = colors.map { $0.cgColor }
        let gradient = CGGradient(colorsSpace: nil,
                                 colors: gradientColors as CFArray,
                                 locations: nil)!
        
        let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.drawLinearGradient(gradient,
                                  start: CGPoint(x: 0, y: 0),
                                  end: CGPoint(x: 1, y: 0),
                                  options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(patternImage: gradientImage!)
    }
}
