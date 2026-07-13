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

        @Published private(set) var bestSpeed: PracticeSession?
        @Published private(set) var bestSurvival: PracticeSession?
        @Published private(set) var bestRush: PracticeSession?

        @Published private(set) var profile = UserProfile()

        @Published var gameCenterName: String?
        @Published var gameCenterAvatar: UIImage?

        private let serviceContainer: ServiceContainer
        private let swiftDB: SwiftDataService
        private let accountService: AccountService
        private let gameCenterService: GameCenterServiceProtocol

        private var cancellables = Set<AnyCancellable>()

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

            loadSessions()
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
            calculateOverallStats()
            calculatePersonalBests()
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

        private func calculatePersonalBests() {
            bestSpeed = bestSession(for: .speed)
            bestSurvival = bestSession(for: .survival)
            bestRush = bestSession(for: .rush)
        }

        private func bestSession(for mode: PracticeMode) -> PracticeSession? {
            sessions
                .filter { $0.mode == mode }
                .max {
                    if $0.questionsCount == $1.questionsCount {
                        return $0.accuracy < $1.accuracy
                    }
                    return $0.questionsCount < $1.questionsCount
                }
        }
    }
}
