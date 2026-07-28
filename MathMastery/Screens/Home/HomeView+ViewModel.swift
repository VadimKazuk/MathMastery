import Combine
import SwiftUI

extension HomeView {
    final class ViewModel: ObservableObject {
        private let swiftDB: SwiftDataService
        private let accountService: AccountService
        private let appSettings: AppSettingsManager

        private let weeklyProgressEngine = WeeklyProgressEngine()
        private let challengeEngine = ChallengeEngine()
        private let challengeGenerator = DailyChallengeGenerator()
        private let improvementEngine: ImprovementEngine

        @Published private(set) var improvement: ImprovementRecommendation?
        private var pendingNextImprovement: ImprovementRecommendation?
        private var shouldAnimateNextImprovementUpdate = false

        enum ImprovementTransition: Equatable {
            case none
            case animatingCompletion(table: Int)
            case completed(table: Int)
            case showingNext(table: Int)
        }

        @Published var improvementTransition: ImprovementTransition = .none

        private let challengeStorage = DailyChallengeStorage()

        @Published private(set) var streakCount: Int = 0

        @Published var progressPercent: Double = 0.65
        @Published var currentTargetTitle: String = "Focus Mode: x7"
        @Published var currentTargetSubtitle: String = "Mastering the 7 times table with speed drills."

        @Published private(set) var challengeCountdown = "23:59:59"

        @Published private(set) var days: [WeeklyDay] = []
        @Published private(set) var challenges: [DailyChallenge] = []

        @Published private(set) var allChallengesTest: [DailyChallenge] = []

        @Published private(set) var todaySummary = TodaySummary(
            questions: 0,
            accuracy: 0,
            practiceTime: 0,
            xp: 0
        )

        @Published var animatedImprovementProgress: Double = 0
        @Published var animatedImprovementPercentage: Int = 0

        private var previousProgress: [DailyChallengeType: Double] = [:]
        private var previousImprovementProgress: Double?
        private var previousImprovementPercentage: Int?

        private var testChallengeDate = Date()

        private var countdownTimer: AnyCancellable?
        private var improvementTimer: Timer?
        private var improvementTransitionWorkItem: DispatchWorkItem?

        @Published private(set) var pendingChallenges: [DailyChallenge] = []
        @Published private(set) var shouldShowNewChallengesButton = false

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
            self.accountService = serviceContainer.resolve(AccountService.self)
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.appSettings = serviceContainer.resolve(AppSettingsManager.self)

            self.improvementEngine = ImprovementEngine()
        }

        deinit {
            countdownTimer?.cancel()
            improvementTimer?.invalidate()
            improvementTransitionWorkItem?.cancel()
        }

        func loadProgressData() {
            let sessions = swiftDB.fetchSessions()
            let shouldAnimateImprovement = shouldAnimateNextImprovementUpdate
            shouldAnimateNextImprovementUpdate = false

            streakCount = weeklyProgressEngine.calculateStreak(from: sessions)
            days = weeklyProgressEngine.weeklyDays(from: sessions)

            let newImprovement = improvementEngine.recommendation(sessions: sessions)

            if case .none = improvementTransition,
               shouldAnimateImprovement,
               let old = improvement,
               case .focusTable(let table) = old.action,
               let completedImprovement = improvementEngine.recommendation(
                sessions: sessions,
                forTable: table
               ),
               newImprovement?.focusTitle != old.focusTitle {

                improvement = completedImprovement
                pendingNextImprovement = newImprovement
                improvementTransition = .animatingCompletion(table: table)

            } else if case .none = improvementTransition {
                improvement = newImprovement
            }

            // MARK: - Логика Челленджей

            // 1. Проверяем, открывал ли пользователь челленджи СЕГОДНЯ
            let isAppliedToday = challengeStorage.hasAppliedChallenges(for: testChallengeDate)

            let definitions: [DailyChallengeDefinition]

            if let saved = challengeStorage.load(for: testChallengeDate) {
                // Данные на сегодня уже есть
                definitions = saved
            } else {
                // Первый запуск ИЛИ новый день -> генерируем новые челленджи
                let generated = challengeGenerator.generate(from: sessions, for: testChallengeDate)
                challengeStorage.save(generated, date: testChallengeDate) // save() сбросит hasApplied в false
                definitions = generated
            }

            let generated = challengeEngine.dailyChallenges(
                from: sessions,
                definitions: definitions
            )

            let formattedChallenges = generated.map { challenge in
                DailyChallenge(
                    id: challenge.id,
                    title: challenge.title,
                    icon: challenge.icon,
                    checkmark: challenge.checkmark,
                    current: challenge.current,
                    target: challenge.target,
                    mode: challenge.mode,
                    metadata: challenge.metadata,
                    shouldAnimate: false
                )
            }

            // 2. Распределяем по состоянию
            if isAppliedToday {
                // Челленджи уже открыты сегодня -> показываем их сразу, даже после выгрузки приложения
                challenges = formattedChallenges
                pendingChallenges = []
                shouldShowNewChallengesButton = false
            } else {
                // Челленджи еще НЕ открыты (Первый в жизни запуск ИЛИ новый день)
                pendingChallenges = formattedChallenges
                challenges = []
                shouldShowNewChallengesButton = true
            }

            loadTodaySummary()
            startChallengeCountdown()

            DispatchQueue.main.async { [weak self] in
                self?.updateImprovementAnimation(animate: shouldAnimateImprovement)

                if case .animatingCompletion = self?.improvementTransition {
                    self?.scheduleCompletionReward()
                }
            }

            allChallengesTest = challengeEngine.allChallenges(from: sessions)
        }

