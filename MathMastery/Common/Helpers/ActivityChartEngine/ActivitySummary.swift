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
    case xp
}
