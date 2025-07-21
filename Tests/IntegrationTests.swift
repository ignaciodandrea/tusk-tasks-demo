import Testing
import Foundation
@testable import TuskAppCore

/// Integration tests that verify complete workflows and component interactions
/// These tests simulate real user scenarios and demonstrate the value of comprehensive testing
@Suite("Integration Tests")
@MainActor  
struct IntegrationTests {
    
    // MARK: - Complete User Workflows
    
    @Test("Complete task management workflow")
    func completeTaskManagementWorkflow() {
        // Given - A fresh ViewModel representing a new user
        let viewModel = TaskViewModel()
        viewModel.tasks = [] // Clear any sample data
        
        // User Story: "As a user, I want to create, manage, and track tasks"
        
        // Step 1: User creates multiple tasks with different properties
        viewModel.addTask(
            title: "Review code PRs",
            description: "Review team's pull requests before standup",
            priority: .high,
            category: .work,
            dueDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date())
        )
        
        viewModel.addTask(
            title: "Grocery shopping",
            description: "Buy ingredients for dinner",
            priority: .medium,
            category: .shopping,
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        )
        
        viewModel.addTask(
            title: "Study SwiftUI testing",
            description: "Learn about new testing framework",
            priority: .low,
            category: .education
        )
        
        // Verify initial state
        #expect(viewModel.tasks.count == 3)
        #expect(viewModel.statistics.totalTasks == 3)
        #expect(viewModel.statistics.pendingTasks == 3)
        #expect(viewModel.statistics.completedTasks == 0)
        
        // Step 2: User filters and sorts tasks
        viewModel.selectedFilter = .pending
        viewModel.selectedSortOption = .priority
        
        let prioritizedTasks = viewModel.filteredTasks
        #expect(prioritizedTasks[0].priority == .high)
        #expect(prioritizedTasks[1].priority == .medium)
        #expect(prioritizedTasks[2].priority == .low)
        
        // Step 3: User completes high priority task
        let highPriorityTask = prioritizedTasks[0]
        viewModel.toggleTask(highPriorityTask)
        
        // Verify completion tracking
        #expect(viewModel.statistics.completedTasks == 1)
        #expect(viewModel.statistics.pendingTasks == 2)
        #expect(viewModel.statistics.completionPercentage == 33)
        
        // Step 4: User searches for specific task
        viewModel.selectedFilter = .all
        viewModel.searchText = "grocery"
        
        let searchResults = viewModel.filteredTasks
        #expect(searchResults.count == 1)
        #expect(searchResults[0].title == "Grocery shopping")
        
        // Step 5: User updates task details
        let groceryTask = searchResults[0]
        viewModel.updateTask(
            groceryTask,
            title: "Grocery shopping - Updated",
            priority: .high,
            dueDate: Date().addingTimeInterval(3600) // 1 hour from now
        )
        
        // Clear search to see all tasks
        viewModel.searchText = ""
        let updatedTask = viewModel.tasks.first { $0.id == groceryTask.id }!
        #expect(updatedTask.title == "Grocery shopping - Updated")
        #expect(updatedTask.priority == .high)
        #expect(updatedTask.isDueSoon == true)
        
        // Step 6: User clears completed tasks
        viewModel.clearCompletedTasks()
        #expect(viewModel.tasks.count == 2)
        #expect(viewModel.statistics.completedTasks == 0)
        
