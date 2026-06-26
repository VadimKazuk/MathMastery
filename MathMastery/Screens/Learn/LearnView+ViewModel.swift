import Combine
import SwiftUI

extension LearnView {
    final class ViewModel: ObservableObject {

        static let gridCoordinateSpaceName = "GRID"

        private let serviceContainer: ServiceContainer
        private var cancellables = Set<AnyCancellable>()
        private var cellCenters: [SelectedCell: CGPoint] = [:]

        let numbers = Array(1...9)
        let focusTables = Array(1...9)

        @Published var mode: LearnMode = .explore
        @Published var selectedRow: Int?
        @Published var selectedColumn: Int?
        @Published private(set) var focusTable: Int = 1
        @Published private(set) var activeCell: SelectedCell?

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            setFocusTable(1)
        }

        var isFocusMode: Bool {
            mode == .focus
        }

        var selectedText: String {
            guard let row = selectedRow,
                  let column = selectedColumn else {
                return "Select a cell"
            }

            return "\(row) × \(column) = \(row * column)"
        }

        var equationTitle: String {
            guard let row = selectedRow,
                  let column = selectedColumn else {
                return "Select a cell"
            }

            return "\(row) × \(column) = \(row * column)"
        }

        var equationSubtitle: String {
            guard let row = selectedRow,
                  let column = selectedColumn else {
                return "Tap any cell to begin"
            }

            return "\(row) groups of \(column) makes \(row * column)"
        }

        func selectMode(_ mode: LearnMode) {
            self.mode = mode

            if mode == .explore {
                clearSelection()
            } else if selectedRow == nil {
                setFocusTable(1)
            }
        }

        func setFocusTable(_ number: Int) {
            guard let rowIndex = numbers.firstIndex(of: number),
                  let columnIndex = numbers.firstIndex(of: 1) else {
                return
            }

            focusTable = number
            activeCell = SelectedCell(row: rowIndex, column: columnIndex)
            selectCell(row: number, column: 1)
        }

        func selectCell(row: Int, column: Int) {
            selectedRow = row
            selectedColumn = column
        }

        func isSelected(row: Int, column: Int) -> Bool {
            selectedRow == row && selectedColumn == column
        }

        func isActiveCell(rowIndex: Int, columnIndex: Int) -> Bool {
            activeCell == SelectedCell(row: rowIndex, column: columnIndex)
        }

        func value(row: Int, column: Int) -> Int {
            row * column
        }

        func cellText(rowIndex: Int, columnIndex: Int) -> String {
            let row = numbers[rowIndex]
            let column = numbers[columnIndex]

            return "\(value(row: row, column: column))"
        }

        func updateCellCenter(_ center: CGPoint, rowIndex: Int, columnIndex: Int) {
            let cell = SelectedCell(row: rowIndex, column: columnIndex)
            cellCenters[cell] = center
        }

        func updateSelection(at point: CGPoint) {
            guard isFocusMode else { return }
            guard let closestCell = closestCell(to: point) else { return }

            activeCell = closestCell
            focusTable = numbers[closestCell.row]
            selectCell(
                row: numbers[closestCell.row],
                column: numbers[closestCell.column]
            )
        }

        func cellColor(rowIndex: Int, columnIndex: Int) -> Color {
            guard isFocusMode else {
                return Color.clear
            }

            if isActiveCell(rowIndex: rowIndex, columnIndex: columnIndex) {
                return AppColor.commonAccentBlue
            }

            return Color.clear
        }

        func cellTextColor(rowIndex: Int, columnIndex: Int) -> Color {
            guard isFocusMode else {
                return Color.primary
            }

            if isActiveCell(rowIndex: rowIndex, columnIndex: columnIndex) {
                return Color.white
            }

            guard activeCell != nil else {
                return Color.primary
            }

            if isCellOnMultiplierPath(rowIndex: rowIndex, columnIndex: columnIndex) {
                return Color.primary
            }

            return Color.gray.opacity(0.45)
        }

        func headerTextColor(rowIndex: Int?, columnIndex: Int?) -> Color {
            guard isFocusMode else {
                return AppColor.commonAccentBlue
            }

            guard activeCell != nil else {
                return AppColor.commonAccentBlue
            }

            if isHeaderRelatedToActiveCell(rowIndex: rowIndex, columnIndex: columnIndex) {
                return AppColor.commonAccentBlue
            }

            return Color.gray.opacity(0.45)
        }

        func cellBorderColor(rowIndex: Int, columnIndex: Int) -> Color {
            guard isFocusMode else {
                return Color.clear
            }

            guard isCellOnMultiplierPath(rowIndex: rowIndex, columnIndex: columnIndex) else {
                return Color.clear
            }

            return Color.gray.opacity(0.35)
        }

        func headerColor(rowIndex: Int?, columnIndex: Int?) -> Color {
            Color.gray.opacity(0.15)
        }

        func headerBorderColor(rowIndex: Int?, columnIndex: Int?) -> Color {
            guard isFocusMode else {
                return Color.clear
            }

            guard isHeaderRelatedToActiveCell(rowIndex: rowIndex, columnIndex: columnIndex) else {
                return Color.clear
            }

            return Color.gray.opacity(0.35)
        }

        func focusTableColor(_ number: Int) -> Color {
            if focusTable == number {
                return AppColor.commonAccentBlue
            }

            return Color.white
        }

        func focusTableTextColor(_ number: Int) -> Color {
            if focusTable == number {
                return Color.white
            }

            return Color.primary
        }

        func moveSelection(offset: Int) {
            guard let currentColumn = selectedColumn,
                  let focusRowIndex = numbers.firstIndex(of: focusTable),
                  let currentColumnIndex = numbers.firstIndex(of: currentColumn) else {
                setFocusTable(1)
                return
            }

            let nextColumnIndex = min(max(currentColumnIndex + offset, 0), numbers.count - 1)
            let nextColumn = numbers[nextColumnIndex]

            activeCell = SelectedCell(row: focusRowIndex, column: nextColumnIndex)
            selectCell(row: focusTable, column: nextColumn)
        }

        private func clearSelection() {
            selectedRow = nil
            selectedColumn = nil
            activeCell = nil
        }

        private func isCellOnMultiplierPath(rowIndex: Int, columnIndex: Int) -> Bool {
            distanceToMultiplier(rowIndex: rowIndex, columnIndex: columnIndex) != Int.max
        }

        private func isHeaderRelatedToActiveCell(rowIndex: Int?, columnIndex: Int?) -> Bool {
            guard let activeCell else {
                return false
            }

            if rowIndex == nil && columnIndex == nil {
                return false
            }

            return rowIndex == activeCell.row || columnIndex == activeCell.column
        }

        private func closestCell(to point: CGPoint) -> SelectedCell? {
            cellCenters.min { lhs, rhs in
                distanceSquared(lhs.value, point) < distanceSquared(rhs.value, point)
            }?.key
        }

        private func distanceSquared(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
            let dx = a.x - b.x
            let dy = a.y - b.y

            return dx * dx + dy * dy
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
    }
}

enum LearnMode: String, CaseIterable, Identifiable {
    case explore
    case focus

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .focus: return "Focus Mode"
        }
    }
}

struct SelectedCell: Hashable {
    let row: Int
    let column: Int
}
