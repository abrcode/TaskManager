import SwiftUI

struct EmptyStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: String
    @Binding var showingAddTask: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Bouncing checklist icon
            Image(systemName: "checklist")
                .font(.system(size: 70))
                .foregroundColor(Color.purple.opacity(0.7))
                .symbolEffect(.bounce)
            
            // Message text
            Text(message)
                .font(.system(size: 20))
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientUtility.defaultGradient(for: colorScheme))
    }
}
