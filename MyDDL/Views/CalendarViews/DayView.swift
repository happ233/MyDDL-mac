import SwiftUI

struct DayView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedDate: Date
    @Binding var selectedTask: Task?
    let selectedProjectId: UUID?

    @State private var showingTaskForm = false

    var body: some View {
        HStack(spacing: 0) {
            // Main day view
            VStack(spacing: 0) {
                // Day header
                DayHeader(date: selectedDate, tasks: filteredTasks)
                    .environmentObject(dataStore)

                // Task list
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        if filteredTasks.isEmpty {
                            EmptyDayView(onAddTask: { showingTaskForm = true })
                        } else {
                            ForEach(filteredTasks) { task in
                                TaskCard(
                                    task: task,
                                    project: dataStore.project(for: task),
                                    isCompact: false,
                                    onTap: { selectedTask = task },
                                    onStatusChange: { status in
                                        updateTaskStatus(task: task, status: status)
                                    }
                                )
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.xl)
                }

                // Quick add task
                QuickAddTaskView(date: selectedDate)
                    .environmentObject(dataStore)
            }
            .background(DesignSystem.Colors.secondaryBackground)

            // Side panel - upcoming days
            UpcomingDaysPanel(
                startDate: selectedDate,
                selectedProjectId: selectedProjectId,
                onTaskTap: { selectedTask = $0 }
            )
            .environmentObject(dataStore)
            .frame(width: 300)
        }
        .sheet(isPresented: $showingTaskForm) {
            TaskFormView(
                isPresented: $showingTaskForm,
                initialDate: selectedDate,
                existingTask: nil
            )
        }
    }

    private var filteredTasks: [Task] {
        let tasks = dataStore.tasks(for: selectedDate)
        if let projectId = selectedProjectId {
            return tasks.filter { $0.projectId == projectId }
        }
        return tasks
    }

    private func updateTaskStatus(task: Task, status: TaskStatus) {
        var updatedTask = task
        updatedTask.status = status
        dataStore.updateTask(updatedTask)
    }
}

struct DayHeader: View {
    @EnvironmentObject var dataStore: DataStore
    let date: Date
    let tasks: [Task]

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            // Date info
            HStack(spacing: DesignSystem.Spacing.lg) {
                // Day number
                ZStack {
                    if date.isToday {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                    } else {
                        Circle()
                            .stroke(DesignSystem.Colors.border, lineWidth: 2)
                            .frame(width: 56, height: 56)
                    }

                    Text("\(date.dayOfMonth)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(date.isToday ? .white : DesignSystem.Colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(date.isToday ? "今天" : date.weekdayName)
                        .font(DesignSystem.Fonts.largeTitle)
                        .foregroundColor(date.isToday ? DesignSystem.Colors.accent : DesignSystem.Colors.textPrimary)

                    Text(date.fullDateString)
                        .font(DesignSystem.Fonts.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }

            Spacer()

            // Stats
            HStack(spacing: DesignSystem.Spacing.md) {
                DayStatCard(
                    icon: "list.bullet",
                    value: "\(tasks.count)",
                    label: "任务",
                    color: DesignSystem.Colors.accent
                )

                DayStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(tasks.filter { $0.status == .completed }.count)",
                    label: "完成",
                    color: DesignSystem.Colors.success
                )
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            DesignSystem.Colors.cardBackground
        )
    }
}

struct DayStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundColor(color)

            Text(label)
                .font(DesignSystem.Fonts.tiny)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(color.opacity(0.1))
        )
    }
}

struct EmptyDayView: View {
    var onAddTask: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("今天没有任务")
                    .font(DesignSystem.Fonts.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("享受轻松的一天，或者添加新任务")
                    .font(DesignSystem.Fonts.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }

            Button(action: onAddTask) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("添加任务")
                        .font(DesignSystem.Fonts.caption)
                }
            }
            .buttonStyle(GradientButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xxl)
    }
}

