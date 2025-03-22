import SwiftUI

struct TaskHeaderView: View {
    let completionProgress: Double
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 25) {
                Text("Task Manager")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.primary)
                
                CircularProgressRing(progress: completionProgress, size: 50)
                    .animation(.spring(response: 0.6), value: completionProgress)
                    .padding(.vertical, 8)
            }
            .padding(.top, 15)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom, 10)
        .background(GradientUtility.defaultGradient)
    }
}

