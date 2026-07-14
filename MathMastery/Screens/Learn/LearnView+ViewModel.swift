import Combine
import SwiftUI

extension LearnView {
    final class ViewModel: ObservableObject {

        static let gridCoordinateSpaceName = "GRID"

        // MARK: - Dependencies
        private let swiftDB: SwiftDataService
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        // MARK: - Engine
        private let engine = LearnEngine()
        private var state: LearnEngine.State = .init(
            answersIndex: [:],
            gridState: []
        )

        // MARK: - Data
        @Published private(set) var sessions: [PracticeSession] = []
        @Published private(set) var grid = MultiplicationGridState(
            numbers: Array(2...9),
            cells: []
        )

        // MARK: - UI State
        @Published var mode: LearnMode = .explore

        @Published var isFocusPanelVisible: Bool = true

        // MARK: - Init
        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)

            loadSessions()
        }

        // MARK: - Derived
        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        var isFocusMode: Bool {
            mode == .focus
        }

        // MARK: - Equation UI
        func equationTitle(
            selection: GridSelectionController
        ) -> String {

            guard
                let row = selection.selectedRow,
                let col = selection.selectedColumn
            else {
                return "Select a cell"
            }

            return "\(row) × \(col) = \(row * col)"
        }

        func equationAccuracyText(
            selection: GridSelectionController
        ) -> String {

            guard
                let row = selection.selectedRow,
                let col = selection.selectedColumn
            else {
                return "ACTIVE LEARNING"
            }

            let stats = stats(for: row, col)

            guard stats.total > 0 else {
                return "ACTIVE LEARNING"
            }

            let percent = Int(
                (Double(stats.correct) / Double(stats.total) * 100).rounded()
            )

            return "\(percent)% ACCURACY"
        }

        func currentEquationLevel(
            selection: GridSelectionController
        ) -> MistakeLevel {

            guard
                let row = selection.selectedRow,
                let col = selection.selectedColumn
            else {
                return .none
            }

            let s = stats(for: row, col)

            return CellEngine.level(
                correct: s.correct,
                total: s.total
            )
        }

        // MARK: - Load
        func loadSessions() {
            sessions = swiftDB.fetchSessions()
            rebuildState()
        }

        private func rebuildState() {
            state = engine.makeState(from: sessions)
            grid = MultiplicationGridState(
                numbers: Array(2...9),
                cells: state.gridState
            )
        }

        // MARK: - Stats
        private func stats(for row: Int, _ col: Int, limit: Int = 5) -> (correct: Int, total: Int) {

            let key = SelectedCell(row: min(row, col),
                                   column: max(row, col))

            guard let answers = state.answersIndex[key] else {
                return (0, 0)
            }

            let slice = answers.prefix(limit)

            return (
                correct: slice.filter { $0.isCorrect }.count,
                total: slice.count
            )
        }

        // MARK: - Mode
        func selectMode(_ mode: LearnMode) {
            self.mode = mode

            if mode == .focus {
                isFocusPanelVisible = false
            }

            if mode == .explore {
                isFocusPanelVisible = true
            }
        }

        func toggleFocusPanel() {
            isFocusPanelVisible.toggle()
        }

    }
}
