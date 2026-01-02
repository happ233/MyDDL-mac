import SwiftUI

// MARK: - 设计系统 (支持多主题)
struct DesignSystem {
    // 动态颜色 - 根据当前主题返回
    struct Colors {
        private static var currentColors: ThemeColors {
            ThemeColors.colors(for: ThemeManager.shared.currentTheme)
        }

        // 背景色
        static var background: Color { currentColors.background }
        static var secondaryBackground: Color { currentColors.secondaryBackground }
        static var cardBackground: Color { currentColors.cardBackground }
        static var elevatedBackground: Color { currentColors.elevatedBackground }

        // 强调色（保持不变）
        static let accent = ThemeColors.accent
        static let accentLight = ThemeColors.accentLight

        // 语义色（保持不变）
        static let success = ThemeColors.success
        static let successLight = ThemeColors.successLight
        static let warning = ThemeColors.warning
        static let warningLight = ThemeColors.warningLight
        static let danger = ThemeColors.danger
        static let dangerLight = ThemeColors.dangerLight

        // 文字色
        static var textPrimary: Color { currentColors.textPrimary }
        static var textSecondary: Color { currentColors.textSecondary }
        static var textTertiary: Color { currentColors.textTertiary }

        // 边框和分割线
        static var border: Color { currentColors.border }
        static var divider: Color { currentColors.divider }

        // 悬停和选中
        static var hover: Color { currentColors.hover }
        static var selected: Color { currentColors.selected }

        // 项目颜色 - 鲜艳配色
        static let projectColors: [String] = [
            "#6366F1", // Indigo
            "#8B5CF6", // Violet
            "#EC4899", // Pink
            "#F43F5E", // Rose
            "#F97316", // Orange
            "#EAB308", // Yellow
            "#22C55E", // Green
            "#14B8A6", // Teal
            "#06B6D4", // Cyan
            "#3B82F6", // Blue
        ]

        // 渐变背景
        static var gradientBackground: LinearGradient {
            LinearGradient(
                colors: [background, secondaryBackground, background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static let accentGradient = LinearGradient(
            colors: [accent, accentLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let successGradient = LinearGradient(
            colors: [success, successLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // 圆角
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
    }

    // 间距
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // 字体
    struct Fonts {
        static let largeTitle = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 15, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 14, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        static let tiny = Font.system(size: 10, weight: .medium, design: .rounded)
    }

    // 阴影
    struct Shadows {
        static var small: Color {
            ThemeManager.shared.currentTheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
        }
        static var medium: Color {
            ThemeManager.shared.currentTheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.15)
        }
        static var large: Color {
            ThemeManager.shared.currentTheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.2)
        }
        static let colored = { (color: Color) in color.opacity(0.4) }
    }
}

// MARK: - 卡片样式修饰符
struct CardStyle: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    var padding: CGFloat = DesignSystem.Spacing.md
    var cornerRadius: CGFloat = DesignSystem.Radius.medium

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DesignSystem.Colors.cardBackground)
                    .shadow(color: DesignSystem.Shadows.small, radius: 4, x: 0, y: 2)
            )
    }
}

extension View {
    func cardStyle(padding: CGFloat = DesignSystem.Spacing.md, cornerRadius: CGFloat = DesignSystem.Radius.medium) -> some View {
        modifier(CardStyle(padding: padding, cornerRadius: cornerRadius))
    }
}

// MARK: - 悬停效果
struct HoverEffect: ViewModifier {
    @State private var isHovered = false
    var scaleAmount: CGFloat = 1.02

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scaleAmount : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    func hoverEffect(scale: CGFloat = 1.02) -> some View {
        modifier(HoverEffect(scaleAmount: scale))
    }
}

// MARK: - 渐变按钮
struct GradientButtonStyle: ButtonStyle {
    var color: Color = DesignSystem.Colors.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Fonts.caption)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(DesignSystem.Radius.medium)
            .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
