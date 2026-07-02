import Combine
import SwiftUI

extension HomeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        private var cancellables = Set<AnyCancellable>()

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }
        
        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
        }

    }
}
