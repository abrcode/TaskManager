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
    
    // Update FetchRequest to use dynamic sort descriptors
    @State private var sortOption: SortOption = .dueDate
    @State private var sortAscending = true
    
    private var sortDescriptors: [NSSortDescriptor] {
        switch sortOption {
        case .dueDate:
            return [NSSortDescriptor(key: "taskDueDate", ascending: sortAscending)]
            
        case .priority:
            return [NSSortDescriptor(key: "taskPriority", ascending: sortAscending)]
            
        case .alphabetical:
            return [NSSortDescriptor(key: "taskTitle", ascending: sortAscending)]
        }
    }



    
    @FetchRequest private var tasks: FetchedResults<Task>
    
       
       @State private var showingAddTask = false
       @State private var selectedFilter: TaskFilter = .all
       @Namespace private var animation
    
    init() {
            let request = FetchRequest<Task>(
                sortDescriptors: [NSSortDescriptor(keyPath: \Task.taskDueDate, ascending: true)],
                animation: .default
            )
            self._tasks = request
        }
       
       var filteredTasks: [Task] {
           switch selectedFilter {
           case .all:
               return Array(tasks)
           case .pending:
               return tasks.filter { !$0.isCompleted }
           case .completed:
               return tasks.filter { $0.isCompleted }
           }
       }
    
    
    // Add computed property for progress
       private var completionProgress: Double {
           let totalTasks = tasks.count
           guard totalTasks > 0 else { return 0 }
           let completedTasks = tasks.filter { $0.isCompleted }.count
           return Double(completedTasks) / Double(totalTasks)
       }
       
       var body: some View {
           NavigationStack {
               ZStack {
                   
                   VStack(spacing: 10) {
                       
                     // Custom Header Section
                      VStack(spacing: 15) {
                          HStack(spacing: 25) {
                              Text("Task Manager")
                                  .font(.system(size: 38, weight: .bold))
                                  .foregroundColor(.primary)
                              
                              CircularProgressRing(progress: completionProgress, size: 65)
                                  .animation(.spring(response: 0.6), value: completionProgress)
                                  .padding(10)
                          }
                          .padding(.top, 15)

                      }
                      .frame(maxWidth: .infinity)
                      .padding(.horizontal)
                      .background(Color(UIColor.systemGroupedBackground))
                       
                       //ScrollView Content
                       ScrollView {
                            
                           VStack(spacing: 20) {
                               HStack {
                                   
                                   // Custom Segmented Control
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
                                                           .fill(Color.blue)
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
                                   // Sort Menu Button
                                   Menu {
                                       ForEach(SortOption.allCases, id: \.self) { option in
                                           Button {
                                               if sortOption == option {
                                                   sortAscending.toggle()
                                               } else {
                                                   sortOption = option
                                                   sortAscending = true
                                               }
                                               updateSortDescriptors()
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
                                   .padding(.leading, 8)
                                   
                               }
                               .padding(.horizontal)
                               
                               // Current sort indicator
                               HStack {
                                   Image(systemName: "arrow.up.arrow.down")
                                       .foregroundColor(.secondary)
                                   Text("Sorted by: \(sortOption.rawValue) (\(sortAscending ? "ascending" : "descending"))")
                                       .font(.caption)
                                       .foregroundColor(.secondary)
                                   Spacer()
                               }
                               .padding(.horizontal)
                               .padding(.top, -10)
                               
                               // Tasks List
                               LazyVStack(spacing: 20) {
                                   ForEach(filteredTasks) { task in
                                       NavigationLink(destination: TaskDetailView(task: task)) {
                                           TaskRow(task: task)
                                       }
                                       .buttonStyle(PlainButtonStyle())
                                       .padding()
                                       .background(Color(UIColor.systemBackground))
                                       .cornerRadius(12)
                                       .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                       // Add swipe actions
                                       .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                           // Delete button
                                           Button(role: .destructive) {
                                               deleteTask(task)
                                           } label: {
                                               Label("Delete", systemImage: "trash")
                                           }
                                           
                                           // Edit button
                                           Button {
                                               // Handle edit action
                                               showingAddTask = true
                                               // You'll need to modify AddEditTaskView to handle editing
                                           } label: {
                                               Label("Edit", systemImage: "pencil")
                                           }
                                           .tint(.orange)
                                       }
                                       .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                           // Toggle completion button
                                           Button {
                                               toggleTaskCompletion(task)
                                           } label: {
                                               Label(task.isCompleted ? "Mark Incomplete" : "Mark Complete",
                                                     systemImage: task.isCompleted ? "xmark.circle" : "checkmark.circle")
                                           }
                                           .tint(task.isCompleted ? .red : .green)
                                       }
                                   }
                               }
                               .padding(.horizontal)
                           }
                           .padding(.vertical)
                       }
                       .background(Color(UIColor.systemGroupedBackground))
                       
                   }
                
                   // Floating Action Button
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
                                   .background(Color.blue)
                                   .clipShape(Circle())
                                   .shadow(radius: 4)
                           }
                           .padding(.trailing, 20)
                           .padding(.bottom, 20)
                       }
                   }
               }
               .navigationBarTitleDisplayMode(.inline)
               .sheet(isPresented: $showingAddTask) {
                   AddEditTaskView()
               }
           }
       }
    
    private func updateSortDescriptors() {
        tasks.nsSortDescriptors = sortDescriptors
    }

    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete task: \(error.localizedDescription)")
            }
        }
    }
    
    // Add these helper functions
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
