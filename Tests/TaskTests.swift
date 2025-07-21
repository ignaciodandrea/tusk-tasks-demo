import Testing
import Foundation
@testable import TuskAppCore

/// Comprehensive unit tests for the Task model
/// Demonstrates various testing scenarios including edge cases, business logic validation,
/// and computed properties behavior
@Suite("Task Model Tests")
struct TaskTests {
    
    // MARK: - Initialization Tests
    
    @Test("Task initializes with default values correctly")
    func taskInitializationWithDefaults() {
        // Given
        let title = "Test Task"
        
        // When
        let task = Task(title: title)
        
        // Then
        #expect(task.title == title)
        #expect(task.description == "")
        #expect(task.isCompleted == false)
        #expect(task.priority == .medium)
        #expect(task.category == .personal)
        #expect(task.dueDate == nil)
        #expect(task.completedAt == nil)
        #expect(task.id != UUID())  // Should be unique
    }
    
    @Test("Task initializes with custom values correctly")
    func taskInitializationWithCustomValues() {
        // Given
        let title = "Custom Task"
        let description = "Task description"
        let priority = TaskPriority.high
        let category = TaskCategory.work
        let dueDate = Date().addingTimeInterval(86400) // 1 day from now
        
        // When
        let task = Task(
            title: title,
            description: description,
            priority: priority,
            category: category,
            dueDate: dueDate
        )
        
        // Then
        #expect(task.title == title)
        #expect(task.description == description)
        #expect(task.priority == priority)
        #expect(task.category == category)
        #expect(task.dueDate == dueDate)
        #expect(task.isCompleted == false)
        #expect(task.completedAt == nil)
    }
    
    // MARK: - Completion Tests
    
    @Test("Task can be marked as completed")
    func markTaskAsCompleted() {
        // Given
        var task = Task(title: "Test Task")
        #expect(task.isCompleted == false)
        #expect(task.completedAt == nil)
        
        // When
        task.complete()
        
        // Then
        #expect(task.isCompleted == true)
        #expect(task.completedAt != nil)
        #expect(task.completedAt! <= Date()) // Should be recent
    }
    
    @Test("Task can be unmarked as completed")
    func unmarkTaskAsCompleted() {
        // Given
        var task = Task(title: "Test Task")
        task.complete() // First complete it
        #expect(task.isCompleted == true)
        #expect(task.completedAt != nil)
        
        // When
        task.uncomplete()
        
        // Then
        #expect(task.isCompleted == false)
        #expect(task.completedAt == nil)
    }
    
    // MARK: - Due Date Logic Tests
    
    @Test("Task without due date is not overdue")
    func taskWithoutDueDateIsNotOverdue() {
        // Given
        let task = Task(title: "Test Task")
        
        // Then
        #expect(task.isOverdue == false)
        #expect(task.isDueSoon == false)
    }
    
    @Test("Completed task is never overdue")
    func completedTaskIsNeverOverdue() {
        // Given
        var task = Task(
            title: "Test Task",
            dueDate: Date().addingTimeInterval(-86400) // 1 day ago
        )
        task.complete()
        
        // Then
        #expect(task.isOverdue == false)
        #expect(task.isDueSoon == false)
    }
    
    @Test("Task with past due date is overdue")
    func taskWithPastDueDateIsOverdue() {
        // Given
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let task = Task(title: "Test Task", dueDate: pastDate)
        
        // Then
        #expect(task.isOverdue == true)
        #expect(task.isDueSoon == false)
    }
    
    @Test("Task due soon is detected correctly")
    func taskDueSoonIsDetectedCorrectly() {
        // Given
        let soonDate = Date().addingTimeInterval(3600) // 1 hour from now
        let task = Task(title: "Test Task", dueDate: soonDate)
        
        // Then
        #expect(task.isDueSoon == true)
        #expect(task.isOverdue == false)
    }
    
    @Test("Task due in 3 days is not due soon")
    func taskDueIn3DaysIsNotDueSoon() {
        // Given
        let futureDate = Date().addingTimeInterval(3 * 86400) // 3 days from now
        let task = Task(title: "Test Task", dueDate: futureDate)
        
        // Then
        #expect(task.isDueSoon == false)
        #expect(task.isOverdue == false)
    }
    
    // MARK: - Codable Tests
    
    @Test("Task can be encoded and decoded correctly")
    func taskCodableSupport() throws {
        // Given
        let originalTask = Task(
            title: "Codable Test",
            description: "Testing serialization",
            priority: .high,
            category: .work,
            dueDate: Date()
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTask)
        
        let decoder = JSONDecoder()
        let decodedTask = try decoder.decode(Task.self, from: data)
        
        // Then
        #expect(decodedTask.id == originalTask.id)
        #expect(decodedTask.title == originalTask.title)
        #expect(decodedTask.description == originalTask.description)
        #expect(decodedTask.priority == originalTask.priority)
        #expect(decodedTask.category == originalTask.category)
        #expect(decodedTask.isCompleted == originalTask.isCompleted)
    }
    
    // MARK: - Edge Cases
    
    @Test("Task with empty title is allowed")
    func taskWithEmptyTitle() {
        // Given & When
        let task = Task(title: "")
        
        // Then
        #expect(task.title == "")
    }
    
    @Test("Task creation time is recent")
    func taskCreationTimeIsRecent() {
        // Given
        let beforeCreation = Date()
        
        // When
        let task = Task(title: "Test Task")
        
        // Then
        let afterCreation = Date()
        #expect(task.createdAt >= beforeCreation)
        #expect(task.createdAt <= afterCreation)
    }
}

// MARK: - Priority and Category Enum Tests

@Suite("TaskPriority Tests")
struct TaskPriorityTests {
    
    @Test("Priority display names are correct")
    func priorityDisplayNames() {
        #expect(TaskPriority.low.displayName == "Baja")
        #expect(TaskPriority.medium.displayName == "Media")
        #expect(TaskPriority.high.displayName == "Alta")
    }
    
    @Test("Priority colors are defined")
    func priorityColors() {
        #expect(TaskPriority.low.color == "blue")
        #expect(TaskPriority.medium.color == "orange")
        #expect(TaskPriority.high.color == "red")
    }
    
    @Test("All priority cases are available")
    func allPriorityCases() {
        let allCases = TaskPriority.allCases
        #expect(allCases.count == 3)
        #expect(allCases.contains(.low))
        #expect(allCases.contains(.medium))
        #expect(allCases.contains(.high))
    }
}

@Suite("TaskCategory Tests")
struct TaskCategoryTests {
    
    @Test("Category display names are correct")
    func categoryDisplayNames() {
        #expect(TaskCategory.work.displayName == "Trabajo")
        #expect(TaskCategory.personal.displayName == "Personal")
        #expect(TaskCategory.health.displayName == "Salud")
        #expect(TaskCategory.shopping.displayName == "Compras")
        #expect(TaskCategory.education.displayName == "Educación")
    }
    
    @Test("Category icons are defined")
    func categoryIcons() {
        #expect(TaskCategory.work.icon == "briefcase")
        #expect(TaskCategory.personal.icon == "person")
        #expect(TaskCategory.health.icon == "heart")
        #expect(TaskCategory.shopping.icon == "cart")
        #expect(TaskCategory.education.icon == "book")
    }
    
    @Test("All category cases are available")
    func allCategoryCases() {
        let allCases = TaskCategory.allCases
        #expect(allCases.count == 5)
        #expect(allCases.contains(.work))
        #expect(allCases.contains(.personal))
        #expect(allCases.contains(.health))
        #expect(allCases.contains(.shopping))
        #expect(allCases.contains(.education))
    }
} 