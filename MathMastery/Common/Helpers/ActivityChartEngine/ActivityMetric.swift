import Foundation

enum ActivityMetric: String, CaseIterable, Identifiable {

    case solved
    case accuracy
    case responseTime
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

        case .responseTime:
            return "Response Time"

        case .sessions:
            return "Sessions"

        case .xp:
            return "XP"
        }
    }
}
