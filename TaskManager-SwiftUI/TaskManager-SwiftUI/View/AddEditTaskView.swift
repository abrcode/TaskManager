//
//  AddEditTaskView.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 21/03/25.
//

import SwiftUI

// First, let's add a Snackbar view component
struct Snackbar: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.8))
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}

struct AddEditTaskView: View {
    @EnvironmentObject var taskModel: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var priority = "Low"
    @State private var dueDate = Date()
    @State private var showDatePicker = false
    
    // Add task parameter for edit mode
    var task: Task?
    
    // Snackbar states
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    
    // Add initializer to set up edit mode
    init(task: Task? = nil) {
        self.task = task
        let initialTitle = task?.taskTitle ?? ""
        let initialDescription = task?.taskDescription ?? ""
        let initialDueDate = task?.taskDueDate ?? Date()
        
        // Convert priority number to string
        let initialPriority: String = {
            switch task?.taskPriority {
            case 0: return "Low"
            case 1: return "Medium"
            case 2: return "High"
            default: return "Low"
            }
        }()
        
        // Initialize state properties
        _title = State(initialValue: initialTitle)
        _description = State(initialValue: initialDescription)
        _priority = State(initialValue: initialPriority)
        _dueDate = State(initialValue: initialDueDate)
    }
    
    // Update navigation title based on mode
    private var navigationTitle: String {
        task == nil ? "New Task" : "Edit Task"
    }
    
    let priorities = ["Low", "Medium", "High"]
    
    private func validateForm() -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedTitle.isEmpty {
            showError("Title cannot be empty")
            return false
        }
        
        if !description.isEmpty && trimmedDescription.isEmpty {
            showError("Description cannot contain only whitespace")
            return false
        }
        
        return true
    }
    
    private func showError(_ message: String) {
        snackbarMessage = message
        showSnackbar = true
        
        // Hide the snackbar after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSnackbar = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                VStack(spacing: 10) {
                    Text(navigationTitle)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Fill in the details below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .background(Color(UIColor.systemBackground).opacity(0.8))
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Title Field with icon
                        HStack(spacing: 15) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            TextField("Task Title", text: $title)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Description Field with icon
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                Text("Description")
                                    .font(.headline)
                            }
                            
                            TextEditor(text: $description)
                                .frame(height: 100)
                                .padding(10)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(15)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Priority Selection with animated background
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Priority Level")
                                .font(.headline)
                            
                            HStack(spacing: 12) {
                                ForEach(priorities, id: \.self) { p in
                                    PriorityButton(title: p, isSelected: priority == p) {
                                        withAnimation(.spring()) {
                                            priority = p
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Date Picker with icon
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                Text("Due Date")
                                    .font(.headline)
                            }
                            
                            DatePicker(
                                "Due Date",
                                selection: $dueDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .accentColor(.blue)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding()
                }
                
                // Save Button with gradient and animation
                Button {
                    if validateForm() {
                        withAnimation {
                            saveTask()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Task")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                      startPoint: .leading,
                                      endPoint: .trailing)
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(16)
            }
            
            // Cancel Button
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    
                    Spacer()
                }
                Spacer()
            }
            
            // Snackbar overlay
            if showSnackbar {
                VStack {
                    Spacer()
                    Snackbar(message: snackbarMessage)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: showSnackbar)
                        .padding(.bottom, 20)
                }
            }
        }
    }
    
    // Update saveTask function to handle both new and edit modes
    private func saveTask() {
        let taskToSave: Task
        
        if let existingTask = task {
            // Update existing task
            taskToSave = existingTask
        } else {
            // Create new task
            taskToSave = Task(context: viewContext)
        }
        
        // Update task properties
        taskToSave.taskTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        taskToSave.taskDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        switch priority {
        case "Low": taskToSave.taskPriority = 0
        case "Medium": taskToSave.taskPriority = 1
        case "High": taskToSave.taskPriority = 2
        default: taskToSave.taskPriority = 0
        }
        taskToSave.taskDueDate = dueDate
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            showError("Failed to save task: \(error.localizedDescription)")
        }
    }
}

// Add PriorityButton component
struct PriorityButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var color: Color {
        switch title {
        case "High": return .red
        case "Medium": return .orange
        default: return .green
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
                .animation(.spring(), value: isSelected)
        }
    }
}

// Preview remains the same

struct AddNewTask_Previews: PreviewProvider {
    static var previews: some View {
        AddEditTaskView()
            .environmentObject(TaskViewModel())
    }
}
