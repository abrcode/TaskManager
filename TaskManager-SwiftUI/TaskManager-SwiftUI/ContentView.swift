//
//  ContentView.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 20/03/25.
//

iimport SwiftUI
import CoreData

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
    @State private var isEditMode = false
    
    // FetchRequest setup
    @FetchRequest private var tasks: FetchedResults<Task>
    
    // Initialize with proper sort descriptors
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                GradientUtility.defaultGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    TaskHeaderView(completionProgress: completionProgress)
                    
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
                    .background( GradientUtility.defaultGradient)
                    .padding(.vertical, 10)
                    
                    Divider()
                        .frame(height: 1.5)
                        .overlay(Color.gray.opacity(0.3))
                        .padding(.vertical, 8)
                    
                    // Task List with Empty State
                    if filteredTasks.isEmpty {
                        EmptyStateView(message: getEmptyStateMessage(), showingAddTask: $showingAddTask)
                    } else {
                        taskListView
                    }
                }
                .background( GradientUtility.defaultGradient)
                
                AddTaskButton(showingAddTask: $showingAddTask)
            }
            .sheet(isPresented: $showingAddTask, onDismiss: handleAddTaskDismiss) {
                AddEditTaskView(task: selectedTask)
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
    
    // MARK: - Task List View
    private var taskListView: some View {
        List {
            ForEach(filteredTasks) { task in
                TaskRow(task: task)
                    .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        deleteButton(for: task)
                        editButton(for: task)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        toggleCompletionButton(for: task)
                    }
                    .onTapGesture {
                        if !isEditMode {
                            selectedTask = task
                        }
                    }
            }
            .onMove(perform: moveItems)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .background(GradientUtility.defaultGradient)
        .environment(\.editMode, .constant(reorderingTasks ? .active : .inactive))
    }
    
    // MARK: - Swipe Action Buttons
    private func deleteButton(for task: Task) -> some View {
        Button(role: .destructive) {
            deleteTask(task)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private func editButton(for task: Task) -> some View {
        Button {
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
    
    private func toggleCompletionButton(for task: Task) -> some View {
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
    
    // MARK: - Helper Functions
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
    
    private var filteredTasks: [Task] {
        switch selectedFilter {
        case .all: return Array(tasks)
        case .pending: return tasks.filter { !$0.isCompleted }
        case .completed: return tasks.filter { $0.isCompleted }
        }
    }
    
    private var completionProgress: Double {
        let totalTasks = tasks.count
        guard totalTasks > 0 else { return 0 }
        let completedTasks = tasks.filter { $0.isCompleted }.count
        return Double(completedTasks) / Double(totalTasks)
    }
    
    private func handleAddTaskDismiss() {
        if isEditMode {
            isEditMode = false
            selectedTask = nil
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        var items = filteredTasks
        items.move(fromOffsets: source, toOffset: destination)
        
        for (index, task) in items.enumerated() {
            task.displayOrder = Int16(index)
        }
        
        try? viewContext.save()
    }
    
    private func updateSortDescriptors() {
        tasks.nsSortDescriptors = sortDescriptors
    }
    
    private func deleteTask(_ task: Task) {
        withAnimation {
            viewContext.delete(task)
            try? viewContext.save()
        }
    }
    
    private func toggleTaskCompletion(_ task: Task) {
        withAnimation {
            task.isCompleted.toggle()
            try? viewContext.save()
        }
    }
    
    private func getEmptyStateMessage() -> String {
        switch selectedFilter {
        case .all:
            return "You haven't created any tasks yet.\nTap the button below to get started!"
        case .pending:
            return "No pending tasks!\nYou're all caught up."
        case .completed:
            return "No completed tasks yet.\nComplete some tasks to see them here!"
        }
    }
}
