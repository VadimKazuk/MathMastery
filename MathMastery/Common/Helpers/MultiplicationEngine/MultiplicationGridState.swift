import Foundation

struct MultiplicationGridState {

    let numbers: [Int]
    let cells: [[CellViewState]]

    func cell(row: Int, column: Int) -> CellViewState {
        cells[row][column]
    }
}
