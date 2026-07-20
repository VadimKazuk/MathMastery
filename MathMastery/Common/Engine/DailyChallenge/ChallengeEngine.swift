import Foundation

final class ChallengeEngine {

    private let calendar = Calendar.current

    func dailyChallenges(
        from sessions: [PracticeSession]
    ) -> [DailyChallenge] {

        [
            speedChallenge(from: sessions),
            masteryChallenge(from: sessions),
            xpChallenge(from: sessions),
            survivalChallenge(from: sessions)
        ]
    }

    private func speedChallenge(
        from sessions: [PracticeSession]
    ) -> DailyChallenge {

        let completed = sessions.filter {
            $0.mode == .speed &&
            calendar.isDateInToday($0.date)
        }.count

        return DailyChallenge(
            id: .speed,
            title: "Complete Speed Mode",
            icon: "ic_bolt_daily",
            checkmark: "ic_check_yellow",
            current: completed,
            target: 1
        )
    }

    private func masteryChallenge(
        from sessions: [PracticeSession]
    ) -> DailyChallenge {

        let correct = sessions
            .filter {
                calendar.isDateInToday($0.date)
            }
            .reduce(0) {
                $0 + $1.correctAnswers
            }

        return DailyChallenge(
            id: .questions,
            title: "Solve 20 Questions",
            icon: "ic_fire_daily",
            checkmark: "ic_check_red",
            current: correct,
            target: 20
        )
    }

    private func survivalChallenge(
        from sessions: [PracticeSession]
    ) -> DailyChallenge {

        let duration = sessions
            .filter {
                $0.mode == .survival &&
                calendar.isDateInToday($0.date)
            }
            .reduce(0) {
                $0 + ($1.duration ?? 0)
            }

        return DailyChallenge(
            id: .survival,
            title: "Survive 2 minutes",
            icon: "ic_watch_daily",
            checkmark: "ic_check_orange",
            current: duration,
            target: 120
        )
    }

    private func xpChallenge(
        from sessions: [PracticeSession]
    ) -> DailyChallenge {

        let todaySessions = sessions.filter {
            calendar.isDateInToday($0.date)
        }

        let xp = XPSystem.total(
            sessions: todaySessions
        )

        return DailyChallenge(
            id: .xp,
            title: "Earn 150 XP",
            icon: "ic_rocket_daily",
            checkmark: "ic_check_blue",
            current: xp,
            target: 150
        )
    }
}