        func isDevMode() -> Bool {
            appSettings.developerMode
        }

        func shouldShowAllChallenges() -> Bool {
            appSettings.showAllChallenges
        }

        func startImprovementPractice() {
            shouldAnimateNextImprovementUpdate = true
        }

        func applyPendingChallenges() {
            guard !pendingChallenges.isEmpty else { return }

            challenges = pendingChallenges
            pendingChallenges = []
            shouldShowNewChallengesButton = false

            // Сохраняем флаг, что пользователь открыл челленджи сегодня
            challengeStorage.setChallengesApplied(for: testChallengeDate)
        }

        private func loadTodaySummary() {
            let sessions = swiftDB.fetchSessions()

            let todaySessions = sessions.filter {
                Calendar.current.isDateInToday($0.date)
            }

            let questions = todaySessions.reduce(0) {
                $0 + $1.questionsCount
            }

            let correct = todaySessions.reduce(0) {
                $0 + $1.correctAnswers
            }

            let accuracy = questions > 0
                ? Int(Double(correct) / Double(questions) * 100)
                : 0

            let practiceTime = todaySessions
                .compactMap(\.duration)
                .reduce(0) {
                    $0 + $1
                }

            let xp = todaySessions.reduce(0) {
                $0 + XPSystem.xp(for: $1)
            }

            todaySummary = TodaySummary(
                questions: questions,
                accuracy: accuracy,
                practiceTime: TimeInterval(practiceTime),
                xp: xp
            )
        }

        private func startChallengeCountdown() {
            updateChallengeCountdown()

            countdownTimer?.cancel()

            countdownTimer = Timer.publish(
                every: 1,
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateChallengeCountdown()
            }
        }

        private func updateChallengeCountdown() {
            let calendar = Calendar.current
            let now = Date()

            guard let tomorrow = calendar.date(
                byAdding: .day,
                value: 1,
                to: calendar.startOfDay(for: now)
            ) else {
                return
            }

            let remaining = Int(tomorrow.timeIntervalSince(now))

            let hours = remaining / 3600
            let minutes = (remaining % 3600) / 60
            let seconds = remaining % 60

            challengeCountdown = String(
                format: "%02d:%02d:%02d",
                hours,
                minutes,
                seconds
            )
        }

        private func updateImprovementAnimation(animate: Bool) {
            guard let improvement else { return }

            improvementTimer?.invalidate()

            let newProgress = improvement.progress
            let newPercentage = Int(improvement.currentValue * 100)
            let oldProgress = previousImprovementProgress ?? newProgress
            let oldPercentage = previousImprovementPercentage ?? newPercentage

            previousImprovementProgress = newProgress
            previousImprovementPercentage = newPercentage

            guard animate,
                  oldProgress != newProgress || oldPercentage != newPercentage else {
                animatedImprovementProgress = newProgress
                animatedImprovementPercentage = newPercentage
                return
            }

            animatedImprovementProgress = oldProgress
            animatedImprovementPercentage = oldPercentage

            withAnimation(.easeOut(duration: 0.8)) {
                animatedImprovementProgress = newProgress
            }

            guard newPercentage > oldPercentage else {
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedImprovementPercentage = newPercentage
                }
                return
            }

            let interval = 0.8 / Double(newPercentage - oldPercentage)
            var currentPercentage = oldPercentage

            improvementTimer = Timer.scheduledTimer(
                withTimeInterval: interval,
                repeats: true
            ) { [weak self] timer in
                guard let self else {
                    timer.invalidate()
                    return
                }

                currentPercentage += 1
                self.animatedImprovementPercentage = currentPercentage

                if currentPercentage >= newPercentage {
                    timer.invalidate()
                }
            }
        }

        private func scheduleCompletionReward() {
            improvementTransitionWorkItem?.cancel()

            let workItem = DispatchWorkItem { [weak self] in
                guard let self,
                      case .animatingCompletion(let table) = self.improvementTransition else {
                    return
                }

                self.improvementTransition = .completed(table: table)
                self.scheduleNextImprovement()
            }

            improvementTransitionWorkItem = workItem
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.8,
                execute: workItem
            )
        }

        private func scheduleNextImprovement() {
            improvementTransitionWorkItem?.cancel()

            let workItem = DispatchWorkItem { [weak self] in
                self?.showingNextImprovement()
            }

            improvementTransitionWorkItem = workItem
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 3,
                execute: workItem
            )
        }

        private func showingNextImprovement() {
            guard case .completed = improvementTransition else { return }

            guard let nextImprovement = pendingNextImprovement,
                  case .focusTable(let table) = nextImprovement.action else {
                improvement = nil
                animatedImprovementProgress = 0
                animatedImprovementPercentage = 0
                improvementTransition = .none
                return
            }

            improvement = nextImprovement
            pendingNextImprovement = nil
            animatedImprovementProgress = nextImprovement.progress
            animatedImprovementPercentage = Int(nextImprovement.currentValue * 100)
            previousImprovementProgress = nextImprovement.progress
            previousImprovementPercentage = Int(nextImprovement.currentValue * 100)
            improvementTransition = .showingNext(table: table)

            improvementTransitionWorkItem = DispatchWorkItem { [weak self] in
                self?.improvementTransition = .none
            }

            if let improvementTransitionWorkItem {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 1.25,
                    execute: improvementTransitionWorkItem
                )
            }
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


            challengeStorage.save(
                definitions,
                date: testChallengeDate
            )


            let generated = challengeEngine.dailyChallenges(
                from: sessions,
                definitions: definitions
            )


            pendingChallenges = generated.map {

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


            shouldShowNewChallengesButton = true
        }
    }
}
