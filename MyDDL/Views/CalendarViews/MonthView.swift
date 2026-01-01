import SwiftUI
import UniformTypeIdentifiers

// 全局日志函数
func debugLog(_ message: String) {
    let timestamp = Date().formatted(date: .omitted, time: .standard)
    let logMessage = "[\(timestamp)] \(message)\n"
    let logFile = "/tmp/myddl_debug.log"

    if let handle = FileHandle(forWritingAtPath: logFile) {
        handle.seekToEndOfFile()
        if let data = logMessage.data(using: .utf8) {
            handle.write(data)
        }
        handle.closeFile()
    } else {
        FileManager.default.createFile(atPath: logFile, contents: logMessage.data(using: .utf8))
    }
}

struct MonthView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var settings = AppSettings.shared
    @Binding var selectedDate: Date
    @Binding var selectedTask: Task?
    let selectedProjectId: UUID?

    // 使用回调而不是 Binding
    var onRangeSelected: ((Date, Date) -> Void)?

    // 范围选择状态（Option+点击）
    @State private var rangeSelectionStart: Date?

    private var weekdays: [String] {
        if settings.weekStartDay == .monday {
            return ["一", "二", "三", "四", "五", "六", "日"]
        } else {
            return ["日", "一", "二", "三", "四", "五", "六"]
        }
    }

    private var weekendIndices: [Int] {
        if settings.weekStartDay == .monday {
            return [5, 6]  // 周六、周日在索引5和6
        } else {
            return [0, 6]  // 周日在索引0，周六在索引6
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Weekday header
            HStack(spacing: 0) {
                ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(DesignSystem.Fonts.caption)
                        .foregroundColor(weekendIndices.contains(index) ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                }
            }
            .background(DesignSystem.Colors.cardBackground)

            // 范围选择提示
            if rangeSelectionStart != nil {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(DesignSystem.Colors.accent)
                    Text("已选择起始日期，按住 ⌥ Option 点击结束日期")
                        .font(DesignSystem.Fonts.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Spacer()
                    Button("取消") {
                        rangeSelectionStart = nil
                    }
                    .font(DesignSystem.Fonts.caption)
                    .foregroundColor(DesignSystem.Colors.danger)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.accent.opacity(0.1))
            }

            // 日历网格
            SimpleCalendarGrid(
                selectedDate: selectedDate,
                currentSelectedDate: selectedDate,  // 当前选中的日期用于高亮
                rangeSelectionStart: rangeSelectionStart,
                selectedProjectId: selectedProjectId,
                onDayTap: { date in
                    selectedDate = date
                },
                onOptionClick: { date in
                    handleOptionClick(date)
                },
                onTaskTap: { task in
                    selectedTask = task
                }
            )
        }
    }

    private func handleOptionClick(_ date: Date) {
        debugLog("handleOptionClick: \(date), current start: \(String(describing: rangeSelectionStart))")
        if let start = rangeSelectionStart {
            let calendar = Calendar.current
            if !calendar.isDate(start, inSameDayAs: date) {
                let startDate = min(start, date)
                let endDate = max(start, date)
                debugLog("Calling onRangeSelected with: \(startDate) to \(endDate)")
                onRangeSelected?(startDate, endDate)
            }
            rangeSelectionStart = nil
        } else {
            rangeSelectionStart = date
        }
    }
}

// 日历网格组件
struct SimpleCalendarGrid: View {
    @EnvironmentObject var dataStore: DataStore
    let selectedDate: Date
    let currentSelectedDate: Date  // 当前选中的日期
    let rangeSelectionStart: Date?
    let selectedProjectId: UUID?
    var onDayTap: (Date) -> Void
    var onOptionClick: (Date) -> Void
    var onTaskTap: (Task) -> Void

    private var calendarDays: [Date?] {
        Date.calendarGridDays(for: selectedDate)
    }

