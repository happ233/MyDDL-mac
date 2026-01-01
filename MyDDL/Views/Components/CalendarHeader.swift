import SwiftUI

struct CalendarHeader: View {
    @Binding var selectedDate: Date
    @Binding var viewType: CalendarViewType
    @Binding var showingTaskForm: Bool
    @EnvironmentObject var dataStore: DataStore
    @State private var showingSettings = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // 日期导航
            HStack(spacing: DesignSystem.Spacing.sm) {
                // 上一页
                NavigationButton(icon: "chevron.left", action: navigatePrevious)

                // 今天按钮
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedDate = Date()
                    }
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Circle()
                            .fill(DesignSystem.Colors.accent)
                            .frame(width: 6, height: 6)

                        Text("今天")
                            .font(DesignSystem.Fonts.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.accent)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                            .fill(DesignSystem.Colors.accent.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                                    .stroke(DesignSystem.Colors.accent.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .hoverEffect(scale: 1.05)

                // 下一页
                NavigationButton(icon: "chevron.right", action: navigateNext)
            }

            // 日期标题
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(dateTitle)
                    .font(DesignSystem.Fonts.title)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                // 当前日期的任务数
                let taskCount = tasksForCurrentView
                if taskCount > 0 {
                    Text("\(taskCount) 任务")
                        .font(DesignSystem.Fonts.tiny)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(DesignSystem.Colors.border)
                        )
                }
            }

            Spacer()

            // 视图切换
            HStack(spacing: 0) {
                ForEach(CalendarViewType.allCases, id: \.self) { type in
                    ViewTypeButton(
                        type: type,
                        isSelected: viewType == type,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewType = type
                            }
                        }
                    )
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .fill(DesignSystem.Colors.elevatedBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                    )
            )

            // 新建任务按钮
            Button(action: { showingTaskForm = true }) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("新建任务")
                }
            }
            .buttonStyle(GradientButtonStyle())

            // 设置按钮
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                            .fill(DesignSystem.Colors.elevatedBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .hoverEffect(scale: 1.1)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            DesignSystem.Colors.cardBackground
        )
        .sheet(isPresented: $showingSettings) {
            SettingsView(isPresented: $showingSettings)
        }
    }

    private var tasksForCurrentView: Int {
        switch viewType {
        case .month:
            return dataStore.tasks(in: selectedDate.startOfMonth...selectedDate.endOfMonth).count
        case .week:
            return dataStore.tasks(in: selectedDate.startOfWeek...selectedDate.endOfWeek).count
        case .day:
            return dataStore.tasks(for: selectedDate).count
        }
    }

    private var dateTitle: String {
        switch viewType {
        case .month:
            return "\(selectedDate.yearString)年\(selectedDate.monthName)"
        case .week:
            let start = selectedDate.startOfWeek
            let end = selectedDate.endOfWeek
            if start.isSameMonth(as: end) {
                return "\(start.yearString)年\(start.monthName) \(start.dayOfMonth)-\(end.dayOfMonth)日"
            } else {
                return "\(start.shortDateString) - \(end.shortDateString)"
            }
        case .day:
            return selectedDate.fullDateString + " " + selectedDate.weekdayName
        }
    }

    private func navigatePrevious() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            switch viewType {
            case .month:
                selectedDate = selectedDate.adding(months: -1)
            case .week:
                selectedDate = selectedDate.adding(weeks: -1)
            case .day:
                selectedDate = selectedDate.adding(days: -1)
            }
        }
    }

    private func navigateNext() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            switch viewType {
            case .month:
                selectedDate = selectedDate.adding(months: 1)
            case .week:
                selectedDate = selectedDate.adding(weeks: 1)
            case .day:
                selectedDate = selectedDate.adding(days: 1)
            }
        }
    }
}

struct NavigationButton: View {
    let icon: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isHovered ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                        .fill(isHovered ? DesignSystem.Colors.accent.opacity(0.15) : DesignSystem.Colors.elevatedBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ViewTypeButton: View {
    let type: CalendarViewType
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: type.icon)
                    .font(.system(size: 10))

                Text(type.displayName)
                    .font(DesignSystem.Fonts.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .foregroundColor(isSelected ? .white : (isHovered ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary))
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                    .fill(isSelected ?
                          LinearGradient(colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accentLight], startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [Color.clear, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .shadow(color: isSelected ? DesignSystem.Colors.accent.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
