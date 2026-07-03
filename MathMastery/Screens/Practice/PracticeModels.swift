import SwiftUI

enum PracticeMode: String, CaseIterable, Identifiable, Hashable {
    case speed
    case classic
    case survival
    case boss

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .speed: return "Speed"
        case .classic: return "Classic"
        case .survival: return "Survival"
        case .boss: return "Boss"
        }
    }

    var trainingFocus: String {
        switch self {
        case .speed: return "Reaction"
        case .classic: return "Understanding"
        case .survival: return "Pressure"
        case .boss: return "Mastery"
        }
    }

    var subtitle: String {
        switch self {
        case .speed: return "60s sprint to solve as many as possible."
        case .classic: return "Standard pace. Focus on core mastery."
        case .survival: return "No room for error. One mistake ends it."
        case .boss: return "Conquer one table and expose weak facts."
        }
    }

    var systemImage: String {
        switch self {
        case .speed: return "timer"
        case .classic: return "book"
        case .survival: return "heart"
        case .boss: return "bolt"
        }
    }

    var lottieImage: String {
        switch self {
        case .speed: return "speed"
        case .classic: return "book"
        case .survival: return "heart"
        case .boss: return "man"
        }
    }

    var accentColor: Color {
        switch self {
        case .speed: return Color(red: 0.68, green: 0.25, blue: 0.16)
        case .classic: return AppColor.commonAccentBlue
        case .survival: return Color(red: 0.72, green: 0.10, blue: 0.14)
        case .boss: return Color(red: 0.18, green: 0.19, blue: 0.22)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .speed: return Color(red: 0.98, green: 0.92, blue: 0.90)
        case .classic: return Color(red: 0.88, green: 0.94, blue: 1.0)
        case .survival: return Color(red: 1.0, green: 0.94, blue: 0.94)
        case .boss: return Color(red: 0.90, green: 0.90, blue: 0.91)
        }
    }
}

extension PracticeMode {
    var raw: String {
        rawValue
    }
}

enum PracticeRoute: Hashable {
    case speed
    case classic
    case survival
    case boss
    case result(PracticeSession)
}

struct PracticeQuestion: Hashable {
    let left: Int
    let right: Int
    let questionMark: String = "?"

    var answer: Int {
        left * right
    }

    var title: String {
        "\(left) × \(right) = \(questionMark)"
    }

    var fact: String {
        "\(left) × \(right) = \(answer)"
    }
}

struct PracticeResultMetric: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let value: String
}

struct PracticeResult: Hashable {
    let mode: PracticeMode
    let title: String
    let summary: String
    let metrics: [PracticeResultMetric]
    let answers: [PracticeAnswer]
    let bossTable: Int?
}

struct AnswerOption: Identifiable, Hashable {
    let id = UUID()
    let value: Int
    var state: AnswerState = .normal
}

enum AnswerState {
    case normal
    case correct
    case wrong
}

@Model
final class PracticeAnswer {

    var id: UUID = UUID()

    var left: Int
    var right: Int

    var correctAnswer: Int
    var userAnswer: Int

    var modeRaw: String
    var date: Date = Date()

    var session: PracticeSession?

    init(
        left: Int,
        right: Int,
        correctAnswer: Int,
        userAnswer: Int,
        mode: PracticeMode
    ) {
        self.left = left
        self.right = right
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.modeRaw = mode.rawValue
    }

    var isCorrect: Bool {
        userAnswer == correctAnswer
    }

    var question: String {
        "\(left) × \(right)"
    }
}


import SwiftData

@Model
final class PracticeSession {

    var id: UUID
    var date: Date
    var modeRaw: String

    var duration: Int?
    var difficulty: String?

    var correctAnswers: Int
    var questionsCount: Int
    var longestStreak: Int
    var averageResponseTime: Double?

    @Relationship(deleteRule: .cascade)
    var answers: [PracticeAnswer]

    init(
        mode: PracticeMode,
        duration: Int? = nil,
        difficulty: String? = nil,
        correctAnswers: Int,
        questionsCount: Int,
        longestStreak: Int,
        averageResponseTime: Double? = nil,
        answers: [PracticeAnswer] = []
    ) {
        self.id = UUID()
        self.date = Date()
        self.modeRaw = mode.rawValue

        self.duration = duration
        self.difficulty = difficulty

        self.correctAnswers = correctAnswers
        self.questionsCount = questionsCount
        self.longestStreak = longestStreak
        self.averageResponseTime = averageResponseTime
        self.answers = answers
    }

    var mode: PracticeMode {
        PracticeMode(rawValue: modeRaw) ?? .classic
    }
    
    var accuracy: Int {
        guard questionsCount > 0 else { return 0 }

        let value = Int((Double(correctAnswers) / Double(questionsCount)) * 100)
        return value
    }

    var mistakesCount: Int {
        answers.reduce(0) { $0 + ($1.isCorrect ? 0 : 1) }
    }

    var hasMistakes: Bool {
        mistakesCount > 0
    }
}

enum MistakeLevel {
    case none
    case perfect
    case medium
    case high
    case hard

    var color: Color {
        switch self {
        case .none:
            return Color.gray.opacity(0.10)

        case .perfect:
            return Color.green.opacity(0.25)

        case .medium:
            return Color.yellow.opacity(0.25)

        case .high:
            return Color.orange.opacity(0.21)

        case .hard:
            return Color.red.opacity(0.32)
        }
    }

}