    var body: some View {
        let days = calendarDays
        let rows = stride(from: 0, to: days.count, by: 7).map { Array(days[$0..<min($0+7, days.count)]) }

        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: 1) {
                        ForEach(0..<rows[rowIndex].count, id: \.self) { colIndex in
                            SimpleDayCell(
                                date: rows[rowIndex][colIndex],
                                isCurrentMonth: rows[rowIndex][colIndex]?.isSameMonth(as: selectedDate) ?? false,
                                isSelected: isSelected(rows[rowIndex][colIndex]),
                                isRangeStart: isRangeStart(rows[rowIndex][colIndex]),
                                tasks: tasksFor(rows[rowIndex][colIndex]),
                                onDayTap: onDayTap,
                                onOptionClick: onOptionClick,
                                onTaskTap: onTaskTap
                            )
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(DesignSystem.Colors.background)
    }

    private func isSelected(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDate(date, inSameDayAs: currentSelectedDate)
    }

    private func isRangeStart(_ date: Date?) -> Bool {
        guard let date = date, let start = rangeSelectionStart else { return false }
        return Calendar.current.isDate(date, inSameDayAs: start)
    }

    private func tasksFor(_ date: Date?) -> [Task] {
        guard let date = date else { return [] }
        let tasks = dataStore.tasks(for: date)
        if let projectId = selectedProjectId {
            return tasks.filter { $0.projectId == projectId }
        }
        return tasks
    }
}

// 日期单元格
struct SimpleDayCell: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var settings = AppSettings.shared
    let date: Date?
    let isCurrentMonth: Bool
    let isSelected: Bool  // 是否是当前选中的日期
    let isRangeStart: Bool
    let tasks: [Task]
    var onDayTap: (Date) -> Void
    var onOptionClick: (Date) -> Void
    var onTaskTap: (Task) -> Void

    @State private var showingTaskForm = false
    @State private var lastClickTime: Date = .distantPast
    @State private var isDropTargeted = false

    // 日期格式化器 - 使用时间戳避免时区问题
    private static func encodeDateForDrag(_ date: Date) -> String {
        return String(Int(date.timeIntervalSince1970))
    }

