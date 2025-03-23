import SwiftUI

struct CircularProgressRing: View {
    // Add colorScheme environment
    @Environment(\.colorScheme) private var colorScheme
    let progress: Double
    let size: CGFloat
    
    private var ringColor: Color {
        colorScheme == .dark ? .white : .blue
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
                .stroke(ringColor, style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.3))
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
        }
        .frame(width: size, height: size)
    }
}
