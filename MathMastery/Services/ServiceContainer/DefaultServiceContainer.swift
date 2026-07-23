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
                let storageService = UserDefaultsStorageService()

                self?.register(
                    type: AccountService.self,
                    as: .singleton
                ) {
                    AccountService(storageService: storageService)
                }

                self?.register(
                    type: AppSettingsManager.self,
                    as: .singleton
                ) {
                    AppSettingsManager()
                }

                self?.register(
                    type: KeychainService.self,
                    as: .singleton
                ) {
                    KeychainManager()
                }

                self?.register(
                    type: GameCenterServiceProtocol.self,
                    as: .singleton
                ) {
                    GameCenterService()
                }

                self?.register(
                    type: SwiftDataService.self,
                    as: .singleton
                ) {
                    SwiftDataManager()
                }

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
