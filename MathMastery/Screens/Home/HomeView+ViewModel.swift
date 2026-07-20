import Combine
import SwiftUI

extension HomeView {
    final class ViewModel: ObservableObject {
        private let swiftDB: SwiftDataService
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let analyticsService: PracticeAnalyticsService

        private var cancellables = Set<AnyCancellable>()

        @Published var greetingName: String = "Alex"
        @Published private(set) var streakCount: Int = 0
        @Published var currentTargetTitle: String = "Focus Mode: x7"
        @Published var currentTargetSubtitle: String = "Mastering the 7 times table with speed drills."
        @Published var progressPercent: Double = 0.65
        @Published var drillsCompleted: Int = 13
        @Published var totalDrills: Int = 20

        @Published private(set) var days: [WeeklyDay] = []

        var streakLevel: StreakLevel {
            StreakLevel(days: streakCount)
        }

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        var hasCompletedToday: Bool {
            days.contains {
                $0.status == .completed &&
                Calendar.current.isDateInToday($0.date)
            }
        }

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.analyticsService =
                serviceContainer.resolve(PracticeAnalyticsService.self)
        }

        func loadProgressData() {
            let sessions = swiftDB.fetchSessions()

            streakCount = analyticsService.calculateStreak(from: sessions)
            days = analyticsService.weeklyDays(from: sessions)
        }

    }
}


