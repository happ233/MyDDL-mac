import Foundation
import SwiftUI

// 语言设置
enum AppLanguage: String, CaseIterable, Codable {
    case chinese = "zh"
    case english = "en"

    var displayName: String {
        switch self {
        case .chinese: return "中文"
        case .english: return "English"
        }
    }
}

// 周首日设置
enum WeekStartDay: String, CaseIterable, Codable {
    case monday = "monday"
    case sunday = "sunday"

    var displayName: String {
        switch self {
        case .monday: return "周一"
        case .sunday: return "周日"
        }
    }

    var calendarValue: Int {
        switch self {
        case .monday: return 2  // Calendar.current uses 1=Sunday, 2=Monday
        case .sunday: return 1
        }
    }
}

// 字体大小设置
enum CalendarFontSize: String, CaseIterable, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"

    var displayName: String {
        switch self {
        case .small: return "小"
        case .medium: return "中"
        case .large: return "大"
        }
    }

    var taskFontSize: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 11
        case .large: return 13
        }
    }

    var dateFontSize: CGFloat {
        switch self {
        case .small: return 11
        case .medium: return 12
        case .large: return 14
        }
    }
}

// 预设颜色选项
enum PresetColor: String, CaseIterable, Codable {
    case gray = "gray"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case orange = "orange"
    case pink = "pink"
    case mint = "mint"
    case teal = "teal"

    var displayName: String {
        switch self {
        case .gray: return "灰色"
        case .green: return "绿色"
        case .blue: return "蓝色"
        case .purple: return "紫色"
        case .orange: return "橙色"
        case .pink: return "粉色"
        case .mint: return "薄荷色"
        case .teal: return "青色"
        }
    }

    var color: Color {
        switch self {
        case .gray: return .gray
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .orange: return .orange
        case .pink: return .pink
        case .mint: return .mint
        case .teal: return .teal
        }
    }
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let userDefaults = UserDefaults.standard
    private let languageKey = "app_language"
    private let weekStartDayKey = "week_start_day"
    private let fontSizeKey = "calendar_font_size"
    private let workdayColorKey = "workday_color"
    private let restdayColorKey = "restday_color"

    @Published var language: AppLanguage {
        didSet { saveSettings() }
    }

    @Published var weekStartDay: WeekStartDay {
        didSet { saveSettings() }
    }

    @Published var calendarFontSize: CalendarFontSize {
        didSet { saveSettings() }
    }

    @Published var workdayColor: PresetColor {
        didSet { saveSettings() }
    }

    @Published var restdayColor: PresetColor {
        didSet { saveSettings() }
    }

    init() {
        // Load settings from UserDefaults
        if let langRaw = userDefaults.string(forKey: languageKey),
           let lang = AppLanguage(rawValue: langRaw) {
            language = lang
        } else {
            language = .chinese
        }

        if let weekRaw = userDefaults.string(forKey: weekStartDayKey),
           let week = WeekStartDay(rawValue: weekRaw) {
            weekStartDay = week
        } else {
            weekStartDay = .monday
        }

        if let fontRaw = userDefaults.string(forKey: fontSizeKey),
           let font = CalendarFontSize(rawValue: fontRaw) {
            calendarFontSize = font
        } else {
            calendarFontSize = .medium
        }

        if let colorRaw = userDefaults.string(forKey: workdayColorKey),
           let color = PresetColor(rawValue: colorRaw) {
            workdayColor = color
        } else {
            workdayColor = .gray
        }

        if let colorRaw = userDefaults.string(forKey: restdayColorKey),
           let color = PresetColor(rawValue: colorRaw) {
            restdayColor = color
        } else {
            restdayColor = .green
        }
    }

    private func saveSettings() {
        userDefaults.set(language.rawValue, forKey: languageKey)
        userDefaults.set(weekStartDay.rawValue, forKey: weekStartDayKey)
        userDefaults.set(calendarFontSize.rawValue, forKey: fontSizeKey)
        userDefaults.set(workdayColor.rawValue, forKey: workdayColorKey)
        userDefaults.set(restdayColor.rawValue, forKey: restdayColorKey)
    }

    // 获取工作日背景颜色
    var workdayBackgroundColor: Color {
        workdayColor.color.opacity(0.06)
    }

    // 获取休息日背景颜色
    var restdayBackgroundColor: Color {
        restdayColor.color.opacity(0.08)
    }
}
