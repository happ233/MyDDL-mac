import SwiftUI

struct WeekView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedDate: Date
    @Binding var selectedTask: Task?
    let selectedProjectId: UUID?

    var body: some View {
        let weekDays = Date.daysInWeek(for: selectedDate)

        VStack(spacing: 0) {
            // Day headers
            HStack(spacing: 1) {
                ForEach(weekDays, id: \.self) { day in
                    WeekDayHeader(date: day, totalHours: dataStore.totalHours(for: day))
                }
            }
            .background(DesignSystem.Colors.cardBackground)

            // Week grid
            ScrollView {
                HStack(spacing: 1) {
                    ForEach(weekDays, id: \.self) { day in
                        WeekDayColumn(
                            date: day,
                            tasks: filteredTasks(for: day),
                            onTaskTap: { task in
                                selectedTask = task
                            },
                            onStatusChange: { task, status in
                                var updatedTask = task
                                updatedTask.status = status
                                dataStore.updateTask(updatedTask)
                            }
                        )
                        .environmentObject(dataStore)
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    private func filteredTasks(for date: Date) -> [Task] {
        let tasks = dataStore.tasks(for: date)
        if let projectId = selectedProjectId {
            return tasks.filter { $0.projectId == projectId }
        }
        return tasks
    }
}

struct WeekDayHeader: View {
    let date: Date
    let totalHours: Double

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(date.shortWeekdayName)
                .font(DesignSystem.Fonts.caption)
                .foregroundColor(date.isWeekend ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textSecondary)

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
                        .frame(width: 36, height: 36)
                }

                Text("\(date.dayOfMonth)")
                    .font(.system(size: 16, weight: date.isToday ? .bold : .medium, design: .rounded))
                    .foregroundColor(date.isToday ? .white : DesignSystem.Colors.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(date.isToday ? DesignSystem.Colors.accent.opacity(0.05) : Color.clear)
    }
}

struct WeekDayColumn: View {
    @EnvironmentObject var dataStore: DataStore
    let date: Date
    let tasks: [Task]
    var onTaskTap: (Task) -> Void
    var onStatusChange: (Task, TaskStatus) -> Void

    @State private var showingTaskForm = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(tasks) { task in
                TaskCard(
                    task: task,
                    project: dataStore.project(for: task),
                    isCompact: true,
                    onTap: { onTaskTap(task) },
                    onStatusChange: { status in
                        onStatusChange(task, status)
                    }
                )
            }

            if tasks.isEmpty {
                Spacer()
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, minHeight: 400)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(backgroundColor)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture(count: 2) {
            showingTaskForm = true
        }
        .sheet(isPresented: $showingTaskForm) {
            TaskFormView(
                isPresented: $showingTaskForm,
                initialDate: date,
                existingTask: nil
            )
        }
    }

    private var backgroundColor: Color {
        if date.isToday {
            return DesignSystem.Colors.accent.opacity(0.08)
        }
        if isHovered {
            return DesignSystem.Colors.elevatedBackground
        }
        return DesignSystem.Colors.cardBackground
    }
}
