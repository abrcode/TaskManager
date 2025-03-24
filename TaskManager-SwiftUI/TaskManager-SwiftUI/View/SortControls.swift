import SwiftUI

struct SortMenuButton: View {
    @Binding var sortOption: SortOption
    @Binding var sortAscending: Bool
    var onSort: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    if sortOption == option {
                        sortAscending.toggle()
                    } else {
                        sortOption = option
                        sortAscending = true
                    }
                    onSort()
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if sortOption == option {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title3)
                .foregroundColor(colorScheme == .dark ? .white : .blue)
                .frame(width: 45, height: 45)
                .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

struct SortIndicator: View {
    let sortOption: SortOption
    let sortAscending: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(.secondary)
            Text("Sorted by: \(sortOption.rawValue) (\(sortAscending ? "ascending" : "descending"))")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
