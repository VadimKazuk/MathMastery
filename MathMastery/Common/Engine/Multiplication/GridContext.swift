import SwiftUI
import Combine

final class GridContext: ObservableObject {

    let selection: GridSelectionController
    let interaction: GridInteractionController

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.selection = GridSelectionController()
        self.interaction = GridInteractionController()

        selection.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
