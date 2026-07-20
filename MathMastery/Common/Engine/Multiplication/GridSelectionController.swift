import Foundation
import Combine

final class GridSelectionController: ObservableObject {
    
    @Published private(set) var selectedRow: Int?
    @Published private(set) var selectedColumn: Int?
    @Published private(set) var activeCell: SelectedCell?
    
    private let numbers = Array(2...9)
    
    func selectCell(rowIndex: Int, columnIndex: Int) {

        guard numbers.indices.contains(rowIndex),
              numbers.indices.contains(columnIndex)
        else {
            return
        }

        selectedRow = numbers[rowIndex]
        selectedColumn = numbers[columnIndex]

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
    
    func clear() {
        selectedRow = nil
        selectedColumn = nil
        activeCell = nil
    }
    
    private func updateActiveCell() {
        
        guard
            let row = selectedRow,
            let column = selectedColumn,
            let r = numbers.firstIndex(of: row),
            let c = numbers.firstIndex(of: column)
        else {
            activeCell = nil
            return
        }
        
        activeCell = SelectedCell(
            row: r,
            column: c
        )
    }
}
