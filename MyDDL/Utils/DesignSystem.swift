import SwiftUI

// MARK: - 设计系统 (暗色主题)
struct DesignSystem {
    // 颜色 - 灰黑色主题
    struct Colors {
        // 背景色
        static let background = Color(red: 0.11, green: 0.11, blue: 0.12)
        static let secondaryBackground = Color(red: 0.15, green: 0.15, blue: 0.16)
        static let cardBackground = Color(red: 0.18, green: 0.18, blue: 0.20)
        static let elevatedBackground = Color(red: 0.22, green: 0.22, blue: 0.24)

        // 强调色
        static let accent = Color(red: 0.45, green: 0.55, blue: 1.0)
        static let accentLight = Color(red: 0.60, green: 0.70, blue: 1.0)

        // 语义色
        static let success = Color(red: 0.30, green: 0.85, blue: 0.60)
        static let successLight = Color(red: 0.45, green: 0.92, blue: 0.72)
        static let warning = Color(red: 1.0, green: 0.75, blue: 0.30)
        static let warningLight = Color(red: 1.0, green: 0.85, blue: 0.50)
        static let danger = Color(red: 1.0, green: 0.45, blue: 0.50)
        static let dangerLight = Color(red: 1.0, green: 0.60, blue: 0.65)

        // 文字色
        static let textPrimary = Color(red: 0.95, green: 0.95, blue: 0.97)
        static let textSecondary = Color(red: 0.70, green: 0.70, blue: 0.75)
        static let textTertiary = Color(red: 0.50, green: 0.50, blue: 0.55)

        // 边框和分割线
        static let border = Color.white.opacity(0.12)
        static let divider = Color.white.opacity(0.08)

        // 悬停和选中
        static let hover = Color.white.opacity(0.08)
        static let selected = Color.white.opacity(0.15)

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

        // 渐变背景 - 暗色
        static let gradientBackground = LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.10, blue: 0.12),
                Color(red: 0.12, green: 0.11, blue: 0.14),
                Color(red: 0.11, green: 0.12, blue: 0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

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

    // 阴影 - 暗色主题用更深的阴影
    struct Shadows {
        static let small = Color.black.opacity(0.3)
        static let medium = Color.black.opacity(0.4)
        static let large = Color.black.opacity(0.5)
        static let colored = { (color: Color) in color.opacity(0.4) }
    }
}

// MARK: - 卡片样式修饰符
struct CardStyle: ViewModifier {
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
