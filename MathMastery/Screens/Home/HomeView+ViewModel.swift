import Combine
import SwiftUI

extension HomeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private var cancellables = Set<AnyCancellable>()

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer

        }

    }
}
