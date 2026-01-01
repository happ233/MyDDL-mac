import SwiftUI

struct RequirementListView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedStatus: RequirementStatus?
    @Binding var selectedRequirement: Requirement?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            RequirementListHeader(selectedStatus: $selectedStatus)

            // Content
            if let status = selectedStatus {
                RequirementGridForStatus(
                    status: status,
                    selectedRequirement: $selectedRequirement
                )
            } else {
                RequirementKanbanView(selectedRequirement: $selectedRequirement)
            }
        }
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Header
struct RequirementListHeader: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedStatus: RequirementStatus?

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text("需求管理")
                    .font(DesignSystem.Fonts.title)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("共 \(dataStore.requirements.count) 个需求")
                    .font(DesignSystem.Fonts.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }

            Spacer()

            // Status filter
            HStack(spacing: DesignSystem.Spacing.sm) {
                StatusFilterButton(
                    title: "全部",
                    isSelected: selectedStatus == nil,
                    color: DesignSystem.Colors.accent
                ) {
                    withAnimation { selectedStatus = nil }
                }

                ForEach(RequirementStatus.allCases, id: \.self) { status in
                    StatusFilterButton(
                        title: status.displayName,
                        isSelected: selectedStatus == status,
                        color: status.color
                    ) {
                        withAnimation { selectedStatus = status }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(DesignSystem.Colors.cardBackground)
    }
}

struct StatusFilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    var onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Text(title)
            .font(DesignSystem.Fonts.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .fill(isSelected ? color : (isHovered ? color.opacity(0.15) : DesignSystem.Colors.elevatedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .stroke(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
            )
            .onHover { isHovered = $0 }
            .onTapGesture { onTap() }
    }
}

// MARK: - Kanban View (全部状态)
struct RequirementKanbanView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedRequirement: Requirement?

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.lg) {
            ForEach(RequirementStatus.allCases, id: \.self) { status in
                KanbanColumn(
                    status: status,
                    requirements: dataStore.requirements(for: status),
                    selectedRequirement: $selectedRequirement
                )
            }
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

struct KanbanColumn: View {
    @EnvironmentObject var dataStore: DataStore
    let status: RequirementStatus
    let requirements: [Requirement]
    @Binding var selectedRequirement: Requirement?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Column header
            HStack {
                Image(systemName: status.icon)
                    .font(.system(size: 14))
                    .foregroundColor(status.color)

                Text(status.displayName)
                    .font(DesignSystem.Fonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Text("\(requirements.count)")
                    .font(DesignSystem.Fonts.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(status.color))
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .fill(status.color.opacity(0.1))
            )

            // Requirements list
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(requirements) { req in
                        RequirementListCard(
                            requirement: req,
                            project: dataStore.project(for: req),
                            onTap: { selectedRequirement = req },
                            onStatusChange: { newStatus in
                                var updated = req
                                updated.status = newStatus
                                dataStore.updateRequirement(updated)
                            }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.large)
                .fill(DesignSystem.Colors.cardBackground)
        )
    }
}

// MARK: - Grid View (单个状态)
struct RequirementGridForStatus: View {
    @EnvironmentObject var dataStore: DataStore
    let status: RequirementStatus
    @Binding var selectedRequirement: Requirement?

    var body: some View {
        let requirements = dataStore.requirements(for: status)

        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(requirements) { req in
                    RequirementListCard(
                        requirement: req,
                        project: dataStore.project(for: req),
                        onTap: { selectedRequirement = req },
                        onStatusChange: { newStatus in
                            var updated = req
                            updated.status = newStatus
                            dataStore.updateRequirement(updated)
                        }
                    )
                }

                if requirements.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(DesignSystem.Colors.textTertiary)

                        Text("暂无\(status.displayName)的需求")
                            .font(DesignSystem.Fonts.body)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 100)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - List Card
struct RequirementListCard: View {
    let requirement: Requirement
    let project: Project?
    var onTap: () -> Void
    var onStatusChange: ((RequirementStatus) -> Void)?
    var isCompact: Bool = false

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Top row: Priority + Status
            HStack {
                // Priority
                Text(requirement.priority.displayName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(requirement.priority.color)
                    )

                Spacer()

                // Status
                HStack(spacing: 4) {
                    Image(systemName: requirement.status.icon)
                        .font(.system(size: 12))
                    Text(requirement.status.displayName)
                        .font(DesignSystem.Fonts.tiny)
                }
                .foregroundColor(requirement.status.color)
            }

            // Title - 完整显示
            Text(requirement.title)
                .font(DesignSystem.Fonts.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            // Description
            if !requirement.description.isEmpty {
                Text(requirement.description)
                    .font(DesignSystem.Fonts.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .lineLimit(2)
            }

            // Bottom row: Project
            if let project = project {
                HStack(spacing: 4) {
                    Circle()
                        .fill(project.color)
                        .frame(width: 8, height: 8)
                    Text(project.name)
                        .font(DesignSystem.Fonts.tiny)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(isHovered ? DesignSystem.Colors.elevatedBackground : DesignSystem.Colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(isHovered ? requirement.status.color.opacity(0.3) : DesignSystem.Colors.border, lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
        .onHover { isHovered = $0 }
        .onTapGesture { onTap() }
        .contextMenu {
            ForEach(RequirementStatus.allCases, id: \.self) { status in
                Button {
                    onStatusChange?(status)
                } label: {
                    Label(status.displayName, systemImage: status.icon)
                }
            }
        }
    }
}
