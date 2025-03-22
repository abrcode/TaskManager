//
//  TaskRowView.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 21/03/25.
//

import SwiftUI

struct TaskRow: View {
    @ObservedObject var task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title with strike-through if completed
            Text(task.taskTitle ?? "Untitled")
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(.primary)
                .strikethrough(task.isCompleted)
                .padding(.bottom, 2)
            
            // Description with strike-through if completed
            if let description = task.taskDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .strikethrough(task.isCompleted)
                    .padding(.bottom, 2)
            }
            
            // Tags and Date Row combined
            HStack {
                // Priority Tag
                Text(priorityString(for: task.taskPriority))
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(priorityColor(for: task.taskPriority).opacity(0.15))
                    .foregroundColor(priorityColor(for: task.taskPriority))
                    .clipShape(Capsule())
                
                Spacer()
                
                // Date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(task.taskDueDate?.formatted(date: .numeric, time: .omitted) ?? "No date")
                        .font(.caption)
                }
                .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
        .opacity(task.isCompleted ? 0.6 : 1.0)
    }
    
    // Helper function for priority colors
    private func priorityColor(for priority: Int16) -> Color {
        switch priority {
        case 2: return .red   // High
        case 1: return .orange // Medium
        default: return .green // Low
        }
    }
    
    // Helper function to check if task is overdue
    private func isOverdue(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return date < Date() && !task.isCompleted
    }
    
    // Helper function for priority strings
    private func priorityString(for priority: Int16) -> String {
        switch priority {
        case 2: return "High"
        case 1: return "Medium"
        default: return "Low"
        }
    }
}

// Preview
struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleTask = Task(context: context)
        sampleTask.taskTitle = "Sample Task"
        sampleTask.taskDueDate = Date()
        sampleTask.taskDescription = "This is a sample task description."
        sampleTask.isCompleted = false
        return TaskRow(task: sampleTask).environment(\.managedObjectContext, context)
    }
}
