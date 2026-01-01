import SwiftUI

struct RequirementFormView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var isPresented: Bool
    let existingRequirement: Requirement?
    var onDismiss: (() -> Void)?

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var status: RequirementStatus = .developing
    @State private var priority: RequirementPriority = .p2
    @State private var selectedProjectId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(existingRequirement == nil ? "新建需求" : "编辑需求")
                        .font(DesignSystem.Fonts.title)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text(existingRequirement == nil ? "添加一个新的需求" : "修改需求信息")
                        .font(DesignSystem.Fonts.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }

                Spacer()

                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .frame(width: 28, height: 28)
                        .background(DesignSystem.Colors.elevatedBackground)
                        .cornerRadius(DesignSystem.Radius.small)
                }
                .buttonStyle(.plain)
                .hoverEffect(scale: 1.1)
            }
            .padding(DesignSystem.Spacing.xl)

            Rectangle()
                .fill(DesignSystem.Colors.divider)
                .frame(height: 1)

            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    // Title
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("需求名称")
                            .font(DesignSystem.Fonts.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)

                        TextField("输入需求名称...", text: $title)
                            .textFieldStyle(.plain)
                            .font(DesignSystem.Fonts.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .padding(DesignSystem.Spacing.md)
                            .background(DesignSystem.Colors.elevatedBackground)
                            .cornerRadius(DesignSystem.Radius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                    }

                    // Status
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("状态")
                            .font(DesignSystem.Fonts.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(RequirementStatus.allCases, id: \.self) { s in
                                StatusChip(
                                    status: s,
                                    isSelected: status == s,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            status = s
                                        }
                                    }
                                )
                            }
                        }
                    }

                    // Priority
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("优先级")
                            .font(DesignSystem.Fonts.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(RequirementPriority.allCases, id: \.self) { p in
                                PriorityChip(
                                    priority: p,
                                    isSelected: priority == p,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            priority = p
                                        }
                                    }
                                )
                            }
                        }
                    }

                    // Project
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("关联项目")
                            .font(DesignSystem.Fonts.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(dataStore.projects) { project in
                                ProjectChip(
                                    project: project,
                                    isSelected: selectedProjectId == project.id,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            selectedProjectId = project.id
                                        }
                                    }
                                )
                            }
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("需求描述")
                            .font(DesignSystem.Fonts.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)

                        TextEditor(text: $description)
                            .font(DesignSystem.Fonts.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(height: 100)
                            .padding(DesignSystem.Spacing.sm)
                            .background(DesignSystem.Colors.elevatedBackground)
                            .cornerRadius(DesignSystem.Radius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                    }
                }
                .padding(DesignSystem.Spacing.xl)
            }

            Rectangle()
                .fill(DesignSystem.Colors.divider)
                .frame(height: 1)

            // Actions
            HStack {
                if existingRequirement != nil {
                    Button(action: {
                        if let req = existingRequirement {
                            dataStore.deleteRequirement(req)
                        }
                        dismiss()
                    }) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                            Text("删除")
                                .font(DesignSystem.Fonts.caption)
                        }
                        .foregroundColor(DesignSystem.Colors.danger)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.danger.opacity(0.2))
                        .cornerRadius(DesignSystem.Radius.medium)
                    }
                    .buttonStyle(.plain)
                    .hoverEffect(scale: 1.02)
                }

                Spacer()

                Button(action: dismiss) {
                    Text("取消")
                        .font(DesignSystem.Fonts.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.elevatedBackground)
                        .cornerRadius(DesignSystem.Radius.medium)
                }
                .buttonStyle(.plain)
                .hoverEffect(scale: 1.02)

                Button(action: save) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                        Text("保存")
                            .font(DesignSystem.Fonts.caption)
                    }
                }
                .buttonStyle(GradientButtonStyle())
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
            .padding(DesignSystem.Spacing.xl)
        }
        .frame(width: 480, height: 520)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xlarge)
                .fill(DesignSystem.Colors.cardBackground)
        )
        .onAppear {
            if let req = existingRequirement {
                title = req.title
                description = req.description
                status = req.status
                priority = req.priority
                selectedProjectId = req.projectId
            } else {
                if let firstProject = dataStore.projects.first {
                    selectedProjectId = firstProject.id
                }
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        if var req = existingRequirement {
            req.title = trimmedTitle
            req.description = description
            req.status = status
            req.priority = priority
            req.projectId = selectedProjectId
            dataStore.updateRequirement(req)
        } else {
            let req = Requirement(
                title: trimmedTitle,
                description: description,
                status: status,
                priority: priority,
                projectId: selectedProjectId
            )
            dataStore.addRequirement(req)
        }

        dismiss()
    }

    private func dismiss() {
        onDismiss?()
        isPresented = false
    }
}

// Status Chip
struct StatusChip: View {
    let status: RequirementStatus
    let isSelected: Bool
    var onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: status.icon)
                .font(.system(size: 10))

            Text(status.displayName)
                .font(DesignSystem.Fonts.caption)
        }
        .foregroundColor(isSelected ? .white : status.color)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(isSelected ? status.color : (isHovered ? status.color.opacity(0.2) : DesignSystem.Colors.elevatedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(isSelected ? Color.clear : status.color.opacity(0.5), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

// Priority Chip
struct PriorityChip: View {
    let priority: RequirementPriority
    let isSelected: Bool
    var onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Text(priority.displayName)
            .font(DesignSystem.Fonts.caption)
            .fontWeight(.bold)
            .foregroundColor(isSelected ? .white : priority.color)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .fill(isSelected ? priority.color : (isHovered ? priority.color.opacity(0.2) : DesignSystem.Colors.elevatedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .stroke(isSelected ? Color.clear : priority.color.opacity(0.5), lineWidth: 1)
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHovered = hovering
                }
            }
            .onTapGesture {
                onTap()
            }
    }
}
