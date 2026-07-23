import Foundation

final class ChallengeEngine {

    private let personalBestEngine = PersonalBestEngine()

    private let calendar = Calendar.current

    func dailyChallenges(
        from sessions: [PracticeSession],
        definitions: [DailyChallengeDefinition]
    ) -> [DailyChallenge] {

        definitions.map {
            makeChallenge(
                definition: $0,
                sessions: sessions
            )
        }
    }

    private func makeChallenge(
        definition: DailyChallengeDefinition,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        switch definition.type {

        case .questions:
            return questionsChallenge(
                target: definition.target,
                sessions: sessions
            )

        case .accuracy:
            return accuracyChallenge(
                target: definition.target,
                sessions: sessions
            )

        case .mode:
            return modeChallenge(
                mode: definition.mode ?? .speed,
                sessions: sessions
            )

        case .mastery:
            return masteryChallenge(
                table: definition.metadata ?? "7",
                target: definition.target,
                sessions: sessions
            )

        case .survival:
            return survivalChallenge(
                target: definition.target,
                sessions: sessions
            )

        case .xp:
            return xpChallenge(
                target: definition.target,
                sessions: sessions
            )

        case .streak:
            return streakChallenge(
                target: definition.target,
                sessions: sessions
            )

        case .noMistakes:
            return noMistakesChallenge(
                target: definition.target,
                sessions: sessions
            )

        case .modeMaster:
            return modeMasterChallenge(
                sessions: sessions
            )

        case .personalBest:
            return personalBestChallenge(
                mode: definition.mode ?? .speed,
                sessions: sessions
            )
        }
    }


    // MARK: - Questions

    private func questionsChallenge(
        target: Int,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let solved = todaySessions(from: sessions)
            .reduce(0) {
                $0 + $1.questionsCount
            }

        return DailyChallenge(
            id: .questions,
            title: "Solve \(target) Questions",
            icon: "ic_fire_daily",
            checkmark: "ic_check_red",
            current: solved,
            target: target,
            mode: nil,
            metadata: nil
        )
    }


    // MARK: - Accuracy

    private func accuracyChallenge(
        target: Int,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let bestAccuracy = todaySessions(from: sessions)
            .filter {
                $0.questionsCount >= 10
            }
            .map(\.accuracy)
            .max() ?? 0

        return DailyChallenge(
            id: .accuracy,
            title: "Reach 100% Accuracy",
            icon: "ic_accuracy_daily",
            checkmark: "ic_check_green",
            current: bestAccuracy,
            target: target,
            mode: nil,
            metadata: "10+ questions"
        )
    }


    // MARK: - Practice Mode

    private func modeChallenge(
        mode: PracticeMode,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let completed = todaySessions(from: sessions)
            .contains {
                $0.mode == mode
            }

        return DailyChallenge(
            id: .mode,
            title: "Complete \(mode.title) Mode",
            icon: mode.icImage,
            checkmark: "ic_check_yellow",
            current: completed ? 1 : 0,
            target: 1,
            mode: mode,
            metadata: nil
        )
    }


    // MARK: - Mastery

    private func masteryChallenge(
        table: String,
        target: Int,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let tableNumber = Int(table) ?? 7

        let progress = todaySessions(from: sessions)
            .flatMap(\.answers)
            .filter {
                $0.left == tableNumber ||
                $0.right == tableNumber
            }
            .count


        return DailyChallenge(
            id: .mastery,
            title: "Master ×\(tableNumber)",
            icon: "ic_master_daily",
            checkmark: "ic_check_purple",
            current: min(progress, target),
            target: target,
            mode: nil,
            metadata: table
        )
    }


    // MARK: - Survival

    private func survivalChallenge(
        target: Int,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let duration = todaySessions(from: sessions)
            .filter {
                $0.mode == .survival
            }
            .reduce(0) {
                $0 + ($1.duration ?? 0)
            }


        return DailyChallenge(
            id: .survival,
            title: "Survive \(target / 60) Minutes",
            icon: "ic_pacman_daily",
            checkmark: "ic_check_orange",
            current: duration,
            target: target,
            mode: .survival,
            metadata: "\(target / 60) minutes"
        )
    }


    // MARK: - XP

    private func xpChallenge(
        target: Int,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let xp = XPSystem.total(
            sessions: todaySessions(from: sessions)
        )

        return DailyChallenge(
            id: .xp,
            title: "Earn \(target) XP",
            icon: "ic_rocket_daily",
            checkmark: "ic_check_blue",
            current: xp,
            target: target,
            mode: nil,
            metadata: nil
        )
    }

    private func streakChallenge(
        target: Int,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let best = todaySessions(from: sessions)
            .map(\.longestStreak)
            .max() ?? 0

        return DailyChallenge(
            id: .streak,
            title: "\(target) Answer Streak",
            icon: "ic_rock_n_roll_daily",
            checkmark: "ic_check_green",
            current: best,
            target: target,
            mode: nil,
            metadata: nil
        )
    }

    private func noMistakesChallenge(
        target: Int,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let completed = todaySessions(from: sessions)
            .contains {
                $0.questionsCount >= target &&
                $0.mistakesCount == 0
            }


        return DailyChallenge(
            id: .noMistakes,
            title: "\(target) Perfect Answers",
            icon: "ic_done_folder_daily",
            checkmark: "ic_check_mint",
            current: completed ? target : 0,
            target: target,
            mode: nil,
            metadata: nil
        )
    }

    private func modeMasterChallenge(
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let modes: Set<PracticeMode> =
            Set(
                todaySessions(from: sessions)
                    .map(\.mode)
            )

        return DailyChallenge(
            id: .modeMaster,
            title: "Complete All Modes",
            icon: "ic_task_daily",
            checkmark: "ic_check_indigo",
            current: modes.count,
            target: 4,
            mode: nil,
            metadata: "Speed, Focus, Rush, Survival"
        )
    }

    // MARK: - Personal Best

    private func personalBestChallenge(
        mode: PracticeMode,
        sessions: [PracticeSession]
    ) -> DailyChallenge {

        let history = sessions.filter {
            $0.mode == mode &&
            !calendar.isDateInToday($0.date)
        }

        let today = todaySessions(from: sessions)
            .filter {
                $0.mode == mode
            }

        let previousBest = personalBestEngine.bestSession(
            for: mode,
            sessions: history
        )

        let todayBest = personalBestEngine.bestSession(
            for: mode,
            sessions: today
        )

        let beaten: Bool

        if previousBest == nil {

            beaten = todayBest != nil

        } else if let previousBest,
                  let todayBest {

            beaten = personalBestEngine.isBetter(
                todayBest,
                than: previousBest,
                mode: mode
            )

        } else {

            beaten = false
        }

        return DailyChallenge(
            id: .personalBest,
            title: "Beat Your \(mode.title) Record",
            icon: "ic_crown_daily",
            checkmark: "ic_check_pink",
            current: beaten ? 1 : 0,
            target: 1,
            mode: mode,
            metadata: previousBest.map {
                personalBestEngine.value(
                    for: $0,
                    mode: mode
                )
            } ?? "-"
        )
    }

    // MARK: - Helpers

    private func todaySessions(
        from sessions: [PracticeSession]
    ) -> [PracticeSession] {

        sessions.filter {
            calendar.isDateInToday($0.date)
        }
    }
}

