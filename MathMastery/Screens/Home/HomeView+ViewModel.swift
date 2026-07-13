import Combine
import SwiftUI

extension HomeView {
    final class ViewModel: ObservableObject {
        private let swiftDB: SwiftDataService
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        private let engine = LearnEngine()

        private var cancellables = Set<AnyCancellable>()

        // Mock data or fetched values from your services
        @Published var greetingName: String = "Alex"
        @Published var streakCount: Int = 5
        @Published var currentTargetTitle: String = "Focus Mode: x7"
        @Published var currentTargetSubtitle: String = "Mastering the 7 times table with speed drills."
        @Published var progressPercent: Double = 0.65
        @Published var drillsCompleted: Int = 13
        @Published var totalDrills: Int = 20

        @Published var weeklyActivity: [DailyActivity] = []

        // Статистика под графиком
        @Published var solvedCount: String = "0"
        @Published var avgAccuracy: String = "0%"
        @Published var timePerDay: String = "0m"

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)

            let sessions = swiftDB.fetchSessions()

            weeklyActivity = engine.weeklyActivity(from: sessions)
            loadActivity(from: sessions)
        }

        func loadActivity(from sessions: [PracticeSession]) {

            let stats = engine.activityStats(from: sessions)

            solvedCount = "\(stats.solved)"
            avgAccuracy = "\(stats.avgAccuracy)%"

            let minutes = stats.totalTime / 60
            timePerDay = "\(minutes)m"
        }

        func resumeSession() {
            print("Resuming session...")
        }
    }
}
