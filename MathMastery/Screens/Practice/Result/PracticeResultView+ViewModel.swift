import Combine
import SwiftUI

extension PracticeResultView {
    final class ViewModel: ObservableObject {   // ← Добавили ObservableObject
        let session: PracticeSession

        let mistakes: [PracticeAnswer]

        init(serviceContainer: ServiceContainer, session: PracticeSession) {
            self.session = session
            self.mistakes = session.answers.filter { !$0.isCorrect }
        }

        var title: String {
            "\(session.mode.title) Summary"
        }

        var summary: String {
            switch session.mode {
            case .focus:  return "Correctness practice without time pressure."
            case .speed:    return "Fast recall session complete."
            case .survival: return "You ran out of lives."
            case .rush:     return "Rush recall session complete."
            }
        }

        var metrics: [PracticeResultMetric] {
            var metrics: [PracticeResultMetric] = [
                .init(title: "Questions", value: "\(session.questionsCount)"),
                .init(title: "Correct", value: "\(session.correctAnswers)"),
                .init(title: "Accuracy", value: "\(session.accuracy)%")
            ]

            if let avgTime = session.averageResponseTime {
                metrics.append(.init(title: "Avg Time", value: String(format: "%.1fs", avgTime)))
            }

            if session.longestStreak > 0 {
                metrics.append(.init(title: "Best Streak", value: "\(session.longestStreak)"))
            }

            return metrics
        }

        var mistakeTitle: String {
            session.mode == .rush ? "Weak Points" : "Mistakes"
        }
    }
}
