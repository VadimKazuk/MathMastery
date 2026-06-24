import SwiftUI
import Combine

extension ProgressViewModifier {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer

        @Published var isShowing: Bool = false

        private var cancellables = Set<AnyCancellable>()

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer

            let progressManager = serviceContainer.resolve(ProgressManager.self)
            progressManager.$isShowing
                .map{
                    $0
                }
                .assign(to: \.isShowing, on: self)
                .store(in: &cancellables)
        }

    }
}
