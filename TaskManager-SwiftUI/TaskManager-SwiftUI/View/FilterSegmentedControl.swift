import SwiftUI

struct FilterSegmentedControl: View {
    @Binding var selectedFilter: TaskFilter
    var animation: Namespace.ID
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background {
                        if selectedFilter == filter {
                            Capsule()
                                .fill(GradientUtility.buttonGradient)
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
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(GradientUtility.defaultGradient)
        )
    }
}
