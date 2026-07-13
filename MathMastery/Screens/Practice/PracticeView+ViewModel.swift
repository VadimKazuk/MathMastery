import Combine
import SwiftUI

extension PracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        private var cancellables = Set<AnyCancellable>()

        let currentStreak = 12
        let bestScore = 2_450
        let modes = PracticeMode.allCases

        @Published var selectedMode: PracticeMode? = nil
        @Published var path: [PracticeRoute] = []

        @Published var showStartButton = false

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        private var sessions: [PracticeSession] {
            serviceContainer
                .resolve(SwiftDataService.self)
                .fetchSessions()
        }

        private var bestSpeed: PracticeSession? {
            sessions
                .filter { $0.mode == .speed }
                .min {
                    ($0.averageResponseTime ?? .infinity) <
                    ($1.averageResponseTime ?? .infinity)
                }
        }

        private var bestFocus: PracticeSession? {
            sessions
                .filter { $0.mode == .focus }
                .max {
                    if $0.correctAnswers == $1.correctAnswers {
                        return $0.accuracy < $1.accuracy
                    }

                    return $0.correctAnswers < $1.correctAnswers
                }
        }

        private var bestSurvival: PracticeSession? {
            sessions
                .filter { $0.mode == .survival }
                .max {
                    if $0.correctAnswers == $1.correctAnswers {
                        return $0.accuracy < $1.accuracy
                    }

                    return $0.correctAnswers < $1.correctAnswers
                }
        }

        private var bestRush: PracticeSession? {
            sessions
                .filter { $0.mode == .rush }
                .max {
                    if $0.correctAnswers == $1.correctAnswers {
                        return $0.accuracy < $1.accuracy
                    }

                    return $0.correctAnswers < $1.correctAnswers
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

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
        }

        func selectMode(_ mode: PracticeMode) {
            if selectedMode == mode {
                selectedMode = nil
            } else {
                selectedMode = mode
            }
        }

        func startSelectedMode() {
            guard let mode = selectedMode else { return }
            startMode(mode)
        }

        func startMode(_ mode: PracticeMode) {
            selectedMode = mode

            switch mode {
            case .speed:
                path = [.speed]
            case .focus:
                path = [.focusTableSelection] // Изменено: сначала идем на выбор таблицы
            case .survival:
                path = [.survival]
            case .rush:
                path = [.rush]
            }
        }

        func showResult(_ result: PracticeSession) {
            path.append(.result(result))
        }

        func retry(_ mode: PracticeMode) {
            startMode(mode)
        }

        func returnToHub() {
            path = []
        }
    }
}
