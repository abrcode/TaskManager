import Foundation
import SwiftUI

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case completed = "Completed"
}

enum SortOption: String, CaseIterable {
    case dueDate = "Due Date"
    case priority = "Priority"
    case alphabetical = "Alphabetical"
}

enum TaskPriority: Int, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

