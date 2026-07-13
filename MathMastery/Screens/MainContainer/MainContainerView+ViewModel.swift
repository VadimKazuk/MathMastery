import Combine
import CoreLocation
import SwiftUI

extension MainContainerView {
    final class ViewModel: ObservableObject {
        @Published var contentViewType: ContentViewType = .splash
        @Published var showAlert: Bool = false

        private var subscriptions = Set<AnyCancellable>()
        private let serviceContainer: ServiceContainer

        @Published var splashState: SplashState = .loading

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer

            serviceContainer.$isLoading
                .filter { isLoading in
                    isLoading == false
                }
                .sink { [weak self] _ in
                    self?.initSubscriptions(serviceContainer: serviceContainer)
                }
                .store(in: &subscriptions)
        }

        private func initSubscriptions(serviceContainer: ServiceContainer) {
//            let accountService = serviceContainer.resolve(AccountService.self)
//            accountService.$isLoggedIn
//                .receive(on: DispatchQueue.main)
//                .sink { [weak self] isLoggedIn in
//                    guard let self else { return }
//
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        self.contentViewType = isLoggedIn ? .home : .initial
//                    }
//                }
//                .store(in: &subscriptions)

            //TEMP

            self.splashState = .intro

//            let messagingService = serviceContainer.resolve(MessagingService.self)
//            let restService = serviceContainer.resolve(RESTService.self)
//
//            let deviceId = messagingService.deviceId
//            if let deviceToken = messagingService.deviceToken,
//               let restToken = accountService.token
//            {
//                restService.configureDeviceForPushes(
//                    token: restToken,
//                    deviceId: deviceId,
//                    deviceToken: deviceToken
//                )
//                .sink { completion in
//                    switch completion {
//                    case .failure(let error):
//                        print("MessagingService: Push token not sent to backend with error: \(error)")
//                    default:
//                        break
//                    }
//                } receiveValue: { _ in
//                    print("MessagingService: Push token was sent to backend")
//                }
//                .store(in: &subscriptions)
//            }
//
//            Publishers.CombineLatest(messagingService.$deviceToken, accountService.$token)
//                .filter { deviceToken, restToken in
//                    return deviceToken != nil && restToken != nil
//                }
//                .flatMap { deviceToken, restToken in
//                    return restService.configureDeviceForPushes(
//                        token: restToken!,
//                        deviceId: deviceId,
//                        deviceToken: deviceToken!
//                    )
//                }
//                .sink { completion in
//                    switch completion {
//                    case .failure(let error):
//                        print("MessagingService: Push token not sent to backend with error: \(error)")
//                    default:
//                        break
//                    }
//                } receiveValue: { _ in
//                    print("MessagingService: Push token was sent to backend")
//                }
//                .store(in: &subscriptions)
        }
    }
}
