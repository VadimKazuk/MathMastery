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
