import SwiftUI

enum LearnMode: String, CaseIterable, Identifiable {
    case explore
    case focus

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .focus: return "Focus"
        }
    }
}

struct SelectedCell: Hashable {
    let row: Int
    let column: Int
}

struct CellViewState: Hashable {
    let row: Int
    let column: Int

    let value: Int
    let level: MistakeLevel
}

extension CellViewState {
    static var empty: CellViewState {
        CellViewState(
            row: 0,
            column: 0,
            value: 0,
            level: .none
        )
    }
}

struct DailyActivity: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let isCurrent: Bool

    var weekdayIndex: Int {
        Calendar.current.component(.weekday, from: date)
    }

    var title: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
