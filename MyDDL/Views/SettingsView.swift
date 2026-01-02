import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var appSettings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("设置")
                    .font(DesignSystem.Fonts.title)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
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
                    // Theme Section
                    SettingsSection(title: "主题") {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                ThemeOptionCard(
                                    theme: theme,
                                    isSelected: themeManager.currentTheme == theme,
                                    onSelect: {
                                        withAnimation(.spring(response: 0.3)) {
                                            themeManager.currentTheme = theme
                                        }
                                    }
                                )
                            }
                        }
                    }

                    // Language Section
                    SettingsSection(title: "语言") {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(AppLanguage.allCases, id: \.self) { lang in
                                SettingsOptionButton(
                                    title: lang.displayName,
                                    isSelected: appSettings.language == lang,
                                    onSelect: { appSettings.language = lang }
                                )
                            }
                        }
                    }

                    // Week Start Day Section
                    SettingsSection(title: "周首日") {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(WeekStartDay.allCases, id: \.self) { day in
                                SettingsOptionButton(
                                    title: day.displayName,
                                    isSelected: appSettings.weekStartDay == day,
                                    onSelect: { appSettings.weekStartDay = day }
                                )
                            }
                        }
                    }

                    // Font Size Section
                    SettingsSection(title: "日历字体大小") {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(CalendarFontSize.allCases, id: \.self) { size in
                                SettingsOptionButton(
                                    title: size.displayName,
                                    isSelected: appSettings.calendarFontSize == size,
                                    onSelect: { appSettings.calendarFontSize = size }
                                )
                            }
                        }
                    }

                    // Day Colors Section
                    SettingsSection(title: "日期颜色") {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            // Workday Color
                            HStack {
                                Text("工作日")
                                    .font(DesignSystem.Fonts.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .frame(width: 50, alignment: .leading)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: DesignSystem.Spacing.sm) {
                                        ForEach(PresetColor.allCases, id: \.self) { color in
                                            ColorOptionButton(
                                                color: color,
                                                isSelected: appSettings.workdayColor == color,
                                                onSelect: { appSettings.workdayColor = color }
                                            )
                                        }
                                    }
                                }
                            }

                            // Restday Color
                            HStack {
                                Text("休息日")
                                    .font(DesignSystem.Fonts.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .frame(width: 50, alignment: .leading)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: DesignSystem.Spacing.sm) {
                                        ForEach(PresetColor.allCases, id: \.self) { color in
                                            ColorOptionButton(
                                                color: color,
                                                isSelected: appSettings.restdayColor == color,
                                                onSelect: { appSettings.restdayColor = color }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(DesignSystem.Spacing.xl)
            }
        }
        .frame(width: 480, height: 520)
        .background(DesignSystem.Colors.cardBackground)
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.Fonts.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            content
        }
    }
}

// MARK: - Settings Option Button
struct SettingsOptionButton: View {
    let title: String
    let isSelected: Bool
    var onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            Text(title)
                .font(DesignSystem.Fonts.caption)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                        .fill(isSelected ?
                              LinearGradient(colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accentLight], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [isHovered ? DesignSystem.Colors.hover : DesignSystem.Colors.elevatedBackground, isHovered ? DesignSystem.Colors.hover : DesignSystem.Colors.elevatedBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                                .stroke(isSelected ? Color.clear : DesignSystem.Colors.border, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - Color Option Button
struct ColorOptionButton: View {
    let color: PresetColor
    let isSelected: Bool
    var onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 28, height: 28)

                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 22, height: 22)

                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .overlay(
                Circle()
                    .stroke(isSelected ? color.color : (isHovered ? color.color.opacity(0.5) : Color.clear), lineWidth: 2)
                    .frame(width: 34, height: 34)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
    }
}

// MARK: - Theme Option Card
struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    var onSelect: () -> Void

    @State private var isHovered = false

    private var themeColors: ThemeColors {
        ThemeColors.colors(for: theme)
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Theme preview
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                    .fill(themeColors.cardBackground)
                    .frame(width: 80, height: 50)

                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(themeColors.textPrimary.opacity(0.3))
                        .frame(width: 50, height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(themeColors.textSecondary.opacity(0.3))
                        .frame(width: 40, height: 4)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                    .stroke(isSelected ? DesignSystem.Colors.accent : Color.clear, lineWidth: 2)
            )

            // Theme name
            Text(theme.displayName)
                .font(DesignSystem.Fonts.caption)
                .foregroundColor(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)

            // Selected indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.accent)
            } else {
                Circle()
                    .stroke(DesignSystem.Colors.border, lineWidth: 1.5)
                    .frame(width: 14, height: 14)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(isSelected ? DesignSystem.Colors.accent.opacity(0.1) : (isHovered ? DesignSystem.Colors.hover : Color.clear))
        )
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { hovering in isHovered = hovering }
    }
}
