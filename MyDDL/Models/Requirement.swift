import Foundation
import SwiftUI

// 需求状态
enum RequirementStatus: String, Codable, CaseIterable {
    case developing = "developing"
    case testing = "testing"
    case released = "released"
    case deprecated = "deprecated"

    var displayName: String {
        switch self {
        case .developing: return "开发中"
        case .testing: return "测试中"
        case .released: return "已上线"
        case .deprecated: return "已废弃"
        }
    }

    var icon: String {
        switch self {
        case .developing: return "hammer.fill"
        case .testing: return "testtube.2"
        case .released: return "checkmark.seal.fill"
        case .deprecated: return "trash.fill"
        }
    }

    var color: Color {
        switch self {
        case .developing: return DesignSystem.Colors.warning
        case .testing: return DesignSystem.Colors.accent
        case .released: return DesignSystem.Colors.success
        case .deprecated: return DesignSystem.Colors.textTertiary
        }
    }
}

// 需求优先级
enum RequirementPriority: String, Codable, CaseIterable {
    case p0 = "P0"
    case p1 = "P1"
    case p2 = "P2"
    case p3 = "P3"

    var displayName: String {
        rawValue
    }

    var color: Color {
        switch self {
        case .p0: return DesignSystem.Colors.danger
        case .p1: return DesignSystem.Colors.warning
        case .p2: return DesignSystem.Colors.accent
        case .p3: return DesignSystem.Colors.textTertiary
        }
    }
}

// 需求模型
struct Requirement: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var status: RequirementStatus
    var priority: RequirementPriority
    var projectId: UUID?
    var relatedTaskIds: [UUID]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        status: RequirementStatus = .developing,
        priority: RequirementPriority = .p2,
        projectId: UUID? = nil,
        relatedTaskIds: [UUID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.priority = priority
        self.projectId = projectId
        self.relatedTaskIds = relatedTaskIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
