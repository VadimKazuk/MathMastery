import SwiftUI

struct GridStyleProvider {

    let configuration: GridConfiguration
    let selection: GridSelectionController
    let grid: MultiplicationGridState

    func cellTextColor(rowIndex: Int, columnIndex: Int) -> Color {

        guard configuration.interactive else {
            return .primary
        }

        if selection.activeCell == SelectedCell(
            row: rowIndex,
            column: columnIndex
        ) {
            return .primary
        }

        return selection.activeCell == nil
        ? .primary
        : .gray.opacity(0.45)
    }


    func cellBorderColor(rowIndex: Int, columnIndex: Int) -> Color {

        guard configuration.interactive else {
            return .clear
        }

        guard isCellOnMultiplierPath(
            rowIndex: rowIndex,
            columnIndex: columnIndex
        )
        else {
            return .clear
        }

        return .gray
    }


    func headerColor(
        rowIndex: Int?,
        columnIndex: Int?
    ) -> Color {

        .clear
    }


    func headerTextColor(
        rowIndex: Int?,
        columnIndex: Int?
    ) -> Color {

        if let r = rowIndex,
           selection.selectedRow == grid.numbers[r] {

            return AppColor.commonAccentBlue
        }

        if let c = columnIndex,
           selection.selectedColumn == grid.numbers[c] {

            return AppColor.commonAccentBlue
        }

        return .gray
    }


    func headerBorderColor(
        rowIndex: Int?,
        columnIndex: Int?
    ) -> Color {

        guard configuration.interactive else {
            return .clear
        }

        guard isHeaderRelatedToActiveCell(
            rowIndex: rowIndex,
            columnIndex: columnIndex
        )
        else {
            return .clear
        }

        return .gray.opacity(0.35)
    }



    private func isHeaderRelatedToActiveCell(
        rowIndex: Int?,
        columnIndex: Int?
    ) -> Bool {

        if let r = rowIndex,
           selection.selectedRow == grid.numbers[r] {
            return true
        }

        if let c = columnIndex,
           selection.selectedColumn == grid.numbers[c] {
            return true
        }

        return false
    }


    private func isCellOnMultiplierPath(
        rowIndex: Int,
        columnIndex: Int
    ) -> Bool {

        guard let activeCell = selection.activeCell else {
            return false
        }

        if rowIndex == activeCell.row &&
            columnIndex < activeCell.column {

            return true
        }

        if columnIndex == activeCell.column &&
            rowIndex < activeCell.row {

            return true
        }

        return false
    }
}
