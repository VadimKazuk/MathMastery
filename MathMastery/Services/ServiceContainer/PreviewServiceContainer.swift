import Combine
import Foundation

final class PreviewServiceContainer: ServiceContainer {
    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        initServices()
    }

    private func initServices() {
        Deferred {
            Future<Bool, Never> { [weak self] promise in

                let _ = MemoryStorageService()

                self?.register(
                    type: AppSettingsManager.self,
                    as: .singleton
                ) {
                    AppSettingsManager()
                }

                promise(.success(true))
            }
        }
        .delay(for: .seconds(2), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.didFinishLoading()
        } receiveValue: { _ in
        }
        .store(in: &subscriptions)
    }
}
