import Foundation
import Combine

enum TaskFilter: String, CaseIterable {
    case all = "all"
    case pending = "pending"
    case completed = "completed"
    case overdue = "overdue"
    case dueSoon = "dueSoon"
    
    var displayName: String {
        switch self {
        case .all: return "Todas"
        case .pending: return "Pendientes"
        case .completed: return "Completadas"
        case .overdue: return "Vencidas"
        case .dueSoon: return "Próximas a vencer"
        }
    }
}

enum TaskSortOption: String, CaseIterable {
    case createdDate = "createdDate"
    case dueDate = "dueDate"
    case priority = "priority"
    case title = "title"
    
    var displayName: String {
        switch self {
        case .createdDate: return "Fecha de creación"
        case .dueDate: return "Fecha de vencimiento"
        case .priority: return "Prioridad"
        case .title: return "Título"
        }
    }
}

struct TaskStatistics {
    let totalTasks: Int
    let completedTasks: Int
    let pendingTasks: Int
    let overdueTasks: Int
    let dueSoonTasks: Int
    let completionRate: Double
    let tasksByCategory: [TaskCategory: Int]
    let tasksByPriority: [TaskPriority: Int]
    
    var completionPercentage: Int {
        Int(completionRate * 100)
    }
}

@available(iOS 14.0, macOS 11.0, *)
@MainActor
class TaskViewModel: ObservableObject {
    
    @Published var tasks: [Task] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedSortOption: TaskSortOption = .createdDate
    @Published var selectedCategory: TaskCategory? = nil
    
    private let tasksKey = "savedTasks"
    
    var filteredTasks: [Task] {
        var filtered = tasks
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .pending:
            filtered = filtered.filter { !$0.isCompleted }
        case .completed:
            filtered = filtered.filter { $0.isCompleted }
        case .overdue:
            filtered = filtered.filter { $0.isOverdue }
        case .dueSoon:
            filtered = filtered.filter { $0.isDueSoon }
        }
        
        // Apply sorting
        switch selectedSortOption {
        case .createdDate:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .dueDate:
            filtered.sort { (task1, task2) in
                switch (task1.dueDate, task2.dueDate) {
                case (nil, nil): return task1.createdAt > task2.createdAt
                case (nil, _): return false
                case (_, nil): return true
                case (let date1?, let date2?): return date1 < date2
                }
            }
        case .priority:
            filtered.sort { task1, task2 in
                let priority1 = task1.priority == .high ? 3 : (task1.priority == .medium ? 2 : 1)
                let priority2 = task2.priority == .high ? 3 : (task2.priority == .medium ? 2 : 1)
                return priority1 > priority2
            }
        case .title:
            filtered.sort { $0.title < $1.title }
        }
        
        return filtered
    }
    
    var statistics: TaskStatistics {
        let total = tasks.count
        let completed = tasks.filter { $0.isCompleted }.count
        let pending = total - completed
        let overdue = tasks.filter { $0.isOverdue }.count
        let dueSoon = tasks.filter { $0.isDueSoon }.count
        let completionRate = total > 0 ? Double(completed) / Double(total) : 0.0
        
        let byCategory = Dictionary(grouping: tasks, by: { $0.category })
            .mapValues { $0.count }
        let byPriority = Dictionary(grouping: tasks, by: { $0.priority })
            .mapValues { $0.count }
        
        return TaskStatistics(
            totalTasks: total,
            completedTasks: completed,
            pendingTasks: pending,
            overdueTasks: overdue,
            dueSoonTasks: dueSoon,
            completionRate: completionRate,
            tasksByCategory: byCategory,
            tasksByPriority: byPriority
        )
    }
    
    init() {
        loadTasks()
    }
    
    func addTask(title: String, description: String = "", priority: TaskPriority = .medium, 
                category: TaskCategory = .personal, dueDate: Date? = nil) {
        let task = Task(title: title, description: description, priority: priority, 
                       category: category, dueDate: dueDate)
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task, title: String? = nil, description: String? = nil, 
                   priority: TaskPriority? = nil, category: TaskCategory? = nil, 
                   dueDate: Date? = nil) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        if let title = title { tasks[index].title = title }
        if let description = description { tasks[index].description = description }
        if let priority = priority { tasks[index].priority = priority }
        if let category = category { tasks[index].category = category }
        if let dueDate = dueDate { tasks[index].dueDate = dueDate }
        
        saveTasks()
    }
    
    func toggleTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        if tasks[index].isCompleted {
            tasks[index].uncomplete()
        } else {
            tasks[index].complete()
        }
        saveTasks()
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func deleteTasks(at indexSet: IndexSet) {
        let tasksToDelete = indexSet.map { filteredTasks[$0] }
        for task in tasksToDelete {
            deleteTask(task)
        }
    }
    
    func clearCompletedTasks() {
        tasks.removeAll { $0.isCompleted }
        saveTasks()
    }
    
    func resetFilters() {
        searchText = ""
        selectedFilter = .all
        selectedCategory = nil
        selectedSortOption = .createdDate
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        } else {
            // Add sample data for demo purposes
            addSampleTasks()
        }
    }
    
    private func addSampleTasks() {
        let sampleTasks = [
            Task(title: "Revisar PRs pendientes", description: "Revisar pull requests del equipo", 
                priority: .high, category: .work, 
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())),
            Task(title: "Comprar comida para la cena", description: "Ir al supermercado", 
                priority: .medium, category: .shopping, 
                dueDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date())),
            Task(title: "Ejercicio matutino", description: "30 minutos de cardio", 
                priority: .low, category: .health, 
                dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
            Task(title: "Estudiar SwiftUI", description: "Completar tutorial de navegación", 
                priority: .medium, category: .education),
            Task(title: "Llamar a mamá", description: "", 
                priority: .high, category: .personal, 
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()))
        ]
        
        // Mark some as completed
        var completedTask = sampleTasks[3]
        completedTask.complete()
        
        tasks = sampleTasks.dropLast() + [completedTask]
        saveTasks()
    }
} 
