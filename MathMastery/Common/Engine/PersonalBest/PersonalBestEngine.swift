import Foundation

final class PersonalBestEngine {

    func bestSession(
        for mode: PracticeMode,
        sessions: [PracticeSession]
    ) -> PracticeSession? {

        let filtered = sessions.filter {
            $0.mode == mode
        }

        guard !filtered.isEmpty else {
            return nil
        }

        switch mode {

        case .speed:

            return filtered
                .filter {
                    $0.questionsCount >= 10
                }
                .min {
                    ($0.averageResponseTime ?? .infinity)
                    <
                    ($1.averageResponseTime ?? .infinity)
                }

        case .focus:

            return filtered.max {

                if $0.correctAnswers == $1.correctAnswers {
                    return $0.accuracy < $1.accuracy
                }

                return $0.correctAnswers < $1.correctAnswers
            }

        case .survival:

            return filtered.max {

                let lhs = $0.duration ?? 0
                let rhs = $1.duration ?? 0

                if lhs == rhs {
                    return $0.correctAnswers < $1.correctAnswers
                }

                return lhs < rhs
            }

        case .rush:

            return filtered.max {

                if $0.correctAnswers == $1.correctAnswers {
                    return $0.accuracy < $1.accuracy
                }

                return $0.correctAnswers < $1.correctAnswers
            }
        }
    }

    func isBetter(
        _ first: PracticeSession,
        than second: PracticeSession,
        mode: PracticeMode
    ) -> Bool {

        switch mode {

        case .speed:

            guard first.questionsCount >= 10 else {
                return false
            }

            return (first.averageResponseTime ?? .infinity)
                <
                (second.averageResponseTime ?? .infinity)

        case .focus:

            if first.correctAnswers == second.correctAnswers {
                return first.accuracy > second.accuracy
            }

            return first.correctAnswers > second.correctAnswers

        case .survival:

            let lhs = first.duration ?? 0
            let rhs = second.duration ?? 0

            if lhs == rhs {
                return first.correctAnswers > second.correctAnswers
            }

            return lhs > rhs

        case .rush:

            if first.correctAnswers == second.correctAnswers {
                return first.accuracy > second.accuracy
            }

            return first.correctAnswers > second.correctAnswers
        }
    }

    func value(
        for session: PracticeSession,
        mode: PracticeMode
    ) -> String {

        switch mode {

        case .speed:

            guard let time = session.averageResponseTime else {
                return "-"
            }

            return String(
                format: "%.2fs",
                time
            )

        case .focus, .survival, .rush:

            return "\(session.correctAnswers)"
        }
    }
}
