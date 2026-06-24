import Combine
import SwiftUI

extension LearnView {
    final class ViewModel: ObservableObject {

        private let serviceContainer: ServiceContainer
        private var cancellables = Set<AnyCancellable>()

        let numbers = Array(1...9)

        @Published var selectedRow: Int?
        @Published var selectedColumn: Int?

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
        }

        var selectedText: String {
            guard let row = selectedRow,
                  let column = selectedColumn else {
                return "Select a cell"
            }

            return "\(row) × \(column) = \(row * column)"
        }

        func selectCell(row: Int, column: Int) {
            selectedRow = row
            selectedColumn = column
        }

        func isSelected(row: Int, column: Int) -> Bool {
            selectedRow == row && selectedColumn == column
        }

        func value(row: Int, column: Int) -> Int {
            row * column
        }
    }
}

struct SelectedCell {
    let row: Int
    let column: Int
}
