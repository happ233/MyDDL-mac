import SwiftUI

struct RequirementCard: View {
    let requirement: Requirement
    let project: Project?
    var onTap: () -> Void = {}
    var onStatusChange: ((RequirementStatus) -> Void)?

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Status indicator
            Circle()
                .fill(requirement.status.color)
                .frame(width: 8, height: 8)

            // Priority badge
            Text(requirement.priority.displayName)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(requirement.priority.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(requirement.priority.color.opacity(0.2))
                .cornerRadius(4)

            // Title
            Text(requirement.title)
                .font(DesignSystem.Fonts.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(1)

            Spacer()

            // Project indicator
            if let project = project {
                Circle()
                    .fill(project.color)
                    .frame(width: 8, height: 8)
            }

            // Status icon
            Image(systemName: requirement.status.icon)
                .font(.system(size: 12))
                .foregroundColor(requirement.status.color)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(isHovered ? DesignSystem.Colors.elevatedBackground : DesignSystem.Colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(isHovered ? requirement.status.color.opacity(0.4) : DesignSystem.Colors.border, lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onTap()
        }
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

// Compact version for sidebar
struct RequirementStatusRow: View {
    @EnvironmentObject var dataStore: DataStore
    let status: RequirementStatus
    let isSelected: Bool
    var onTap: () -> Void = {}

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: status.icon)
                .font(.system(size: 14))
                .foregroundColor(status.color)
                .frame(width: 24)

            Text(status.displayName)
                .font(DesignSystem.Fonts.body)
                .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)
                .fontWeight(isSelected ? .semibold : .regular)

            Spacer()

            Text("\(dataStore.requirementsCount(for: status))")
                .font(DesignSystem.Fonts.caption)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textTertiary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(isSelected ? status.color : DesignSystem.Colors.elevatedBackground)
                )
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(isSelected ? status.color.opacity(0.5) : Color.clear, lineWidth: 1)
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

    private var backgroundColor: Color {
        if isSelected {
            return status.color.opacity(0.15)
        }
        if isHovered {
            return DesignSystem.Colors.elevatedBackground
        }
        return .clear
    }
}
