import Foundation
import SwiftUI

class DataStore: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var projects: [Project] = []
    @Published var requirements: [Requirement] = []

    private let tasksKey = "myddl_tasks"
    private let projectsKey = "myddl_projects"
    private let requirementsKey = "myddl_requirements"

    init() {
        loadData()
    }

    // MARK: - Data Persistence

    private func loadData() {
        if let tasksData = UserDefaults.standard.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            tasks = decodedTasks
        }

        if let projectsData = UserDefaults.standard.data(forKey: projectsKey),
           let decodedProjects = try? JSONDecoder().decode([Project].self, from: projectsData) {
            projects = decodedProjects
        }

        if let requirementsData = UserDefaults.standard.data(forKey: requirementsKey),
           let decodedRequirements = try? JSONDecoder().decode([Requirement].self, from: requirementsData) {
            requirements = decodedRequirements
        }

        // 首次运行时导入已上线需求
        if requirements.isEmpty {
            importReleasedRequirements()
        }

        // 检查是否需要导入已废弃需求
        let hasDeprecated = requirements.contains { $0.status == .deprecated }
        if !hasDeprecated {
            importDeprecatedRequirements()
        }

        // Add default project if none exist
        if projects.isEmpty {
            let defaultProject = Project(name: "默认项目", colorHex: "#5B8DEF")
            projects.append(defaultProject)
            saveProjects()
        }
    }

    private func importReleasedRequirements() {
        let releasedRequirements = [
            "【需求】双语学习报告优化/反讲落报告",
            "【需求】精准学报告支持英语图书",
            "【需求】背单词状态推4s",
            "【需求】学习报告 http开头的icon https 3.12上线",
            "【fix】【bug】报告老师信息",
            "【需求】学习报告新增互动 非凡 10.04",
            "【优化】每日挑战-伴读未解锁状态能点进去 非凡 4.9上线",
            "【需求】学习报告 - 双语 - 原生语音测评语音条",
            "【BUG】时长 补点BUG",
            "【需求】错题本 - 举一反三 4.9上线",
            "【bug】学研配置后台 加游戏化配置项下发",
            "【需求】创新思维阶段报告url推4s exam服务",
            "【需求】学研后台-新版学习中心排查页",
            "【需求】阶段报告配置化 5.26上线",
            "【BUG】报告慢查询 5.28上线",
            "【BUG】一讲三练 非标",
            "【需求】报告-新互动K歌 6.3上线",
            "【BUG】duration-worker: 补点",
            "【其他】diary表加联合索引",
            "【需求】游戏化1.0加任务 K歌 6.4上线",
            "【BUG】AI平台入口",
            "【需求】智能课表-订单跳转 6.10上线",
            "【需求】阅读探究 - 改获取奖励的接口 6.11上线",
            "【优化】阶段报告缓存问题",
            "【时长】缓存过期",
            "【BUG】阅读L0报告 不绑魔方ID报错",
            "【需求】janus主动缓存 P0",
            "【需求】Redis key问题",
            "【需求】janus强依赖",
            "【需求】开口练-新版-新老大纲",
            "【优化】反讲审核标签推4S优化 兼容质检",
            "游戏化2.0 janus studycenter",
            "游戏化2.0后台 xyadmin xes-service-monitor",
            "报告 请求quize接口加参数",
            "老师评语模块接口",
            "游戏化1.0 加天天练课程工具入口",
            "时长 修时长推topic上线",
            "报告 - 大纲考试",
            "【需求】阶段报告新模块、链接推4S",
            "大头照课前推互动 10.22上线",
            "案例后台 10.27上线",
            "案例后台 权限改造",
            "案例后台 业务线改造",
            "初中学情报告",
            "learningreport, stageexam 双活域名改造",
            "模拟回复agent 1.0",
            "模拟回复agent 评测",
            "rpa群自动化一期",
            "大头照积压优化+压测",
            "零宽埋点"
        ]

        let baseDate = Date()
        for (index, title) in releasedRequirements.enumerated() {
            let priority: RequirementPriority
            if title.contains("P0") {
                priority = .p0
            } else if title.contains("BUG") || title.contains("bug") || title.contains("fix") {
                priority = .p1
            } else if title.contains("优化") {
                priority = .p2
            } else {
                priority = .p2
            }

            // 按顺序递增时间戳，后面的需求时间更晚
            let createdAt = baseDate.addingTimeInterval(Double(index))

            let req = Requirement(
                title: title,
                description: "",
                status: .released,
                priority: priority,
                projectId: nil,
                relatedTaskIds: [],
                createdAt: createdAt,
                updatedAt: createdAt
            )
            requirements.append(req)
        }
        saveRequirements()
    }

    private func importDeprecatedRequirements() {
        let deprecatedRequirements = [
            "通用宝箱补发",
            "【需求】janus panic问题修复 studycenter 主动缓存内存问题",
            "【优化】录播消费品学习报告优化 测试中 learningreport fix/record_report_up",
            "【优化】studycenter慢接口上线 反讲",
            "【BUG】【待启动】代码本调课问题 URL里加两个字段",
            "【需求】阅读探究 老版/游戏化/新版 支持新老大纲",
            "【需求】【开发】精准学Pad适配 待定",
            "【开发】【脚本】深度补偿发家具",
            "【测试】【优化】周宝箱 重复接口调用优化 非凡 studycenter - fix/weekTask_inter_op",
            "【测试】【BUG】修 反讲 审核中/未审核 展示状态 studycenter - feature/retell_status，assess",
            "【评审】时长 客户端补点",
            "【评审】【需求】报告-互动开放",
            "【评审】需求机器人",
            "【worker上云】 duration-worker learningreport-worker",
            "课中大头照优化 去掉视频处理"
        ]

        let baseDate = Date()
        for (index, title) in deprecatedRequirements.enumerated() {
            let priority: RequirementPriority
            if title.contains("BUG") || title.contains("bug") {
                priority = .p1
            } else if title.contains("优化") {
                priority = .p2
            } else {
                priority = .p3
            }

            // 按顺序递增时间戳，后面的需求时间更晚（倒序展示时第一个会在最上面）
            let createdAt = baseDate.addingTimeInterval(Double(index))

            let req = Requirement(
                title: title,
                description: "",
                status: .deprecated,
                priority: priority,
                projectId: nil,
                relatedTaskIds: [],
                createdAt: createdAt,
                updatedAt: createdAt
            )
            requirements.append(req)
        }
        saveRequirements()
    }

    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }

    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: projectsKey)
        }
    }

    private func saveRequirements() {
        if let encoded = try? JSONEncoder().encode(requirements) {
            UserDefaults.standard.set(encoded, forKey: requirementsKey)
        }
    }

    // MARK: - Task CRUD

    func addTask(_ task: Task) {
        var newTask = task

        // Auto-create a corresponding requirement
        let requirement = Requirement(
            title: task.title,
            description: task.notes,
            status: .developing,
            priority: task.priority == .high ? .p1 : (task.priority == .medium ? .p2 : .p3),
            projectId: task.projectId,
            relatedTaskIds: [task.id]
        )
        requirements.append(requirement)

        // Link task to the requirement
        newTask.requirementId = requirement.id
        tasks.append(newTask)

        saveTasks()
        saveRequirements()
    }

    // 添加任务但不自动创建需求（用于拆分任务等场景）
    func addTaskWithoutRequirement(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }

    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.updatedAt = Date()
            tasks[index] = updatedTask

            // Sync to requirement if linked
            if let reqId = task.requirementId,
               let reqIndex = requirements.firstIndex(where: { $0.id == reqId }) {
                var req = requirements[reqIndex]
                req.title = task.title
                req.description = task.notes
                req.projectId = task.projectId
                req.updatedAt = Date()
                requirements[reqIndex] = req
                saveRequirements()
            }

            saveTasks()
        }
    }

    func deleteTask(_ task: Task) {
        // Also delete the linked requirement
        if let reqId = task.requirementId {
            requirements.removeAll { $0.id == reqId }
            saveRequirements()
        }

        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    func deleteTask(id: UUID) {
        if let task = tasks.first(where: { $0.id == id }) {
            deleteTask(task)
        } else {
            tasks.removeAll { $0.id == id }
            saveTasks()
        }
    }

    // MARK: - Project CRUD

    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
    }

    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }

    func deleteProject(_ project: Project) {
        // Remove all tasks associated with this project
        tasks.removeAll { $0.projectId == project.id }
        projects.removeAll { $0.id == project.id }
        saveTasks()
        saveProjects()
    }

    // MARK: - Query Methods

    func tasks(for date: Date) -> [Task] {
        tasks.filter { $0.isOnDate(date) }
            .sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }

    func tasks(for project: Project) -> [Task] {
        tasks.filter { $0.projectId == project.id }
    }

    func tasks(in dateRange: ClosedRange<Date>) -> [Task] {
        tasks.filter { task in
            let taskRange = task.startDate...task.endDate
            return taskRange.overlaps(dateRange)
        }
    }

    func project(for task: Task) -> Project? {
        guard let projectId = task.projectId else { return nil }
        return projects.first { $0.id == projectId }
    }

    // MARK: - Statistics

    func totalHours(for date: Date) -> Double {
        tasks(for: date).reduce(0) { total, task in
            // For multi-day tasks, distribute hours evenly
            let hoursPerDay = task.estimatedHours / Double(task.daySpan)
            return total + hoursPerDay
        }
    }

    func totalHours(for dateRange: ClosedRange<Date>) -> Double {
        var total: Double = 0
        var currentDate = dateRange.lowerBound
        let calendar = Calendar.current

        while currentDate <= dateRange.upperBound {
            total += totalHours(for: currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return total
    }

    func completedTasksCount(for date: Date) -> Int {
        tasks(for: date).filter { $0.status == .completed }.count
    }

    func overdueTasksCount() -> Int {
        tasks.filter { $0.isOverdue }.count
    }

    // MARK: - Task Movement

    func moveTask(_ task: Task, to newStartDate: Date) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            let duration = task.endDate.timeIntervalSince(task.startDate)
            updatedTask.startDate = newStartDate
            updatedTask.endDate = newStartDate.addingTimeInterval(duration)
            updatedTask.updatedAt = Date()
            tasks[index] = updatedTask
            saveTasks()
        }
    }

    func resizeTask(_ task: Task, newEndDate: Date) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.endDate = max(newEndDate, task.startDate)
            updatedTask.updatedAt = Date()
            tasks[index] = updatedTask
            saveTasks()
        }
    }

    // MARK: - Requirement CRUD

    func addRequirement(_ requirement: Requirement) {
        requirements.append(requirement)
        saveRequirements()
    }

    func updateRequirement(_ requirement: Requirement) {
        if let index = requirements.firstIndex(where: { $0.id == requirement.id }) {
            var updated = requirement
            updated.updatedAt = Date()
            requirements[index] = updated
            saveRequirements()

            // Sync title/description back to linked task
            if let taskIndex = tasks.firstIndex(where: { $0.requirementId == requirement.id }) {
                var task = tasks[taskIndex]
                task.title = requirement.title
                task.notes = requirement.description
                task.projectId = requirement.projectId
                task.updatedAt = Date()
                tasks[taskIndex] = task
                saveTasks()
            }
        }
    }

    func deleteRequirement(_ requirement: Requirement) {
        // Also delete linked task
        if let taskIndex = tasks.firstIndex(where: { $0.requirementId == requirement.id }) {
            tasks.remove(at: taskIndex)
            saveTasks()
        }

        requirements.removeAll { $0.id == requirement.id }
        saveRequirements()
    }

    func deleteRequirement(id: UUID) {
        if let req = requirements.first(where: { $0.id == id }) {
            deleteRequirement(req)
        } else {
            requirements.removeAll { $0.id == id }
            saveRequirements()
        }
    }

    // MARK: - Requirement Query

    func requirements(for status: RequirementStatus) -> [Requirement] {
        requirements.filter { $0.status == status }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func requirements(for project: Project) -> [Requirement] {
        requirements.filter { $0.projectId == project.id }
    }

    func requirementsCount(for status: RequirementStatus) -> Int {
        requirements.filter { $0.status == status }.count
    }

    func project(for requirement: Requirement) -> Project? {
        guard let projectId = requirement.projectId else { return nil }
        return projects.first { $0.id == projectId }
    }

    func requirement(for task: Task) -> Requirement? {
        guard let requirementId = task.requirementId else { return nil }
        return requirements.first { $0.id == requirementId }
    }

    func tasks(for requirement: Requirement) -> [Task] {
        tasks.filter { $0.requirementId == requirement.id }
    }
}
