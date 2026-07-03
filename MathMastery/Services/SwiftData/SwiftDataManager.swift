import SwiftData
import Foundation

protocol SwiftDataService {
    func insert<T: PersistentModel>(_ model: T)
    func delete<T: PersistentModel>(_ model: T)
    func save() throws
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T]

    func saveSession(_ session: PracticeSession)
    func fetchSessions() -> [PracticeSession]

    func clearSessions()
}

final class SwiftDataManager: SwiftDataService {

    private let container: ModelContainer
    private let context: ModelContext

    init() {
        do {
            self.container = try ModelContainer(
                for: PracticeSession.self,
                PracticeAnswer.self
            )
            self.context = container.mainContext
        } catch {
            fatalError("❌SwiftData container failed: \(error)")
        }
    }

    // MARK: - Generic CRUD

    func insert<T: PersistentModel>(_ model: T) {
        context.insert(model)
    }

    func delete<T: PersistentModel>(_ model: T) {
        context.delete(model)
    }

    func save() throws {
        try context.save()
    }

    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        try context.fetch(descriptor)
    }

    // MARK: - Domain specific

    func saveSession(_ session: PracticeSession) {
        context.insert(session)

        do {
            try context.save()
            print("✅ SAVED SESSION")
        } catch {
            print("❌ SAVE ERROR:", error)
        }
    }

    func fetchSessions() -> [PracticeSession] {
        let descriptor = FetchDescriptor<PracticeSession>(
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    func clearSessions() {
        do {
            let allSessions = try context.fetch(FetchDescriptor<PracticeSession>())

            for session in allSessions {
                context.delete(session)
            }
            try context.save()
            print("✅ ALL SESSIONS WERE DELETED")
        } catch {
            print("❌ERROR WHILE DELETING ALL SESSIONS: \(error)")
        }
    }
}
