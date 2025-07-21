//
//  ContentView.swift
//  TuskApp
//
//  Created by Ignacio D'Andrea on 18/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some View {
        TabView {
            TaskListView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Tareas")
                }
            
            StatisticsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Estadísticas")
                }
        }
    }
}

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var isAddingTask = false
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchAndFilterView(viewModel: viewModel, showingFilters: $showingFilters)
                
                if viewModel.filteredTasks.isEmpty {
                    EmptyStateView(filter: viewModel.selectedFilter)
                } else {
                    TaskListContent(viewModel: viewModel)
                }
            }
            .navigationTitle("Tusk Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button(action: { isAddingTask = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.tasks.filter({ $0.isCompleted }).count > 0 {
                        Button("Limpiar completadas") {
                            withAnimation {
                                viewModel.clearCompletedTasks()
                            }
                        }
                        .font(.caption)
                    }
                }
            }
            .sheet(isPresented: $isAddingTask) {
                AddTaskView(viewModel: viewModel, isPresented: $isAddingTask)
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(viewModel: viewModel, isPresented: $showingFilters)
            }
        }
    }
}

struct SearchAndFilterView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var showingFilters: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Buscar tareas...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Quick filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.displayName,
                            isSelected: viewModel.selectedFilter == filter,
                            action: { viewModel.selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct TaskListContent: View {
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                TaskRowView(task: task, viewModel: viewModel)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete { indexSet in
                withAnimation {
                    viewModel.deleteTasks(at: indexSet)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 12) {
                // Completion button
                Button(action: { withAnimation { viewModel.toggleTask(task) } }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                        .font(.title2)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(task.title)
                            .font(.headline)
                            .strikethrough(task.isCompleted)
                            .foregroundColor(task.isCompleted ? .secondary : .primary)
                        
                        Spacer()
                        
                        // Priority indicator
                        Circle()
                            .fill(priorityColor(for: task.priority))
                            .frame(width: 8, height: 8)
                    }
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        // Category
                        HStack(spacing: 4) {
                            Image(systemName: task.category.icon)
                            Text(task.category.displayName)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Due date
                        if let dueDate = task.dueDate {
                            Text(dueDate.formatted(.dateTime.month(.abbreviated).day()))
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(dueDateBackgroundColor(for: task))
                                .foregroundColor(dueDateTextColor(for: task))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            TaskDetailView(task: task, viewModel: viewModel, isPresented: $showingDetail)
        }
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    private func dueDateBackgroundColor(for task: Task) -> Color {
        if task.isOverdue { return .red }
        if task.isDueSoon { return .orange }
        return .gray.opacity(0.2)
    }
    
    private func dueDateTextColor(for task: Task) -> Color {
        if task.isOverdue || task.isDueSoon { return .white }
        return .primary
    }
}

struct EmptyStateView: View {
    let filter: TaskFilter
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(emptyMessage)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("¡Agrega una nueva tarea para comenzar!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyMessage: String {
        switch filter {
        case .all: return "No hay tareas"
        case .pending: return "No hay tareas pendientes"
        case .completed: return "No hay tareas completadas"
        case .overdue: return "No hay tareas vencidas"
        case .dueSoon: return "No hay tareas próximas a vencer"
        }
    }
}

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var category: TaskCategory = .personal
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información básica") {
                    TextField("Título", text: $title)
                    TextField("Descripción (opcional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Detalles") {
                    Picker("Prioridad", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    
                    Picker("Categoría", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    
                    Toggle("Fecha de vencimiento", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Vence el", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Nueva Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") {
                        viewModel.addTask(
                            title: title,
                            description: description,
                            priority: priority,
                            category: category,
                            dueDate: hasDueDate ? dueDate : nil
                        )
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct TaskDetailView: View {
    @State private var task: Task
    @ObservedObject var viewModel: TaskViewModel
    @Binding var isPresented: Bool
    @State private var isEditing = false
    
    init(task: Task, viewModel: TaskViewModel, isPresented: Binding<Bool>) {
        _task = State(initialValue: task)
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Status and action buttons
                    HStack {
                        Button(action: { 
                            withAnimation {
                                viewModel.toggleTask(task)
                                if let updatedTask = viewModel.tasks.first(where: { $0.id == task.id }) {
                                    task = updatedTask
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                Text(task.isCompleted ? "Completada" : "Marcar como completada")
                            }
                            .foregroundColor(task.isCompleted ? .green : .blue)
                        }
                        
                        Spacer()
                        
                        Button("Editar") {
                            isEditing = true
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Task details
                    VStack(alignment: .leading, spacing: 16) {
                        Text(task.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .strikethrough(task.isCompleted)
                        
                        if !task.description.isEmpty {
                            Text(task.description)
                                .font(.body)
                        }
                        
                        // Metadata
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "flag.fill", 
                                   title: "Prioridad", 
                                   value: task.priority.displayName,
                                   color: priorityColor(for: task.priority))
                            
                            InfoRow(icon: task.category.icon, 
                                   title: "Categoría", 
                                   value: task.category.displayName)
                            
                            InfoRow(icon: "calendar", 
                                   title: "Creada", 
                                   value: task.createdAt.formatted(.dateTime.month().day().hour().minute()))
                            
                            if let dueDate = task.dueDate {
                                InfoRow(icon: "clock", 
                                       title: "Vence", 
                                       value: dueDate.formatted(.dateTime.month().day().hour().minute()),
                                       color: task.isOverdue ? .red : (task.isDueSoon ? .orange : nil))
                            }
                            
                            if let completedAt = task.completedAt {
                                InfoRow(icon: "checkmark.circle", 
                                       title: "Completada", 
                                       value: completedAt.formatted(.dateTime.month().day().hour().minute()),
                                       color: .green)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Detalle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cerrar") {
                        isPresented = false
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditTaskView(task: task, viewModel: viewModel, isPresented: $isEditing) { updatedTask in
                    task = updatedTask
                }
            }
        }
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color?
    
    init(icon: String, title: String, value: String, color: Color? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color ?? .secondary)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(color ?? .primary)
        }
    }
}

struct EditTaskView: View {
    @State private var title: String
    @State private var description: String
    @State private var priority: TaskPriority
    @State private var category: TaskCategory
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    
    let originalTask: Task
    @ObservedObject var viewModel: TaskViewModel
    @Binding var isPresented: Bool
    let onUpdate: (Task) -> Void
    
    init(task: Task, viewModel: TaskViewModel, isPresented: Binding<Bool>, onUpdate: @escaping (Task) -> Void) {
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _priority = State(initialValue: task.priority)
        _category = State(initialValue: task.category)
        _hasDueDate = State(initialValue: task.dueDate != nil)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        
        self.originalTask = task
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información básica") {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Detalles") {
                    Picker("Prioridad", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    
                    Picker("Categoría", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    
                    Toggle("Fecha de vencimiento", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Vence el", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section {
                    Button("Eliminar tarea") {
                        viewModel.deleteTask(originalTask)
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Editar Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        viewModel.updateTask(
                            originalTask,
                            title: title,
                            description: description,
                            priority: priority,
                            category: category,
                            dueDate: hasDueDate ? dueDate : nil
                        )
                        
                        if let updatedTask = viewModel.tasks.first(where: { $0.id == originalTask.id }) {
                            onUpdate(updatedTask)
                        }
                        
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct FilterView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Filtros") {
                    Picker("Estado", selection: $viewModel.selectedFilter) {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    
                    Picker("Categoría", selection: $viewModel.selectedCategory) {
                        Text("Todas las categorías").tag(nil as TaskCategory?)
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.displayName)
                            }
                            .tag(category as TaskCategory?)
                        }
                    }
                }
                
                Section("Ordenar por") {
                    Picker("Criterio", selection: $viewModel.selectedSortOption) {
                        ForEach(TaskSortOption.allCases, id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                }
                
                Section {
                    Button("Restablecer filtros") {
                        viewModel.resetFilters()
                    }
                }
            }
            .navigationTitle("Filtros y Ordenamiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct StatisticsView: View {
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "Total", value: "\(viewModel.statistics.totalTasks)", color: .blue)
                        StatCard(title: "Completadas", value: "\(viewModel.statistics.completedTasks)", color: .green)
                        StatCard(title: "Pendientes", value: "\(viewModel.statistics.pendingTasks)", color: .orange)
                        StatCard(title: "Vencidas", value: "\(viewModel.statistics.overdueTasks)", color: .red)
                    }
                    
                    // Completion rate
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progreso de Finalización")
                            .font(.headline)
                        
                        ProgressView(value: viewModel.statistics.completionRate) {
                            HStack {
                                Text("Completado")
                                Spacer()
                                Text("\(viewModel.statistics.completionPercentage)%")
                            }
                            .font(.caption)
                        }
                        .tint(.green)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Category breakdown
                    if !viewModel.statistics.tasksByCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tareas por Categoría")
                                .font(.headline)
                            
                            ForEach(Array(viewModel.statistics.tasksByCategory.sorted(by: { $0.value > $1.value })), id: \.key) { category, count in
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Text(category.displayName)
                                    
                                    Spacer()
                                    
                                    Text("\(count)")
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Priority breakdown
                    if !viewModel.statistics.tasksByPriority.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tareas por Prioridad")
                                .font(.headline)
                            
                            ForEach(TaskPriority.allCases.reversed(), id: \.self) { priority in
                                if let count = viewModel.statistics.tasksByPriority[priority], count > 0 {
                                    HStack {
                                        Circle()
                                            .fill(priorityColor(for: priority))
                                            .frame(width: 12, height: 12)
                                        
                                        Text(priority.displayName)
                                        
                                        Spacer()
                                        
                                        Text("\(count)")
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Estadísticas")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
