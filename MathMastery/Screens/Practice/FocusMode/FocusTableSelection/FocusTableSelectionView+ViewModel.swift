import Combine
import SwiftUI

extension FocusTableSelectionView {
    @MainActor
    final class ViewModel: ObservableObject {

        private var cellStates: [FocusTableKey: TableCellState] = [:]

        private let engine = LearnEngine()
        private var state = LearnEngine.State(
            answersIndex: [:],
            gridState: []
        )

        private let swiftDB: SwiftDataService
        private let serviceContainer: ServiceContainer

        let allTablesMode: Int? = nil
        let tables: [FocusTableSelection] =
            Array(2...9).map { .table($0) }

        var overallStats: (accuracy: Int, level: OverallLevel)? {
            engine.overallStats(index: state.answersIndex)
        }
        
        var overallAccuracy: Int {
            overallStats?.accuracy ?? 0
        }

        var overallLevel: OverallLevel {
            overallStats?.level ?? .none
        }

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            load()
        }

        func resetStates() {
            cellStates.removeAll()
        }

        func load() {
            let sessions = swiftDB.fetchSessions()
            state = engine.makeState(from: sessions)
            resetStates()
        }

        func status(for table: Int) -> TableStatus {

            guard let stats = engine.tableStats(
                table: table,
                index: state.answersIndex
            ) else {

                if table == 2 {
                    return .progress(0, .none)
                }

                return .locked
            }

            if stats.accuracy == 100 {
                return .completed
            }

            return .progress(
                stats.accuracy,
                stats.level
            )
        }

        func state(for key: FocusTableKey) -> TableCellState {
            if let state = cellStates[key] {
                return state
            }

            let newState = TableCellState(id: key)
            cellStates[key] = newState
            return newState
        }

        func allState() -> TableCellState {
            state(for: .all)
        }

        func key(for item: FocusTableSelection) -> FocusTableKey {
            switch item {
            case .all:
                return .all
            case .table(let table):
                return .table(table)
            }
        }
    }
}

enum FocusTableKey: Hashable {
    case all
    case table(Int)
}

final class TableCellState: ObservableObject {

    let id: FocusTableKey

    @Published var animatedProgress: CGFloat = 0
    @Published var displayedPercentage: Int = 0
    @Published var isAnimationFinished: Bool = false
    @Published var hasAnimated: Bool = false

    init(id: FocusTableKey) {
        self.id = id
    }
}
