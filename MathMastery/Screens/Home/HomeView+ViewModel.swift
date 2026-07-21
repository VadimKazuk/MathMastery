import Combine
import SwiftUI

extension HomeView {

    final class ViewModel: ObservableObject {

        private let swiftDB: SwiftDataService
        private let accountService: AccountService

        private let weeklyProgressEngine = WeeklyProgressEngine()
        private let challengeEngine = ChallengeEngine()
        private let challengeGenerator = DailyChallengeGenerator()

        private let challengeStorage = DailyChallengeStorage()

        @Published private(set) var streakCount: Int = 0

        @Published var progressPercent: Double = 0.65
        @Published var currentTargetTitle: String = "Focus Mode: x7"
        @Published var currentTargetSubtitle: String = "Mastering the 7 times table with speed drills."

        @Published private(set) var days: [WeeklyDay] = []
        @Published private(set) var challenges: [DailyChallenge] = []

        @Published private(set) var todaySummary = TodaySummary(
            questions: 0,
            accuracy: 0,
            practiceTime: 0,
            xp: 0
        )

        private var previousProgress: [DailyChallengeType: Double] = [:]

        private var testChallengeDate = Date()

        var streakLevel: StreakLevel {
            StreakLevel(days: streakCount)
        }

        var hasCompletedToday: Bool {
            days.contains {
                $0.status == .completed &&
                Calendar.current.isDateInToday($0.date)
            }
        }

        var todayDateText: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE dd"
            return formatter.string(from: Date()).uppercased()
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

            let definitions: [DailyChallengeDefinition]

            if let saved = challengeStorage.load() {
                definitions = saved
            } else {
                let generated = challengeGenerator.generate(from: sessions)
                challengeStorage.save(generated)
                definitions = generated
            }

            let generated = challengeEngine.dailyChallenges(
                from: sessions,
                definitions: definitions
            )

            challenges = generated.map { challenge in

                let oldProgress = previousProgress[challenge.id]

                previousProgress[challenge.id] = challenge.progress

                let shouldAnimate: Bool = {
                    guard let oldProgress else {
                        return false
                    }

                    return challenge.progress > oldProgress
                }()

                return DailyChallenge(
                    id: challenge.id,
                    title: challenge.title,
                    icon: challenge.icon,
                    checkmark: challenge.checkmark,
                    current: challenge.current,
                    target: challenge.target,
                    mode: challenge.mode,
                    metadata: challenge.metadata,
                    shouldAnimate: shouldAnimate
                )
            }

            loadTodaySummary()
        }

        private func loadTodaySummary() {

            let sessions = swiftDB.fetchSessions()

            let todaySessions = sessions.filter {
                Calendar.current.isDateInToday($0.date)
            }

            let questions = todaySessions
                .reduce(0) {
                    $0 + $1.questionsCount
                }

            let correct = todaySessions
                .reduce(0) {
                    $0 + $1.correctAnswers
                }

            let accuracy =
                questions > 0
                ? Int(Double(correct) / Double(questions) * 100)
                : 0

            let practiceTime = todaySessions
                .compactMap(\.duration)
                .reduce(0) {
                    $0 + $1
                }

            let xp = todaySessions
                .reduce(0) {
                    $0 + XPSystem.xp(for: $1)
                }

            todaySummary = TodaySummary(
                questions: questions,
                accuracy: accuracy,
                practiceTime: TimeInterval(practiceTime),
                xp: xp
            )
        }

        func generateNextDayChallengesForTest() {
            let sessions = swiftDB.fetchSessions()

            testChallengeDate = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: testChallengeDate
            ) ?? testChallengeDate


            let definitions = challengeGenerator.generate(
                from: sessions,
                for: testChallengeDate
            )

            challengeStorage.save( definitions,
                date: testChallengeDate
            )

            let generated = challengeEngine.dailyChallenges(
                from: sessions,
                definitions: definitions
            )


            challenges = generated.map {
                DailyChallenge(
                    id: $0.id,
                    title: $0.title,
                    icon: $0.icon,
                    checkmark: $0.checkmark,
                    current: $0.current,
                    target: $0.target,
                    mode: $0.mode,
                    metadata: $0.metadata,
                    shouldAnimate: false
                )
            }
        }
    }
}
