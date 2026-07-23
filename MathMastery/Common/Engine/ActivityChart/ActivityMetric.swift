import Foundation

enum ActivityMetric: String, CaseIterable, Identifiable {

    case solved
    case accuracy
    case averageResponseTime
    case fastestResponseTime
    case answersPerMinute
    case duration
    case sessions
    case xp

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .solved:
            return "Solved"

        case .accuracy:
            return "Accuracy"

        case .averageResponseTime:
            return "Average Time"

        case .fastestResponseTime:
            return "Fastest Time"

        case .answersPerMinute:
            return "Answers / Min"

        case .duration:
            return "Practice Time"

        case .sessions:
            return "Sessions"

        case .xp:
            return "XP"
        }
    }
}