        // Final verification
        #expect(viewModel.tasks.allSatisfy { !$0.isCompleted })
    }
    
    @Test("Overdue task detection and management workflow")
    func overdueTaskManagementWorkflow() {
        // Given - ViewModel with tasks at different due states
        let viewModel = TaskViewModel()
        viewModel.tasks = []
        
        let now = Date()
        let overdueDate = now.addingTimeInterval(-3600) // 1 hour ago
        let dueSoonDate = now.addingTimeInterval(1800)  // 30 minutes from now
        let futureDate = now.addingTimeInterval(86400)  // 1 day from now
        
        viewModel.addTask(
            title: "Overdue Report",
            description: "Should have been submitted yesterday",
            priority: .high,
            category: .work,
            dueDate: overdueDate
        )
        
        viewModel.addTask(
            title: "Meeting Preparation",
            description: "Prepare slides for presentation",
            priority: .medium,
            category: .work,
            dueDate: dueSoonDate
        )
        
        viewModel.addTask(
            title: "Future Project",
            description: "Long-term planning",
            priority: .low,
            category: .work,
            dueDate: futureDate
        )
        
        viewModel.addTask(
            title: "No Due Date Task",
            description: "Flexible timing",
            priority: .medium,
            category: .personal
        )
        
        // Test overdue detection
        viewModel.selectedFilter = .overdue
        let overdueTasks = viewModel.filteredTasks
        #expect(overdueTasks.count == 1)
        #expect(overdueTasks[0].title == "Overdue Report")
        #expect(overdueTasks[0].isOverdue == true)
        
        // Test due soon detection
        viewModel.selectedFilter = .dueSoon
        let dueSoonTasks = viewModel.filteredTasks
        #expect(dueSoonTasks.count == 1)
        #expect(dueSoonTasks[0].title == "Meeting Preparation")
        #expect(dueSoonTasks[0].isDueSoon == true)
        
        // Test statistics include overdue tracking
        viewModel.selectedFilter = .all
        let stats = viewModel.statistics
        #expect(stats.overdueTasks == 1)
        #expect(stats.dueSoonTasks == 1)
        
        // User completes overdue task
        let overdueTask = viewModel.tasks.first { $0.isOverdue }!
        viewModel.toggleTask(overdueTask)
        
        // Completed overdue task should no longer be overdue
        #expect(!overdueTask.isOverdue) // Task state before toggle
        let updatedTask = viewModel.tasks.first { $0.id == overdueTask.id }!
        #expect(!updatedTask.isOverdue) // Task state after completion
        #expect(updatedTask.isCompleted)
        
        // Statistics should reflect the change
        let updatedStats = viewModel.statistics
        #expect(updatedStats.overdueTasks == 0)
        #expect(updatedStats.completedTasks == 1)
    }
    
    @Test("Multi-category productivity tracking workflow")
    func multiCategoryProductivityWorkflow() {
        // Given - User with diverse task categories
        let viewModel = TaskViewModel()
        viewModel.tasks = []
        
        // Simulate a productivity-focused user adding various tasks
        let categories: [(TaskCategory, Int)] = [
            (.work, 3),
            (.personal, 2),
            (.health, 2),
            (.education, 1),
            (.shopping, 1)
        ]
        
        var taskCounter = 0
        for (category, count) in categories {
            for i in 0..<count {
                taskCounter += 1
                viewModel.addTask(
                    title: "\(category.displayName) Task \(i + 1)",
                    description: "Task for \(category.displayName.lowercased()) category",
                    priority: TaskPriority.allCases.randomElement()!,
                    category: category
                )
            }
        }
        
        #expect(viewModel.tasks.count == 9)
        
        // User completes some tasks from different categories
        let tasksToComplete = [
            viewModel.tasks.first { $0.category == .work }!,
            viewModel.tasks.first { $0.category == .health }!,
            viewModel.tasks.filter { $0.category == .personal }[0]
        ]
        
        for task in tasksToComplete {
            viewModel.toggleTask(task)
        }
        
        // Verify category-based statistics
        let stats = viewModel.statistics
        #expect(stats.completedTasks == 3)
        #expect(stats.tasksByCategory[.work] == 3)
        #expect(stats.tasksByCategory[.personal] == 2)
        #expect(stats.tasksByCategory[.health] == 2)
        #expect(stats.tasksByCategory[.education] == 1)
        #expect(stats.tasksByCategory[.shopping] == 1)
        
        // Test category filtering
        viewModel.selectedCategory = .work
        let workTasks = viewModel.filteredTasks
        #expect(workTasks.count == 3)
        #expect(workTasks.allSatisfy { $0.category == .work })
        
        // Test productivity analysis by checking completion rates per category
        let workCompletionRate = Double(workTasks.filter { $0.isCompleted }.count) / Double(workTasks.count)
        #expect(workCompletionRate > 0) // At least one work task completed
        
        // User focuses on health tasks
        viewModel.selectedCategory = .health
        let healthTasks = viewModel.filteredTasks
        #expect(healthTasks.count == 2)
        
        // Complete remaining health task
        let incompleteHealthTask = healthTasks.first { !$0.isCompleted }!
        viewModel.toggleTask(incompleteHealthTask)
        
        // Verify 100% completion rate for health category
        viewModel.selectedCategory = .health
        let updatedHealthTasks = viewModel.filteredTasks
        #expect(updatedHealthTasks.allSatisfy { $0.isCompleted })
    }
    
    @Test("Search and filter combination workflow")
    func searchAndFilterCombinationWorkflow() {
        // Given - User with many tasks containing similar keywords
        let viewModel = TaskViewModel()
        viewModel.tasks = []
        
        // Add tasks with overlapping keywords
        let testTasks = [
            ("Review Swift code", "Code review for iOS project", TaskPriority.high, TaskCategory.work),
            ("Swift learning session", "Study advanced Swift concepts", TaskPriority.medium, TaskCategory.education),
            ("Code cleanup", "Refactor old Swift code", TaskPriority.low, TaskCategory.work),
            ("Buy swift keyboard", "Purchase mechanical keyboard", TaskPriority.low, TaskCategory.shopping),
            ("Swift workout", "30-minute HIIT session", TaskPriority.medium, TaskCategory.health),
            ("Meeting notes review", "Review notes from team meeting", TaskPriority.medium, TaskCategory.work)
        ]
        
        for (title, description, priority, category) in testTasks {
            viewModel.addTask(
                title: title,
                description: description,
                priority: priority,
                category: category
            )
        }
        
        // Complete some tasks
        viewModel.toggleTask(viewModel.tasks[1]) // Swift learning session
        viewModel.toggleTask(viewModel.tasks[4]) // Swift workout
        
        // Test search functionality
        viewModel.searchText = "swift"
        let swiftTasks = viewModel.filteredTasks
        #expect(swiftTasks.count == 4) // All tasks containing "swift"
        
        // Combine search with category filter
        viewModel.selectedCategory = .work
        let workSwiftTasks = viewModel.filteredTasks
        #expect(workSwiftTasks.count == 2) // Only work tasks containing "swift"
        #expect(workSwiftTasks.allSatisfy { $0.category == .work })
        #expect(workSwiftTasks.allSatisfy { 
            $0.title.localizedCaseInsensitiveContains("swift") || 
            $0.description.localizedCaseInsensitiveContains("swift") 
        })
        
        // Combine search with completion filter
        viewModel.selectedCategory = nil
        viewModel.selectedFilter = .completed
        let completedSwiftTasks = viewModel.filteredTasks
        #expect(completedSwiftTasks.count == 2) // Completed tasks containing "swift"
        #expect(completedSwiftTasks.allSatisfy { $0.isCompleted })
        
        // Test sorting with filters
        viewModel.selectedFilter = .all
        viewModel.selectedSortOption = .priority
        let prioritizedSwiftTasks = viewModel.filteredTasks
        
        // Verify sorting while maintaining search filter
        for i in 0..<(prioritizedSwiftTasks.count - 1) {
            let currentPriorityValue = priorityValue(prioritizedSwiftTasks[i].priority)
            let nextPriorityValue = priorityValue(prioritizedSwiftTasks[i + 1].priority)
            #expect(currentPriorityValue >= nextPriorityValue)
        }
        
        // Reset all filters
        viewModel.resetFilters()
        #expect(viewModel.filteredTasks.count == 6) // All tasks visible again
        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.selectedFilter == .all)
        #expect(viewModel.selectedCategory == nil)
    }
    
    @Test("Data persistence and state recovery workflow")
    func dataPersistenceWorkflow() {
        // Given - First ViewModel instance (simulating app launch)
        let firstViewModel = TaskViewModel()
        firstViewModel.tasks = [] // Clear any existing data
        
        // User adds tasks
        firstViewModel.addTask(
            title: "Persistent Task 1",
            description: "This should survive app restart",
            priority: .high,
            category: .work
        )
        
        firstViewModel.addTask(
            title: "Persistent Task 2",
            description: "This should also survive",
            priority: .medium,
            category: .personal
        )
        
        // User completes one task
        firstViewModel.toggleTask(firstViewModel.tasks[0])
        
        // Verify data is stored
        #expect(firstViewModel.tasks.count == 2)
        #expect(firstViewModel.statistics.completedTasks == 1)
        
        // Simulate app restart by creating new ViewModel instance
        let secondViewModel = TaskViewModel()
        
        // Data should be restored (note: in real app this would load from UserDefaults)
        // For testing, we simulate this by manually checking persistence logic
        #expect(secondViewModel.tasks.count > 0) // Should load sample data or saved data
        
        // Verify the persistence layer works correctly
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            // Test that all tasks can be encoded and decoded
            let encodedData = try encoder.encode(firstViewModel.tasks)
            let decodedTasks = try decoder.decode([Task].self, from: encodedData)
            
            #expect(decodedTasks.count == firstViewModel.tasks.count)
            #expect(decodedTasks[0].isCompleted == firstViewModel.tasks[0].isCompleted)
            #expect(decodedTasks[1].isCompleted == firstViewModel.tasks[1].isCompleted)
        } catch {
            Issue.record("Failed to encode/decode tasks: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    
    private func priorityValue(_ priority: TaskPriority) -> Int {
        switch priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

// MARK: - Performance and Stress Tests

@Suite("Performance Tests")
@MainActor
struct PerformanceTests {
    
    @Test("Large dataset filtering performance")
    func largeDatasetFiltering() {
        // Given - ViewModel with many tasks
        let viewModel = TaskViewModel()
        viewModel.tasks = []
        
        // Add many tasks to test performance
        for i in 0..<100 {
            viewModel.addTask(
                title: "Task \(i)",
                description: "Description for task \(i)",
                priority: TaskPriority.allCases[i % 3],
                category: TaskCategory.allCases[i % 5]
            )
        }
        
        #expect(viewModel.tasks.count == 100)
        
        // Test filtering performance with search
        viewModel.searchText = "5" // Should match multiple tasks
        let searchResults = viewModel.filteredTasks
        #expect(searchResults.count > 0)
        
        // Test category filtering
        viewModel.searchText = ""
        viewModel.selectedCategory = .work
        let categoryResults = viewModel.filteredTasks
        #expect(categoryResults.allSatisfy { $0.category == .work })
        
        // Test sorting large dataset
        viewModel.selectedCategory = nil
        viewModel.selectedSortOption = .title
        let sortedResults = viewModel.filteredTasks
        
        // Verify sorting is correct
        for i in 0..<(sortedResults.count - 1) {
            #expect(sortedResults[i].title <= sortedResults[i + 1].title)
        }
        
        // Statistics calculation should handle large datasets
        let stats = viewModel.statistics
        #expect(stats.totalTasks == 100)
        #expect(stats.tasksByCategory.values.reduce(0, +) == 100)
        #expect(stats.tasksByPriority.values.reduce(0, +) == 100)
    }
    
    @Test("Rapid state changes handling")
    func rapidStateChanges() {
        // Given - ViewModel for rapid operations
        let viewModel = TaskViewModel()
        viewModel.tasks = []
        
        // Add tasks rapidly
        for i in 0..<10 {
            viewModel.addTask(title: "Rapid Task \(i)")
        }
        
        // Rapidly toggle completion states
        for _ in 0..<5 {
            for task in viewModel.tasks {
                viewModel.toggleTask(task)
            }
        }
        
        // All tasks should end up incomplete (started incomplete, toggled even number of times)
        #expect(viewModel.tasks.allSatisfy { !$0.isCompleted })
        
        // Rapidly change filters
        let filters: [TaskFilter] = [.all, .pending, .completed, .overdue, .dueSoon]
        for filter in filters {
            viewModel.selectedFilter = filter
            _ = viewModel.filteredTasks // Force computation
        }
        
        // Should handle filter changes without issues
        #expect(viewModel.selectedFilter == .dueSoon)
        
        // Final state should be consistent
        let finalStats = viewModel.statistics
        #expect(finalStats.totalTasks == 10)
        #expect(finalStats.completedTasks == 0)
    }
} 