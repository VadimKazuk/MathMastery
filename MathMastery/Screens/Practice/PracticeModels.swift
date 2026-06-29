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

enum PracticeRoute: Hashable {
    case speed
    case classic
    case survival
    case boss
    case result(PracticeResult)
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
    let mistakes: [String]
    let bossTable: Int?
}
