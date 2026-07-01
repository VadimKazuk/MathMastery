import Combine
import SwiftUI
import SwiftData

extension HistoryListView {
    final class ViewModel: ObservableObject {
        @Published var sessions: [PracticeSession] = []

        private let serviceContainer: ServiceContainer
        private let swiftDB: SwiftDataService

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
        }

        func loadSessions() {
            sessions = swiftDB.fetchSessions()
                .sorted { $0.date > $1.date }
        }
    }
}
