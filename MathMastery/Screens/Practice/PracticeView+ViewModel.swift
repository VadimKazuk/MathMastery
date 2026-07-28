import Combine
import SwiftUI

extension PracticeView {

    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let appSettings: AppSettingsManager

        @Published var path: [PracticeRoute] = []

        let modes = PracticeMode.allCases

        private var cancellables = Set<AnyCancellable>()

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        private var sessions: [PracticeSession] {
            serviceContainer.resolve(SwiftDataService.self).fetchSessions()
        }

        private var bestSpeed: PracticeSession? {
            sessions
                .filter {
                    $0.mode == .speed
                }
                .min {
                    ($0.averageResponseTime ?? .infinity)
                    <
                        ($1.averageResponseTime ?? .infinity)
                }
        }

        private var bestFocus: PracticeSession? {
            sessions
                .filter {
                    $0.mode == .focus
                }
                .max {
                    if $0.correctAnswers == $1.correctAnswers {
                        return $0.accuracy < $1.accuracy
                    }

                    return $0.correctAnswers < $1.correctAnswers
                }
        }

        private var bestSurvival: PracticeSession? {
            sessions
                .filter {
                    $0.mode == .survival
                }
                .max {
                    if $0.correctAnswers == $1.correctAnswers {
                        return $0.accuracy < $1.accuracy
                    }

                    return $0.correctAnswers < $1.correctAnswers
                }
        }

        private var bestRush: PracticeSession? {
            sessions
                .filter {
                    $0.mode == .rush
                }
                .max {
                    if $0.correctAnswers == $1.correctAnswers {
                        return $0.accuracy < $1.accuracy
                    }
                    return $0.correctAnswers < $1.correctAnswers
                }
        }

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer

            self.accountService = serviceContainer.resolve(AccountService.self)
            self.appSettings = serviceContainer.resolve(AppSettingsManager.self)
        }

        // MARK: - Navigation
        func startMode(_ mode: PracticeMode) {
            switch mode {
            case .speed:
                path = [.speed]
            case .focus:
                path = [.focusTableSelection]
            case .survival:
                path = [.survival]
            case .rush:
                path = [.rush]
            }
        }

        func returnToHub() {
            path.removeAll()
        }

        func showResult(_ session: PracticeSession) {
            path.append(.result(session))
        }

        // MARK: - Best Result
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
    }
}
