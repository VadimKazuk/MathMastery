import Foundation

enum ActivityModeFilter: Identifiable, CaseIterable {

    case all
    case speed
    case survival
    case rush
    case focus


    var id: String {

        switch self {

        case .all:
            return "all"

        case .speed:
            return "speed"

        case .survival:
            return "survival"

        case .rush:
            return "rush"

        case .focus:
            return "focus"
        }
    }


    var title: String {

        switch self {

        case .all:
            return "All"

        case .focus:
            return "Focus"

        case .speed:
            return "Speed"

        case .survival:
            return "Survival"

        case .rush:
            return "Rush"
        }
    }


    var practiceMode: PracticeMode? {

        switch self {

        case .all:
            return nil

        case .focus:
            return .focus

        case .speed:
            return .speed

        case .survival:
            return .survival

        case .rush:
            return .rush
        }
    }
}
