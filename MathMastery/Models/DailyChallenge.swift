import SwiftUI

struct DailyChallenge: Identifiable {
    let id: DailyChallengeType

    let title: String
    let icon: String
    let checkmark: String

    let current: Int
    let target: Int

    let mode: PracticeMode?
    let metadata: String?
    
    var shouldAnimate: Bool = false

    var remaining: Int {
        max(target - current, 0)
    }

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1)
    }

    var isCompleted: Bool {
        current >= target
    }
}

extension DailyChallenge {

    var color: Color {
        switch id {

        case .questions:
            return .red

        case .accuracy:
            return .green

        case .mode:
            return .yellow

        case .mastery:
            return .purple

        case .survival:
            return .orange

        case .xp:
            return .blue

        case .streak:
            return .green

        case .noMistakes:
            return .mint

        case .modeMaster:
            return .indigo

        case .personalBest:
            return .pink
        }
    }


    var subtitle: String {
        switch id {

        case .questions:
            return isCompleted
                ? "Daily goal completed!"
                : "\(remaining) questions remaining"

        case .accuracy:
            return isCompleted
                ? "Perfect run completed!"
                : "Minimum 10 questions"

        case .mode:
            let modeTitle = mode?.title ?? "Practice"

            return isCompleted
                ? "\(modeTitle) session completed!"
                : "Complete \(modeTitle) Mode"

        case .mastery:
            let table = metadata ?? ""

            return isCompleted
                ? "Table mastered!"
                : "Practice ×\(table) table"

        case .xp:
            return isCompleted
                ? "XP goal reached!"
                : "\(remaining) XP remaining"

        case .survival:
            let duration = metadata ?? "\(target / 60) minutes"

            return isCompleted
                ? "Challenge completed!"
                : "Survive for \(duration), Rush Mode"

        case .streak:
            return isCompleted
                ? "Streak achieved!"
                : "\(target) correct answers in a row"

        case .noMistakes:
            return isCompleted
                ? "Perfect accuracy!"
                : "\(target) questions, no mistakes"

        case .modeMaster:
            return isCompleted
                ? "All modes completed!"
                : "\(current)/\(target) modes completed"

        case .personalBest:
            return isCompleted
                ? "New record achieved!"
                : "Beat your personal best"
        }
    }
}
