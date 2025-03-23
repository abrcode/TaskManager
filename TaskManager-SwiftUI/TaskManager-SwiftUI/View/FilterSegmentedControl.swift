import SwiftUI

struct FilterSegmentedControl: View {
    @Binding var selectedFilter: TaskFilter
    @Environment(\.colorScheme) private var colorScheme  
    var animation: Namespace.ID
    
    private var capsuleGradient: LinearGradient {
        GradientUtility.buttonGradient(for: colorScheme)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedFilter == filter ? 
                        .white : 
                        (colorScheme == .dark ? .white : .primary))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background {
                        if selectedFilter == filter {
                            Capsule()
                                .fill(capsuleGradient)  
                                .matchedGeometryEffect(id: "FILTER", in: animation)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedFilter = filter
                        }
                    }
            }
        }
        .padding(3)
        .background(.clear)
    }
}
