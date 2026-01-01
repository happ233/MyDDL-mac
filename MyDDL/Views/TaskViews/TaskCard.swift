import SwiftUI

// 任务颜色调色板 - 根据任务名分配颜色
struct TaskColorPalette {
    static let colors: [Color] = [
        .blue,
        .green,
        .orange,
        .red,
        .purple,
        .pink,
        .cyan,
        .indigo,
    ]

    static func color(for task: Task) -> Color {
        // 使用任务名的哈希值来分配颜色，同名任务显示相同颜色
        let hash = task.title.hashValue
        let index = abs(hash) % colors.count
        return colors[index]
    }
}

struct TaskCard: View {
    let task: Task
    let project: Project?
    let isCompact: Bool
    var onTap: () -> Void = {}
    var onStatusChange: ((TaskStatus) -> Void)?

    @State private var isHovered = false

    // 任务专属颜色
    private var taskColor: Color {
        TaskColorPalette.color(for: task)
    }

    var body: some View {
        if isCompact {
            compactView
        } else {
            fullView
        }
    }

    // 紧凑视图 - 日历中使用
    private var compactView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 标题 - 增大字号，完整显示
            Text(task.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(taskColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: taskColor.opacity(0.4), radius: 4, x: 0, y: 2)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button {
                    onStatusChange?(status)
                } label: {
                    Label(status.displayName, systemImage: status.icon)
                }
            }
        }
    }

    // 完整视图
    private var fullView: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Status checkbox with animation
            Button(action: cycleStatus) {
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(statusColor.opacity(0.3), lineWidth: 2)
                        .frame(width: isCompact ? 18 : 22, height: isCompact ? 18 : 22)

                    // Inner fill based on status
                    if task.status == .completed {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.success, DesignSystem.Colors.successLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: isCompact ? 18 : 22, height: isCompact ? 18 : 22)

                        Image(systemName: "checkmark")
                            .font(.system(size: isCompact ? 9 : 11, weight: .bold))
                            .foregroundColor(.white)
                    } else if task.status == .inProgress {
                        Circle()
                            .trim(from: 0, to: 0.5)
                            .stroke(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.warning, DesignSystem.Colors.warningLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: isCompact ? 18 : 22, height: isCompact ? 18 : 22)
                            .rotationEffect(.degrees(-90))

                        Circle()
                            .fill(DesignSystem.Colors.warning.opacity(0.2))
                            .frame(width: isCompact ? 10 : 12, height: isCompact ? 10 : 12)
                    }
                }
            }
            .buttonStyle(.plain)
            .hoverEffect(scale: 1.15)

            // Priority indicator
            if !isCompact {
                RoundedRectangle(cornerRadius: 3)
                    .fill(priorityGradient)
                    .frame(width: 4, height: 32)
                    .shadow(color: priorityColor.opacity(0.3), radius: 4, x: 0, y: 0)
            }

            // Project color bar
            if let project = project {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [project.color, project.color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: isCompact ? 20 : 32)
            }

            // Title and info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(task.title)
                        .font(isCompact ? DesignSystem.Fonts.caption : DesignSystem.Fonts.body)
                        .fontWeight(isCompact ? .medium : .regular)
                        .foregroundColor(task.status == .completed ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary)
                        .strikethrough(task.status == .completed, color: DesignSystem.Colors.textTertiary)
                        .lineLimit(isCompact ? 1 : 2)

                    if !isCompact && task.priority == .high {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 10))
                            .foregroundColor(DesignSystem.Colors.danger)
                    }
                }

                if !isCompact {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        if task.isMultiDay {
                            Label("\(task.startDate.shortDateString) - \(task.endDate.shortDateString)", systemImage: "calendar")
                                .font(DesignSystem.Fonts.tiny)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }

                        if task.estimatedHours != 8.0 {
                            Label(String(format: "%.1fh", task.estimatedHours), systemImage: "clock")
                                .font(DesignSystem.Fonts.tiny)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                }
            }

            Spacer()

            // Overdue indicator
            if task.isOverdue {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundColor(DesignSystem.Colors.danger)
                    .shadow(color: DesignSystem.Colors.danger.opacity(0.3), radius: 4, x: 0, y: 0)
            }
        }
        .padding(.horizontal, isCompact ? DesignSystem.Spacing.sm : DesignSystem.Spacing.md)
        .padding(.vertical, isCompact ? DesignSystem.Spacing.sm : DesignSystem.Spacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .fill(backgroundColor)

                if isHovered {
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .shadow(color: shadowColor, radius: isHovered ? 12 : 4, x: 0, y: isHovered ? 6 : 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(borderColor, lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onTap()
        }
    }

    private var statusColor: Color {
        switch task.status {
        case .notStarted:
            return DesignSystem.Colors.textTertiary
        case .inProgress:
            return DesignSystem.Colors.warning
        case .completed:
            return DesignSystem.Colors.success
        }
    }

    private var priorityColor: Color {
        switch task.priority {
        case .high: return DesignSystem.Colors.danger
        case .medium: return DesignSystem.Colors.warning
        case .low: return DesignSystem.Colors.success
        }
    }

    private var priorityGradient: LinearGradient {
        switch task.priority {
        case .high:
            return LinearGradient(colors: [DesignSystem.Colors.danger, DesignSystem.Colors.dangerLight], startPoint: .top, endPoint: .bottom)
        case .medium:
            return LinearGradient(colors: [DesignSystem.Colors.warning, DesignSystem.Colors.warningLight], startPoint: .top, endPoint: .bottom)
        case .low:
            return LinearGradient(colors: [DesignSystem.Colors.success, DesignSystem.Colors.successLight], startPoint: .top, endPoint: .bottom)
        }
    }

    private var backgroundColor: Color {
        if task.isOverdue {
            return DesignSystem.Colors.danger.opacity(0.12)
        }
        return DesignSystem.Colors.cardBackground
    }

    private var shadowColor: Color {
        if task.isOverdue {
            return DesignSystem.Colors.danger.opacity(isHovered ? 0.15 : 0.08)
        }
        return Color.black.opacity(isHovered ? 0.12 : 0.06)
    }

    private var borderColor: Color {
        if task.isOverdue {
            return DesignSystem.Colors.danger.opacity(0.3)
        }
        if isHovered {
            return DesignSystem.Colors.accent.opacity(0.4)
        }
        return DesignSystem.Colors.border
    }

    private func cycleStatus() {
        let newStatus: TaskStatus
        switch task.status {
        case .notStarted:
            newStatus = .inProgress
        case .inProgress:
            newStatus = .completed
        case .completed:
            newStatus = .notStarted
        }
        onStatusChange?(newStatus)
    }
}

struct MultiDayTaskBar: View {
    let task: Task
    let project: Project?
    let startOffset: Int
    let length: Int
    let totalDays: Int
    var onTap: () -> Void = {}

    @State private var isHovered = false

    // 使用任务专属颜色
    private var barColor: Color {
        TaskColorPalette.color(for: task)
    }

    var body: some View {
        GeometryReader { geometry in
            let dayWidth = geometry.size.width / CGFloat(totalDays)
            let barWidth = dayWidth * CGFloat(length) - 4
            let xOffset = dayWidth * CGFloat(startOffset) + 2

            HStack(spacing: DesignSystem.Spacing.xs) {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 6, height: 6)

                Text(task.title)
                    .font(DesignSystem.Fonts.tiny)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .frame(width: barWidth, height: 26)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                    .fill(
                        LinearGradient(
                            colors: [barColor, barColor.opacity(0.75)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: barColor.opacity(0.35), radius: isHovered ? 8 : 4, x: 0, y: isHovered ? 4 : 2)
            )
            .offset(x: xOffset)
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            .onTapGesture {
                onTap()
            }
        }
        .frame(height: 26)
    }
}
