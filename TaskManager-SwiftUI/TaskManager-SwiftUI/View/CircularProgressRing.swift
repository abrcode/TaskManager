import SwiftUI

struct CircularProgressRing: View {
    @Environment(\.colorScheme) private var colorScheme
    let progress: Double
    let size: CGFloat
    
    private var gradientColors: [Color] {
        colorScheme == .dark ? 
            [.purple.opacity(0.8), .blue.opacity(0.8)] : 
            [.blue, .purple]
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    colorScheme == .dark ? Color.white.opacity(0.2) : Color.gray.opacity(0.2),
                    lineWidth: 4
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.3))
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
        }
        .frame(width: size, height: size)
    }
}
