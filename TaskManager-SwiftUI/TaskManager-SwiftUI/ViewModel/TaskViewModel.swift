//
//  TaskViewModel.swift
//  TaskManager-SwiftUI
//
//  Created by Aniket Rao on 20/03/25.
//

import SwiftUI
import CoreData

class TaskViewModel : ObservableObject {
    
    @Published var currentTab: String = "All"
    
    // MARK: New Task Properties
    @Published var openEditTask: Bool = false
    @Published var taskTitle: String = ""
    @Published var taskDescription: String = ""
    @Published var taskDueDate: Date = Date()
    @Published var taskPriority: Int16 = 0
    @Published var showDatePicker: Bool = false
    
    
    // MARK: - Editing Existing Core Data
    @Published var editTask: Task?
    @Published var taskDisplayOrder: Int16 = 0
    
    
    // MARK: - For Add and Update Task
    func addTask(context : NSManagedObjectContext) -> Bool {
        // MARK: Updating Existing Task
        var task: Task!
        
        if let editTask = editTask {
            task = editTask
            // Preserve existing display order for edits
                      taskDisplayOrder = editTask.displayOrder

        }else{
            task = Task(context: context)
            // For new tasks, get the highest display order and add 1
                        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: false)]
                        fetchRequest.fetchLimit = 1
                        
                        if let lastTask = try? context.fetch(fetchRequest).first {
                            taskDisplayOrder = lastTask.displayOrder + 1
                        }
        }
        task.taskTitle = taskTitle
        task.taskDescription = taskDescription
        task.taskDueDate = taskDueDate
        task.taskPriority = taskPriority
        task.isCompleted = false
        
        if let _ = try? context.save(){
            return true
        } else{
            return false
        }
    }
    
    // Add this new function for deleting tasks
    func deleteTask(_ task: Task, context: NSManagedObjectContext) {
        context.delete(task)
        
        if let _ = try? context.save() {
            print("Task deleted successfully")
        }
    }
    
    // MARK: - Restting Data
    func resetTaskData(){
        taskPriority = 0
        taskTitle = ""
        taskDescription = ""
        taskDueDate = Date()
        taskDisplayOrder = 0  // Reset display order

    }
    
    // MARK: - If Edit task exist
    func setUpTask(){
        if let editTask = editTask {
            taskTitle = editTask.taskTitle ?? ""
            taskDescription = editTask.taskDescription ?? ""
            taskPriority = editTask.taskPriority
            taskDueDate = editTask.taskDueDate ?? Date()
            taskDisplayOrder = editTask.displayOrder  // Preserve display order

        }
    }
    
    // MARK: - Computed Property to Display Priority as String
      var taskPriorityString: String {
          switch taskPriority {
          case 0:
              return "Low"
          case 1:
              return "Medium"
          case 2:
              return "High"
          default:
              return "Low" // Default to Low if somehow the value is invalid
          }
      }
}
