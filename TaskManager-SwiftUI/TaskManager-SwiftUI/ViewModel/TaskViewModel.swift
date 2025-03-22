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
    
    
    // MARK: - For Add and Update Task
    func addTask(context : NSManagedObjectContext) -> Bool {
        // MARK: Updating Existing Task
        var task: Task!
        
        if let editTask = editTask {
            task = editTask
        }else{
            task = Task(context: context)
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
    
    
    // MARK: - Restting Data
    func resetTaskData(){
        taskPriority = 0
        taskTitle = ""
        taskDescription = ""
        taskDueDate = Date()
    }
    
    // MARK: - If Edit task exist
    func setUpTask(){
        if let editTask = editTask {
            taskTitle = editTask.taskTitle ?? ""
            taskDescription = editTask.taskDescription ?? ""
            taskPriority = editTask.taskPriority
            taskDueDate = editTask.taskDueDate ?? Date()
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
