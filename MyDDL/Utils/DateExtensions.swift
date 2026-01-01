import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfWeek: Date {
        var components = DateComponents()
        components.day = 6
        return Calendar.current.date(byAdding: components, to: startOfWeek) ?? self
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 1 || weekday == 7
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: self)
    }

    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: self)
    }

    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    var shortWeekdayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: other) &&
               calendar.component(.month, from: self) == calendar.component(.month, from: other)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    // 是否为中国法定节假日
    var isChineseHoliday: Bool {
        ChineseHolidays.isHoliday(self)
    }

    // 是否为调休日（周末但需要上班）
    var isWorkdayOverride: Bool {
        ChineseHolidays.isWorkday(self)
    }

    // 是否为休息日（周末或法定节假日，但排除调休日）
    var isRestDay: Bool {
        // 如果是调休日，不是休息日
        if isWorkdayOverride { return false }
        // 法定节假日或周末
        return isChineseHoliday || isWeekend
    }

    static func daysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = date.startOfMonth

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    static func daysInWeek(for date: Date) -> [Date] {
        let startOfWeek = date.startOfWeek
        return (0..<7).compactMap { day -> Date? in
            Calendar.current.date(byAdding: .day, value: day, to: startOfWeek)
        }
    }

    static func calendarGridDays(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        let daysInMonth = Self.daysInMonth(for: date)
        let settings = AppSettings.shared

        guard let firstDay = daysInMonth.first else { return [] }

        // Get the weekday of the first day (1 = Sunday, 2 = Monday, ...)
        let weekday = calendar.component(.weekday, from: firstDay)

        // Calculate offset based on week start day setting
        var offset: Int
        if settings.weekStartDay == .monday {
            // Monday start: 1 = Monday, 7 = Sunday
            offset = weekday == 1 ? 6 : weekday - 2
        } else {
            // Sunday start: 0 = Sunday, 6 = Saturday
            offset = weekday - 1
        }

        var result: [Date?] = Array(repeating: nil, count: offset)
        result.append(contentsOf: daysInMonth)

        // Fill remaining days to complete the grid
        while result.count % 7 != 0 {
            result.append(nil)
        }

        return result
    }
}

// 中国法定节假日
struct ChineseHolidays {
    // 2025年法定节假日
    private static let holidays2025: Set<String> = [
        // 元旦
        "2025-01-01",
        // 春节
        "2025-01-28", "2025-01-29", "2025-01-30", "2025-01-31", "2025-02-01", "2025-02-02", "2025-02-03", "2025-02-04",
        // 清明节
        "2025-04-04", "2025-04-05", "2025-04-06",
        // 劳动节
        "2025-05-01", "2025-05-02", "2025-05-03", "2025-05-04", "2025-05-05",
        // 端午节
        "2025-05-31", "2025-06-01", "2025-06-02",
        // 中秋节+国庆节
        "2025-10-01", "2025-10-02", "2025-10-03", "2025-10-04", "2025-10-05", "2025-10-06", "2025-10-07", "2025-10-08",
    ]

    // 2025年调休日（需要上班）
    private static let workdays2025: Set<String> = [
        // 春节调休
        "2025-01-26", // 周日
        "2025-02-08", // 周六
        // 劳动节调休
        "2025-04-27", // 周日
        // 国庆节调休
        "2025-09-28", // 周日
        "2025-10-11", // 周六
    ]

    // 2026年法定节假日
    private static let holidays2026: Set<String> = [
        // 元旦
        "2026-01-01", "2026-01-02", "2026-01-03",
        // 春节（预估）
        "2026-02-14", "2026-02-15", "2026-02-16", "2026-02-17", "2026-02-18", "2026-02-19", "2026-02-20",
        // 清明节（预估）
        "2026-04-04", "2026-04-05", "2026-04-06",
        // 劳动节（预估）
        "2026-05-01", "2026-05-02", "2026-05-03",
        // 端午节（预估）
        "2026-06-19", "2026-06-20", "2026-06-21",
        // 中秋节（预估）
        "2026-09-25", "2026-09-26", "2026-09-27",
        // 国庆节（预估）
        "2026-10-01", "2026-10-02", "2026-10-03", "2026-10-04", "2026-10-05", "2026-10-06", "2026-10-07",
    ]

    // 2026年调休日（预估，需要上班）
    private static let workdays2026: Set<String> = [
        // 元旦调休
        "2026-01-04", // 周日
        // 春节调休（预估）
        "2026-02-07", // 周六
        "2026-02-21", // 周六
    ]

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func isHoliday(_ date: Date) -> Bool {
        let dateString = dateFormatter.string(from: date)
        return holidays2025.contains(dateString) || holidays2026.contains(dateString)
    }

    // 是否为调休日（周末但需要上班）
    static func isWorkday(_ date: Date) -> Bool {
        let dateString = dateFormatter.string(from: date)
        return workdays2025.contains(dateString) || workdays2026.contains(dateString)
    }
}
