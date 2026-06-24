import Combine
import Foundation

extension ContentContainerView {
    final class ViewModel: ObservableObject {
        @Published var contentViewType: ContentViewType = .home

        private var subscriptions = Set<AnyCancellable>()

        init(serviceContainer: ServiceContainer) {
            self.contentViewType = contentViewType

//            let messagingService = serviceContainer.resolve(MessagingService.self)
//            messagingService.$didReceivePush
//                .receive(on: DispatchQueue.main)
//                .sink { [weak self] push in
//                    guard let self,
//                          push != nil
//                    else {
//                        return
//                    }
//
//                    contentViewType = .home
//                }
//                .store(in: &subscriptions)
        }
    }
}
