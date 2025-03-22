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
            HStack(spacing: 15) {
                
                VStack(alignment: .leading, spacing: 8) {
                    // Title and Priority with status effect
                    HStack(alignment: .top) {
                        Text(task.taskTitle ?? "Untitled")
                            .font(.headline)
                            .foregroundColor(task.isCompleted ? .gray : .primary)
                            .strikethrough(task.isCompleted)
                            .opacity(task.isCompleted ? 0.7 : 1.0)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if task.isCompleted {
                            Text("DONE!")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .clipShape(Capsule())
                        } else {
                            // Priority Badge
                            Text(priorityString(for: task.taskPriority))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(priorityColor(for: task.taskPriority).opacity(0.2))
                                .foregroundColor(priorityColor(for: task.taskPriority))
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Description if available
                    if let description = task.taskDescription, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(task.isCompleted ? .gray.opacity(0.7) : .secondary)
                            .lineLimit(2)
                    }
                    
                    // Due date with icon
                    HStack {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "calendar")
                            .font(.caption)
                            .foregroundColor(task.isCompleted ? .green : .gray)
                        
                        Text(task.taskDueDate ?? Date(), style: .date)
                            .font(.caption)
                        
                        if !task.isCompleted && isOverdue(task.taskDueDate) {
                            Text("OVERDUE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                    }
                    .foregroundColor(task.isCompleted ? .gray : .gray)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 5)
            .opacity(task.isCompleted ? 0.7 : 1.0)

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


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleTask = Task(context: context)
    sampleTask.taskTitle = "Sample Task"
    sampleTask.taskDueDate = Date()
    sampleTask.taskDescription = "This is a sample task description."
    sampleTask.isCompleted = false
    return TaskRow(task: sampleTask).environment(\.managedObjectContext, context)
}
