//
//  TaskDetailView.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 21/03/25.
//

import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(task.taskTitle ?? "Untitled")
                            .font(.title)
                            .bold()
                        Spacer()
                        PriorityBadge(priority: priorityString(for: task.taskPriority))
                    }
                    
                    Text("Due " + formattedDate(task.taskDueDate))
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .white : .gray)
                }
                .padding()
                .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color(UIColor.systemBackground))
                .cornerRadius(15)
                .shadow(color: (colorScheme == .dark ? Color.white : Color.black).opacity(0.09),
                        radius: 8, x: 0, y: 2)
                
                // Description Card
                if let description = task.taskDescription, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                        
                        Text(description)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color(UIColor.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: (colorScheme == .dark ? Color.white : Color.black).opacity(0.09),
                            radius: 8, x: 0, y: 2)
                }
                
                // Action Button
                Button(action: { toggleCompletion() }) {
                    HStack {
                        Image(systemName: task.isCompleted ? "xmark.circle" : "checkmark.circle")
                        Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Completed")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [
                            task.isCompleted ? .red : .green,
                            task.isCompleted ? .pink : .mint
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing)
                    )
                    .foregroundColor(colorScheme == .dark ? .white : .white)
                    .cornerRadius(15)
                    .shadow(color: (task.isCompleted ? Color.red : Color.green).opacity(0.3),
                            radius: 8, x: 0, y: 4)
                }
                .padding(.top)
            }
            .padding()
        }
        .background(GradientUtility.defaultGradient(for: colorScheme)
            .ignoresSafeArea())
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleCompletion() {
        task.isCompleted.toggle()
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to update task: \(error.localizedDescription)")
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "No Due Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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

// Add this helper view for priority badge
struct PriorityBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let priority: String
    
    var backgroundColor: Color {
        switch priority {
        case "High": return .red.opacity(0.2)
        case "Medium": return .orange.opacity(0.2)
        default: return .green.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        default: return .green
        }
    }
    
    var body: some View {
        Text(priority)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(colorScheme == .dark ? .white : textColor)
            .clipShape(Capsule())
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleTask = Task(context: context)
    sampleTask.taskTitle = "Sample Task"
    sampleTask.taskDueDate = Date()
    sampleTask.taskDescription = "This is a sample task description."
    sampleTask.isCompleted = false
    return TaskDetailView(task: sampleTask).environment(\.managedObjectContext, context)
}
