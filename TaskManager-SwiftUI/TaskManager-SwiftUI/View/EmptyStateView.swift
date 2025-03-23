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
                .foregroundColor(Color.blue.opacity(0.7))
                .symbolEffect(.bounce)
            
            // Message text
            Text(message)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
//
//            // Create task button with gradient
//            Button {
//                showingAddTask = true
//            } label: {
//                HStack(spacing: 8) {
//                    Image(systemName: "plus.circle.fill")
//                    Text("Create New Task")
//                }
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 12)
//                .background(GradientUtility.buttonGradient)
//                .cornerRadius(25)
//            }
//            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientUtility.defaultGradient(for: colorScheme))
    }
}
