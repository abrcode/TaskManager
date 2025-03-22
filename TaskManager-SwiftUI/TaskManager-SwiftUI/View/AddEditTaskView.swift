//
//  AddEditTaskView.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 21/03/25.
//

import SwiftUI

// Your imports remain the same

//struct AddEditTaskView: View {
//    @EnvironmentObject var taskModel: TaskViewModel
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.managedObjectContext) var viewContext
//    
//    @State private var title = ""
//    @State private var description = ""
//    @State private var priority = "Low"
//    @State private var dueDate = Date()
//    @State private var showDatePicker = false
//    
//    // Validation states
//    @State private var showTitleError = false
//    @State private var showDescriptionError = false
//    @State private var titleErrorMessage = ""
//    @State private var descriptionErrorMessage = ""
//    
//    var isFormValid: Bool {
//            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
//            let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            // Reset error states
//            showTitleError = false
//            showDescriptionError = false
//            
//            // Validate title
//            if trimmedTitle.isEmpty {
//                titleErrorMessage = "Title cannot be empty"
//                showTitleError = true
//                return false
//            }
//            
//            // Validate description (optional but can't be only whitespace if provided)
//            if !description.isEmpty && trimmedDescription.isEmpty {
//                descriptionErrorMessage = "Description cannot contain only whitespace"
//                showDescriptionError = true
//                return false
//            }
//            
//            return true
//        }
//    
//    
//    let priorities = ["Low", "Medium", "High"]
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                // Title Section
//                Section(header: Text("Title").foregroundColor(.gray)) {
//                    TextField("Required", text: $title)
//                }
//                
//                // Description Section
//                Section(header: Text("Description").foregroundColor(.gray)) {
//                    TextEditor(text: $description)
//                        .frame(height: 100)
//                }
//                
//                // Priority Section
//                Section(header: Text("Priority").foregroundColor(.gray)) {
//                    Picker("Priority", selection: $priority) {
//                        ForEach(priorities, id: \.self) { priority in
//                            Text(priority)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                }
//                
//                // Due Date Section
//                Section(header: Text("Due Date").foregroundColor(.gray)) {
//                    DatePicker(
//                        "Due Date",
//                        selection: $dueDate,
//                        displayedComponents: [.date]
//                    )
//                }
//            }
//            .navigationTitle("New Task")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        saveTask()
//                    }
//                    .disabled(title.isEmpty)
//                }
//            }
//        }
//    }
//    
//    private func saveTask() {
//        let task = Task(context: viewContext)
//        task.taskTitle = title
//        task.taskDescription = description
//        switch priority {
//           case "Low":
//               task.taskPriority = 0 // Low -> 0
//           case "Medium":
//               task.taskPriority = 1 // Medium -> 1
//           case "High":
//               task.taskPriority = 2 // High -> 2
//           default:
//               task.taskPriority = 0 // Default to Low if an unexpected value occurs
//           }
//        task.taskDueDate = dueDate
//        task.isCompleted = false
//        
//        do {
//            try viewContext.save()
//            dismiss()
//        } catch {
//            print("Error saving task: \(error)")
//        }
//    }
//}

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
    
    // Snackbar states
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    
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
        NavigationStack {
            ZStack {
                // Main content
                Form {
                    // Title Section
                    Section(header: Text("Title").foregroundColor(.gray)) {
                        TextField("Required", text: $title)
                    }
                    
                    // Description Section
                    Section(header: Text("Description").foregroundColor(.gray)) {
                        TextEditor(text: $description)
                            .frame(height: 100)
                    }
                    
                    // Priority Section
                    Section(header: Text("Priority").foregroundColor(.gray)) {
                        Picker("Priority", selection: $priority) {
                            ForEach(priorities, id: \.self) { priority in
                                Text(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Due Date Section
                    Section(header: Text("Due Date").foregroundColor(.gray)) {
                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                    }
                }
                .navigationTitle("New Task")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            if validateForm() {
                                saveTask()
                            }
                        }
                    }
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
    }
    
    private func saveTask() {
        let task = Task(context: viewContext)
        task.taskTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.taskDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        switch priority {
        case "Low":
            task.taskPriority = 0
        case "Medium":
            task.taskPriority = 1
        case "High":
            task.taskPriority = 2
        default:
            task.taskPriority = 0
        }
        task.taskDueDate = dueDate
        task.isCompleted = false
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            showError("Failed to save task: \(error.localizedDescription)")
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
