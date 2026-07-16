import Foundation

enum ActivityRange: String, CaseIterable, Identifiable {

    case last7Days
    case last30Days
    case last3Months
    case lastYear
    case allTime

    var id: String {
        rawValue
    }

    var title: String {
        switch self {

        case .last7Days:
            return "7 Days"

        case .last30Days:
            return "30 Days"

        case .last3Months:
            return "3 Months"

        case .lastYear:
            return "Year"

        case .allTime:
            return "All Time"
        }
    }

    var days: Int? {
        switch self {

        case .last7Days:
            return 7

        case .last30Days:
            return 30

        case .last3Months:
            return 90

        case .lastYear:
            return 365

        case .allTime:
            return nil
        }
    }

    func xAxisLabel(for date: Date) -> String {
        switch self {

        case .last7Days:
            return date.formatted(.dateTime.weekday(.narrow))

        case .last30Days:
            return date.formatted(.dateTime.day())

        case .last3Months:
            return date.formatted(.dateTime.day().month(.abbreviated))

        case .lastYear:
            return date.formatted(.dateTime.month(.abbreviated))

        case .allTime:
            return date.formatted(.dateTime.month(.abbreviated).year(.twoDigits))
        }
    }
}
