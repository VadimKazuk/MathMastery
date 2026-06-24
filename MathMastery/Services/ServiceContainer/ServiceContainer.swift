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
        factory: @autoclosure @escaping () -> Service
    ) {
        servicesFactories[String(describing: type.self)] = factory

        if serviceType == .singleton {
            servicesCache[String(describing: type.self)] = factory()
        }
    }

    func resolve<Service>(
        dependencyType: ServiceType = .automatic,
        _ type: Service.Type
    ) -> Service {
        let key = String(describing: type.self)
        switch dependencyType {
        case .singleton:
            if let cachedService = servicesCache[key] as? Service {
                return cachedService
            } else {
                fatalError("\(String(describing: type.self)) is not registered as singleton")
            }

        case .automatic:
            if let cachedService = servicesCache[key] as? Service {
                return cachedService
            }

            fallthrough

        case .newInstance:
            if let service = servicesFactories[key]?() as? Service {
                servicesCache[String(describing: type.self)] = service
                return service
            } else {
                fatalError("\(String(describing: type.self)) don't have factory for creation")
            }
        }
    }
}