struct QuickAddTaskView: View {
    @EnvironmentObject var dataStore: DataStore
    let date: Date
    @State private var taskTitle = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.accent)

            TextField("快速添加任务...", text: $taskTitle)
                .textFieldStyle(.plain)
                .font(DesignSystem.Fonts.body)
                .focused($isFocused)
                .onSubmit {
                    addTask()
                }

            if !taskTitle.isEmpty {
                Button(action: addTask) {
                    Text("添加")
                        .font(DesignSystem.Fonts.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.accent)
                        .cornerRadius(DesignSystem.Radius.small)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            DesignSystem.Colors.cardBackground
                .background(.ultraThinMaterial)
        )
    }

    private func addTask() {
        let title = taskTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        let task = Task(
            title: title,
            startDate: date,
            endDate: date,
            projectId: dataStore.projects.first?.id
        )
        dataStore.addTask(task)
        taskTitle = ""
    }
}

struct UpcomingDaysPanel: View {
    @EnvironmentObject var dataStore: DataStore
    let startDate: Date
    let selectedProjectId: UUID?
    var onTaskTap: (Task) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("接下来")
                    .font(DesignSystem.Fonts.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Text("7 天")
                    .font(DesignSystem.Fonts.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            .padding(DesignSystem.Spacing.lg)

            Rectangle()
                .fill(DesignSystem.Colors.divider)
                .frame(height: 1)

            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(1..<8, id: \.self) { offset in
                        let date = startDate.adding(days: offset)
                        let tasks = filteredTasks(for: date)

                        UpcomingDayCard(
                            date: date,
                            tasks: tasks,
                            onTaskTap: onTaskTap
                        )
                        .environmentObject(dataStore)
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .background(
            DesignSystem.Colors.cardBackground
                .background(.ultraThinMaterial)
        )
    }

    private func filteredTasks(for date: Date) -> [Task] {
        let tasks = dataStore.tasks(for: date)
        if let projectId = selectedProjectId {
            return tasks.filter { $0.projectId == projectId }
        }
        return tasks
    }
}

struct UpcomingDayCard: View {
    @EnvironmentObject var dataStore: DataStore
    let date: Date
    let tasks: [Task]
    var onTaskTap: (Task) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Date header
            HStack {
                Text(date.shortDateString)
                    .font(DesignSystem.Fonts.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text(date.shortWeekdayName)
                    .font(DesignSystem.Fonts.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)

                Spacer()

                if !tasks.isEmpty {
                    Text("\(tasks.count)")
                        .font(DesignSystem.Fonts.tiny)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(DesignSystem.Colors.accent)
                        .cornerRadius(DesignSystem.Radius.small)
                }
            }

            // Tasks
            if tasks.isEmpty {
                Text("无任务")
                    .font(DesignSystem.Fonts.tiny)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .padding(.vertical, DesignSystem.Spacing.xs)
            } else {
                ForEach(tasks.prefix(3)) { task in
                    MiniTaskCard(
                        task: task,
                        project: dataStore.project(for: task)
                    )
                    .onTapGesture {
                        onTaskTap(task)
                    }
                }

                if tasks.count > 3 {
                    Text("+\(tasks.count - 3) 更多")
                        .font(DesignSystem.Fonts.tiny)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(DesignSystem.Colors.elevatedBackground)
        )
    }
}

struct MiniTaskCard: View {
    let task: Task
    let project: Project?

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(project?.color ?? DesignSystem.Colors.accent)
                .frame(width: 3, height: 16)

            Text(task.title)
                .font(DesignSystem.Fonts.tiny)
                .foregroundColor(task.status == .completed ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary)
                .strikethrough(task.status == .completed, color: DesignSystem.Colors.textTertiary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                .fill((project?.color ?? DesignSystem.Colors.accent).opacity(isHovered ? 0.15 : 0.08))
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}
