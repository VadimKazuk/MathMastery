import SwiftUI
import Combine

final class GridInteractionController: ObservableObject {

    private var cellCenters: [SelectedCell: CGPoint] = [:]

    let numbers = Array(2...9)

    func updateCellCenter(
        _ center: CGPoint,
        rowIndex: Int,
        columnIndex: Int
    ) {

        let cell = SelectedCell(
            row: rowIndex,
            column: columnIndex
        )

        cellCenters[cell] = center
    }

    func selectClosestCell(
        to point: CGPoint,
        selection: GridSelectionController
    ) {
        guard let closest = closestCell(to: point) else {
            return
        }
        selection.selectCell(
            rowIndex: closest.row,
            columnIndex: closest.column
        )
    }

    private func closestCell(
        to point: CGPoint
    ) -> SelectedCell? {

        cellCenters.min {
            distanceSquared($0.value, point)
            <
            distanceSquared($1.value, point)
        }?.key
    }

    private func distanceSquared(
        _ a: CGPoint,
        _ b: CGPoint
    ) -> CGFloat {

        let dx = a.x - b.x
        let dy = a.y - b.y

        return dx * dx + dy * dy
    }
}
