//
//  TaskManager_SwiftUIUITests.swift
//  TaskManager-SwiftUIUITests
//
//  Created by Aniket Rao on 20/03/25.
//

import XCTest

class TaskManager_SwiftUIUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    // MARK: - Task Creation Tests
    func testTaskCreation() throws {
        // Tap add task button
        let addButton = app.buttons["Add Task"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        // Fill task details
        let titleTextField = app.textFields["Task Title"]
        XCTAssertTrue(titleTextField.exists)
        titleTextField.tap()
        titleTextField.typeText("Test Task")
        
        let descriptionTextView = app.textViews["Task Description"]
        XCTAssertTrue(descriptionTextView.exists)
        descriptionTextView.tap()
        descriptionTextView.typeText("This is a test task description")
        
        // Set priority
        let priorityPicker = app.segmentedControls["Priority"]
        XCTAssertTrue(priorityPicker.exists)
        priorityPicker.buttons["High"].tap()
        
        // Save task
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        // Verify task appears in list
        let taskCell = app.staticTexts["Test Task"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
    }
    
    // MARK: - Filtering Tests
    func testTaskFiltering() throws {
        // Test All Tasks
        let allFilter = app.buttons["All"]
        XCTAssertTrue(allFilter.exists)
        allFilter.tap()
        
        // Test Pending Tasks
        let pendingFilter = app.buttons["Pending"]
        XCTAssertTrue(pendingFilter.exists)
        pendingFilter.tap()
        
        // Test Completed Tasks
        let completedFilter = app.buttons["Completed"]
        XCTAssertTrue(completedFilter.exists)
        completedFilter.tap()
    }
    
    // MARK: - Sorting Tests
    func testTaskSorting() throws {
        // Open sort menu
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.exists)
        sortButton.tap()
        
        // Test different sort options
        let dueDateSort = app.buttons["Due Date"]
        XCTAssertTrue(dueDateSort.exists)
        dueDateSort.tap()
        
        let prioritySort = app.buttons["Priority"]
        XCTAssertTrue(prioritySort.exists)
        prioritySort.tap()
    }
    
    // MARK: - Animation Tests
    func testTaskCompletionAnimation() throws {
        // Create a test task if not exists
        try testTaskCreation()
        
        // Find and tap the task to open details
        let taskCell = app.staticTexts["Test Task"]
        XCTAssertTrue(taskCell.exists)
        taskCell.tap()
        
        // Test completion button animation
        let completeButton = app.buttons["Mark as Completed"]
        XCTAssertTrue(completeButton.exists)
        
        // Capture initial state
        let initialFrame = completeButton.frame
        
        // Tap the button
        completeButton.tap()
        
        // Wait for animation
        Thread.sleep(forTimeInterval: 0.5)
        
        // Verify button state changed
        let incompleteButton = app.buttons["Mark as Incomplete"]
        XCTAssertTrue(incompleteButton.exists)
    }
    
    // MARK: - Swipe Actions Tests
    func testSwipeToDelete() throws {
        // First create a test task
        try testTaskCreation()
        
        // Find the task cell
        let taskCell = app.staticTexts["Test Task"]
        XCTAssertTrue(taskCell.exists)
        
        // Perform swipe action
        taskCell.swipeLeft()
        
        // Tap delete button that appears after swipe
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()
        
        // Verify task is deleted
        XCTAssertFalse(taskCell.exists)
    }
    
    func testSwipeToEdit() throws {
        // First create a test task
        try testTaskCreation()
        
        // Find the task cell
        let taskCell = app.staticTexts["Test Task"]
        XCTAssertTrue(taskCell.exists)
        
        // Perform swipe action
        taskCell.swipeLeft()
        
        // Tap edit button that appears after swipe
        let editButton = app.buttons["Edit"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 2))
        editButton.tap()
        
        // Verify edit screen appears
        let titleTextField = app.textFields["Task Title"]
        XCTAssertTrue(titleTextField.exists)
        XCTAssertEqual(titleTextField.value as? String, "Test Task")
        
        // Edit the task
        titleTextField.tap()
        titleTextField.clearText()
        titleTextField.typeText("Updated Test Task")
        
        // Save changes
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        // Verify task was updated
        let updatedTaskCell = app.staticTexts["Updated Test Task"]
        XCTAssertTrue(updatedTaskCell.waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        //let app = XCUIApplication()
        //app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        
        // Get the coordinates of the text field
        let coordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.99, dy: 0.5))
        coordinate.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
