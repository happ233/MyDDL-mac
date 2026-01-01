import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("设置")
                        .font(DesignSystem.Fonts.title)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("自定义应用偏好设置")
                        .font(DesignSystem.Fonts.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }

                Spacer()

                Button(action: { isPresented = false }) {
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
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // 语言设置
                    SettingsSection(title: "语言设置", icon: "globe") {
                        SettingsPicker(
                            title: "界面语言",
                            selection: $settings.language,
                            options: AppLanguage.allCases
                        ) { lang in
                            lang.displayName
                        }
                    }

                    // 日历设置
                    SettingsSection(title: "日历设置", icon: "calendar") {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            // 周首日
                            SettingsPicker(
                                title: "每周首日",
                                selection: $settings.weekStartDay,
                                options: WeekStartDay.allCases
                            ) { day in
                                day.displayName
                            }

                            Divider()

                            // 字体大小
                            SettingsPicker(
                                title: "任务字体大小",
                                selection: $settings.calendarFontSize,
                                options: CalendarFontSize.allCases
                            ) { size in
                                size.displayName
                            }

                            Divider()

                            // 工作日颜色
                            SettingsColorPicker(
                                title: "工作日背景色",
                                selection: $settings.workdayColor
                            )

                            Divider()

                            // 休息日颜色
                            SettingsColorPicker(
                                title: "休息日背景色",
                                selection: $settings.restdayColor
                            )
                        }
                    }

                    // 预览
                    SettingsSection(title: "颜色预览", icon: "eye") {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Text("工作日")
                                    .font(DesignSystem.Fonts.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)

                                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                                    .fill(settings.workdayBackgroundColor)
                                    .frame(height: 60)
                                    .overlay(
                                        Text("1")
                                            .font(.system(size: settings.calendarFontSize.dateFontSize, weight: .medium))
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                    )
                            }

                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Text("休息日")
                                    .font(DesignSystem.Fonts.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)

                                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                                    .fill(settings.restdayBackgroundColor)
                                    .frame(height: 60)
                                    .overlay(
                                        Text("6")
                                            .font(.system(size: settings.calendarFontSize.dateFontSize, weight: .medium))
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(DesignSystem.Spacing.xl)
            }
        }
        .frame(width: 500, height: 600)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xlarge)
                .fill(DesignSystem.Colors.cardBackground)
        )
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.accent)

                Text(title)
                    .font(DesignSystem.Fonts.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }

            content
                .padding(DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                        .fill(DesignSystem.Colors.elevatedBackground)
                )
        }
    }
}

// MARK: - Settings Picker
struct SettingsPicker<T: Hashable>: View {
    let title: String
    @Binding var selection: T
    let options: [T]
    let displayName: (T) -> String

    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Fonts.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Spacer()

            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selection = option
                        }
                    }) {
                        Text(displayName(option))
                            .font(DesignSystem.Fonts.caption)
                            .foregroundColor(selection == option ? .white : DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                                    .fill(selection == option ? DesignSystem.Colors.accent : DesignSystem.Colors.cardBackground)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Settings Color Picker
struct SettingsColorPicker: View {
    let title: String
    @Binding var selection: PresetColor

    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Fonts.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Spacer()

            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(PresetColor.allCases, id: \.self) { color in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selection = color
                        }
                    }) {
                        Circle()
                            .fill(color.color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selection == color ? 2 : 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(selection == color ? DesignSystem.Colors.accent : Color.clear, lineWidth: 2)
                                    .scaleEffect(1.3)
                            )
                    }
                    .buttonStyle(.plain)
                    .help(color.displayName)
                }
            }
        }
    }
}
