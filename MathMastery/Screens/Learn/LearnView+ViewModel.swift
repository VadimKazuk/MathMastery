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
        @Published private(set) var gridState: [[CellViewState]] = []

        // MARK: - UI State
        @Published var mode: LearnMode = .explore
        @Published var selectedRow: Int?
        @Published var selectedColumn: Int?
        @Published private(set) var focusTable: Int?
        @Published private(set) var activeCell: SelectedCell?
        @Published var isFocusPanelVisible: Bool = true

        private var cellCenters: [SelectedCell: CGPoint] = [:]

        let numbers = Array(2...9)

        // MARK: - Init
        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)

            clearSelection()
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
        var equationTitle: String {
            guard
                let row = selectedRow,
                let col = selectedColumn
            else {
                return "Select a cell"
            }

            return "\(row) × \(col) = \(row * col)"
        }

        var equationAccuracyText: String {
            guard
                let row = selectedRow,
                let col = selectedColumn
            else {
                return "ACTIVE LEARNING"
            }

            let stats = stats(for: row, col)

            guard stats.total > 0 else {
                return "ACTIVE LEARNING"
            }

            let percent = Int((Double(stats.correct) / Double(stats.total) * 100).rounded())
            return "\(percent)% ACCURACY"
        }

        var currentEquationLevel: MistakeLevel {
            guard
                let row = selectedRow,
                let col = selectedColumn
            else {
                return .none
            }

            let s = stats(for: row, col)
            return CellEngine.level(correct: s.correct, total: s.total)
        }

        // MARK: - Load
        func loadSessions() {
            sessions = swiftDB.fetchSessions()
            rebuildState()
        }

        private func rebuildState() {
            state = engine.makeState(from: sessions)
            gridState = state.gridState
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
                clearSelection()
                isFocusPanelVisible = true
            }
        }

        func toggleFocusPanel() {
            isFocusPanelVisible.toggle()
        }

        // MARK: - Selection
        func setFocusTable(_ number: Int?) {
            focusTable = number

            guard let number else {
                clearSelection()
                return
            }

            selectedRow = number
            updateActiveCell()
        }

        func selectRow(_ number: Int) {
            selectedRow = number
            updateActiveCell()
        }

        func selectColumn(_ number: Int) {
            selectedColumn = number
            updateActiveCell()
        }

        func setColumn(_ number: Int?) {
            selectedColumn = number
            updateActiveCell()
        }

        func selectCell(rowIndex: Int, columnIndex: Int) {
            selectedRow = numbers[rowIndex]
            selectedColumn = numbers[columnIndex]
            focusTable = numbers[rowIndex]
            updateActiveCell()
        }

        func clearSelection() {
            selectedRow = nil
            selectedColumn = nil
            updateActiveCell()
        }

        private func updateActiveCell() {
            guard
                let row = selectedRow,
                let col = selectedColumn,
                let r = numbers.firstIndex(of: row),
                let c = numbers.firstIndex(of: col)
            else {
                activeCell = nil
                return
            }

            activeCell = SelectedCell(row: r, column: c)
        }

        private func isActiveCell(rowIndex: Int, columnIndex: Int) -> Bool {
            activeCell == SelectedCell(row: rowIndex, column: columnIndex)
        }

        // MARK: - Grid interaction
        private func value(row: Int, column: Int) -> Int {
            row * column
        }

        private func cellText(rowIndex: Int, columnIndex: Int) -> String {
            let row = numbers[rowIndex]
            let col = numbers[columnIndex]
            return "\(value(row: row, column: col))"
        }

        func updateCellCenter(_ center: CGPoint, rowIndex: Int, columnIndex: Int) {
            let cell = SelectedCell(row: rowIndex, column: columnIndex)
            cellCenters[cell] = center
        }

        func updateSelection(at point: CGPoint) {
            guard
                isFocusMode,
                let closest = closestCell(to: point)
            else { return }

            selectedRow = numbers[closest.row]
            selectedColumn = numbers[closest.column]

            focusTable = selectedRow
            updateActiveCell()
        }

        // MARK: - UI colors

        func cellTextColor(rowIndex: Int, columnIndex: Int) -> Color {
            guard isFocusMode else { return .primary }

            if isActiveCell(rowIndex: rowIndex, columnIndex: columnIndex) {
                return .primary
            }

            return activeCell == nil
                ? .primary
                : .gray.opacity(0.45)
        }

        func cellBorderColor(rowIndex: Int, columnIndex: Int) -> Color {
            guard
                isFocusMode,
                isCellOnMultiplierPath(rowIndex: rowIndex, columnIndex: columnIndex)
            else { return .clear }

            return .gray
        }

        func headerColor(rowIndex: Int?, columnIndex: Int?) -> Color {
            .gray.opacity(0.15)
        }

        func headerTextColor(rowIndex: Int?, columnIndex: Int?) -> Color {
            if let r = rowIndex,
               selectedRow == numbers[r] {
                return AppColor.commonAccentBlue
            }

            if let c = columnIndex,
               selectedColumn == numbers[c] {
                return AppColor.commonAccentBlue
            }

            return .gray
        }

        func headerBorderColor(rowIndex: Int?, columnIndex: Int?) -> Color {
            guard
                isFocusMode, isHeaderRelatedToActiveCell(rowIndex: rowIndex, columnIndex: columnIndex)
            else { return .clear }

            return .gray.opacity(0.35)
        }


        // MARK: - Helpers
        private func closestCell(to point: CGPoint) -> SelectedCell? {
            cellCenters.min {
                distanceSquared($0.value, point) < distanceSquared($1.value, point)
            }?.key
        }

        private func distanceSquared(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
            let dx = a.x - b.x
            let dy = a.y - b.y
            return dx * dx + dy * dy
        }

        private func isCellOnMultiplierPath(rowIndex: Int, columnIndex: Int) -> Bool {
            distanceToMultiplier(rowIndex: rowIndex, columnIndex: columnIndex) != Int.max
        }

        private func isHeaderRelatedToActiveCell(rowIndex: Int?, columnIndex: Int?) -> Bool {
            if let r = rowIndex,
               selectedRow == numbers[r] { return true }

            if let c = columnIndex,
               selectedColumn == numbers[c] { return true }

            return false
        }

        private func distanceToMultiplier(rowIndex: Int, columnIndex: Int) -> Int {
            guard let activeCell else { return Int.max }

            if rowIndex == activeCell.row && columnIndex < activeCell.column {
                return activeCell.column - columnIndex
            }

            if columnIndex == activeCell.column && rowIndex < activeCell.row {
                return activeCell.row - rowIndex
            }

            return Int.max
        }

        func moveSelection(offset: Int) {
            guard
                let row = selectedRow,
                let col = selectedColumn,
                let r = numbers.firstIndex(of: row),
                let c = numbers.firstIndex(of: col)
            else { return }

            var newR = r
            var newC = c + offset

            if newC < 0 {
                newC = numbers.count - 1
                newR -= 1
            } else if newC >= numbers.count {
                newC = 0
                newR += 1
            }

            guard numbers.indices.contains(newR) else { return }

            selectedRow = numbers[newR]
            selectedColumn = numbers[newC]

            updateActiveCell()
        }

    }
}
