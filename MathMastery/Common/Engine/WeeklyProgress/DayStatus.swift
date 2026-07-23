import SwiftUI

enum DayStatus {
    case completed
    case missed
    case current
    case locked
    case reward
    case notStarted

    var textColor: Color {
        switch self {
        case .completed:
            return .green
        case .current:
            return AppColor.commonAccentBlue
        case .missed:
            return .red
        case .locked, .reward, .notStarted:
            return .secondary
        }
    }

    var pillBackground: Color {
        switch self {
        case .completed:
            return Color.green.opacity(0.06)
        case .current:
            return AppColor.colorTodayBlue
        case .missed:
            return Color.red.opacity(0.06)
        case .locked, .reward, .notStarted:
            return Color(.systemGray6).opacity(0.5)
        }
    }

    var pillBorder: Color {
        switch self {
        case .completed:
            return Color.green.opacity(0.15)
        case .current:
            return AppColor.commonAccentBlue.opacity(0.2)
        default:
            return Color(.systemGray4).opacity(0.3)
        }
    }

    var iconName: String {
        switch self {
        case .completed:
            return "ic_check_milestone"

        case .current:
            return "ic_star_milestone"

        case .missed:
            return "ic_xmark_milestone"

        case .locked:
            return "ic_lock_grey"

        case .reward:
            return "ic_trophy_grey"

        case .notStarted:
            return "ic_empty_milestone"
        }
    }

    var iconColor: Color {
        switch self {
        case .completed, .missed:
            return .white

        case .current:
            return AppColor.commonAccentBlue

        case .locked, .reward, .notStarted:
            return .secondary
        }
    }
}
