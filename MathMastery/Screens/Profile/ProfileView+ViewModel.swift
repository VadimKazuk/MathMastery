import Combine
import SwiftUI
import SwiftData

extension ProfileView {
    final class ViewModel: ObservableObject {

        @Published var sessions: [PracticeSession] = []

        // Вычисляемые общие статистики
        @Published var overallAccuracy: Int = 0
        @Published var overallAverageTime: Double = 0.0
        @Published var fastestTime: Double = 0.0
        @Published var totalSessions: Int = 0

        private let serviceContainer: ServiceContainer
        private let swiftDB: SwiftDataService

        private var cancellables = Set<AnyCancellable>()

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            loadSessions()
        }

        func loadSessions() {
            sessions = swiftDB.fetchSessions()
            calculateOverallStats()
        }

        func refresh() {
            loadSessions()
        }

        func addSession(_ session: PracticeSession) {
            sessions.insert(session, at: 0)
            calculateOverallStats()
        }

        // MARK: - Расчёт общей статистики
        private func calculateOverallStats() {
            guard !sessions.isEmpty else {
                overallAccuracy = 0
                overallAverageTime = 0
                fastestTime = 0
                totalSessions = 0
                return
            }

            totalSessions = sessions.count

            // Accuracy
            let totalCorrect = sessions.reduce(0) { $0 + $1.correctAnswers }
            let totalQuestions = sessions.reduce(0) { $0 + $1.questionsCount }
            overallAccuracy = totalQuestions > 0 ? Int(round(Double(totalCorrect) / Double(totalQuestions) * 100)) : 0

            // Average Response Time (только сессии, где есть данные)
            let sessionsWithTime = sessions.compactMap { $0.averageResponseTime }
            if !sessionsWithTime.isEmpty {
                overallAverageTime = sessionsWithTime.reduce(0, +) / Double(sessionsWithTime.count)
            } else {
                overallAverageTime = 0
            }

            // Fastest Time
            fastestTime = sessions.compactMap { $0.averageResponseTime }
                .min() ?? 0.0
        }
    }
}
