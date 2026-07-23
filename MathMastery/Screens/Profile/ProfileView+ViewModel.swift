import Combine
import SwiftUI
import SwiftData

extension ProfileView {
    final class ViewModel: ObservableObject {

        @Published var sessions: [PracticeSession] = []

        @Published var chartPoints: [ActivityPoint] = []
        @Published var chartSummary: ActivitySummary?

        @Published var selectedMode: ActivityModeFilter = .all
        @Published var selectedMetric: ActivityMetric = .solved
        @Published var selectedRange: ActivityRange = .last7Days

        // Вычисляемые общие статистики
        @Published var overallAccuracy: Int = 0
        @Published var overallAverageResponseTime: Double = 0.0
        @Published var fastestResponseTime: Double = 0.0
        @Published var totalSessions: Int = 0

        @Published private(set) var bestSpeed: PracticeSession?
        @Published private(set) var bestSurvival: PracticeSession?
        @Published private(set) var bestRush: PracticeSession?
        @Published private(set) var bestFocus: PracticeSession?

        @Published private(set) var profile = UserProfile()

        @Published var gameCenterName: String?
        @Published var gameCenterAvatar: UIImage?

        @Published var learningGrid = MultiplicationGridState(
            numbers: Array(2...9),
            cells: Array(
                repeating: Array(
                    repeating: .empty,
                    count: 8
                ),
                count: 8
            )
        )

        private let serviceContainer: ServiceContainer
        private let swiftDB: SwiftDataService
        private let accountService: AccountService
        private let gameCenterService: GameCenterServiceProtocol
        
        private let chartEngine = ActivityChartEngine()
        private let learnEngine = LearnEngine()
        private let personalBestEngine = PersonalBestEngine()

        private var cancellables = Set<AnyCancellable>()

        var yDomain: ClosedRange<Double> {
            let maxValue = chartPoints
                .map(\.value)
                .max() ?? 0

            switch selectedMetric {

            case .accuracy:
                return 0...100

            case .averageResponseTime,
                 .fastestResponseTime:
                return 0...max(10, ceil(maxValue + 1))

            case .duration:
                return 0...max(300, ceil(maxValue + 60))

            default:
                let step = max(5, ceil(maxValue * 0.2))
                return 0...max(5, ceil(maxValue / step) * step)
            }
        }

        var xAxisDates: [Date] {

            switch selectedRange {

            case .last7Days:
                return chartPoints.map(\.date)

            case .last30Days:
                return chartPoints.enumerated()
                    .filter { $0.offset % 5 == 0 }
                    .map { $0.element.date }

            case .last3Months:
                return chartPoints.enumerated()
                    .filter { $0.offset % 2 == 0 }
                    .map { $0.element.date }

            case .lastYear:
                return chartPoints.map(\.date)

            case .allTime:
                return chartPoints.enumerated()
                    .filter { $0.offset % 3 == 0 }
                    .map { $0.element.date }
            }
        }

        var profileName: String {
            gameCenterName ?? "No player"
        }

        var profileImage: UIImage? {
            gameCenterAvatar
        }

        var level: Int {
            LevelSystem.level(for: profile.totalXP)
        }

        var levelProgress: Double {
            LevelSystem.progress(for: profile.totalXP)
        }

        var nextLevelXP: Int {
            LevelSystem.nextLevelXP(for: profile.totalXP)
        }

        func progress(for xp: Int) -> Double {
            LevelSystem.progress(for: xp)
        }

        var totalXP: Int {
            profile.totalXP
        }
        
        var avatarName: String {
            "img_profile_\(profile.avatarId)"
        }

        var displayName: String {
            profile.name.isEmpty ? "Guest" : profile.name
        }

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.gameCenterService = serviceContainer.resolve(GameCenterServiceProtocol.self)

            profile = accountService.profile

            accountService.$profile
                .receive(on: DispatchQueue.main)
                .assign(to: &$profile)

            gameCenterService.playerNamePublisher
                .receive(on: DispatchQueue.main)
                .assign(to: &$gameCenterName)

            gameCenterService.avatarPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: &$gameCenterAvatar)

