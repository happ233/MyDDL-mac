import Foundation
import GRDB

class DatabaseManager {
    static let shared = DatabaseManager()

    private var dbQueue: DatabaseQueue?

    private init() {
        setupDatabase()
    }

    private var databasePath: String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbFolder = documentsPath.appendingPathComponent("MyDDL")

        // 创建目录
        try? FileManager.default.createDirectory(at: dbFolder, withIntermediateDirectories: true)

        return dbFolder.appendingPathComponent("myddl.sqlite").path
    }

    private func setupDatabase() {
        do {
            dbQueue = try DatabaseQueue(path: databasePath)
            try createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() throws {
        try dbQueue?.write { db in
            // Tasks table
            try db.create(table: "tasks", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("startDate", .double).notNull()
                t.column("endDate", .double).notNull()
                t.column("status", .text).notNull()
                t.column("priority", .text).notNull()
                t.column("projectId", .text)
                t.column("requirementId", .text)
                t.column("notes", .text).notNull().defaults(to: "")
                t.column("estimatedHours", .double).notNull().defaults(to: 1.0)
                t.column("createdAt", .double).notNull()
                t.column("updatedAt", .double).notNull()
            }

            // Projects table
            try db.create(table: "projects", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("colorHex", .text).notNull()
                t.column("createdAt", .double).notNull()
            }

            // Requirements table
            try db.create(table: "requirements", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("description", .text).notNull().defaults(to: "")
                t.column("status", .text).notNull()
                t.column("priority", .text).notNull()
                t.column("projectId", .text)
                t.column("relatedTaskIds", .text).notNull().defaults(to: "[]")
                t.column("createdAt", .double).notNull()
                t.column("updatedAt", .double).notNull()
            }

            // Notes table
            try db.create(table: "notes", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull().defaults(to: "")
                t.column("content", .text).notNull().defaults(to: "")
                t.column("rtfData", .blob)  // Rich text data (RTFD format)
                t.column("isPinned", .boolean).notNull().defaults(to: false)
                t.column("createdAt", .double).notNull()
                t.column("updatedAt", .double).notNull()
            }

            // Migration: Add rtfData column if not exists
            if try db.columns(in: "notes").contains(where: { $0.name == "rtfData" }) == false {
                try db.alter(table: "notes") { t in
                    t.add(column: "rtfData", .blob)
                }
            }

            // Migration: Add isPinned column if not exists
            if try db.columns(in: "notes").contains(where: { $0.name == "isPinned" }) == false {
                try db.alter(table: "notes") { t in
                    t.add(column: "isPinned", .boolean).defaults(to: false)
                }
            }
        }
    }

    // MARK: - Task Operations

    func fetchAllTasks() -> [Task] {
        do {
            return try dbQueue?.read { db in
                try TaskRecord.fetchAll(db).map { $0.toTask() }
            } ?? []
        } catch {
            print("Fetch tasks error: \(error)")
            return []
        }
    }

    func saveTask(_ task: Task) {
        do {
            try dbQueue?.write { db in
                try TaskRecord(from: task).save(db)
            }
        } catch {
            print("Save task error: \(error)")
        }
    }

    func deleteTask(id: UUID) {
        do {
            try dbQueue?.write { db in
                try db.execute(sql: "DELETE FROM tasks WHERE id = ?", arguments: [id.uuidString])
            }
        } catch {
            print("Delete task error: \(error)")
        }
    }

    // MARK: - Project Operations

    func fetchAllProjects() -> [Project] {
        do {
            return try dbQueue?.read { db in
                try ProjectRecord.fetchAll(db).map { $0.toProject() }
            } ?? []
        } catch {
            print("Fetch projects error: \(error)")
            return []
        }
    }

    func saveProject(_ project: Project) {
        do {
            try dbQueue?.write { db in
                try ProjectRecord(from: project).save(db)
            }
        } catch {
            print("Save project error: \(error)")
        }
    }

    func deleteProject(id: UUID) {
        do {
            try dbQueue?.write { db in
                try db.execute(sql: "DELETE FROM projects WHERE id = ?", arguments: [id.uuidString])
            }
        } catch {
            print("Delete project error: \(error)")
        }
    }

    // MARK: - Requirement Operations

    func fetchAllRequirements() -> [Requirement] {
        do {
            return try dbQueue?.read { db in
                try RequirementRecord.fetchAll(db).map { $0.toRequirement() }
            } ?? []
        } catch {
            print("Fetch requirements error: \(error)")
            return []
        }
    }

    func saveRequirement(_ requirement: Requirement) {
        do {
            try dbQueue?.write { db in
                try RequirementRecord(from: requirement).save(db)
            }
        } catch {
            print("Save requirement error: \(error)")
        }
    }

    func deleteRequirement(id: UUID) {
        do {
            try dbQueue?.write { db in
                try db.execute(sql: "DELETE FROM requirements WHERE id = ?", arguments: [id.uuidString])
            }
        } catch {
            print("Delete requirement error: \(error)")
        }
    }

    // MARK: - Batch Operations

    func saveTasks(_ tasks: [Task]) {
        do {
            try dbQueue?.write { db in
                for task in tasks {
                    try TaskRecord(from: task).save(db)
                }
            }
        } catch {
            print("Save tasks error: \(error)")
        }
    }

    func saveProjects(_ projects: [Project]) {
        do {
            try dbQueue?.write { db in
                for project in projects {
                    try ProjectRecord(from: project).save(db)
                }
            }
        } catch {
            print("Save projects error: \(error)")
        }
    }

    func saveRequirements(_ requirements: [Requirement]) {
        do {
            try dbQueue?.write { db in
                for requirement in requirements {
                    try RequirementRecord(from: requirement).save(db)
                }
            }
        } catch {
            print("Save requirements error: \(error)")
        }
    }

    // MARK: - Note Operations

    func fetchAllNotes() -> [Note] {
        do {
            return try dbQueue?.read { db in
                try NoteRecord.fetchAll(db).map { $0.toNote() }
            } ?? []
        } catch {
            print("Fetch notes error: \(error)")
            return []
        }
    }

    func saveNote(_ note: Note) {
        do {
            try dbQueue?.write { db in
                try NoteRecord(from: note).save(db)
            }
        } catch {
            print("Save note error: \(error)")
        }
    }

    func deleteNote(id: UUID) {
        do {
            try dbQueue?.write { db in
                try db.execute(sql: "DELETE FROM notes WHERE id = ?", arguments: [id.uuidString])
            }
        } catch {
            print("Delete note error: \(error)")
        }
    }

    func saveNotes(_ notes: [Note]) {
        do {
            try dbQueue?.write { db in
                for note in notes {
                    try NoteRecord(from: note).save(db)
                }
            }
        } catch {
            print("Save notes error: \(error)")
        }
    }
}

// MARK: - Database Records

struct TaskRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "tasks"

    var id: String
    var title: String
    var startDate: Double
    var endDate: Double
    var status: String
    var priority: String
    var projectId: String?
    var requirementId: String?
    var notes: String
    var estimatedHours: Double
    var createdAt: Double
    var updatedAt: Double

    init(from task: Task) {
        self.id = task.id.uuidString
        self.title = task.title
        self.startDate = task.startDate.timeIntervalSince1970
        self.endDate = task.endDate.timeIntervalSince1970
        self.status = task.status.rawValue
        self.priority = task.priority.rawValue
        self.projectId = task.projectId?.uuidString
        self.requirementId = task.requirementId?.uuidString
        self.notes = task.notes
        self.estimatedHours = task.estimatedHours
        self.createdAt = task.createdAt.timeIntervalSince1970
        self.updatedAt = task.updatedAt.timeIntervalSince1970
    }

    func toTask() -> Task {
        Task(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            startDate: Date(timeIntervalSince1970: startDate),
            endDate: Date(timeIntervalSince1970: endDate),
            estimatedHours: estimatedHours,
            priority: TaskPriority(rawValue: priority) ?? .medium,
            status: TaskStatus(rawValue: status) ?? .notStarted,
            projectId: projectId.flatMap { UUID(uuidString: $0) },
            requirementId: requirementId.flatMap { UUID(uuidString: $0) },
            notes: notes,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}

struct ProjectRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "projects"

    var id: String
    var name: String
    var colorHex: String
    var createdAt: Double

    init(from project: Project) {
        self.id = project.id.uuidString
        self.name = project.name
        self.colorHex = project.colorHex
        self.createdAt = project.createdAt.timeIntervalSince1970
    }

    func toProject() -> Project {
        Project(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            colorHex: colorHex,
            createdAt: Date(timeIntervalSince1970: createdAt)
        )
    }
}

struct RequirementRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "requirements"

    var id: String
    var title: String
    var description: String
    var status: String
    var priority: String
    var projectId: String?
    var relatedTaskIds: String
    var createdAt: Double
    var updatedAt: Double

    init(from requirement: Requirement) {
        self.id = requirement.id.uuidString
        self.title = requirement.title
        self.description = requirement.description
        self.status = requirement.status.rawValue
        self.priority = requirement.priority.rawValue
        self.projectId = requirement.projectId?.uuidString
        self.relatedTaskIds = (try? JSONEncoder().encode(requirement.relatedTaskIds.map { $0.uuidString }))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        self.createdAt = requirement.createdAt.timeIntervalSince1970
        self.updatedAt = requirement.updatedAt.timeIntervalSince1970
    }

    func toRequirement() -> Requirement {
        let taskIds: [UUID] = {
            guard let data = relatedTaskIds.data(using: .utf8),
                  let ids = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return ids.compactMap { UUID(uuidString: $0) }
        }()

        return Requirement(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            description: description,
            status: RequirementStatus(rawValue: status) ?? .developing,
            priority: RequirementPriority(rawValue: priority) ?? .p2,
            projectId: projectId.flatMap { UUID(uuidString: $0) },
            relatedTaskIds: taskIds,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}

struct NoteRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "notes"

    var id: String
    var title: String
    var content: String
    var rtfData: Data?
    var isPinned: Bool
    var createdAt: Double
    var updatedAt: Double

    init(from note: Note) {
        self.id = note.id.uuidString
        self.title = note.title
        self.content = note.content
        self.rtfData = note.rtfData
        self.isPinned = note.isPinned
        self.createdAt = note.createdAt.timeIntervalSince1970
        self.updatedAt = note.updatedAt.timeIntervalSince1970
    }

    func toNote() -> Note {
        Note(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            content: content,
            rtfData: rtfData,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt),
            isPinned: isPinned
        )
    }
}
