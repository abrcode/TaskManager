//
//  ContentView.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 20/03/25.
//

import SwiftUI
import CoreData

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

// Add this enum for Priority order
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
}


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // State variables
    @State private var sortOption: SortOption = .dueDate
    @State private var sortAscending = true
    @State private var selectedTask: Task? = nil
    @State private var showingAddTask = false
    @State private var selectedFilter: TaskFilter = .all
    @Namespace private var animation
    @State private var reorderingTasks = false
    
    // Add this property to track edit mode
     @State private var isEditMode = false
    
    // FetchRequest setup
    @FetchRequest private var tasks: FetchedResults<Task>
    
    // Update the fetch request in init() to include displayOrder
        init() {
            let request = FetchRequest<Task>(
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Task.displayOrder, ascending: true),
                    NSSortDescriptor(keyPath: \Task.taskDueDate, ascending: true)
                ],
                animation: .default
            )
            self._tasks = request
        }
    
    // Update your sortDescriptors computed property
        private var sortDescriptors: [NSSortDescriptor] {
            if reorderingTasks {
                return [NSSortDescriptor(key: "displayOrder", ascending: true)]
            }
            
            switch sortOption {
            case .dueDate:
                return [NSSortDescriptor(key: "taskDueDate", ascending: sortAscending)]
            case .priority:
                return [NSSortDescriptor(key: "taskPriority", ascending: sortAscending)]
            case .alphabetical:
                return [NSSortDescriptor(key: "taskTitle", ascending: sortAscending)]
            }
        }
    
    var filteredTasks: [Task] {
        switch selectedFilter {
        case .all: return Array(tasks)
        case .pending: return tasks.filter { !$0.isCompleted }
        case .completed: return tasks.filter { $0.isCompleted }
        }
    }
    
    // Add this function to update sort when edit mode changes
        private func updateEditMode(isEditing: Bool) {
            withAnimation {
                reorderingTasks = isEditing
                if !isEditing {
                    // Reset to normal sort when exiting edit mode
                    updateSortDescriptors()
                }
            }
        }
    
    private var completionProgress: Double {
        let totalTasks = tasks.count
        guard totalTasks > 0 else { return 0 }
        let completedTasks = tasks.filter { $0.isCompleted }.count
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Add gradient background
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                                        VStack(spacing: 15) {
                                            HStack(spacing: 25) {
                                                Text("Task Manager")
                                                    .font(.system(size: 38, weight: .bold))
                                                    .foregroundColor(.primary)
                                                
                                                CircularProgressRing(progress: completionProgress, size: 50)
                                                    .animation(.spring(response: 0.6), value: completionProgress)
                                                    .padding(.vertical, 8) // Add this padding
                                            }
                                            .padding(.top, 15)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal)
                                        .padding(.bottom, 10) // Add this padding
                                        .background( LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing))
                    
                    // Filter and Sort Controls
                    VStack(spacing: 15) {
                        HStack(spacing: 10) {
                            FilterSegmentedControl(selectedFilter: $selectedFilter, animation: animation)
                            
                            SortMenuButton(sortOption: $sortOption, sortAscending: $sortAscending) {
                                updateSortDescriptors()
                            }
                        }
                        .padding(.horizontal)
                        
                        SortIndicator(sortOption: sortOption, sortAscending: sortAscending)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    .background( LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing))
                    
                    Divider()
                        .frame(height: 1.5)
                        .overlay(Color.gray.opacity(0.3))
                        .padding(.vertical, 8)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                                  startPoint: .topLeading,
                                                  endPoint: .bottomTrailing))
                    
                    // Task List
                    List {
                        ForEach(filteredTasks) { task in
                            TaskRow(task: task)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                                                .listRowSeparator(.hidden)
                                                                .listRowBackground(Color.clear)

                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    deleteTask(task)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                
                                                Button {
                                                    // First set the task, then show sheet
                                                    selectedTask = task
                                                    isEditMode = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        showingAddTask = true
                                                    }
                                                } label: {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                                .tint(.orange)
                                            }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        toggleTaskCompletion(task)
                                    } label: {
                                        Label(task.isCompleted ? "Mark Incomplete" : "Mark Complete",
                                              systemImage: task.isCompleted ? "xmark.circle" : "checkmark.circle")
                                    }
                                    .tint(task.isCompleted ?
                                          Color(uiColor: UIColor(gradient: [.systemRed, .systemPink])) :
                                          Color(uiColor: UIColor(gradient: [.systemGreen, .systemMint])))
                                }
                                .onTapGesture {
                                    if !isEditMode {
                                                       selectedTask = task
                                                   }
                                }
                        }
                        .onMove(perform: moveItems) // Add this modifier
                        .listRowSeparator(.hidden)
                    }
                    .padding(.top, 15)
                    .listStyle(.plain)
                    .background( LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing))
                    .environment(\.editMode, .constant(reorderingTasks ? EditMode.active : EditMode.inactive))

                }
                
                // Update Add Task Button with gradient
                AddTaskButton(showingAddTask: $showingAddTask)
            }
            .sheet(isPresented: $showingAddTask, onDismiss: {
                            if isEditMode {
                                isEditMode = false
                                selectedTask = nil
                            }
                        }) {
                            if let task = selectedTask {
                                AddEditTaskView(task: task)
                            } else {
                                AddEditTaskView(task: nil)
                            }
                        }
                        .navigationDestination(isPresented: Binding(
                            get: { selectedTask != nil && !isEditMode },
                            set: { if !$0 { selectedTask = nil } }
                        )) {
                            if let task = selectedTask {
                                TaskDetailView(task: task)
                            }
                        }
        }
    }
    
    // Add this function to ContentView
    private func moveItems(from source: IndexSet, to destination: Int) {
        // Create a mutable array from filteredTasks
        var items = filteredTasks
        
        // Perform the move
        items.move(fromOffsets: source, toOffset: destination)
        
        // Update the order in Core Data
        for (index, task) in items.enumerated() {
            task.displayOrder = Int16(index)
        }
        
        // Save the context
        do {
            try viewContext.save()
        } catch {
            print("Failed to save task order: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    private func updateSortDescriptors() {
        tasks.nsSortDescriptors = sortDescriptors
    }
    
    private func deleteTask(_ task: Task) {
        withAnimation {
            viewContext.delete(task)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete task: \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleTaskCompletion(_ task: Task) {
        withAnimation {
            task.isCompleted.toggle()
            do {
                try viewContext.save()
            } catch {
                print("Failed to update task: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Supporting Views
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
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                                  startPoint: .leading,
                                                  endPoint: .trailing)
                                )
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
    }
}

struct SortMenuButton: View {
    @Binding var sortOption: SortOption
    @Binding var sortAscending: Bool
    var onSort: () -> Void
    
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
                .foregroundColor(.blue)
                .frame(width: 45, height: 45)
                .background(Color.blue.opacity(0.1))
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
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct AddTaskButton: View {
    @Binding var showingAddTask: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                          startPoint: .leading,
                                          endPoint: .trailing)
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct CircularProgressRing: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.3))
                .fontWeight(.medium)
        }
        .frame(width: size, height: size)
    }
}

extension UIColor {
    convenience init(gradient colors: [UIColor]) {
        let gradientColors = colors.map { $0.cgColor }
        let gradient = CGGradient(colorsSpace: nil,
                                 colors: gradientColors as CFArray,
                                 locations: nil)!
        
        let bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.drawLinearGradient(gradient,
                                  start: CGPoint(x: 0, y: 0),
                                  end: CGPoint(x: 1, y: 0),
                                  options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(patternImage: gradientImage!)
    }
}
