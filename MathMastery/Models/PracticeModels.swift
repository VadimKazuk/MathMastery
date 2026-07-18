import SwiftUI

enum PracticeMode: String, CaseIterable, Identifiable, Hashable {
    case focus
    case speed
    case survival
    case rush

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .speed: return "Speed"
        case .focus: return "Focus"
        case .survival: return "Survival"
        case .rush: return "Rush"
        }
    }

    var trainingFocus: String {
        switch self {
        case .speed: return "Reaction"
        case .focus: return "Understanding"
        case .survival: return "Pressure"
        case .rush: return "Mastery"
        }
    }

    var subtitle: String {
        switch self {
        case .speed: return "60s sprint to solve as many as possible."
        case .focus: return "Practice a single multiplication table until you've mastered it."
        case .survival: return "No room for error. One mistake ends it."
        case .rush: return "Race against the timer while protecting your lives."
        }
    }

    var timeTag: String {
        switch self {
        case .focus: return "2–3 min"
        case .speed: return "1 min"
        case .survival: return "2–5 min"
        case .rush: return "1–2 min"
        }
    }

    var systemImage: String {
        switch self {
        case .focus:
            return "target"
        case .speed:
            return "bolt.fill"
        case .survival:
            return "heart.fill"
        case .rush:
            return "flame.fill"
        }
    }

    var icImage: String {
        switch self {
        case .focus:
            return "ic_target_blue"
        case .speed:
            return "ic_bolt_yellow"
        case .survival:
            return "ic_heart_red"
        case .rush:
            return "ic_flame_orange"
        }
    }

    var icImageSized: String {
        switch self {
        case .focus:
            return "ic_target_blue_sized"
        case .speed:
            return "ic_bolt_yellow_sized"
        case .survival:
            return "ic_heart_red_sized"
        case .rush:
            return "ic_flame_orange_sized"
        }
    }

    var skillIcon: String {
        switch self {
        case .focus: return "checkmark.seal.fill"
        case .speed: return "timer"
        case .survival: return "heart.fill"
        case .rush: return "chart.line.uptrend.xyaxis"
        }
    }

    var lottieImage: String {
        switch self {
        case .speed: return "bolt"
        case .focus: return "target"
        case .survival: return "heart"
        case .rush: return "fire"
        }
    }

    var accentColor: Color {
        switch self {
        case .focus:
            return Color.blue
        case .speed:
            return Color.yellow
        case .survival:
            return Color(red: 0.82, green: 0.15, blue: 0.17) // Red
        case .rush:
            return Color(red: 0.93, green: 0.39, blue: 0.05) // Orange
        }
    }

    var backgroundColor: Color {
        switch self {
        case .focus:
            return Color(red: 0.90, green: 0.95, blue: 1.00)
        case .speed:
            return Color(red: 1.00, green: 0.96, blue: 0.87)
        case .survival:
            return Color(red: 1.00, green: 0.92, blue: 0.92)
        case .rush:
            return Color(red: 1.00, green: 0.93, blue: 0.88)
        }
    }
}

enum PracticeRoute: Hashable {
    case speed
    case focusTableSelection
    case focusPractice(table: Int?)
    case survival
    case rush
    case result(PracticeSession)
}

enum FocusPracticeTarget: Hashable {
    case all
    case table(Int)
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

    var focusTable: Int?

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
        focusTable: Int? = nil,
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

        self.focusTable = focusTable

        self.duration = duration
        self.difficulty = difficulty

        self.correctAnswers = correctAnswers
        self.questionsCount = questionsCount
        self.longestStreak = longestStreak
        self.averageResponseTime = averageResponseTime
        self.answers = answers
    }

    var mode: PracticeMode {
        PracticeMode(rawValue: modeRaw) ?? .focus
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

    var baseColor: Color {
        switch self {
        case .none:
            return .clear
        case .perfect:
            return Color.green
        case .medium:
            return Color(red: 0.98, green: 0.78, blue: 0.20) // .yellow
        case .high:
            return Color(red: 0.95, green: 0.55, blue: 0.18) // .orange
        case .hard:
            return Color(red: 0.90, green: 0.25, blue: 0.25) // .red
        }
    }

    var baseColor2: Color {
        switch self {
        case .none:
            return .clear
        case .perfect:
            return Color.colorGreenPerfect
        case .medium:
            return Color.colorGreenGood
        case .high:
            return Color.colorOrangeHigh
        case .hard:
            return Color.colorOrangeHard
        }
    }

    var opacityСolor: Color {
        switch self {
        case .none:
            return baseColor.opacity(0.10)
        case .perfect:
            return baseColor.opacity(0.20)
        case .medium:
            return baseColor.opacity(0.22)
        case .high:
            return baseColor.opacity(0.24)
        case .hard:
            return baseColor.opacity(0.28)
        }
    }
}

enum OverallLevel {
    case none
    case weak
    case improving
    case good
    case excellent

    var color: Color {
        switch self {
        case .none:
            return Color.gray.opacity(0.2)

        case .weak:
            return Color.red.opacity(0.85)

        case .improving:
            return Color.orange.opacity(0.85)

        case .good:
            return Color.yellow.opacity(0.85)

        case .excellent:
            return Color.green.opacity(0.85)
        }
    }
}