    private static func decodeDateFromDrag(_ string: String) -> Date? {
        guard let timestamp = Double(string) else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let date = date {
                // 日期数字
                HStack {
                    ZStack {
                        if date.isToday {
                            Circle()
                                .fill(DesignSystem.Colors.danger)  // 今天用红色
                                .frame(width: 26, height: 26)
                        } else if isRangeStart {
                            Circle()
                                .fill(DesignSystem.Colors.success)
                                .frame(width: 26, height: 26)
                        } else if isSelected {
                            Circle()
                                .fill(DesignSystem.Colors.accent)  // 选中日期用蓝色
                                .frame(width: 26, height: 26)
                        }

                        Text("\(date.dayOfMonth)")
                            .font(.system(size: 12, weight: (date.isToday || isRangeStart || isSelected) ? .bold : .medium))
                            .foregroundColor(textColor(for: date))
                    }
                    Spacer()
                }
                .padding(4)

                // 任务列表
                if !tasks.isEmpty {
                    VStack(spacing: 3) {
                        ForEach(tasks.prefix(3)) { task in
                            let taskColor = TaskColorPalette.color(for: task)
                            Text(task.title)
                                .font(.system(size: settings.calendarFontSize.taskFontSize, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(taskColor)
                                )
                                .onDrag {
                                    // 传递 taskId|sourceDate 格式（使用时间戳）
                                    let sourceDate = Self.encodeDateForDrag(date)
                                    let dragData = "\(task.id.uuidString)|\(sourceDate)"
                                    return NSItemProvider(object: dragData as NSString)
                                }
                                .onTapGesture {
                                    onTaskTap(task)
                                }
                        }
                        if tasks.count > 3 {
                            Text("+\(tasks.count - 3) 更多")
                                .font(.system(size: 10))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                    .padding(.horizontal, 4)
                }

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(backgroundColor)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isDropTargeted ? DesignSystem.Colors.accent : borderColor, lineWidth: isDropTargeted ? 3 : (shouldShowBorder ? 2 : 0))
        )
        .overlay(
            // 拖拽高亮效果
            RoundedRectangle(cornerRadius: 6)
                .fill(DesignSystem.Colors.accent.opacity(isDropTargeted ? 0.15 : 0))
        )
        .contentShape(Rectangle())
        .onDrop(of: [.text], isTargeted: $isDropTargeted) { providers in
            guard let date = date else { return false }
            guard let provider = providers.first else { return false }

            provider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, error in
                if let data = data as? Data,
                   let dragString = String(data: data, encoding: .utf8) {
                    // 解析 taskId|sourceDate 格式
                    let components = dragString.split(separator: "|")
                    guard components.count >= 1,
                          let taskId = UUID(uuidString: String(components[0])) else {
                        return
                    }

                    // 解析源日期（如果有）- 使用时间戳
                    var sourceDate: Date? = nil
                    if components.count >= 2 {
                        sourceDate = Self.decodeDateFromDrag(String(components[1]))
                    }

                    DispatchQueue.main.async {
                        if let task = dataStore.tasks.first(where: { $0.id == taskId }) {
                            debugLog("[Drop] Moving task '\(task.title)' to \(date), sourceDate: \(String(describing: sourceDate))")
                            moveTask(task, to: date, fromSourceDate: sourceDate)
                        }
                    }
                }
            }
            return true
        }
        .onTapGesture {
            guard let date = date else { return }

            let now = Date()
            let timeSinceLastClick = now.timeIntervalSince(lastClickTime)

            if timeSinceLastClick < 0.3 {
                // 双击 - 创建任务
                showingTaskForm = true
                lastClickTime = .distantPast
            } else {
                // 单击
                if NSEvent.modifierFlags.contains(.option) {
                    onOptionClick(date)
                } else {
                    onDayTap(date)
                }
                lastClickTime = now
            }
        }
        .sheet(isPresented: $showingTaskForm) {
            if let date = date {
                TaskFormView(
                    isPresented: $showingTaskForm,
                    initialDate: date,
                    existingTask: nil
                )
            }
        }
    }

    private func textColor(for date: Date) -> Color {
        if date.isToday || isRangeStart || isSelected {
            return .white
        }
        if !isCurrentMonth {
            return DesignSystem.Colors.textTertiary
        }
        return DesignSystem.Colors.textPrimary
    }

    private var shouldShowBorder: Bool {
        isRangeStart || isSelected || date?.isToday == true
    }

    private var borderColor: Color {
        if isRangeStart { return DesignSystem.Colors.success }
        if date?.isToday == true { return DesignSystem.Colors.danger }  // 今天用红色边框
        if isSelected { return DesignSystem.Colors.accent }
        return .clear
    }

    private var backgroundColor: Color {
        guard let date = date else { return .clear }
        if isRangeStart { return DesignSystem.Colors.success.opacity(0.2) }
        if date.isToday { return DesignSystem.Colors.danger.opacity(0.1) }  // 今天用红色背景
        if isSelected { return DesignSystem.Colors.accent.opacity(0.15) }
        if !isCurrentMonth { return DesignSystem.Colors.background.opacity(0.5) }
        // 周末和法定节假日用设置中的休息日颜色
        if date.isRestDay { return settings.restdayBackgroundColor }
        // 工作日使用设置中的工作日颜色
        return settings.workdayBackgroundColor
    }

    // 移动任务到新日期
    private func moveTask(_ task: Task, to newDate: Date, fromSourceDate sourceDate: Date?) {
        let calendar = Calendar.current
        let isMultiDayTask = !calendar.isDate(task.startDate.startOfDay, inSameDayAs: task.endDate.startOfDay)

        if isMultiDayTask, let sourceDate = sourceDate {
            // 多日任务：拆分出被拖拽的那一天，创建新的单日任务
            let sourceDayStart = calendar.startOfDay(for: sourceDate)
            let taskStartDay = calendar.startOfDay(for: task.startDate)
            let taskEndDay = calendar.startOfDay(for: task.endDate)

            // 创建新的单日任务（在目标日期）- 不继承 requirementId
            debugLog("[Drop] Original task requirementId: \(String(describing: task.requirementId))")
            let newTask = Task(
                id: UUID(),
                title: task.title,
                startDate: calendar.startOfDay(for: newDate),
                endDate: calendar.startOfDay(for: newDate).addingTimeInterval(23 * 3600 + 59 * 60 + 59),
                estimatedHours: task.estimatedHours / Double(task.daySpan),
                priority: task.priority,
                status: task.status,
                projectId: task.projectId,
                requirementId: nil,  // 拆分出的任务不继承需求关联
                notes: task.notes,
                createdAt: Date(),
                updatedAt: Date()
            )
            debugLog("[Drop] New task requirementId: \(String(describing: newTask.requirementId))")
            dataStore.addTaskWithoutRequirement(newTask)  // 使用不创建需求的方法
            debugLog("[Drop] Created new single-day task: \(newTask.title) on \(newDate)")

            // 修改原任务的日期范围
            if calendar.isDate(sourceDayStart, inSameDayAs: taskStartDay) {
                // 拖的是第一天：原任务开始日期后移一天
                let newStartDate = calendar.date(byAdding: .day, value: 1, to: task.startDate)!
                if calendar.isDate(newStartDate.startOfDay, inSameDayAs: taskEndDay) || newStartDate > task.endDate {
                    // 如果只剩一天或没有了，删除原任务
                    if calendar.isDate(newStartDate.startOfDay, inSameDayAs: taskEndDay) {
                        // 还剩一天，更新为单日任务
                        var updatedTask = task
                        updatedTask.startDate = newStartDate
                        updatedTask.updatedAt = Date()
                        dataStore.updateTask(updatedTask)
                        debugLog("[Drop] Updated original task to single day: \(taskEndDay)")
                    } else {
                        dataStore.deleteTask(task)
                        debugLog("[Drop] Deleted original task (no days left)")
                    }
                } else {
                    var updatedTask = task
                    updatedTask.startDate = newStartDate
                    updatedTask.updatedAt = Date()
                    dataStore.updateTask(updatedTask)
                    debugLog("[Drop] Updated original task startDate to: \(newStartDate)")
                }
            } else if calendar.isDate(sourceDayStart, inSameDayAs: taskEndDay) {
                // 拖的是最后一天：原任务结束日期前移一天
                let newEndDate = calendar.date(byAdding: .day, value: -1, to: task.endDate)!
                if calendar.isDate(taskStartDay, inSameDayAs: newEndDate.startOfDay) || newEndDate < task.startDate {
                    // 如果只剩一天或没有了
                    if calendar.isDate(taskStartDay, inSameDayAs: newEndDate.startOfDay) {
                        // 还剩一天，更新为单日任务
                        var updatedTask = task
                        updatedTask.endDate = task.startDate.addingTimeInterval(23 * 3600 + 59 * 60 + 59)
                        updatedTask.updatedAt = Date()
                        dataStore.updateTask(updatedTask)
                        debugLog("[Drop] Updated original task to single day: \(taskStartDay)")
                    } else {
                        dataStore.deleteTask(task)
                        debugLog("[Drop] Deleted original task (no days left)")
                    }
                } else {
                    var updatedTask = task
                    updatedTask.endDate = newEndDate
                    updatedTask.updatedAt = Date()
                    dataStore.updateTask(updatedTask)
                    debugLog("[Drop] Updated original task endDate to: \(newEndDate)")
                }
            } else {
                // 拖的是中间某天：原任务拆成两段
                // 第一段：startDate 到 sourceDate-1（保留原任务的需求关联）
                var firstPart = task
                firstPart.endDate = calendar.date(byAdding: .day, value: -1, to: sourceDayStart)!.addingTimeInterval(23 * 3600 + 59 * 60 + 59)
                firstPart.updatedAt = Date()
                dataStore.updateTask(firstPart)

                // 第二段：sourceDate+1 到 endDate（不继承需求关联）
                let secondPartStart = calendar.date(byAdding: .day, value: 1, to: sourceDayStart)!
                let secondPart = Task(
                    id: UUID(),
                    title: task.title,
                    startDate: secondPartStart,
                    endDate: task.endDate,
                    estimatedHours: task.estimatedHours / Double(task.daySpan),
                    priority: task.priority,
                    status: task.status,
                    projectId: task.projectId,
                    requirementId: nil,  // 拆分出的任务不继承需求关联
                    notes: task.notes,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                dataStore.addTaskWithoutRequirement(secondPart)  // 使用不创建需求的方法
                debugLog("[Drop] Split original task into two parts")
            }
        } else {
            // 单日任务：直接移动到新日期
            let newStartDate = calendar.startOfDay(for: newDate)
            let newEndDate = newStartDate.addingTimeInterval(23 * 3600 + 59 * 60 + 59)

            var updatedTask = task
            updatedTask.startDate = newStartDate
            updatedTask.endDate = newEndDate
            updatedTask.updatedAt = Date()

            debugLog("[Drop] Moving single-day task '\(updatedTask.title)' to \(newDate)")
            dataStore.updateTask(updatedTask)
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
