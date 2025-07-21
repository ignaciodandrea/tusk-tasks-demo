import Foundation

enum TaskPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case work = "work"
    case personal = "personal"
    case health = "health"
    case shopping = "shopping"
    case education = "education"
    
    var displayName: String {
        switch self {
        case .work: return "Trabajo"
        case .personal: return "Personal"
        case .health: return "Salud"
        case .shopping: return "Compras"
        case .education: return "Educación"
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase"
        case .personal: return "person"
        case .health: return "heart"
        case .shopping: return "cart"
        case .education: return "book"
        }
    }
}

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var category: TaskCategory
    var createdAt: Date
    var dueDate: Date?
    var completedAt: Date?
    
    init(title: String, description: String = "", isCompleted: Bool = false, 
         priority: TaskPriority = .medium, category: TaskCategory = .personal, 
         dueDate: Date? = nil) {
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.createdAt = Date()
        self.dueDate = dueDate
        self.completedAt = nil
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return Date() > dueDate
    }
    
    var isDueSoon: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        let twoDaysFromNow = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        return dueDate <= twoDaysFromNow && dueDate > Date()
    }
    
    mutating func complete() {
        isCompleted = true
        completedAt = Date()
    }
    
    mutating func uncomplete() {
        isCompleted = false
        completedAt = nil
    }
    
    // MARK: - AI Testing Demo Functions
    
    /// Determines if this task should be escalated based on priority and overdue status
    /// - Returns: True if task needs escalation
    func shouldEscalate() -> Bool {
        // High priority tasks that are overdue should always escalate
        if priority == .high && isOverdue {
            return true
        }
        
        // Medium priority tasks overdue by more than 2 days
        if priority == .medium && isOverdue {
            guard let dueDate = dueDate else { return false }
            let daysSinceOverdue = Calendar.current.dateComponents([.day], from: dueDate, to: Date()).day ?? 0
            return daysSinceOverdue > 2
        }
        
        // Low priority tasks only escalate after 1 week overdue
        if priority == .low && isOverdue {
            guard let dueDate = dueDate else { return false }
            let daysSinceOverdue = Calendar.current.dateComponents([.day], from: dueDate, to: Date()).day ?? 0
            return daysSinceOverdue > 7
        }
        
        return false
    }
} 