            setupChartBindings()
        }

        func openGameCenter() {
            gameCenterService.showGameCenter()
        }

        var isGameCenterAuthenticated: Bool {
            gameCenterService.isAuthenticated
        }

        func authenticateGameCenter() {
            gameCenterService.authenticate()
        }

        func loadSessions() {
            sessions = swiftDB.fetchSessions()
                .sorted { $0.date > $1.date }

            let state = learnEngine.makeState(from: sessions)

            if state.gridState.count == 8 {
                learningGrid = MultiplicationGridState(
                    numbers: Array(2...9),
                    cells: state.gridState
                )
            }

            calculatePersonalBests()
            calculateOverallStats()
            updateChart()
        }

        func updateChart() {
            chartPoints = chartEngine.chart(
                sessions: sessions,
                mode: selectedMode,
                metric: selectedMetric,
                range: selectedRange
            )

            chartSummary = chartEngine.summary(
                sessions: sessions,
                mode: selectedMode,
                metric: selectedMetric,
                range: selectedRange
            )
        }

        func refresh() {
            loadSessions()
        }

        func addSession(_ session: PracticeSession) {
            swiftDB.saveSession(session)
            sessions.insert(session, at: 0)

            calculatePersonalBests()
            updateChart()
        }

        func formatYAxis(_ value: Double) -> String {
            switch selectedMetric {
            case .accuracy:
                let percent = Int(value)
                return String(format: "%3d%%", percent)

            case .averageResponseTime,
                 .fastestResponseTime:
                return String(format: "%.2fs", value)

            case .duration:
                let minutes = Int(value / 60)
                let seconds = Int(value.truncatingRemainder(dividingBy: 60))
                return "\(minutes)m \(seconds)s"

            case .xp:
                if value >= 1000 {
                    let kValue = value / 1000
                    if kValue >= 10 {
                        return String(format: "%4.0fk", kValue)
                    } else {
                        return String(format: "%4.1fk", kValue)
                    }
                } else {
                    return String(format: "%4d", Int(value))
                }

            default:
                return String(format: "%4d", Int(value))
            }
        }

        func isBest(_ session: PracticeSession) -> Bool {

            switch session.mode {

            case .speed:
                return session.id == bestSpeed?.id

            case .focus:
                return session.id == bestFocus?.id

            case .survival:
                return session.id == bestSurvival?.id

            case .rush:
                return session.id == bestRush?.id
            }
        }

        // MARK: - Расчёт общей статистики
        private func calculateOverallStats() {
            guard !sessions.isEmpty else {
                overallAccuracy = 0
                overallAverageResponseTime = 0
                fastestResponseTime = 0
                totalSessions = 0
                return
            }

            totalSessions = sessions.count

            let totalCorrect = sessions.reduce(0) { $0 + $1.correctAnswers }
            let totalQuestions = sessions.reduce(0) { $0 + $1.questionsCount }
            overallAccuracy = totalQuestions > 0 ? Int(round(Double(totalCorrect) / Double(totalQuestions) * 100)) : 0

            let averageTimes = sessions.compactMap {
                $0.averageResponseTime
            }

            overallAverageResponseTime = averageTimes.isEmpty
            ? 0
            : averageTimes.reduce(0, +) / Double(averageTimes.count)


            fastestResponseTime = sessions.compactMap {
                $0.fastestResponseTime
            }
            .min() ?? 0
        }

        private func calculatePersonalBests() {

            bestSpeed = personalBestEngine.bestSession(
                for: .speed,
                sessions: sessions
            )

            bestFocus = personalBestEngine.bestSession(
                for: .focus,
                sessions: sessions
            )

            bestSurvival = personalBestEngine.bestSession(
                for: .survival,
                sessions: sessions
            )

            bestRush = personalBestEngine.bestSession(
                for: .rush,
                sessions: sessions
            )
        }

        private func setupChartBindings() {
            Publishers.CombineLatest3(
                $selectedMode,
                $selectedMetric,
                $selectedRange
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                DispatchQueue.main.async {
                    self?.updateChart()
                }
            }
            .store(in: &cancellables)
        }
    }

}
