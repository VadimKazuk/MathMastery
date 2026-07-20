import SwiftUI

struct DailyChallenge: Identifiable {
    let id: DailyChallengeType

    let title: String
    let icon: String
    let checkmark: String
    let current: Int
    let target: Int

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
        case .speed:
            return .yellow
        case .mastery:
            return .purple
        case .survival:
            return .orange
        case .xp:
            return .blue
        }
    }
}
