import Combine
import Foundation
import Firebase

final class DefaultServiceContainer: ServiceContainer {
    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        initServices()
    }

    private func initServices() {
        Deferred {
            Future<Bool, Never> { [weak self] promise in
                let _ = UserDefaultsStorageService()

                self?.register(
                    type: KeychainService.self,
                    as: .singleton,
                    factory: KeychainManager()
                )

                self?.register(
                    type: ToastManager.self,
                    as: .singleton,
                    factory: ToastManager()
                )

                self?.register(
                    type: ProgressManager.self,
                    as: .singleton,
                    factory: ProgressManager()
                )

                self?.register(
                    type: SwiftDataService.self,
                    as: .singleton,
                    factory: SwiftDataManager()
                )

                promise(.success(true))
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.didFinishLoading()
        } receiveValue: { _ in
        }
        .store(in: &subscriptions)
    }
}
