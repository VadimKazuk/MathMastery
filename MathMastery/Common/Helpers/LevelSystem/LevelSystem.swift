import Foundation

enum LevelSystem {

    static func level(for xp: Int) -> Int {
        var level = 1
        var required = 100
        var accumulated = 0

        while xp >= accumulated + required {
            accumulated += required
            required = Int(Double(required) * 1.35)
            level += 1
        }

        return level
    }

    static func currentLevelXP(for xp: Int) -> Int {
        var required = 100
        var accumulated = 0

        while xp >= accumulated + required {
            accumulated += required
            required = Int(Double(required) * 1.35)
        }

        return accumulated
    }

    static func nextLevelXP(for xp: Int) -> Int {
        var required = 100
        var accumulated = 0

        while xp >= accumulated + required {
            accumulated += required
            required = Int(Double(required) * 1.35)
        }

        return accumulated + required
    }

    static func progress(for xp: Int) -> Double {
        let current = currentLevelXP(for: xp)
        let next = nextLevelXP(for: xp)

        return Double(xp - current) / Double(next - current)
    }
}

enum XPSystem {
    static func xp(for session: PracticeSession) -> Int {
        var xp = 10                     // за завершение

        xp += session.correctAnswers

        if session.accuracy >= 90 {
            xp += 5
        }

        if session.accuracy == 100 {
            xp += 10
        }

        xp += session.longestStreak / 5

        return xp
    }
}

extension XPSystem {
    static func total(sessions: [PracticeSession]) -> Int {
        sessions.reduce(0) {
            $0 + xp(for: $1)
        }
    }
}
