import SwiftUI
import Combine

class ServiceContainer: ObservableObject {
    @Published private(set) var isLoading = true

    enum ServiceType {
        case singleton
        case newInstance
        case automatic
    }

    private var servicesCache: [String: Any] = [:]
    private var servicesFactories: [String: () -> Any] = [:]

    func didFinishLoading() {
        isLoading = false
    }

    func register<Service>(
        type: Service.Type,
        as serviceType: ServiceType = .automatic,
        factory: @escaping () -> Service
    ) {
        let key = String(describing: type.self)

        servicesFactories[key] = factory

        if serviceType == .singleton {
            servicesCache[key] = factory()
        }
    }

    func resolve<Service>(
        dependencyType: ServiceType = .automatic,
        _ type: Service.Type
    ) -> Service {

        let key = String(describing: type.self)

        switch dependencyType {

        case .singleton:
            guard let service = servicesCache[key] as? Service else {
                fatalError("\(key) is not registered as singleton")
            }

            return service

        case .automatic:
            if let cachedService = servicesCache[key] as? Service {
                return cachedService
            }

            guard let service = servicesFactories[key]?() as? Service else {
                fatalError("\(key) don't have factory")
            }

            servicesCache[key] = service
            return service

        case .newInstance:
            guard let service = servicesFactories[key]?() as? Service else {
                fatalError("\(key) don't have factory")
            }

            return service
        }
    }
}
