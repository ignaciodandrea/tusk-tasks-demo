import Testing
import Foundation
@testable import TuskAppCore

/// Comprehensive tests for TaskViewModel including business logic validation,
/// filtering, sorting, and statistics calculations
@Suite("TaskViewModel Tests")
@MainActor
struct TaskViewModelTests {
    
    // MARK: - Setup and Initialization
    
    func createTestViewModel() -> TaskViewModel {
        let viewModel = TaskViewModel()
        // Clear any existing data
        viewModel.tasks = []
        return viewModel
    }
    
    // MARK: - Basic CRUD Operations
    
    @Test("ViewModel initializes correctly")
    func viewModelInitialization() {
        // When
        let viewModel = createTestViewModel()
        
        // Then
        #expect(viewModel.tasks.isEmpty)
        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.selectedFilter == .all)
        #expect(viewModel.selectedSortOption == .createdDate)
        #expect(viewModel.selectedCategory == nil)
    }
    
    @Test("Adding task works correctly")
    func addingTaskWorks() {
        // Given
        let viewModel = createTestViewModel()
        let title = "Test Task"
        let description = "Test Description"
        let priority = TaskPriority.high
        let category = TaskCategory.work
        
        // When
        viewModel.addTask(
            title: title,
            description: description,
            priority: priority,
            category: category
        )
        
        // Then
        #expect(viewModel.tasks.count == 1)
        let addedTask = viewModel.tasks.first!
        #expect(addedTask.title == title)
        #expect(addedTask.description == description)
        #expect(addedTask.priority == priority)
        #expect(addedTask.category == category)
    }
    
    @Test("Toggling task completion works")
    func toggleTaskCompletion() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Test Task")
        let task = viewModel.tasks.first!
        
        // When - Toggle to completed
        viewModel.toggleTask(task)
        
        // Then
        let updatedTask = viewModel.tasks.first!
        #expect(updatedTask.isCompleted == true)
        #expect(updatedTask.completedAt != nil)
        
        // When - Toggle back to incomplete
        viewModel.toggleTask(updatedTask)
        
        // Then
        let finalTask = viewModel.tasks.first!
        #expect(finalTask.isCompleted == false)
        #expect(finalTask.completedAt == nil)
    }
    
    @Test("Updating task properties works")
    func updateTaskProperties() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Original Title")
        let originalTask = viewModel.tasks.first!
        
        let newTitle = "Updated Title"
        let newDescription = "Updated Description"
        let newPriority = TaskPriority.high
        let newCategory = TaskCategory.education
        
        // When
        viewModel.updateTask(
            originalTask,
            title: newTitle,
            description: newDescription,
            priority: newPriority,
            category: newCategory
        )
        
        // Then
        let updatedTask = viewModel.tasks.first!
        #expect(updatedTask.title == newTitle)
        #expect(updatedTask.description == newDescription)
        #expect(updatedTask.priority == newPriority)
        #expect(updatedTask.category == newCategory)
        #expect(updatedTask.id == originalTask.id) // ID should remain the same
    }
    
    @Test("Deleting task works")
    func deleteTask() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Task to Delete")
        viewModel.addTask(title: "Task to Keep")
        #expect(viewModel.tasks.count == 2)
        
        let taskToDelete = viewModel.tasks.first!
        
        // When
        viewModel.deleteTask(taskToDelete)
        
        // Then
        #expect(viewModel.tasks.count == 1)
        #expect(viewModel.tasks.first!.title == "Task to Keep")
    }
    
    // MARK: - Filtering Tests
    
    @Test("Search filtering works correctly")
    func searchFiltering() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Buy groceries", description: "Milk and bread")
        viewModel.addTask(title: "Walk the dog", description: "Take Bruno for a walk")
        viewModel.addTask(title: "Study Swift", description: "Learn about closures")
        
        // When - Search by title
        viewModel.searchText = "dog"
        
        // Then
        #expect(viewModel.filteredTasks.count == 1)
        #expect(viewModel.filteredTasks.first!.title == "Walk the dog")
        
        // When - Search by description
        viewModel.searchText = "milk"
        
        // Then
        #expect(viewModel.filteredTasks.count == 1)
        #expect(viewModel.filteredTasks.first!.title == "Buy groceries")
        
        // When - Clear search
        viewModel.searchText = ""
        
        // Then
        #expect(viewModel.filteredTasks.count == 3)
    }
    
    @Test("Status filtering works correctly")
    func statusFiltering() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Completed Task")
        viewModel.addTask(title: "Pending Task")
        viewModel.addTask(title: "Overdue Task", dueDate: Date().addingTimeInterval(-3600))
        viewModel.addTask(title: "Due Soon Task", dueDate: Date().addingTimeInterval(3600))
        
        // Complete the first task
        viewModel.toggleTask(viewModel.tasks[0])
        
        // Test completed filter
        viewModel.selectedFilter = .completed
        #expect(viewModel.filteredTasks.count == 1)
        #expect(viewModel.filteredTasks.first!.title == "Completed Task")
        
        // Test pending filter
        viewModel.selectedFilter = .pending
        #expect(viewModel.filteredTasks.count == 3)
        
        // Test overdue filter
        viewModel.selectedFilter = .overdue
        #expect(viewModel.filteredTasks.count == 1)
        #expect(viewModel.filteredTasks.first!.title == "Overdue Task")
        
        // Test due soon filter
        viewModel.selectedFilter = .dueSoon
        #expect(viewModel.filteredTasks.count == 1)
        #expect(viewModel.filteredTasks.first!.title == "Due Soon Task")
    }
    
    @Test("Category filtering works correctly")
    func categoryFiltering() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Work Task", category: .work)
        viewModel.addTask(title: "Personal Task", category: .personal)
        viewModel.addTask(title: "Health Task", category: .health)
        
        // When - Filter by work category
        viewModel.selectedCategory = .work
        
        // Then
        #expect(viewModel.filteredTasks.count == 1)
        #expect(viewModel.filteredTasks.first!.title == "Work Task")
        
        // When - Clear category filter
        viewModel.selectedCategory = nil
        
        // Then
        #expect(viewModel.filteredTasks.count == 3)
    }
    
    // MARK: - Sorting Tests
    
    @Test("Sorting by priority works correctly")
    func sortByPriority() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Low Priority", priority: .low)
        viewModel.addTask(title: "High Priority", priority: .high)
        viewModel.addTask(title: "Medium Priority", priority: .medium)
        
        // When
        viewModel.selectedSortOption = .priority
        
        // Then - Should be sorted high -> medium -> low
        let sortedTasks = viewModel.filteredTasks
        #expect(sortedTasks[0].title == "High Priority")
        #expect(sortedTasks[1].title == "Medium Priority")
        #expect(sortedTasks[2].title == "Low Priority")
    }
    
    @Test("Sorting by title works correctly")
    func sortByTitle() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Zebra")
        viewModel.addTask(title: "Apple")
        viewModel.addTask(title: "Mountain")
        
        // When
        viewModel.selectedSortOption = .title
        
        // Then - Should be sorted alphabetically
        let sortedTasks = viewModel.filteredTasks
        #expect(sortedTasks[0].title == "Apple")
        #expect(sortedTasks[1].title == "Mountain")
        #expect(sortedTasks[2].title == "Zebra")
    }
    
    @Test("Sorting by due date works correctly")
    func sortByDueDate() {
        // Given
        let viewModel = createTestViewModel()
        let futureDate = Date().addingTimeInterval(86400) // 1 day from now
        let nearDate = Date().addingTimeInterval(3600)   // 1 hour from now
        
        viewModel.addTask(title: "No Due Date")
        viewModel.addTask(title: "Future Task", dueDate: futureDate)
        viewModel.addTask(title: "Near Task", dueDate: nearDate)
        
        // When
        viewModel.selectedSortOption = .dueDate
        
        // Then - Should be sorted by due date (nearest first), no due date last
        let sortedTasks = viewModel.filteredTasks
        #expect(sortedTasks[0].title == "Near Task")
        #expect(sortedTasks[1].title == "Future Task")
        #expect(sortedTasks[2].title == "No Due Date")
    }
    
    // MARK: - Statistics Tests
    
    @Test("Statistics calculation is correct")
    func statisticsCalculation() {
        // Given
        let viewModel = createTestViewModel()
        
        // Add various tasks
        viewModel.addTask(title: "Completed Work", priority: .high, category: .work)
        viewModel.addTask(title: "Pending Personal", priority: .medium, category: .personal)
        viewModel.addTask(title: "Overdue Health", priority: .low, category: .health, 
                         dueDate: Date().addingTimeInterval(-3600))
        viewModel.addTask(title: "Due Soon Shopping", priority: .medium, category: .shopping,
                         dueDate: Date().addingTimeInterval(3600))
        
        // Complete the first task
        viewModel.toggleTask(viewModel.tasks[0])
        
        // When
        let stats = viewModel.statistics
        
        // Then
        #expect(stats.totalTasks == 4)
        #expect(stats.completedTasks == 1)
        #expect(stats.pendingTasks == 3)
        #expect(stats.overdueTasks == 1)
        #expect(stats.dueSoonTasks == 1)
        #expect(stats.completionPercentage == 25)
        
        // Test category breakdown
        #expect(stats.tasksByCategory[.work] == 1)
        #expect(stats.tasksByCategory[.personal] == 1)
        #expect(stats.tasksByCategory[.health] == 1)
        #expect(stats.tasksByCategory[.shopping] == 1)
        
        // Test priority breakdown
        #expect(stats.tasksByPriority[.high] == 1)
        #expect(stats.tasksByPriority[.medium] == 2)
        #expect(stats.tasksByPriority[.low] == 1)
    }
    
    @Test("Empty statistics are handled correctly")
    func emptyStatistics() {
        // Given
        let viewModel = createTestViewModel()
        
        // When
        let stats = viewModel.statistics
        
        // Then
        #expect(stats.totalTasks == 0)
        #expect(stats.completedTasks == 0)
        #expect(stats.pendingTasks == 0)
        #expect(stats.completionRate == 0.0)
        #expect(stats.completionPercentage == 0)
        #expect(stats.tasksByCategory.isEmpty)
        #expect(stats.tasksByPriority.isEmpty)
    }
    
    // MARK: - Batch Operations
    
    @Test("Clear completed tasks works")
    func clearCompletedTasks() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Completed Task 1")
        viewModel.addTask(title: "Completed Task 2")
        viewModel.addTask(title: "Pending Task")
        
        // Complete two tasks
        viewModel.toggleTask(viewModel.tasks[0])
        viewModel.toggleTask(viewModel.tasks[1])
        
        #expect(viewModel.tasks.count == 3)
        #expect(viewModel.statistics.completedTasks == 2)
        
        // When
        viewModel.clearCompletedTasks()
        
        // Then
        #expect(viewModel.tasks.count == 1)
        #expect(viewModel.tasks.first!.title == "Pending Task")
    }
    
    @Test("Reset filters works correctly")
    func resetFilters() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.searchText = "search term"
        viewModel.selectedFilter = .completed
        viewModel.selectedCategory = .work
        viewModel.selectedSortOption = .priority
        
        // When
        viewModel.resetFilters()
        
        // Then
        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.selectedFilter == .all)
        #expect(viewModel.selectedCategory == nil)
        #expect(viewModel.selectedSortOption == .createdDate)
    }
    
    // MARK: - Edge Cases and Error Handling
    
    @Test("Toggle non-existent task is handled gracefully")
    func toggleNonExistentTask() {
        // Given
        let viewModel = createTestViewModel()
        let nonExistentTask = Task(title: "Non-existent")
        
        // When & Then - Should not crash
        viewModel.toggleTask(nonExistentTask)
        #expect(viewModel.tasks.isEmpty)
    }
    
    @Test("Update non-existent task is handled gracefully")
    func updateNonExistentTask() {
        // Given
        let viewModel = createTestViewModel()
        let nonExistentTask = Task(title: "Non-existent")
        
        // When & Then - Should not crash
        viewModel.updateTask(nonExistentTask, title: "Updated")
        #expect(viewModel.tasks.isEmpty)
    }
    
    @Test("Delete non-existent task is handled gracefully")
    func deleteNonExistentTask() {
        // Given
        let viewModel = createTestViewModel()
        viewModel.addTask(title: "Existing Task")
        let nonExistentTask = Task(title: "Non-existent")
        
        // When & Then - Should not crash
        viewModel.deleteTask(nonExistentTask)
        #expect(viewModel.tasks.count == 1)
    }
    
    // MARK: - Complex Scenarios
    
    @Test("Complex filtering and sorting scenario")
    func complexFilteringAndSorting() {
        // Given
        let viewModel = createTestViewModel()
        
        // Add various tasks
        viewModel.addTask(title: "Apple Work Task", priority: .high, category: .work)
        viewModel.addTask(title: "Banana Personal Task", priority: .low, category: .personal)
        viewModel.addTask(title: "Cherry Work Task", priority: .medium, category: .work)
        viewModel.addTask(title: "Date Shopping Task", priority: .high, category: .shopping)
        
        // Apply filters and sorting
        viewModel.selectedCategory = .work
        viewModel.selectedSortOption = .title
        
        // When
        let filtered = viewModel.filteredTasks
        
        // Then - Should only show work tasks, sorted by title
        #expect(filtered.count == 2)
        #expect(filtered[0].title == "Apple Work Task")
        #expect(filtered[1].title == "Cherry Work Task")
    }
} 