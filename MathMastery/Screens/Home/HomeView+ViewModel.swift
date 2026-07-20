import Combine
import SwiftUI

extension HomeView {

    final class ViewModel: ObservableObject {

        private let swiftDB: SwiftDataService
        private let accountService: AccountService

        private let weeklyProgressEngine = WeeklyProgressEngine()
        private let challengeEngine = ChallengeEngine()

        @Published private(set) var streakCount: Int = 0

        @Published var progressPercent: Double = 0.65
        @Published var currentTargetTitle: String = "Focus Mode: x7"
        @Published var currentTargetSubtitle: String = "Mastering the 7 times table with speed drills."

        @Published private(set) var days: [WeeklyDay] = []
        @Published private(set) var challenges: [DailyChallenge] = []

        private var previousProgress: [DailyChallengeType: Double] = [:]

        var streakLevel: StreakLevel {
            StreakLevel(days: streakCount)
        }

        var hasCompletedToday: Bool {
            days.contains {
                $0.status == .completed &&
                Calendar.current.isDateInToday($0.date)
            }
        }

        init(serviceContainer: ServiceContainer) {
            self.accountService =
                serviceContainer.resolve(AccountService.self)
            self.swiftDB =
                serviceContainer.resolve(SwiftDataService.self)
        }

        func loadProgressData() {
            let sessions = swiftDB.fetchSessions()

            streakCount = weeklyProgressEngine.calculateStreak(from: sessions)
            days = weeklyProgressEngine.weeklyDays(from: sessions)

            let generated = challengeEngine.dailyChallenges(
                from: sessions
            )

            challenges = generated.map { challenge in
                let oldProgress = previousProgress[challenge.id]

                previousProgress[challenge.id] = challenge.progress

                let shouldAnimate = {
                    guard let oldProgress else { return false }
                    return challenge.progress > oldProgress
                }()

                return DailyChallenge(
                    id: challenge.id,
                    title: challenge.title,
                    icon: challenge.icon,
                    checkmark: challenge.checkmark,
                    current: challenge.current,
                    target: challenge.target,
                    shouldAnimate: shouldAnimate
                )
            }
        }
    }
    

}

