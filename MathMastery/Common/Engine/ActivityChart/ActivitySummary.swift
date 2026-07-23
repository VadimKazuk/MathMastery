import Foundation

struct ActivitySummary {

    let primary: ActivityStat
    let secondary: ActivityStat
    let tertiary: ActivityStat
}

struct ActivityStat {

    let title: String
    let value: Double
    let format: ActivityValueFormat

    var formattedValue: String {

        switch format {

        case .number:
            return "\(Int(value))"

        case .percent:
            return "\(Int(value))%"

        case .seconds:
            return String(
                format: "%.2fs",
                value
            )

        case .duration:
            let minutes = Int(value / 60)
            return "\(minutes)m"

        case .time:
            let minutes = Int(value / 60)
            return "\(minutes)m"

        case .xp:
            return "\(Int(value)) XP"
        }
    }
}

enum ActivityValueFormat {
    case number
    case percent
    case time
    case seconds
    case duration
    case xp
}
