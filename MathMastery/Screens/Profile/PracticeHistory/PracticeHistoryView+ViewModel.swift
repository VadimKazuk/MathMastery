import Combine
import SwiftUI
import SwiftData

extension HistoryListView {
    final class ViewModel: ObservableObject {
        @Published var sessions: [PracticeSession] = []

        private let serviceContainer: ServiceContainer
        private let swiftDB: SwiftDataService

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
                    if $0.accuracy == $1.accuracy {
                        return $0.correctAnswers < $1.correctAnswers
                    }

                    return $0.accuracy < $1.accuracy
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
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
        }

        func loadSessions() {
            sessions = swiftDB.fetchSessions()
                .sorted { $0.date > $1.date }
        }
    }
}
